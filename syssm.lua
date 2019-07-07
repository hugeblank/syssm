-- Syssm shell application - by hugeblank
if not syssm then
    printError("Syssm not enabled")
    print("What is this some kind of sick joke?")
    return "idiots..."
end
local args = {...}
local usage = {"syssm status <name>", "syssm save <name> <logs|error>", "syssm pause <name>", "syssm resume <name>"}

local action = table.remove(args, 1)
local name = table.remove(args, 1)
local function inerror(num)
    if not name then
        print(usage[num])
        return false
    elseif not syssm.getServices()[name] then
        printError("Service "..name.." not found")
        return false
    end
    return true
end

if action == "status" then
    if inerror(1, name) then
        local status = syssm.getServices()[name].status()
        write("Service: "..name.." | Status: ")
        if status == "Running" then
            term.setTextColor(colors.lime)
        elseif status == "Paused" then
            term.setTextColor(colors.yellow)
        elseif status == "Terminated" then
            term.setTextColor(colors.red)
        elseif status == "Stopped" then
            term.setTextColor(colors.gray)
        elseif status == "Initializing" then
            term.setTextColor(colors.lightGray)
        end
        print(status)
        term.setTextColor(colors.white)
        if status ~= "Terminated" then
            print("Latest data:")
            print(syssm.getServices()[name].getLogs(5))
        else
            print("Error:")
            print(syssm.getServices()[name].getError())
        end
    else
        return
    end
elseif action == "save" then
    if inerror(2, name) then
        local info = table.remove(args, 1)
        if not info or info ~= "logs" or info ~= "error" then
            print(usage[2])
            return
        else
            local file = fs.open(name..".log", "w")
            if not file then
                printError("Could not write to disk")
                return
            end
            file.write(syssm.getServices()[name]["get"..info:sub(1,1):upper()..info:sub(2, -1)])
            file.close()
            print(info:sub(1,1):upper()..info:sub(2, -1).." saved to "..name..".log")
        end
    else
        return
    end
elseif action == "pause" then
    if inerror(3, name) then
        syssm.getServices()[name].toggle(false)
        write("Service "..name.." ")
        term.setTextColor(colors.yellow)
        print('paused')
    else
        return
    end
elseif action == "resume" then
    if inerror(4, name) then
        syssm.getServices()[name].toggle(true)
        write("Service "..name.." ")
        term.setTextColor(colors.lime)
        print('resumed')
    else
        return
    end
else
    print(table.concat(usage, "\n"))
end