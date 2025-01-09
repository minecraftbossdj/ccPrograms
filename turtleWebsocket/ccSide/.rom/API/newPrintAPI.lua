API = {}

oldprint = _G.print

function API.newPrint(msg)
    tbl = {}
    tbl["msg"] = msg
    tbl["type"] = "print"
    tbl["id"] = os.getComputerID()
    _G.WS2.send(textutils.serialiseJSON(tbl))
    oldprint(msg)
end

return API
