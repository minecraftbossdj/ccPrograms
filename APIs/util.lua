API = {}

--misc stuff, rounding, even or odd, etc
function API.round(num)
    t = vector.new(num)
    t = t:round()
    return t.x
end

function API.isEven(num)
    if num % 2 == 0 then
        return true
    else
        return false
    end
end

function API.isOdd(num)
    if num % 2 == 0 then
        return false
    else
        return true
    end
end

function API.evenOrOdd(num)
    if num % 2 == 0 then
        return "even"
    else
        return "odd"
    end
end


--modem stuff
function API.getWireless()
    local wireless = {}
    local modems = table.pack(peripheral.find("modem"))
    for i, v in pairs(modems) do
        if type(v) == "table" then
            if v.isWireless() then
                table.insert(wireless,v)
            end
        end
    end
    return table.unpack(wireless)
end

return API
