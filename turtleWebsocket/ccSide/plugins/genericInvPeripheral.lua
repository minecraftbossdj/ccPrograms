plugin = {}


function plugin.WSReceive(WsTbl, serverName, wsmodem)
    if WsTbl["type"] == "refreshPeriphInv" then
        local inv = peripheral.wrap(WsTbl["side"])
        if inv then
            local tbl = {}
            tbl["type"] = "periphInv"
            tbl["id"] = os.getComputerID()
            tbl["invData"] = {}
            tbl["server"] = serverName

            local size = inv.size()
            local contents = inv.list()

            for i = 1, size do
                local item = contents[i]
                if item then
                    item.tags = nil
                    tbl["invData"]["slot_"..i] = item
                else
                    tbl["invData"]["slot_"..i] = {
                        name = "minecraft:air",
                        count = 0,
                    }
                end
            end

            wsmodem.WS2.send(textutils.serialiseJSON(tbl))
        end
    end
end

return plugin
