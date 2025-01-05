local sha = require("/AweOS/APIs/sha2")
local oldPull = os.pullEvent
os.pullEvent = os.pullEventRaw

term.clear()
term.setTextColor(colors.yellow)
term.setCursorPos(1,1)
term.write("AweOS - Password Screen V1")

term.setCursorPos(1,2)
term.setTextColor(colors.white)
term.write("Username:")
term.setCursorPos(1,3)
term.write("Password:")

term.setCursorPos(11,2)
user = read()
term.setCursorPos(11,3)
pass = read("*")
if user == "" or pass == "" then
    textutils.slowPrint("Please put in a username and password!")
    sleep(1)
    shell.run("AweOS/PasswordSys")
elseif user == "/" or pass == "/" then
    textutils.slowPrint("Please put in a valid username and password!")
    sleep(1)
    shell.run("AweOS/PasswordSys")
else
    if fs.exists("AweOS/users/"..user) then
        file = fs.open("AweOS/users/"..user.."/pass.txt","r")
        userPass = file.readAll()
        file.close()
    end
    if fs.exists("AweOS/users/"..user) then
        if sha.hash256(pass) == userPass then
            term.clear()
            shell.run("AweOS/boot.lua")
        else
            textutils.slowPrint("incorrect password!")
            sleep(1)
            shell.run("AweOS/PasswordSys")
        end
    else
        textutils.slowPrint("incorrect username!")
        sleep(1)
        shell.run("AweOS/PasswordSys")
    end
end



os.pullEvent = oldPull
