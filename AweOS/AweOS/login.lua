local Menyuu = require("APIs.Menyuu")
local util = require("APIs.util")
local sha = require("APIs.sha2")

--todo: config for version

local loggedIn = false

function setup()
    local maxX, maxY = term.getSize()
    local background = Menyuu.addMenyuu("background", 1, 1, maxX, maxY, colors.cyan, true, true)
    local login = Menyuu.addMenyuu("login", (maxX/4), util.round(maxY/4), util.round(maxX/4)*2, util.round(maxY/4)*2, colors.lightBlue, true, true)
    local loginX, loginY = login.object.getSize()
    Menyuu.addInput("username", util.round(loginX/4), util.round(loginY/4), util.round(loginX/4)*2, 1, colors.white, colors.black, true, login.object, login)
    Menyuu.addInput("password", util.round(loginX/4), util.round(loginY/4)+2, util.round(loginX/4)*2, 1, colors.white, colors.black, true, login.object, login)

    Menyuu.addButton("login", "OK", function()
        local username = Menyuu.getElementByName("username")
        local password = Menyuu.getElementByName("password")

        if fs.exists("AweOS/users/"..username.text) then
            file = fs.open("AweOS/users/"..username.text.."/password.txt","r")
            if file == nil then error("user "..username.text.."'s password doesn't exist?") end
            local encryptedPassword = file.readAll()
            file.close()

            if sha.hash256(password.text) == encryptedPassword then
                term.clear()
                term.setCursorPos(1,1)
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                loggedIn = true
            end
        end
    end, util.round(loginX/4), util.round(loginY/4)+4, util.round(loginX/8), 1, colors.white, colors.black, true, false, login.object, login)

    util.redirectFunc(login.object, function()
        paintutils.drawLine(1, 1, loginX, 1, colors.blue)
        term.setCursorPos(1,1)
        term.setTextColor(colors.white)
        term.write("Log In")
    end)
end

function changeToWelcome()
    local background = Menyuu.getMenuByName("background")

    background.bgColor = colors.lightBlue
    background.object.setBackgroundColor(colors.lightBlue)
    background.object.clear()

    local bgX, bgY = background.object.getSize()
    util.redirectFunc(background.object, function()
        paintutils.drawFilledBox(1,1, bgX, bgY/8, colors.blue)

        paintutils.drawFilledBox(1,bgY-util.round(bgY/8), bgX, bgY, colors.blue)
        term.setBackgroundColor(colors.lightBlue)
        term.setCursorPos(util.round(bgX/2)-3, util.round(bgY/2))
        term.write("Welcome...")
    end)
end

setup()

function processClick()
    while true do
        local eventData = table.pack(os.pullEvent("mouse_click"))
        if eventData[2] == 1 and not loggedIn then
            Menyuu.handleButton(eventData[3], eventData[4])
            Menyuu.handleInput(eventData[3], eventData[4])
        end
        if loggedIn then
            changeToWelcome()
            sleep(2)
            shell.run("AweOS/boot.lua")
            os.reboot()
        end
    end
end


processClick()
