plugin = {}

function plugin.init()
    bow = peripheral.find("bow")
    if type(bow) ~= "nil" then
        isBow = true
    else
        isBow = false
    end
end

function plugin.WSReceive(WsTbl)
    if WsTbl["type"] == "shootBow" then
        if isBow then
            bow.shoot(tonumber(WsTbl["strength"]))
        end
    end
end

return plugin