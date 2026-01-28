local API = {}

--yeah im lazy stfu
function API.serializeTable(table)
    if type(table) == "table" then
        local success, returnTbl = pcall(function ()
            return textutils.serialiseJSON(table)
        end)
        if success then
            return returnTbl
        else
            return ""
        end
    end
end

function API.unserializeTable(table)
    if type(table) == "string" then
        return textutils.unserialiseJSON(table)
    end
end

function API.titleAndInfo(typeAPI,hivemindVersion,serverName)
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.yellow)
    print("Turtle Hivemind "..hivemindVersion)
    term.setTextColor(colors.white)
    print(("%s | ID: %d | Serv: "..serverName):format(os.getComputerLabel(), os.getComputerID()))
    print("Computer Type: "..typeAPI.getComputerFamily().." "..typeAPI.getComputerType())
    term.setCursorPos(1,4)
end

return API