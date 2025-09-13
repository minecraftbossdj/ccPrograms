typeAPI = {}

function typeAPI.getComputerType()
    if turtle and link_turtle then
        return "Link Turtle"
    elseif turtle then
        return "Turtle"
    elseif pocket and link then
        return "Link"
    elseif pocket then
        return "Pocket"
    elseif android then
        return "Android"
    elseif drone then
        return "Drone"
    elseif nanodrone then
        return "Nano Drone"
    else
        return "Computer"
    end
end

function typeAPI.getComputerFamily()
    if shell.openTab then
        return "Advanced"
    elseif exec then
        return "Command"
    else
        return "Normal"
    end
end


return typeAPI
