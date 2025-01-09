function getTblFromFile(name)
    file = fs.open(name,"r")
    data = file.readAll()
    file.close()
    return textutils.unserialise(data)
end

firstTbl = getTblFromFile("/data/first_names.json")
lastTbl = getTblFromFile("/data/last_names.json")

first = firstTbl[math.random(1,#firstTbl)]
last = lastTbl[math.random(1,#lastTbl)]

os.setComputerLabel(first.." "..last)
