function addThread(func, name, terminal, cantBePaused)
    local th = _G.thread.new(func)
    local threadTbl = {
        name = name,
        thread = th,
        paused = false,
        cantBePaused = cantBePaused or false
    }
    threadTbl.thread.terminal = terminal
    table.insert(_G.threads, threadTbl)
    return threadTbl
end

function threadExists(name)
    for _, v in pairs(_G.threads) do
        if v.name == name then
            return true
        end
    end
    return false
end

function getThreadByName(name)
    for _, v in pairs(_G.threads) do
        if v.name == name then
            return v
        end
    end
end

local args = {...}

local newTerm = peripheral.wrap(args[2])
if newTerm == nil then newTerm = term.native() end

if not fs.exists(args[1]) then error("Not a program name!") end

addThread(function() 
    local oldterm = term.redirect(newTerm)
    shell.run(args[1])
    term.redirect(oldterm)
end, arg[1], newTerm)