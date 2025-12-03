local x, y = term.getSize()

term.clear()

local fileTbl = fs.list("/")
local directory = "/"

local fileWindow = window.create(term.current(),1,4,x,y)

term.setCursorPos(1,2)
term.write(directory)

local selectedFileNum = 1

local isDirTbl = {}

local scrollOffset = 0
local displayHeight = y - 4

local function getParentDir(path)
    if path ~= "/" then
        path = path:gsub("/+$", "")
    end

    local parent = path:match("^(.*)/[^/]*$") or "/"
    return parent == "" and "/" or parent
end

local function hasExtension(filename)
    return filename:match("^[^.].*%.[^./]+$") ~= nil
end

local function refreshDirectory()
    fileTbl = fs.list(directory)
    isDirTbl = {}
    for i, v in ipairs(fileTbl) do
        isDirTbl[i] = fs.isDir(fs.combine(directory, v))
    end
end

local dirty = false

function delete(fileDirectory)
    local deleting = true
    term.clear()
    fileWindow.setBackgroundColor(colors.black)
    fileWindow.setTextColor(colors.white)
    fileWindow.clear()
    
    local selected = "yes"

    term.setCursorPos(1, 2)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clearLine()
    term.write("[Yes] No ")

    local selectedIndex = 1

    while deleting do
        local event, key = os.pullEvent("key")
        if key == keys.right then
            selectedIndex = selectedIndex + 1
        elseif key == keys.left then
            selectedIndex = selectedIndex - 1
        end

        if selectedIndex == 0 then
            selectedIndex = 2
        elseif selectedIndex == 3 then
            selectedIndex = 1
        end

        if selectedIndex == 1 then
            term.setCursorPos(1,2)
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.clearLine()
            term.write("[Yes] No ")
            selected = "yes"
        elseif selectedIndex == 2 then
            term.setCursorPos(1,2)
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.clearLine()
            term.write(" Yes [No]")
            selected = "no"
        end

        if key == keys.enter then
            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.black)
            fileWindow.setTextColor(colors.white)
            fileWindow.setBackgroundColor(colors.black)
            fileWindow.clear()
            if not fs.isReadOnly(fileDirectory) then
                if selected == "yes" then
                    fs.delete(fileDirectory)
                    term.clear()
                    term.setCursorPos(1,2)
                    term.write(directory)
                    deleting = false
                elseif selected == "no" then
                    term.clear()
                    term.setCursorPos(1,2)
                    term.write(directory)
                    deleting = false
                end
            else
                term.clear()
                term.setCursorPos(1,2)
                term.write(directory)
                deleting = false
            end
        end
    end

end

function selector(fileDirectory)
    local selecting = true
    term.clear()
    fileWindow.setBackgroundColor(colors.black)
    fileWindow.setTextColor(colors.white)
    fileWindow.clear()
    
    local selected = "edit"

    term.setCursorPos(1, 2)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clearLine()
    term.write("[Edit] Run  Exit ")

    local selectedIndex = 1

    while selecting do
        local event, key = os.pullEvent("key")
        if key == keys.right then
            selectedIndex = selectedIndex + 1
        elseif key == keys.left then
            selectedIndex = selectedIndex - 1
        end

        if selectedIndex == 0 then
            selectedIndex = 3
        elseif selectedIndex == 4 then
            selectedIndex = 1
        end

        if selectedIndex == 1 then
            term.setCursorPos(1,2)
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.clearLine()
            term.write("[Edit] Run  Exit ")
            selected = "edit"
        elseif selectedIndex == 2 then
            term.setCursorPos(1,2)
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.clearLine()
            term.write(" Edit [Run] Exit ")
            selected = "run"
        elseif selectedIndex == 3 then
            term.setCursorPos(1,2)
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.clearLine()
            term.write(" Edit  Run [Exit]")
            selected = "exit"
        end

        if key == keys.enter then
            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.black)
            fileWindow.setTextColor(colors.white)
            fileWindow.setBackgroundColor(colors.black)
            fileWindow.clear()
            if selected == "edit" then
                shell.run("edit "..fileDirectory)
                term.clear()
                term.setCursorPos(1,2)
                term.write(directory)
                selecting = false
            elseif selected == "run" then
                shell.run(fileDirectory)
                local cursx, cursy = term.getCursorPos()
                if cursx ~= 1 then
                    term.setCursorPos(1,cursy+1)
                end
                print("Press any key to continue...")
                os.pullEvent("key")
                term.clear()
                term.setCursorPos(1,2)
                term.write(directory)
                selecting = false
            elseif selected == "exit" then
                term.clear()
                term.setCursorPos(1,2)
                term.write(directory)
                selecting = false
            end
        end
    end

