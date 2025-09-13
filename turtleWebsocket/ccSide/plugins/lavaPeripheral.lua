plugin = {}

function plugin.init()
    lava = peripheral.find("lava_bucket")
end

function plugin.WSReceive(WsTbl)
    if WsTbl["type"] == "voidItem" then
        if lava then
            lava.void()
        end
    end
end

return plugin