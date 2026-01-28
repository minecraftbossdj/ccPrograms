plugin = {}

function plugin.WSReceive(WsTbl)
    if WsTbl["type"] == "digOrAttack" then
        if turtle.inspect() then
            turtle.dig()
        else
            turtle.attack()
        end
    end

    if WsTbl["type"] == "getSelectedItemDetail" then
        local itemDetail = turtle.getItemDetail(turtle.getSelectedSlot())
        local item = {}
        item["type"] = "turtleHotbarItemDetail"
        item["count"] = itemDetail.count
        item["name"] = itemDetail.name
        item["id"] = os.getComputerID()
        _G.WS2.send(textutils.serialiseJSON(item))
    end
end

return plugin