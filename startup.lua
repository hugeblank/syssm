
if not syssm then
    -- Syssm by hugeblank
    -- SYStem Service Managment Tool
    -- Provides the ability to add background services to any OS for CC
    -- This file is meant to go at the very bottom of your startup file. Handles shell initialization.
    --[[
        To modify the path of the shell use the setting "syssm.boot_path". Default is CraftOS.
        To add a service, use syssm's `inject` function, providing a name for the service, and a function to run in the 
        background. This service will not have any forms of direct output to the terminal, meaning term, 
        paintutils and similar APIs are disabled (full blacklist on line 67). If you would like to log something, 
        please use the function `log`. If there's an error, use `error`.
    ]]

    if not fs.exists("raisin.lua") then -- Download/Install Raisin, the star of this show
        local Hhandle, Fhandle = http.get("https://raw.githubusercontent.com/hugeblank/raisin/master/raisin.lua"), fs.open("raisin.lua", "w")
        if not Hhandle then
            error("Could not download Raisin, try again later.", 2)
        end
        Fhandle.write(Hhandle.readAll())
        Fhandle.close() Hhandle.close()
    end
    local boot, raisin, syssm, services, expect = settings.get("syssm.boot_path"), require("raisin"), {}, {}, _G["~expect"]

    local function setBoot()
        if not boot then -- Set OS boot path if not done already
            settings.set("syssm.boot_path",
            (function() 
                if multishell then
                    boot = "/rom/programs/advanced/multishell.lua"
                else
                    boot = "/rom/programs/shell.lua"
                end
                return boot
            end)())
        end
    end

    -- Statuses: Running, Initializing, Terminated, Stopped, Paused
    syssm.inject = function(name, func) -- Inject a function into the background
        expect(1, name, "string")
        expect(2, func, "function")
        if services[name] then -- Prevent duplicate service names
            return false
        end
        -- Create variables
        local locallog, log, err = {}, {}, ""
        local thread, env

        -- Create local log instance
        do
            locallog.status = "Initializing"
            locallog.log = function(...)
                local out = "["..os.clock().."] "
                for _, val in pairs({...}) do
                    out = out..tostring(val).." "
                end
                log[#log+1] = out
            end
            locallog.error = function(msg)
                err = "["..os.clock().."] "..msg
                locallog.status = "Terminated"
                thread.remove()
            end
        end

        -- Generate function environment
        do
            local blacklist = { "io", "term", "paintutils", "window", "print", "write", "error", "printError", "_G"}
            env = {
                print = locallog.log,
                write = locallog.log,
                printError = locallog.log,
                error = locallog.error,
                _G = env
            }
            for k, v in pairs(_G) do
                local okay = true
                for i = 1, #blacklist do
                    if k == blacklist[i] then
                        okay = false
                        break
                    end
                end
                if okay then
                    env[k] = v
                end
            end
        end

        -- Create thread
        local tfunc = function() 
            locallog.log(name.." started")
            locallog.status = "Running"
            setfenv(func, env)()
            if locallog.status ~= "Terminated" then
                locallog.status = "Stopped"
                locallog.log(name.." stopped")
            end
        end
        thread = raisin.thread(tfunc)


        -- Create service data instance
        local service = {}
        do
            service.toggle = function(input)
                local out = thread.toggle(input)
                if not thread.state() then
                    locallog.status = "Paused"
                else
                    locallog.status = "Running"
                end
                return out
            end     
            
            service.status = function()
                return locallog.status
            end

            service.getLogs = function(snip)
                if not snip then
                    return table.concat(log, "\n")
                end
                expect(1, snip, "number")
                if snip > #log then
                    snip = #log
                elseif snip < 0 then
                    snip = 5
                end
                local out = {}
                for i = #log-snip, #log do
                    out[#out+1] = log[i]
                end
                return table.concat(log, "\n")
            end

            service.getError = function()
                return err
            end
            
        end
        services[name] = service
        return service
    end

    syssm.getServices = function()
        local function r(tbl)
            local out = {}
            for k, v in pairs(tbl) do
                if type(v) == "table" then
                    out[k] = r(v)
                else
                    out[k] = v
                end
            end
            return out
        end
        return r(services)
    end

    do -- Create OS thread: no service attachment
        local osproc
        repeat
            setBoot()
            osproc = loadfile(boot)
            if not osproc then
                boot = nil
                err("Could not load "..boot..", reverting to CraftOS")
            end
        until osproc
        raisin.thread(osproc)
    end

    -- Apply syssm globally.
    _G.syssm = syssm

    -- Add static thread that dynamically loads services
    raisin.thread(function()
        if not fs.exists("init.d") then
            fs.makeDir("init.d")
        end
        local function r(dir)
            local list = fs.list(dir)
            for i = 1, #list do
                local absolute = fs.combine(dir, list[i])
                if fs.isDir(absolute) then
                    r(absolute)
                else
                    local suc, err = loadfile(absolute)
                    if not suc then
                        printError("Failed to load service: "..err)
                    else
                        local name = list[i]:sub(1, list[i]:find("[.]")-1)
                        syssm.inject(name, suc)
                    end
                end
            end
        end
        r("init.d")
    end)

    local suc, error = pcall(function() raisin.manager.run(os.pullEventRaw, 2) end)

    if not suc then
        printError(err)
        print("Press any key to reboot")
        os.pullEvent("key")
        os.reboot()
    else
        term.setTextColor(colors.yellow)
        print("Goodbye!")
        term.setTextColor(colors.white)
        sleep(1)
        os.shutdown()
    end
end