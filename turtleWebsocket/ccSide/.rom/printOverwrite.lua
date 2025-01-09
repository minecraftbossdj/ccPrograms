API = require("API/newPrintAPI")

if _G.WS then
    _G.print = API.newPrint
end
