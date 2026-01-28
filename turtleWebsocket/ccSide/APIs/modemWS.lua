local API = {}

--this file will be loaded AFTER 
local config = require("/APIs/configAPI")
config.registerName("configs/hivemind-main")
local modemPort1 = config.getConfigOption("modemPort1")
local modemPort2 = config.getConfigOption("modemPort2")

local modemFallback = config.getConfigOption("fallbackToModem")

local ip = config.getConfigOption("ip")

API.WS = nil
API.WS2 = nil
API.isModem = nil

function getModem()
    for _,v in pairs(table.pack(peripheral.find("modem"))) do
        if type(v) ~= "table" then return end
        if v.isWireless then
            return v
        end
    end
    error("No Wireless Modem found!")
end

function tryConnect()
    if API.WS == nil then
        API.WS = http.websocket("ws://"..ip..":5000")
    end
    if API.WS2 == nil then
        API.WS2 = http.websocket("ws://"..ip..":5001")
    end
end

function API.init()
    tryConnect()

    for i=1,2 do
        if API.WS == nil or API.WS == nil then
            print("Websocket(s) did NOT connect. Retrying...")
            sleep(0.5)
            if i == 2 and not modemFallback then
                os.reboot()
            elseif i == 2 and modemFallback then
                API.isModem = true
            end
            tryConnect()
        end
    end
end

--setup
function API.setMode(mode)
    if string.lower(mode) == "modem" then
        API.isModem = true
        local modem = getModem()
        if modem ~= nil then API.modem = modem end
    elseif string.lower(mode) == "ws" then
        API.isModem = false
    end
end

function API.open() --due to how i do WS, this will only be used for modems, close will be used for both.
    if API.isModem then 
        if type(modemPort1) == "number" then
            API.modem.open(modemPort1)
        end
        if type(modemPort2) == "number" then
            API.modem.open(modemPort2)
        end
    end
end

function API.close() -- close both ws and modem, just in case.
    if API.WS then
        API.WS.close()
    end
    if API.WS2 then
        API.WS2.close()
    end
    API.modem.closeAll()
end

--send and receive
function API.receive(number)
    if API.isModem then
        _, side, channel, _, message, _ = os.pullEvent("modem_message")
        if side == peripheral.getName(API.modem) then
            if channel == modemPort1 and number == 1 then
                return true, message
            elseif channel == modemPort2 and number == 2 then
                return true, message
            end
        end
    else
        if number == 1 and API.WS then
            local msg = API.WS.receive()
            return true, msg
        elseif number == 2 and API.WS2 then
            local msg = API.WS2.receive()
            return true, msg
        end
    end
    return false
end

function API.send(message,num)
    if type(message) ~= "string" then error("Message not a string! WS only supports strings, please use textutils.serializeJSON!") end -- NERD
    if API.isModem then
        if num == 1 then
            API.modem.transmit(modemPort1, modemPort1, message)
        elseif num == 2 then
            API.modem.transmit(modemPort2, modemPort2, message)
        end
    else
        if num == 1 and API.WS ~= nil then
            API.WS.send(message)
        elseif num == 2 and API.WS2 ~= nil then
            API.WS2.send(message)
        end
    end
end

return API