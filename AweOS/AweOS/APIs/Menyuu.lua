--if you know, you know.

local API = {}

API.windows = {}
API.menyuus = {}
API.elements = {}

function API.addMenyuu(name, x, y, width, height, bkColor, visible, static, parentTerm, parentMenyuu)
    if parentTerm == nil then parentTerm = term.current() end
    local returnWin = window.create(parentTerm, x, y, width, height, visible)
    local menyuu = {
        name = name,
        x = x,
        y = y,
        width = width,
        height = height,
        bkColor = bkColor,
        static = static,
        object = returnWin,
        parentTerm = parentTerm,
        parentMenyuu = parentMenyuu,
        childMenyuus = {},
        childElements = {}
    }
    returnWin.setBackgroundColor(bkColor)
    returnWin.clear()
    returnWin.redraw()
    table.insert(API.menyuus, menyuu)
    if parentMenyuu then
        table.insert(parentMenyuu.childMenyuus, menyuu)
    end
    return menyuu
end

function API.removeMenyuu(name) 
    for i, v in pairs(API.menyuus) do
        if v.name == name then
            table.remove(API.menyuus,i)
        end
    end
end

function API.repositionMenyuu(menyuuName, x, y, w, h, refresh)
    local menyuu = API.getMenuByName(menyuuName)
    if menyuu.static then return end
   
    menyuu.x = x or menyuu.x
    menyuu.y = y or menyuu.y
    menyuu.width = w or menyuu.width
    menyuu.height = h or menyuu.height

    menyuu.object.reposition(menyuu.x, menyuu.y, menyuu.width, menyuu.height, menyuu.parentTerm or term.current())
    if refresh then menyuu.object.redraw() end
    return true
end

function API.getMenuByName(name)
    for i, v in pairs(API.menyuus) do
        if v.name == name then
            return v
        end
    end
end

function API.getMenyuuSize(name)
    local menu = API.getMenuByName(name)

    return menu.x, menu.y, menu.x+(menu.width-1), menu.y+(menu.height-1)
end

function API.renderMenyuuLoop(menyuuName)
    while true do
        local menyuu = API.getMenuByName(menyuuName)
        menyuu.object.redraw()
        sleep()
    end
end

function API.setMenyuuVisible(menyuuName, visible)
    local menyuu = API.getMenuByName(menyuuName)
    menyuu.object.setVisible(visible)
    for _, v in pairs(menyuu.childElements) do
        if type(v) == "table" then
            local elem = API.getElementByName(v.name)
            if elem ~= nil then
                elem.object.setVisible(visible)
            end
        end
    end
    for _, v in pairs(menyuu.childMenyuus) do
        if type(v) == "table" then
            local childMenyuu = API.getMenuByName(v.name)
            if childMenyuu ~= nil then
                childMenyuu.object.setVisible(visible)
            end
        end
    end
end

--elements
function API.addInput(name, x, y, width, height, bgColor, textColor, visible, parentTerm, parentMenyuu, isParentWindow)
    if parentTerm == nil then parentTerm = term.current() end
    if textColor == nil then textColor = colors.white end
    local elementWin = window.create(parentTerm, x, y, width, height, visible)
    elementWin.setBackgroundColor(bgColor)
    elementWin.clear()
    elementWin.setTextColor(textColor)
    elementWin.redraw()
    local elementTbl = {
        type = "input",
        text = "",
        name = name,
        x = x,
        y = y,
        width = width,
        height = height,
        bgColor = bgColor,
        textColor = textColor,
        active = false,
        object = elementWin,
        parentTerm = parentTerm,
        parentMenyuu = parentMenyuu,
        isParentWindow = isParentWindow
    }
    if parentMenyuu then
        table.insert(parentMenyuu.childElements, elementTbl)
    end
    table.insert(API.elements,elementTbl)
    return elementTbl
end

function API.addButton(name, text, runnable, x, y, width, height, bgColor, textColor, visible, toggle, parentTerm, parentMenyuu, isParentWindow)
    if parentTerm == nil then parentTerm = term.current() end
    if textColor == nil then textColor = colors.white end
    local elementWin = window.create(parentTerm, x, y, width, height, visible)
    elementWin.setBackgroundColor(bgColor)
    elementWin.clear()
    elementWin.setTextColor(textColor)
    elementWin.setCursorPos(1,1)
    elementWin.write(text)
    elementWin.redraw()
    if type(runnable) ~= "function" then error("No function supplied!") end
    local elementTbl = {
        type = "button",
        text = text,
        name = name,
        x = x,
        y = y,
        width = width,
        height = height,
        bgColor = bgColor,
        pressed = false,
        toggle = toggle,
        object = elementWin,
        parentTerm = parentTerm,
        func = runnable,
        parentMenyuu = parentMenyuu,
        isParentWindow = isParentWindow
    }
    if parentMenyuu then
        table.insert(parentMenyuu.childElements, elementTbl)
    end
    table.insert(API.elements,elementTbl)
    return elementTbl
end

function API.getElementByName(name)
    for i, v in pairs(API.elements) do
        if v.name == name then
            return v
        end
    end
end

function API.getElemSize(name)
    local elem = API.getElementByName(name)

    return elem.x, elem.y, elem.x+(elem.width-1), elem.y+(elem.height-1)
end

function API.isElemInside(x, y, x1, y1, x2, y2)
    return x >= x1 and x <= x2 and y >= y1 and y <= y2
end

function API.getElementAt(x, y)
    for i, v in pairs(API.elements) do
        local x1, y1, x2, y2 = API.getElemSize(v.name)
        if v.parentMenyuu or v.isParentWindow then
            local parent = v.parentMenyuu
            local worldX = parent.x + (v.x - 1)
            local worldY = parent.y + (v.y - 1)

            if API.isElemInside(x, y, worldX, worldY, worldX+(v.width-1), worldY+(v.height-1)) then
                return v
            end
        else
            if API.isElemInside(x, y, x1, y1, x2, y2) then
                return v
            end
        end
    end
end

function API.repositionElement(elem, x, y, width, height, refresh, parentTerm)
    if width == nil then width = elem.width end
    if height == nil then height = elem.height end
    if x == nil then x = elem.x end
    if y == nil then y = elem.y end

    if parentTerm == nil then parentTerm = elem.parentTerm end

    elem.object.reposition(x, y, width, height, parentTerm)
    if refresh then elem.object.redraw() end
    return true
end

function API.handleInput(x, y)
    local elem = API.getElementAt(x,y)
    if elem and elem.type == "input" and elem.object.isVisible() then
        if elem.parentMenyuu and not elem.parentMenyuu.object.isVisible() then return end
        elem.object.setBackgroundColor(elem.bgColor)
        elem.object.clear()
        elem.object.setBackgroundColor(elem.bgColor)
        elem.object.setTextColor(elem.textColor)
        elem.object.setCursorPos(1,1)
        elem.active = true
        local old = term.redirect(elem.object)
        elem.object.setCursorPos(1,1)
        elem.text = read()
        term.redirect(old)
        elem.active = false
        elem.object.setCursorBlink(false)
        elem.object.setCursorPos(1,1)
        elem.object.write(elem.text)
        elem.object.setBackgroundColor(colors.black)
        elem.object.setTextColor(colors.white)
    end
end

function API.handleButton(x, y)
    local elem = API.getElementAt(x,y)
    if elem and elem.type == "button" and elem.object.isVisible() then
        if elem.toggle then
            elem.pressed = not elem.pressed
            elem.func(elem)
        else
            elem.pressed = true
            elem.func(elem)
            elem.pressed = false
        end
        return elem
    end
end

return API