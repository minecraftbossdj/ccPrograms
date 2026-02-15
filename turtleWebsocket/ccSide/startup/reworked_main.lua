local oldPull = os.pullEvent
os.pullEvent = os.pullEventRaw

--load le apis
local typeAPI = require("/APIs/typeAPI")
local config = require("/APIs/configAPI")
local misc = require("/APIs/miscAPI")
local printAPI = require("/APIs/newPrintAPI")

--configs yummy
config.registerName("configs/hivemind-main")
config.addConfigOption("version", "v3.0.0")
config.addConfigOption("server", "Havoc")
config.addConfigOption("hiddenHivemind", false)
config.addConfigOption("autoRename", true)
config.addConfigOption("fallbackToModem", true) --modem stuff, incase SOMEBODY (looking at you perseus) turns off http
config.addConfigOption("modemPort1", 2107)
config.addConfigOption("modemPort2", 2108)
config.addConfigOption("forceModem", false)
config.addConfigOption("ip", "1.1.1.1")
config.addConfigOption("autoReboot", true)

--grab config options
local hivemindVersion = config.getConfigOption("version")
local hiddenHivemindConfig = config.getConfigOption("hiddenHivemind")
local autoRename = config.getConfigOption("autoRename")
local forceModem = config.getConfigOption("forceModem")
local serverName = config.getConfigOption("server")
local ip = config.getConfigOption("ip")

--get it here so config is already registered, and WS file has already ran
local wsmodem = require("/APIs/modemWS")

wsmodem.init()

if type(forceModem) == "boolean" and forceModem then
    wsmodem.isModem = true
end

if wsmodem.isModem then
    print("HTTP offline (or forced modem), fallback to modem.")
    wsmodem.setMode("modem")
else
    wsmodem.setMode("ws")
end

if wsmodem.WS or wsmodem.WS2 or wsmodem.isModem then
    _G.print = printAPI.newPrint
end

--the name inator!
if os.getComputerLabel() == nil and autoRename then
    dofile(".hrom/rename.lua")
end

--plugin trolling
local pluginNames = fs.list("/plugins/")
local plugins = {}
local pluginsWithLoop = {}

for _,v in pairs(pluginNames) do
    local pluginName = v:gsub("%.lua", "")
    plugins[pluginName] = require("/plugins/"..pluginName)
end

for _,v in pairs(plugins) do
    if type(v.init) == "function" then
        v.init(serverName, wsmodem)
    end
end

for _,v in pairs(plugins) do --arigato, nulshart
    if type(v.loop) == "function" then
        table.insert(pluginsWithLoop,v)
    end
end

--for update
local function install(filename)
    local internetFile = http.get("https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/turtleWebsocket/ccSide/"..filename)
    if internetFile ~= nil then
        local data = internetFile.readAll()
        internetFile.close()

        local file = fs.open(filename,"w")
        file.write(data)
        file.close()
    end
end

local function update()
    fs.delete(".hrom")
    fs.delete("data")
    fs.delete("startup")
    fs.delete("APIs")

    fs.makeDir(".hrom")
    fs.makeDir(".hrom/API")
    fs.makeDir("data")
    fs.makeDir("APIs")
    fs.makeDir("startup")

    local filesToInstall = {
        "startup/main.lua",
        "startup/test.lua",
        ".hrom/rename.lua",
        --apis
        ".hrom/API/newPrintAPI.lua",
        "APIs/configAPI.lua",
        "APIs/typeAPI.lua",
        "APIs/modemWS.lua",
        "APIs/miscAPI.lua",
        --data, i really gotta change these names :sob: fuckin 2 year ago i made these names
        "data/first_names.json",
        "data/last_names.json"
    }
 
    for _,v in pairs(filesToInstall) do
        install(v)
    end
end

local function turtleInv()
    local inv = {
        type = "inventory",
        id = os.getComputerID(),
        server = serverName
    }
    for i=1,16 do
        inv["slot_"..tostring(i)] = {}
        inv["slot_"..tostring(i)]["count"] = 0
        inv["slot_"..tostring(i)]["name"] = "minecraft:air"
        if turtle.getItemDetail(i) ~= nil then
            inv["slot_"..tostring(i)] = turtle.getItemDetail(i)
        end
    end
    inv["selectedSlot"] = turtle.getSelectedSlot()

    wsmodem.send(misc.serializeTable(inv),2)
end

