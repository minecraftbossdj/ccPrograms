term.clear()
term.setCursorPos(1,1)
term.write("Do you want to delete all data? Y/N")
term.setCursorPos(1,2)
term.write("(this will automatically delete startup.lua if you have it.)")
term.setCursorPos(1,3)
local answer = read()
if string.lower(answer) == "y" then
    shell.run("rm /*")
    term.clear()
    term.setCursorPos(1,1)
elseif string.lower(answer) == "n" then
    term.clear()
    term.setCursorPos(1,1)
    if fs.exists("startup.lua") or fs.exists("startup") then
        fs.delete("startup.lua")
    end
else
    os.reboot()
end

fs.makeDir(".rom")
fs.makeDir(".rom/API")
fs.makeDir("data")
fs.makeDir("startup")
fs.makeDir("plugins")
fs.makeDir("configs")

shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/turtleWebsocket/ccSide/startup/main.lua startup/main.lua")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/turtleWebsocket/ccSide/startup/test.lua startup/test.lua")

shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/turtleWebsocket/ccSide/.rom/printOverwrite.lua .rom/printOverwrite.lua")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/turtleWebsocket/ccSide/.rom/rename.lua .rom/rename.lua")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/turtleWebsocket/ccSide/.rom/websocket.lua .rom/websocket.lua")

--apis
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/turtleWebsocket/ccSide/.rom/API/newPrintAPI.lua .rom/API/newPrintAPI.lua")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/turtleWebsocket/ccSide/APIs/configAPI.lua APIs/configAPI.lua")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/turtleWebsocket/ccSide/APIs/typeAPI.lua APIs/typeAPI.lua")

shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/turtleWebsocket/ccSide/data/first_names.json data/first_names.json")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/turtleWebsocket/ccSide/data/last_names.json data/last_names.json")

if link then
    shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/turtleWebsocket/ccSide/plugins/openTabOnStartup.lua plugins/hiddenHivemind.lua")
end

if turtle then
    turtle.dig()
end
os.reboot()