end

function createNew(fileDirectory)
    local creating = true
    term.clear()
    fileWindow.setBackgroundColor(colors.black)
    fileWindow.setTextColor(colors.white)
    fileWindow.clear()
    
    local selected = "file"

    term.setCursorPos(1, 2)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clearLine()
    term.write("[File] Folder ")

    local selectedIndex = 1

    while creating do 
        local event, key = os.pullEvent("key")
        if key == keys.right then
            selectedIndex = selectedIndex + 1
        elseif key == keys.left then
            selectedIndex = selectedIndex - 1
        end
       
        if selectedIndex == 0 then
            selectedIndex = 2
        elseif selectedIndex == 3 then
            selectedIndex = 1
        end

        if selectedIndex == 1 then
            term.setCursorPos(1,2)
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.clearLine()
            term.write("[File] Folder ")
            selected = "file"
        elseif selectedIndex == 2 then
            term.setCursorPos(1,2)
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.clearLine()
            term.write(" File [Folder]")
            selected = "folder"
        end

        if key == keys.enter then
            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.black)
            fileWindow.setTextColor(colors.white)
            fileWindow.setBackgroundColor(colors.black)
            fileWindow.clear()
            if selected == "file" then
                term.setCursorPos(1, 2)
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                term.clearLine()
                term.write("Name: ")
                local fileName = read()

                shell.run("edit "..fs.combine(fileDirectory,fileName))
                
                term.clear()
                term.setCursorPos(1,2)
                term.write(directory)
                creating = false
            elseif selected == "folder" then
                term.setCursorPos(1, 2)
                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
                term.clearLine()
                term.write("Name: ")
                local folderName = read()
                fs.makeDir(fs.combine(fileDirectory,folderName))

                term.clear()
                term.setCursorPos(1,2)
                term.write(directory)
                creating = false
            end
        end

        sleep(0)
    end
end

function draw()
    -- initial render
    refreshDirectory()
    local dirty = true

    while true do
        local event, key = os.pullEvent("key")
        local prevSelected = selectedFileNum

        -- navigation
        if key == keys.down then
            selectedFileNum = math.min(selectedFileNum + 1, #fileTbl)
            dirty = true
        elseif key == keys.up then
            selectedFileNum = math.max(selectedFileNum - 1, 1)
            dirty = true
        elseif key == keys.enter then
            if isDirTbl[selectedFileNum] then
                directory = "/" .. fs.combine(directory, fileTbl[selectedFileNum])
                selectedFileNum = 1
                scrollOffset = 0
                refreshDirectory()
                dirty = true
            else
                selector(fs.combine(directory, fileTbl[selectedFileNum]))
                refreshDirectory()
                dirty = true
            end
        elseif key == keys.backspace then
            if directory ~= "/" then
                directory = getParentDir(directory)
                selectedFileNum = 1
                scrollOffset = 0
                refreshDirectory()
                dirty = true
            end
        elseif key == keys.insert then
            createNew(directory)
            refreshDirectory()
            dirty = true
        elseif key == keys.delete then
            delete(fs.combine(directory, fileTbl[selectedFileNum]))
            refreshDirectory()
            dirty = true
        elseif key == keys.f1 then
            term.clear()
            fileWindow.clear()
            term.setCursorPos(1,1)
            return
        end

        -- scroll adjustment
        if selectedFileNum ~= prevSelected then
            if selectedFileNum > scrollOffset + displayHeight then
                scrollOffset = selectedFileNum - displayHeight
                dirty = true
            elseif selectedFileNum <= scrollOffset then
                scrollOffset = selectedFileNum - 1
                dirty = true
            end
        end

        -- redraw only when needed
        if dirty then
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.setCursorPos(1, 2)
            term.clearLine()
            term.write(directory)

            fileWindow.setBackgroundColor(colors.black)
            fileWindow.clear()

            for i = 1, displayHeight do
                local index = scrollOffset + i
                local v = fileTbl[index]
                if v then
                    local isDir = isDirTbl[index]

                    if index == selectedFileNum then
                        fileWindow.setBackgroundColor(colors.white)
                        fileWindow.setTextColor(colors.black)
                    else
                        fileWindow.setBackgroundColor(colors.black)
                        fileWindow.setTextColor(colors.white)
                    end

                    fileWindow.setCursorPos(1, i)

                    if isDir then
                        fileWindow.write("/" .. v .. "/")
                    elseif hasExtension(v) then
                        fileWindow.write(v)
                    else
                        fileWindow.write(v .. ".file")
                    end
                end
            end

            dirty = false
        end
    end
end




draw()
