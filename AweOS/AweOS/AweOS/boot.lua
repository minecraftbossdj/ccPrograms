local oldPull = os.pullEvent
os.pullEvent = os.pullEventRaw

term.clear()
term.setCursorPos(1,1)
term.write("Boot into AweOS? (Y/N)")

term.setCursorPos(1,2)
ans = read()

if ans == "N" or ans == "n" then

    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.yellow)
    term.write("AweOS - Terminal")
    term.setCursorPos(1,2)
    term.setTextColor(colors.white)
    shell.run("AweOS/randomQuote.lua")
    term.setCursorPos(1,3)
    
elseif ans == "Y" or ans == "y" then

    shell.run("AweOS/AweOS.lua")
    
else
    
    term.setCursorPos(1,3)
    term.write("not a answer!")
    shell.run("startup.lua")
end

os.pullEvent = oldPull
