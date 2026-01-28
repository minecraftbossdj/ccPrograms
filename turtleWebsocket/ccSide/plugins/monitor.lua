plugin = {}

function plugin.WSReceive(WsTbl)
    if WsTbl["type"] == "monitorWrite" then
        peripheral.wrap(WsTbl["peripheralName"]).write(WsTbl["message"])
    elseif WsTbl["type"] == "monitorSetCursorPos" then
        peripheral.wrap(WsTbl["peripheralName"]).setCursorPos(WsTbl["x"],WsTbl["y"])
    elseif WsTbl["type"] == "monitorClear" then
        peripheral.wrap(WsTbl["peripheralName"]).clear()
    elseif WsTbl["type"] == "monitorSetScale" then
        peripheral.wrap(WsTbl["peripheralName"]).setTextScale(WsTbl["scale"])
    elseif WsTbl["type"] == "monitorScroll" then
        peripheral.wrap(WsTbl["peripheralName"]).scroll(WsTbl["scrollAmount"])
    end
end

return plugin