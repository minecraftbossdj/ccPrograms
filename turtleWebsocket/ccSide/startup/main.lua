local oldPull = os.pullEvent
os.pullEvent = os.pullEventRaw

if os.getComputerLabel() == nil then
    shell.run(".rom/rename.lua")
end

if _G.WS == nil then
    shell.run(".rom/websocket.lua")
end

shell.run(".rom/printOverwrite.lua")


local typeAPI = require("/APIs/typeAPI")

local config = require("/APIs/configAPI")

config.registerName("configs/hivemind-main")

config.addConfigOption("version","v2.0.0")

local hivemindVersion = config.getConfigOption("version")


local pluginNames = fs.list("/plugins/")
local plugins = {}


if #pluginNames ~= 0 then
    for i,v in pairs(pluginNames) do
        pluginName = v:gsub("%.lua", "")
        plugins[pluginName] = require("/plugins/"..pluginName)
    end
end

for _,v in pairs(plugins) do
    if type(v.init) == "function" then
        v.init()
    end
end

function inv()
    local tbl = {}
    tbl["type"] = "inventory"
    tbl["id"] = os.getComputerID()
    for i=1,16 do
        tbl["slot_"..tostring(i)] = {}
        tbl["slot_"..tostring(i)]["count"] = 0
        tbl["slot_"..tostring(i)]["name"] = "minecraft:air"
        if turtle.getItemDetail(i) ~= nil then
            tbl["slot_"..tostring(i)] = turtle.getItemDetail(i)
        end
    end
    tbl["selectedSlot"] = turtle.getSelectedSlot()
    _G.WS2.send(textutils.serialiseJSON(tbl))
end

function inspect()
    local tbl = {}
    tbl["type"] = "inspect"
    tbl["id"] = os.getComputerID()
    local bool, turtleInspect = turtle.inspect()
    local boolUp, turtleInspectUp = turtle.inspectUp()
    local boolDown, turtleInspectDown = turtle.inspectDown()
    if bool then
        tbl["forward"] = turtleInspect.name
    end
    if boolUp then
        tbl["up"] = turtleInspectUp.name
    end
    if boolDown then
        tbl["down"] = turtleInspectDown.name
    end
    
    _G.WS2.send(textutils.serialiseJSON(tbl))
end

function main()
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.yellow)
    term.write("Turtle Hivemind "..hivemindVersion)
    term.setCursorPos(1,2)
    term.setTextColor(colors.white)
    term.write(os.getComputerLabel().." | ID: "..os.getComputerID())
    term.setCursorPos(1,3)
    term.write("Computer Type: "..typeAPI.getComputerFamily().." "..typeAPI.getComputerType())
    term.setCursorPos(1,4)
    while true do
        fake = _G.WS.receive()
        local tbl = textutils.unserialiseJSON(fake)
        if tbl["type"] ~= nil then
            if tbl["type"] == "function" then
                if tonumber(tbl["id"]) == os.getComputerID() then
                    af=loadstring("return "..tbl["msg"])
                    setfenv(af,
                        {
                            peripheral=peripheral,
                            turtle=turtle,
                            android=android,
                            drone=drone,
                            link=link,
                            print=print,
                            pairs=pairs,
                            textutils=textutils,
                            os={
                                getComputerID=os.getComputerID,
                                getComputerLabel=os.getComputerLabel,
                                reboot=os.reboot
                            },
                            shell={
                                openTab=shell.openTab,
                                switchTab=shell.switchTab
                            },
                            exec=exec,
                            require=require
                        }
                    )
                    local result1,result2 = af()
                    local resultTbl = {}
                    resultTbl["type"] = "result"
                    resultTbl["resultOne"] = result1
                    resultTbl["resultTwo"] = result2
                    resultTbl["id"] = os.getComputerID()
                    result = nil

                    _G.WS2.send(textutils.serialiseJSON(resultTbl))
                end
            elseif tbl["type"] == "refreshInv" then
                if tonumber(tbl["id"]) == os.getComputerID() then
                    if turtle then
                        inv()
                    end
                end
            elseif tbl["type"] == "refreshInspect" then
                if tonumber(tbl["id"]) == os.getComputerID() then
                    if turtle then
                        inspect()
                    end
                end
            else
                for _,v in pairs(plugins) do
                    if tonumber(tbl["id"]) == os.getComputerID() then
                        if type(v.WSReceive) == "function" then
                            v.WSReceive(tbl)
                        end
                    end
                end
            end
        end
        sleep(0)
    end
end

function events()
    while true do
        event, arg1, arg2, arg3 = os.pullEvent()
        if event ~= "websocket_message" then
            local tbl = {}
            tbl["event"] = event
            tbl["arg1"] = arg1
            tbl["arg2"] = arg2
            tbl["arg3"] = arg3
            tbl["type"] = "event"
            tbl["id"] = os.getComputerID()
            _G.WS2.send(textutils.serialiseJSON(tbl))
            if event == "turtle_inventory" then
                inv()
            end
            if event == "turtle_response" then
                inv()
            end
            for _,v in pairs(plugins) do
                if type(v.Event) == "function" then
                    v.Event(event,arg1,arg2,arg3)
                end
            end
        end
        
        sleep(0)
    end
end

parallel.waitForAny(main,events)
--more code or somethin idfk i hate ni-

os.pullEvent = oldPull
