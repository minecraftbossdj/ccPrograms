plugin = {}

function plugin.WSReceive(WsTbl)
    if link_turtle then
        if WsTbl["type"] == "getDirection" then
            local returnTbl = {}
            local direction = link_turtle.getDirection()

            returnTbl["type"] = "direction"
            returnTbl["id"] = os.getComputerID()
            returnTbl["direction"] = direction

            _G.WS2.send(textutils.serialiseJSON(returnTbl))
        end
        if WsTbl["type"] == "raycast" then
            local returnTbl = {}
            local rayData
            if WsTbl["direction"] == "forward" then
                rayData = link_turtle.raycast(5)
            elseif WsTbl["direction"] == "up" then
                rayData = link_turtle.raycastUp(5)
            elseif WsTbl["direction"] == "down" then
                rayData = link_turtle.raycastDown(5)
            end

            returnTbl["type"] = "raycastData"
            returnTbl["id"] = os.getComputerID()
            returnTbl["rayData"] = rayData
            _G.WS2.send(textutils.serialiseJSON(returnTbl))
        end
    end
end

function plugin.Event(event,arg1,arg2,arg3)

end

return plugin