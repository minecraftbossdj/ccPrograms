local Menyuu = require("APIs.Menyuu")
local util = require("APIs.util")
local thread = require("APIs.thread")
_G.thread = thread

_G.threads = {}

function addThread(func, name, terminal, cantBePaused)
    local th = thread.new(func)
    local threadTbl = {
        name = name,
        thread = th,
        paused = false,
        cantBePaused = cantBePaused or false
    }
    threadTbl.thread.terminal = terminal
    table.insert(_G.threads, threadTbl)
    return threadTbl
end

function threadExists(name)
    for _, v in pairs(_G.threads) do
        if v.name == name then
            return true
        end
    end
    return false
end

function getThreadByName(name)
    for _, v in pairs(_G.threads) do
        if v.name == name then
            return v
        end
    end
end

--todo: config for version
--todo: config for time
local timeoffset = -5

if periphemu then --craftos-pc
    timeoffset = 0
end

function goodbyeScreen()
    for _, v in pairs(Menyuu.menyuus) do
        Menyuu.setMenyuuVisible(v.name, false)
        v.object.redraw()
    end

    local shellTerm = Menyuu.getMenuByName("shell")
    Menyuu.setMenyuuVisible("shell", true)

    local bgX, bgY = term.getSize()
    Menyuu.repositionMenyuu("shell", 1, 1, bgX, bgY, true)

    local taskbar = Menyuu.getMenuByName("taskbar")
    Menyuu.setMenyuuVisible("taskbar", true)

    thread.pause(getThreadByName("AweOS_shell").thread, true)
    thread.pause(getThreadByName("AweOS_menuRenderer").thread, true)
    thread.pause(getThreadByName("AweOS_taskbarClockLoop").thread, true)
    
    local shutdownButton = Menyuu.getElementByName("shutdownButton")
    shutdownButton.pressed = false
    sleep(0.1)

    local rebootButton = Menyuu.getElementByName("rebootButton")
    rebootButton.pressed = false
    sleep(0.1)

    local menuButton = Menyuu.getElementByName("menuButton")
    menuButton.pressed = false
    sleep(0.1)
    
    util.redirectFunc(shellTerm.object, function()
        term.setBackgroundColor(colors.lightBlue)
        term.clear()
        
        paintutils.drawFilledBox(1,1, bgX, bgY/8, colors.blue)

        paintutils.drawFilledBox(1,bgY-util.round(bgY/8)+1, bgX, bgY, colors.blue)
        term.setBackgroundColor(colors.lightBlue)
        term.setCursorPos(util.round(bgX/2)-3, util.round(bgY/2))
        term.write("goodbye...")
        term.setCursorBlink(false)
    end)
    util.redirectFunc(taskbar.object, function()
        term.setBackgroundColor(colors.blue)
        term.clear()
    end)
    shellTerm.object.redraw()
end

function setTabThreadPaused(threadName, bool)
    if threadExists(threadName) and not getThreadByName(threadName).cantBePaused then
        --if not bool then getThreadByName(threadName).thread:resume("") end
        --thread.pause(getThreadByName(threadName).thread, bool)
        --coroutine.resume(getThreadByName(threadName).thread.coroutine)
        getThreadByName(threadName).thread:pause(bool)
        getThreadByName(threadName).paused = bool
    end
end

function triggerTab(tabName, pressed)
    local targetTab = Menyuu.getElementByName(tabName)
    targetTab.pressed = pressed
    targetTab.func(targetTab)
end

function updateButtonRenderer(button)
    button.object.clear()
    button.object.setCursorPos(1,1)
    button.object.write(button.text)
end

