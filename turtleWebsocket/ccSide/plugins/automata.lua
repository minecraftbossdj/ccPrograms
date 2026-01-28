plugin = {}


function plugin.init()
    automata = peripheral.find("automata")
    if type(automata) ~= "nil" then
        isAutomata = true
    else
        isAutomata = false
    end
end

function plugin.WSReceive(WsTbl)
    if WsTbl["type"] == "useItemOnBlock" then
        if isAutomata then
            automata.use("block")
        end
    end
    if WsTbl["type"] == "swingItemAutomata" then
        if isAutomata then
            automata.swing("block")
        end
    end
end

return plugin