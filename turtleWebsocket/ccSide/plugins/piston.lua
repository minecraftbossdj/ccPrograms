plugin = {}

function plugin.init()
    piston = peripheral.find("piston")
    if piston then
        piston.setSilent(true)
    end
end

function plugin.WSReceive(WsTbl)
    if WsTbl["type"] == "pistonPush" then
        if piston then
            piston.push()
        end
    end
end

return plugin