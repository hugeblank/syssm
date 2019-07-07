print([[Hey there! hugeblank here. Syssm is run on startup, thereby needing to be appended to your `startup.lua` 
file. You are welcome to do this manually, but this instaler is also provided to make it easier on you. I do however
want your express permission to do so: Is it okay for Syssm to be appended to the bottom of your startup file? [y/n] ]])
local _, key = os.pullEvent("char")
if key:lower() == 'y' then
    print("Splendid! Downloading Syssm & Command Line Utility")
    local syssm, yfile = http.get("https://raw.githubusercontent.com/hugeblank/syssm/master/syssm.lua"), fs.open("syssm.lua", "w")
    local startup, sfile = http.get("https://raw.githubusercontent.com/hugeblank/syssm/master/startup.lua"), fs.open("startup.lua", "a")
    print("Installing...")
    yfile.write(syssm.readAll()) sfile.write(startup.readAll())
    yfile.close() sfile.close() syssm.close() startup.close()
    print("And done! Reboot your computer to start syssm (assuming startup doesn't run another program immediately.)")
else
    print("Understood. Have a good day")
end