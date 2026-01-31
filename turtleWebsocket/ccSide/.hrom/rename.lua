function getTblFromFile(name)
    file = fs.open(name,"r")
    data = file.readAll()
    file.close()
    return textutils.unserialise(data)
end

local firstTbl = getTblFromFile("/data/first_names.json")
local lastTbl = getTblFromFile("/data/last_names.json")

local first = firstTbl[math.random(1,#firstTbl)]
local last = lastTbl[math.random(1,#lastTbl)]

os.setComputerLabel(first.." "..last)
