while true do
    event, user, msg = os.pullEvent("chat")
    
    if string.find(msg,"!gmc") then
        exec("gamemode creative "..user)
    elseif string.find(msg,"!gmsp") then
        exec("gamemode spectator "..user)
    elseif string.find(msg,"!gms") then
        exec("gamemode survival "..user)
    elseif string.find(msg,"!tphere") then
        local words = string.gmatch(msg,"%S+")
        local wordsTable = {}
        
        local fake = true
        local i = 0
        
        while fake do
            i = i + 1
            local word = words()
            if word == nil then
                fake = false
            end
            wordsTable[i] = word
        end
        
        if wordsTable[2] then
           exec("tp "..wordsTable[2].." "..user) 
        end
    elseif string.find(msg,"!tp") then
        local words = string.gmatch(msg,"%S+")
        local wordsTable = {}
        
        local fake = true 
        local i = 0
        
        while fake do
            i = i + 1
            local word = words()
            if word == nil then
                fake = false
            end
            
            wordsTable[i] = word
        end
        
        if wordsTable[2] then
            exec("tp "..user.." "..wordsTable[2])  

        end
    elseif string.find(msg,"!exec") then

        local words = string.gmatch(msg,"%S+")
        local wordsTable = {}
        
        local fake = true 
        local i = 0

        local realcmd = ""
        
        while fake do
            i = i + 1
            local word = words()
            if word == nil then
                fake = false
            end
            
            wordsTable[i] = word
        end

        table.remove(wordsTable,1)
        for i=1,#wordsTable do
            if realcmd = "" then
                realcmd = wordsTable[i]
            else 
                realcmd = realcmd.." "..wordsTable[i]
            end
        end
        exec(realcmd)
    end
    
    sleep(0)
end
