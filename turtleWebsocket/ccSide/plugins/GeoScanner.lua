plugin = {}


function plugin.init()
    isGeoScanner = false
    geo = peripheral.find("geoScanner")
    if geo ~= nil then
        isGeoScanner = true
    end
end

function plugin.WSReceive(WsTbl)
    if isGeoScanner then
        if WsTbl["type"] == "scanArea" then
            local returnTbl = {}
            local blocks = geo.scan(WsTbl["size"])
            for i,v in pairs(blocks) do
                v.tags = nil
            end
            returnTbl["type"] = "geoScanned"
            returnTbl["id"] = os.getComputerID()
            returnTbl["blocks"] = blocks

            _G.WS2.send(textutils.serialiseJSON(returnTbl))
        end
    end
end

return plugin