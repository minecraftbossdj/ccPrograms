local API = {}

oldprint = _G.print

local config = require("/APIs/configAPI")
local wsmodem = require("/APIs/modemWS")
config.registerName("configs/hivemind-main")

local serverName = config.getConfigOption("server")

function API.newPrint(...)
    oldprint(...)
    local msg = table.concat({...}, " ")
    tbl = {
        msg = msg,
        type = "print",
        id = os.getComputerID(),
        server = serverName
    }
    wsmodem.send(textutils.serialiseJSON(tbl),2)
    return
end

return API
