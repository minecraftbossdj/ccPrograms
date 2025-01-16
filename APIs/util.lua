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


--modem stuff
function API.findWireless()
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

function API.findModem()
    local wireless = {}
    local modems = table.pack(peripheral.find("modem"))
    for i, v in pairs(modems) do
        if type(v) == "table" then
            if v.isWireless() then
                table.insert(wireless,v)
            end
        end
    end
    if wireless[1] == nil then
        return modems[1]
    else
        return table.unpack(wireless)
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

--titles n shit
function API.title(name,version)
    term.setCursorPos(1,1)
    term.write("AW3S0FT - "..name.." | "..version.. " | ID: "..os.getComputerID())
end

--lazy shit, you can judge me for this, idrc
function API.toJSON(data)
    return textutils.serialiseJSON(data)
end

function API.fromJSON(data)
    return textutils.unserialiseJSON(data)
end

--ez programs
function API.turtleSlave()
    while true do
        turtle.place()
        sleep(0)
    end
end

function API.monitorLever(doorSide,periphSide)
    local enabled = false

    local m = peripheral.wrap(periphSide)
    
    local color = 0
    
    function redraw()
        oldterm = term.redirect(m)
        local x, y = term.getSize()
        
        if enabled then
            color = colors.lime
        else
            color = colors.red
        end
        
        paintutils.drawFilledBox(1,1,x,y,color)
        term.redirect(oldterm)
    end
    
    while true do
        redraw()
        event, side = os.pullEvent("monitor_touch")

        if side == periphSide then
            enabled = not enabled
        end
        redraw()

        redstone.setOutput(doorSide,enabled)
        sleep(0)
    end
end
return API
