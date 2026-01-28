plugin = {}

function plugin.WSReceive(WsTbl)
    if WsTbl["type"] == "equipHubPeripheral" then
        peripheral.wrap(WsTbl["side"]).equip(tonumber(WsTbl["slot"]))
    end
end


return plugin