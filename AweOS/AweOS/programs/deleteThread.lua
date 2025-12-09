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

args = {...}

if not threadExists(args[1]) then error("Not a thread name!") end

getThreadByName(args[1]).thread:kill()

for i, v in pairs(_G.thread) do
    if v.name == args[1] then
        table.remove(_G.thread, i)
        if _G.thread[args[1]] then
            _G.thread[args[1]] = nil
        end
    end 
end