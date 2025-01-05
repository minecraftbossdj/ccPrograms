rnd = require("APIs/roundAPI")
button = require("APIs/buttonAPI")
winAPI = require("APIs/windowAPI")

function setup()
    x,y = term.getSize()

    bg = window.create(term.current(),1,1,x,y-1)
    bgX,bgY = bg.getSize()
    oldterm = term.redirect(bg)
    paintutils.drawFilledBox(1,1,bgX,bgY,colors.cyan)
    term.redirect(oldterm)

    paintutils.drawLine(1,y,x,y,colors.blue)
    paintutils.drawPixel(1,y,colors.green)
    term.setCursorPos(1,y)
    term.write("M")

    paintutils.drawPixel(x-5,y,colors.gray)
    term.setCursorPos(x-5,y)
    term.write("T")
    paintutils.drawPixel(x-6,y,colors.gray)
    term.setCursorPos(x-6,y)
    term.write("L")
    term.setCursorPos(1,1)
    
    paintutils.drawLine(x-4,y,x,y,colors.lightBlue)

    if math.mod(y,2) == 0 then
        num = 0
    else
        num = 1
    end

    menu = false

    halfY = math.floor(y/2)

    menuWin = window.create(term.current(),1, halfY,1/5*x,halfY+num,false)
    menuWinX,menuWinY = menuWin.getSize()
    oldterm = term.redirect(menuWin)
    paintutils.drawFilledBox(1,1,menuWinX,menuWinY,colors.white)
    paintutils.drawLine(1,1,menuWinX,1,colors.blue)
    paintutils.drawLine(1,menuWinY,menuWinX,menuWinY,colors.blue)
    paintutils.drawPixel(menuWinX,menuWinY,colors.red)
    term.setCursorPos(menuWinX,menuWinY)
    term.write("S")
    paintutils.drawPixel(menuWinX-1,menuWinY,colors.gray)
    term.setCursorPos(menuWinX-1,menuWinY)
    term.write("R")
    term.setCursorPos(1,1)
    term.setBackgroundColor(colors.blue)
    term.write("AweOS v2.0")
    term.redirect(oldterm)

    shell.setAlias("return","AweOS/AweOS.lua")

    local windowMaxX,windowMaxY = x-6,y-6

    winAPI.newWindow(term.native(),1,1,windowMaxX,windowMaxY,true,"mainWin")

end

function mouseclk()
    while true do
        event, _, eX, eY = os.pullEvent("mouse_click")
        --os.queueEvent("test",rnd.round(menuWinX),rnd.round(menuWinY))
        --os.queueEvent("m1",eX,eY)
        if eX == 1 and eY == y and menu then
            menu = false
            menuWin.setVisible(false)
            bg.redraw()
        elseif eX == 1 and eY == y and menu == false then
            menu = true
            menuWin.setVisible(true)
        elseif eX == rnd.round(menuWinX) and eY == y-1 and menu then
            os.shutdown()
        elseif eX == rnd.round(menuWinX)-1 and eY == y-1 and menu then
            os.reboot()
        elseif eX == x-5 and eY == y then
            paintutils.drawFilledBox(1,1,x,y,colors.black)
            term.clear()
            term.setCursorPos(1,1)
            term.setTextColour(colors.yellow)
            term.write("AweOS - Terminal")
            term.setCursorPos(1,2)
            term.setTextColour(colors.white)
            shell.run("AweOS/randomQuote.lua")
            term.setTextColour(colors.red)
            term.setCursorPos(1,3)
            term.write("Welcome to the terminal!")
            term.setCursorPos(1,4)
            term.write("type 'return' to return to AweOS")
            term.setCursorPos(1,5)
            term.setTextColour(colors.white)
            return
        elseif eX == x-6 and eY == y then
            paintutils.drawFilledBox(1,1,x,y,colors.black)
            term.clear()
            term.setCursorPos(1,1)
            term.setTextColour(colors.yellow)
            term.write("AweOS - Lua")
            term.setCursorPos(1,2)
            term.setTextColour(colors.white)
            shell.run("AweOS/randomQuote.lua")
            term.setTextColour(colors.red)
            shell.run("lua")
            term.setCursorPos(1,3)
            term.setTextColour(colors.white)
            return
        end

        sleep(0)
    end
end

function monT()
    while true do
        event, mon, eX, eY = os.pullEvent("monitor_touch")
        if eX == 1 and eY == y and menu then
            menu = false
            menuWin.setVisible(false)
            bg.redraw()
        elseif eX == 1 and eY == y and menu == false then
            menu = true
            menuWin.setVisible(true)
        elseif eX == rnd.round(menuWinX) and eY == y-1 and menu then
            os.shutdown()
        elseif eX == x and eY == y then
            paintutils.drawFilledBox(1,1,x,y,colors.black)
            term.clear()
            term.setCursorPos(1,1)
            term.setTextColour(colors.yellow)
            term.write("AweOS - Terminal")
            term.setCursorPos(1,2)
            term.setTextColour(colors.white)
            shell.run("AweOS/randomQuote.lua")
            term.setTextColour(colors.red)
            term.setCursorPos(1,3)
            term.write("Welcome to the terminal!")
            term.setCursorPos(1,4)
            term.write("type 'return' to return to AweOS")
            term.setCursorPos(1,5)
            term.setTextColour(colors.white)
            return
        elseif eX == x-1 and eY == y then
            paintutils.drawFilledBox(1,1,x,y,colors.black)
            term.clear()
            term.setCursorPos(1,1)
            term.setTextColour(colors.yellow)
            term.write("AweOS - Lua")
            term.setCursorPos(1,2)
            term.setTextColour(colors.white)
            shell.run("AweOS/randomQuote.lua")
            term.setTextColour(colors.red)
            shell.run("lua")
            term.setCursorPos(1,3)
            term.setTextColour(colors.white)
            return
        end
        os.queueEvent("test",menuWinX,menuWinY)
        sleep(0)
    end
end

function drawBackground()
    bg.redraw()
end

local currentButton = ""
local currentTerminal = nil

local function dragManager()
    termX,termY = term.getSize()
    while true do
        local event, button, x, y = os.pullEvent("mouse_drag")
        
        local newX = x - winAPI.getWindow("mainWin").dragOffsetX
        local newY = y - winAPI.getWindow("mainWin").dragOffsetY
        winAPI.moveWindow("mainWin", newX-(termX/2)+2, newY)
        drawBackground()
        winAPI.drawWindows(false,"mainWin",currentButton)
        sleep(0)
    end
end

function winProgram()
    win = winAPI.getWindows()["mainWin"]
    while true do
        event,key = os.pullEvent("key")
        if key == keys.i then
            term.redirect(win.terminal)
            shell.run("shell")
        end
    end
end

function time()
    while true do
        term.setCursorPos(x-4,y)
        term.write(string.sub(os.date(),12))
        sleep(0)
    end
end

setup()
parallel.waitForAll(winProgram,mouseclk,time,dragManager)