function renderBar(thread, row)
    local maxX, maxY = term.getSize()
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1, row)
    term.write(thread.name)
    if thread.thread.status == "dead" then
        paintutils.drawPixel(maxX, row, colors.red)
    elseif thread.paused then
        paintutils.drawPixel(maxX, row, colors.blue)
    else
        paintutils.drawPixel(maxX, row, colors.lime)
    end
    term.setBackgroundColor(colors.black)
    --term.setCursorPos(maxX-#thread.thread.status, row)
    --term.write(thread.thread.status)
end

function backgroundTaskManager()
    local tasky = Menyuu.getMenuByName("taskviewer")
    local old = term.redirect(tasky.object)
    
    bool, err = pcall(function()
        shell.run("AweOS/programs/taskManager.lua")
    end)

    while true do
        term.setBackgroundColor(colors.black)
        term.clear()

        local x, y = term.getSize()
        --[[
        term.setCursorPos(1,2)
        term.setBackgroundColor(colors.black)
        for i=1, x do
            term.write("-")
        end]]
        
        term.setCursorPos(1,1)
        term.setBackgroundColor(colors.black)
        term.write("Task Name ")

        term.setCursorPos(x,1)
        term.write("S")

        term.setBackgroundColor(colors.black)
        
        for i, v in pairs(_G.threads) do
            renderBar(v, i+2)
        end
        

        tasky.object.redraw()
        sleep()
    end
    term.redirect(old)
    file = fs.open("tasky_log.txt","w")
    file.write(err)
    file.close()
end

local tabs = {
    ["shell"] = {
        tabName = "shellTab",
        tabIcon = "S",
        threadName = "AweOS_shell",
        menyuuName = "shell",
        autoThread = true,
        menuFunction = function()
            _G.shellWindow = Menyuu.getMenuByName("shell").object
            local shellWin = Menyuu.getMenuByName("shell")
            local old = term.redirect(shellWin.object)
            shell.run("AweOS/programs/multishell.lua shellWindow")
            term.redirect(old)
        end,
        y = 2
    },
    ["lua"] = {
        tabName = "luaTab",
        tabIcon = "L",
        threadName = "AweOS_lua",
        menyuuName = "lua",
        autoThread = true,
        menuFunction = function() 
            local shellWin = Menyuu.getMenuByName("lua")
            local old = term.redirect(shellWin.object)
            shell.run("lua")
            term.redirect(old)
        end,
        y = 3
    },
    ["explorer"] = {
        tabName = "explorerTab",
        tabIcon = "F",
        threadName = "AweOS_explorer",
        menyuuName = "explorer",
        autoThread = true,
        menuFunction = function() 
            local explorer = Menyuu.getMenuByName("explorer")
            local old = term.redirect(explorer.object)
            shell.run("AweOS/programs/fileExplorer.lua")
            term.redirect(old)
        end,
        y = 4
    },
    ["taskviewer"] = {
        tabName = "taskyTab",
        tabIcon = "T",
        threadName = "AweOS_tasky",
        menyuuName = "taskviewer",
        autoThread = false,
        menuFunction = function() end,
        buttonFunction = {
            isPressed = function()
                if not threadExists("AweOS_tasky") then
                    local tasky = Menyuu.getMenuByName("taskviewer")
                    addThread(function() backgroundTaskManager() end, "AweOS_tasky", tasky.object, true)
                end
            end
        },
        cantBePaused = true,
        y = 5
    },
    ["peripheralviewer"] = {
        tabName = "periphViewerTab",
        tabIcon = "P",
        threadName = "AweOS_periphviewer",
        menyuuName = "peripheralviewer",
        autoThread = false,
        menuFunction = function() end,
        buttonFunction = {
            isPressed = function()
                if not threadExists("AweOS_periphviewer") then
                    local periphview = Menyuu.getMenuByName("peripheralviewer")
                    addThread(function() oldterm = term.redirect(periphview.object) shell.run("AweOS/programs/peripheral_viewer") term.redirect(oldterm) end, "AweOS_periphviewer", periphview.object, false)
                end
            end
        },
        y = 6
    },
    defaultTab = "shell"
}

function setOtherTabs(selfTab, bool)
    for _, tbl in pairs(tabs) do
        if type(tbl) == "table" then
            if tbl.tabName ~= selfTab then
                triggerTab(tbl.tabName, bool)
            end
        end
    end 
end

function setup()
    local maxX, maxY = term.getSize()
    local taskbar = Menyuu.addMenyuu("taskbar", 1, maxY, maxX-1, 1, colors.blue, true, true)
    local sidebar = Menyuu.addMenyuu("sidebar", maxX, 1, maxX, maxY, colors.gray, true, true)
    local tskbarX, tskbarY = taskbar.object.getSize()
    Menyuu.addMenyuu("taskbar_clock", tskbarX-4, 1, tskbarX, 1, colors.white, true, true, taskbar.object, taskbar)

    for name, tbl in pairs(tabs) do
        if type(tbl) == "table" then
            local menu = Menyuu.addMenyuu(tbl.menyuuName, 1, 1, maxX-1, maxY-1, colors.black, false, false)

            Menyuu.addButton(tbl.tabName,tbl.tabIcon,function(button)
                if button.pressed then
                    setOtherTabs(tbl.tabName, false)
                    button.object.setBackgroundColor(colors.black)
                    setTabThreadPaused(tbl.threadName, false)
                    if tbl.buttonFunction and tbl.buttonFunction.isPressed then
                        tbl.buttonFunction.isPressed(button)
                    end
                else
                    button.object.setBackgroundColor(colors.gray)
                    setTabThreadPaused(tbl.threadName, true)
                    if tbl.buttonFunction and tbl.buttonFunction.isNotPressed then
                        tbl.buttonFunction.isPressed(button)
                    end
                end
                updateButtonRenderer(button)
                local tabMenu = Menyuu.getMenuByName(tbl.menyuuName)
                tabMenu.object.setVisible(button.pressed or false)
                tabMenu.object.redraw()
                
                if tbl.buttonFunction and tbl.buttonFunction.isNotPressed then
                    tbl.buttonFunction.afterPressed(button)
                end
            end, 1, tbl.y, 1, 1, colors.gray, nil, true, true, sidebar.object, sidebar)
        end
    end

    --[[
    local backgroundShell = Menyuu.addMenyuu("shell", 1, 1, maxX-1, maxY-1, colors.black, false, false)

    local explorerMenu = Menyuu.addMenyuu("explorer", 1, 1, maxX-1, maxY-1, colors.black, false, false)
    local luaMenu = Menyuu.addMenyuu("lua", 1, 1, maxX-1, maxY-1, colors.black, false, false)
    local tasky = Menyuu.addMenyuu("taskManager", 1, 1, maxX-1, maxY-1, colors.black, false, false)]]

    local startMenu = Menyuu.addMenyuu("startMenu", 1, util.round((maxY-1)/2), util.round(maxX/6), util.round(((maxY)/2)), colors.white, false, true)
    local startMenuX, startMenuY = startMenu.object.getSize()
    util.redirectFunc(startMenu.object, function()
        paintutils.drawFilledBox(1,1,startMenuX, 1, colors.blue)
        term.setCursorPos(1,1)
        term.write("AweOS v3")
        paintutils.drawFilledBox(1,startMenuY,startMenuX, startMenuY, colors.blue)
    end)

    shell.setAlias("addThread", "AweOS/programs/addThread.lua")
    shell.setAlias("killThread", "AweOS/programs/deleteThread.lua")

    --[[
    Menyuu.addButton("shellTab","S",function(button)
        if button.pressed then
            triggerTab("explorerTab", false)
            triggerTab("luaTab", false)
            triggerTab("taskyTab", false)
            button.object.setBackgroundColor(colors.black)
            setTabThreadPaused("AweOS_shell", false)
        else
            button.object.setBackgroundColor(colors.gray)
            setTabThreadPaused("AweOS_shell", true)
        end
        updateButtonRenderer(button)
        local shellMenu = Menyuu.getMenuByName("shell")
        shellMenu.object.setVisible(button.pressed)
        shellMenu.object.redraw()
        
    end, 1, 2, 1, 1, colors.gray, nil, true, true, sidebar.object, sidebar)

    Menyuu.addButton("explorerTab","F",function(button)
        if button.pressed then
            triggerTab("shellTab", false)
            triggerTab("luaTab", false)
            triggerTab("taskyTab", false)
            button.object.setBackgroundColor(colors.black)
            setTabThreadPaused("AweOS_explorer", false)
        else
            button.object.setBackgroundColor(colors.gray)
            setTabThreadPaused("AweOS_explorer", true)
        end
        updateButtonRenderer(button)
        local explorerMenu = Menyuu.getMenuByName("explorer")
        explorerMenu.object.setVisible(button.pressed)
        explorerMenu.object.redraw()
        
    end, 1, 4, 1, 1, colors.gray, nil, true, true, sidebar.object, sidebar)

    Menyuu.addButton("luaTab","L",function(button)
        if button.pressed then
            triggerTab("shellTab", false)
            triggerTab("explorerTab", false)
            triggerTab("taskyTab", false)
            button.object.setBackgroundColor(colors.black)
            setTabThreadPaused("AweOS_lua", false)
        else
            button.object.setBackgroundColor(colors.gray)
            setTabThreadPaused("AweOS_lua", true)
        end
        updateButtonRenderer(button)
        local luaMenu = Menyuu.getMenuByName("lua")
        luaMenu.object.setVisible(button.pressed)
        luaMenu.object.redraw()
    end, 1, 3, 1, 1, colors.gray, nil, true, true, sidebar.object, sidebar)

    Menyuu.addButton("taskyTab","T",function(button)
        if button.pressed then
            triggerTab("shellTab", false)
            triggerTab("explorerTab", false)
            triggerTab("luaTab", false)
            if not threadExists("AweOS_tasky") then 
                local tasky = Menyuu.getMenuByName("taskManager")
                addThread(function() backgroundTaskManager() end, "AweOS_tasky", tasky.object)
            end
            button.object.setBackgroundColor(colors.black)
            setTabThreadPaused("AweOS_tasky", false)
        else
            button.object.setBackgroundColor(colors.gray)
            setTabThreadPaused("AweOS_tasky", true)
        end
        updateButtonRenderer(button)
        local taskyMenu = Menyuu.getMenuByName("taskManager")
        taskyMenu.object.setVisible(button.pressed)
        taskyMenu.object.redraw()
    end, 1, 5, 1, 1, colors.gray, nil, true, true, sidebar.object, sidebar)]]


    --taskbar/menu buttons
    Menyuu.addButton("shutdownButton","X",function(button)
        if button.pressed then
            goodbyeScreen()
            sleep(2)
            os.shutdown()
        end
    end, startMenuX, startMenuY, 1, 1, colors.red, nil, true, false, startMenu.object, startMenu)

    Menyuu.addButton("rebootButton","R",function(button)
        if button.pressed then
            goodbyeScreen()
            sleep(2)
            os.reboot()
        end
    end, startMenuX-1, startMenuY, 1, 1, colors.red, nil, true, false, startMenu.object, startMenu)


    Menyuu.addButton("menuButton", "",function(button)
    end, 1, 1, util.round(maxX/16), 1, colors.lime, nil, true, true, taskbar.object, taskbar)
end

setup()

function processClick()
    while true do
        local eventData = table.pack(os.pullEvent("mouse_click"))
        if eventData[2] == 1 then
            local desktop = Menyuu.getMenuByName("shell")
            local elem = Menyuu.handleButton(eventData[3], eventData[4])
            if elem and string.find(elem.name, "_close") then
                desktop.object.redraw()
                desktop.object.setCursorBlink(false)
                term.setCursorBlink(false)
            end
            Menyuu.handleInput(eventData[3], eventData[4])
        end
    end
end

function hourOffset(offset)
    local t = os.date("*t")
    t.hour = (t.hour + offset) % 24
    return t
end

function taskbarClockLoop()
    while true do
        local taskbarClock = Menyuu.getMenuByName("taskbar_clock")
        util.redirectFunc(taskbarClock.object, function ()
            local date = hourOffset(timeoffset)
            local hourString = tostring(date.hour)
            local minString = tostring(date.min)
            if #hourString == 1 then hourString = "0"..tostring(hourString) end
            if #minString == 1 then minString = "0"..tostring(minString) end
            local time = hourString..":"..minString

            term.setCursorPos(1,1)
            term.setTextColor(colors.black)
            term.write(time)
        end)
        sleep(15)
    end
end

function menuRenderer()
    while true do
        local menu = Menyuu.getMenuByName("startMenu")
        local shellMenu = Menyuu.getMenuByName("shell")
        local explorerMenu = Menyuu.getMenuByName("explorer")
        local luaMenu = Menyuu.getMenuByName("lua")
        local tasky = Menyuu.getMenuByName("taskManager")
        local startButton = Menyuu.getElementByName("menuButton")
        if startButton.pressed and not menu.object.isVisible() then
            Menyuu.setMenyuuVisible(menu.name, true)
            menu.object.redraw()
            if explorerMenu.object.isVisible() then
                setTabThreadPaused("AweOS_explorer", true)
            elseif shellMenu.object.isVisible() then
                setTabThreadPaused("AweOS_shell", true)
            elseif luaMenu.object.isVisible() then
                setTabThreadPaused("AweOS_lua", true)
            elseif tasky.object.isVisible() then
                setTabThreadPaused("AweOS_tasky", true)
            end
        elseif not startButton.pressed and menu.object.isVisible() then
            Menyuu.setMenyuuVisible(menu.name, false)
            menu.object.redraw()
            if explorerMenu.object.isVisible() then
                setTabThreadPaused("AweOS_explorer", false)
                explorerMenu.object.redraw()
            elseif shellMenu.object.isVisible() then
                setTabThreadPaused("AweOS_shell", false)
                shellMenu.object.redraw()
            elseif luaMenu.object.isVisible() then
                setTabThreadPaused("AweOS_lua", false)
                luaMenu.object.redraw()
            elseif tasky.object.isVisible() then
                setTabThreadPaused("AweOS_tasky", false)
                tasky.object.redraw()
            end
        end
        sleep()
    end
end

--[[
function backgroundShell()
    local shellWin = Menyuu.getMenuByName("shell")
    local old = term.redirect(shellWin.object)
    shell.run("AweOS/programs/multishell.lua")
    term.redirect(old) 
end

function backgroundExplorer()
    local explorer = Menyuu.getMenuByName("explorer")
    local old = term.redirect(explorer.object)
    shell.run("AweOS/programs/fileExplorer.lua")
    term.redirect(old)
end

function backgroundLua()
    local lua = Menyuu.getMenuByName("lua")
    local old = term.redirect(lua.object)
    shell.run("lua")
    term.redirect(old)
end]]



bool, err = pcall(function()
    addThread(menuRenderer, "AweOS_menuRenderer")
    addThread(taskbarClockLoop, "AweOS_taskbarClockLoop")
    addThread(processClick, "AweOS_processClick")

    for tabName, tab in pairs(tabs) do
        if type(tab) == "table" then
            local menu = Menyuu.getMenuByName(tab.menyuuName)

            if menu == nil then
                error("menu "..tab.menyuuName.." is nil!")
            end
            
            if tab.autoThread then
                addThread(tab.menuFunction, tab.threadName, menu.object)
            end
        end
    end
    --tabs
    --[[
    local explorer = Menyuu.getMenuByName("explorer")
    local shellBg = Menyuu.getMenuByName("shell")
    local luaBg = Menyuu.getMenuByName("lua")
    local tasky = Menyuu.getMenuByName("taskManager")

    addThread(backgroundShell, "AweOS_shell", shellBg.object)
    addThread(backgroundExplorer, "AweOS_explorer", explorer.object)
    addThread(backgroundLua, "AweOS_lua", luaBg.object)]]

    
    triggerTab(tabs[tabs.defaultTab].tabName, true)

    thread.run()
end)

file = fs.open("log.txt","w")
file.write(err)
file.close()
