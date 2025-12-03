function renderBar(thread, row)
    local maxX, maxY = term.getSize()
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1, row)
    term.write(thread.name)
    if thread.thread.status == "dead" then
        paintutils.drawPixel(maxX, row, colors.red)
    elseif thread.paused then
        paintutils.drawPixel(maxX, row, colors.blue)
    else
        paintutils.drawPixel(maxX, row, colors.lime)
    end
    term.setBackgroundColor(colors.black)
end

local lastCount = 0
while true do
    term.setBackgroundColor(colors.black)
    term.clear()


    local x, y = term.getSize()
    
    term.setCursorPos(1,2)
    term.setBackgroundColor(colors.black)
    for i=1, x do
        term.write("-")
    end
    

    term.setCursorPos(1,1)
    term.setBackgroundColor(colors.black)
    term.write("Task Name")

    term.setCursorPos(x,1)
    term.write("S")

    term.setBackgroundColor(colors.black)
    
    for i, v in pairs(_G.threads) do
        renderBar(v, i+2)
    end
    
    lastCount = #_G.threads
    sleep(0.5)
end
