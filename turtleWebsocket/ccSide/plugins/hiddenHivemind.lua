plugin = {}

function plugin.init()
    if fs.exists("configs/hivemind-main.json") then
        local readFile = fs.open("configs/hivemind-main.json","r")
        local fileData = readFile.readAll()
        readFile.close()

        local tbl = textutils.unserialiseJSON(fileData)
        tbl["hiddenHivemind"] = true

        local writeFileData = textutils.serialiseJSON(tbl)

        local writeFile = fs.open("configs/hivemind-main.json","w")
        writeFile.write(writeFileData)
        writeFile.close()

    end
end

return plugin