local function turtInspect()
    local inspect = {
        type = "inspect",
        id = os.getComputerID(),
        server = serverName
    }

    local toInspect = {
        up = turtle.inspectUp,
        forward = turtle.inspect,
        down = turtle.inspectDown
    }

    for dir, func in pairs(toInspect) do
        if type(dir) == "string" and type(func) == "function" then
            local bool, data = func()
            if type(data.name) ~= "nil" then
                if bool then inspect[dir] = data.name end
            end
        end
    end

    wsmodem.send(misc.serializeTable(inspect),2)
end

local function setEnvironment(func) 
    if not func then return end
    setfenv(func, {
        pairs = pairs, ipairs = ipairs, print = print, 
        tonumber = tonumber, tostring = tostring, type = type, 
        math = math, string = string, table = table,
        peripheral=peripheral, textutils=textutils, require=require,
        --custom apis
        turtle=turtle, android=android, drone=drone, link=link,
        pocket=pocket, exec=exec,
        --table of funcs
        os={
            getComputerID=os.getComputerID,
            getComputerLabel=os.getComputerLabel,
            reboot=os.reboot
        },
        shell={
            openTab=shell.openTab,
            switchTab=shell.switchTab
        }
    })
end

local function runString(string)
    local resultsTbl = {}
    af=loadstring("return "..string)
    setEnvironment(af)
    if af == nil then
        af=loadstring(string)
        setEnvironment(af)
    end
    local success, err = pcall(function()
        resultsTbl = {af()}
    end)

    if success then
        local sendResults = {
            type = "result",
            id = os.getComputerID(),
            server = serverName
        }
        sendResults.results = {table.unpack(resultsTbl)}
        sendResults["resultOne"] = resultsTbl[1]
        sendResults["resultTwo"] = resultsTbl[2] --backwards compatibility

        wsmodem.send(misc.serializeTable(sendResults),2)
    end
end

local function isValid(tbl)
    return tbl.type ~= nil and tonumber(tbl.id) == os.getComputerID() and tbl.server == serverName
end

local function main()
    misc.titleAndInfo(typeAPI,hivemindVersion,serverName)
    wsmodem.open()
    while true do
        local received, receivedinfo = wsmodem.receive(1)
        local infoTbl = misc.unserializeTable(receivedinfo)
        if type(infoTbl) == "table" and isValid(infoTbl) then
            if infoTbl.type == "function" then
                runString(infoTbl["msg"])
            elseif infoTbl.type == "refreshInv" then
                if turtle then turtleInv() end
            elseif infoTbl.type == "refreshInspect" then
                if turtle then turtInspect() end
            elseif infoTbl.type == "update" then
                update()
            else
                for _,v in pairs(plugins) do
                    if type(v.WSReceive) == "function" then
                        v.WSReceive(infoTbl)
                    end
                end
            end
        end
        sleep(0)
    end
end

local function events()
    while true do
        local eventTbl = {os.pullEventRaw()}
        if eventTbl[1] ~= "websocket_message" and eventTbl[1] ~= "timer" then
            local eventSendTbl = {
                type = "event",
                id = os.getComputerID(),
                server = serverName
            }
            eventSendTbl.event = eventTbl[1]
            eventSendTbl.arg1 = eventTbl[2]
            eventSendTbl.arg2 = eventTbl[3]
            eventSendTbl.arg3 = eventTbl[4]
            eventSendTbl.args = {table.unpack(eventTbl)}

            wsmodem.send(misc.serializeTable(eventSendTbl),2)
        end
        if eventTbl[1] == "turtle_inventory" or eventTbl[1] == "turtle_response" then
            turtleInv()
        end
        for _,v in pairs(plugins) do
            if type(v.Event) == "function" then
                v.Event(eventTbl[1],eventTbl[2],eventTbl[3],eventTbl[4],eventTbl)
            end
        end
        sleep(0)
    end
end

local function hiddenHivemind()
    term.clear()
    term.setCursorPos(1,1)
    if term.isColor() then
        shell.run("multishell")
    else
        shell.run("shell")
    end
end

local function websocketRefresh()
    while true do
        if not wsmodem.isModem then
            if wsmodem.WS.send("") ~= nil or wsmodem.WS2.send("") ~= nil then
                os.reboot()
            end
        end
        sleep(120)
    end
end


if hiddenHivemindConfig then
    parallel.waitForAny(main,events,websocketRefresh,hiddenHivemind,table.unpack(pluginsWithLoop))
else
    parallel.waitForAny(main,events,websocketRefresh,table.unpack(pluginsWithLoop))
end

os.pullEvent = oldPull
