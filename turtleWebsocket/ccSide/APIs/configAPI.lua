configAPI = {}

local configName = ""

function configAPI.registerName(name)
    configName = name
end

function configAPI.addConfigOption(stringName,defaultValue)
    local tbl = {}
    if configName ~= "" then
        local fileRead = fs.open(configName..".json","r")
        if fileRead == nil then
            tbl[stringName] = defaultValue
            local fileWrite = fs.open(configName..".json","w")
            fileWrite.write(textutils.serialiseJSON(tbl))
            fileWrite.close()
            return true
        else
            local data = fileRead.readAll()
            tbl = textutils.unserialiseJSON(data)
            if type(tbl[stringName]) == "nil" then
                tbl[stringName] = defaultValue
            end
            local fileWrite = fs.open(configName..".json","w")
            fileWrite.write(textutils.serialiseJSON(tbl))
            fileWrite.close()
            return true
        end
    else
        return false, "Haven't registered config name."
    end
end

function configAPI.getConfigOption(stringName)
    if configName ~= "" then
        local fileRead = fs.open(configName..".json","r")
        if fileRead == nil then
            return "Not a real config name.", false
        else
            local data = fileRead.readAll()
            fileRead.close()
            tbl = textutils.unserialiseJSON(data)
            return tbl[stringName], true
        end
    else
        return "Haven't registered config name.", false
    end
end

return configAPI