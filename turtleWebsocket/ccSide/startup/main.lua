local oldPull = os.pullEvent
os.pullEvent = os.pullEventRaw

if os.getComputerLabel() == nil then
    shell.run(".rom/rename.lua")
end

if _G.WS == nil then
    shell.run(".rom/websocket.lua")
end

shell.run(".rom/printOverwrite.lua")

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
    term.write(os.getComputerLabel().." | ID: "..os.getComputerID())
    while true do
        fake = _G.WS.receive()
        tbl = textutils.unserialiseJSON(fake)
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
                            }
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
            end
        end
        sleep(0)
    end
end

function events()
    while true do
        event, arg1, arg2, arg3 = os.pullEvent()
        if event ~= "websocket_message" then
            tbl = {}
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
        end
        
        sleep(0)
    end
end

parallel.waitForAny(main,events)
--more code or somethin idfk i hate ni-

os.pullEvent = oldPull
