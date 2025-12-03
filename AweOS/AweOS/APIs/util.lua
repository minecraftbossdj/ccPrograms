API = {}

--misc stuff, rounding, even or odd, etc
function API.round(num)
    local t = vector.new(num)
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

function API.toBool(boolStrng)
    if string.lower(boolStrng) == "true" then
        return true
    elseif string.lower(boolStrng) == "false" then
        return false
    end
end

--redirect n shit
function API.redirectFunc(redirect,func)
    local old = term.redirect(redirect)
    func()
    term.redirect(old)
end

function API.redirectPrint(redirect,msg)
    local old = term.redirect(redirect)
    local x, y = term.getCursorPos()
    term.write(msg)
    term.setCursorPos(x,7+1)
    term.redirect(old)
end

function API.redirectPrintReset(redirect,msg)
    local old = term.redirect(redirect)
    local x, y = term.getCursorPos()
    term.write(msg)
    term.setCursorPos(1,y+1)
    term.redirect(old)
end

--lazy shit, you can judge me for this, idrc
function API.toJSON(data)
    return textutils.serialiseJSON(data)
end

function API.fromJSON(data)
    return textutils.unserialiseJSON(data)
end

return API