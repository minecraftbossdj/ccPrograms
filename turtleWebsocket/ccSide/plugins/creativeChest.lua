plugin = {}

function plugin.init()
    creativeChest = peripheral.find("creative_chest")
    if creativeChest ~= nil then
        isCreativeChest = true
    else
        isCreativeChest = false
    end
end

function plugin.WSReceive(WsTbl)
    if WsTbl["type"] == "generateItem" then
        if isCreativeChest then
            creativeChest.generate(WsTbl["itemId"],tonumber(WsTbl["amount"]))
        end
    end
end

return plugin