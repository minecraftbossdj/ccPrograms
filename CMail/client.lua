button = require("buttonAPI")
util = require("util")
cmail = require("clientAPI")
box = require("textBox")

local args = {...}

local dividerX = 0
local offset = 0
local edit = false

local censorPassword = true

--main mail stuff

function renderText(bool)
    local x, y = term.getSize()
    term.setBackgroundColor(colors.black)
    term.setCursorPos(dividerX+1,2)
    term.write("             ")
    term.setCursorPos(dividerX+1,2)
    if bool == nil then
        bool = false
    end
    if edit and not bool then
        term.write("to Address:")
    else
        term.write("from Address:")
    end

    term.setBackgroundColor(colors.black)
    term.setCursorPos(dividerX+1,5)
    term.write("Title/Subject:")

    term.setBackgroundColor(colors.black)
    term.setCursorPos(dividerX+1,8)
    term.write("Message:")
end

function setup()
    term.clear()
    local x, y = term.getSize()
    dividerX = x/4
    for i=1,y do 
        term.setCursorPos(x/4,i)
        term.write("\149")
    end

    address = box.createTextBox(dividerX+1,3,x-(dividerX+1),2,"address",colors.lightGray,colors.white)

    Title = box.createTextBox(dividerX+1,6,x-(dividerX+1),2,"title",colors.lightGray,colors.white)

    message = box.createTextBox(dividerX+1,9,x-(dividerX+1),y-10,"message",colors.lightGray,colors.white)

    renderText(true)
    

    send = button.newButton(term.native(),"mailButtons",x-3,y,"Send","send",colors.lime,colors.black,colors.green,false,4,0)
    cancel = button.newButton(term.native(),"mailButtons",x-10,y,"Cancel","cancel",colors.red,colors.black,colors.gray,false,5,0)
    new = button.newButton(term.native(),"maingui",x-2,1,"New","new",colors.lightBlue,colors.black,colors.blue,false,3,0)
    if pocket then
        refresh = button.newButton(term.native(),"maingui",1,y,"Ref","refresh",colors.blue,colors.white,colors.gray,false,3,0)
    else
        refresh = button.newButton(term.native(),"maingui",1,y,"Refresh","refresh",colors.blue,colors.white,colors.gray,false,7,0)
    end

    button.drawButtons("maingui")
    if edit then
        button.drawButtons("mailButtons")
    end


    local pos = 1
    for i=1,y/3 do
        if util.isOdd(y/3) then
            if i == y then
                return
            end
        end
        
        if type(i) == "number" then
            button.newButton(term.native(),"mail",1,pos,"",tostring(i),colors.lightGray,colors.black,colors.gray,false,dividerX-1,2)
            pos = button.getButton("mail",tostring(i)).maxY+1
            button.drawButtons("mail")
        end
    end
end

function drawMail(tbl,pressed,selectedTbl)
    local x, y = term.getSize()
    button.drawButtons("mail",pressed)
    term.setCursorPos(1,1)
    for i=1,y/3 do
        if util.isOdd(y/3) then
            if i == y then
                return
            end
        end
        if tbl[i+offset] ~= nil then
            term.setTextColor(colors.white)
            print(string.sub(tbl[i+offset].senderAddress,0,dividerX-3).."..")
            term.setTextColor(colors.blue)
            print(string.sub(tbl[i+offset].title,0,dividerX-3).."..")
            term.setTextColor(colors.gray)
            print(string.sub(tbl[i+offset].message,0,dividerX-3).."..")
            term.setTextColor(colors.white)
        end
    end
    term.setBackgroundColor(colors.black)
    for i=1,y do 
        term.setCursorPos(x/4,i)
        term.write("\149")
    end
    local x, y = term.getSize()
    paintutils.drawFilledBox(dividerX+1,2,x,y-1,colors.black)
    renderText(true)


    address:draw()
    Title:draw()
    message:draw()
end

function mailClick(tbl)
    if tbl ~= nil and not edit then
        drawMail(tbl)
        local event, click, x, y = os.pullEvent("mouse_click")
        pressed = button.processButtons(x,y,"mail",term.native())
        pressed = pressed or ""
        drawMail(tbl)
        renderText(false)
        if pressed ~= "" then
            local selectedMail = tbl[tonumber(pressed)+offset]
            if selectedMail ~= nil then
                address.text = selectedMail.senderAddress
                Title.text = selectedMail.title
                message.text = selectedMail.message
                address:draw()
                Title:draw()
                message:draw()
                term.setBackgroundColor(colors.black)
                term.setCursorPos(dividerX+1,1)
                term.write("                     ")
                term.setCursorPos(dividerX+1,1)
                term.setBackgroundColor(colors.lightGray)
                term.write("Sent: "..selectedMail.time.month.."/"..selectedMail.time.day.."/"..selectedMail.time.year.." "..selectedMail.time.hour..":"..selectedMail.time.min)
                drawMail(tbl,pressed,selectedMail)
            end
        end
        drawMail(tbl)
    end
end

function main()
    tbl = cmail.requestMail()
    oldtbl = tbl
    local i = 0
    while true do
        i = i + 1

        if i == 5 then
            tbl = cmail.requestMail()
            i = 0
        end

        tbl = oldtbl
        if tbl ~= nil then
            mailClick(tbl)
        end
        sleep(0)
    end
end

function scroll()
    while true do
        event, num = os.pullEvent("mouse_scroll")
        offset = offset + num
        if offset < 0 then
            offset = 0
        end
        if tbl ~= nil then
            drawMail(tbl)
        end
        sleep(0)
    end

end

function ClickGUI()
    while true do
        button.drawButtons("maingui")
        if edit then
            button.drawButtons("mailButtons")
        end
        local event, click, x, y = os.pullEvent("mouse_click")
        pressed = button.processButtons(x,y,"maingui",term.native())
        pressed = pressed or ""
        button.drawButtons("maingui")
        if edit then
            button.drawButtons("mailButtons")
        end
        if pressed == "new" and not edit then
            edit = true
            renderText()
            address.text = ""
            Title.text = ""
            message.text = ""
            address:draw()
            Title:draw()
            message:draw()
            local x,y = term.getSize()
        end
        if pressed == "send" and edit then
            edit = false
            cmail.sendEmail(message.text,address.text,Title.text)
            address.text = ""
            Title.text = ""
            message.text = ""
            address:draw()
            Title:draw()
            message:draw()
            address.isSelected = false
            Title.isSelected = false
            message.isSelected = false
            renderText(true)
        end
        if pressed == "cancel" and edit then
            edit = false
            address.text = ""
            Title.text = ""
            message.text = ""
            address:draw()
            Title:draw()
            message:draw()
            address.isSelected = false
            Title.isSelected = false
            message.isSelected = false
            renderText(true)
        end
        if pressed == "refresh" then
            tbl = cmail.requestMail()
            drawMail(tbl)
            oldtbl = tbl
        end

        sleep(0)
    end
end

function ClickEditGUI()
    local redrawed = false
    while true do
        if edit then
            redrawed = false
            button.drawButtons("mailButtons")
            local event, click, x, y = os.pullEvent("mouse_click")
            pressed = button.processButtons(x,y,"mailButtons",term.native())
            pressed = pressed or ""
            button.drawButtons("mailButtons")

            if pressed == "send" and edit then
                edit = false
                cmail.sendEmail(message.text,address.text,Title.text)
                address.text = ""
                Title.text = ""
                message.text = ""
                address:draw()
                Title:draw()
                message:draw()
                address.isSelected = false
                Title.isSelected = false
                message.isSelected = false
                renderText(true)
            end
            if pressed == "cancel" and edit then
                edit = false
                address.text = ""
                Title.text = ""
                message.text = ""
                address:draw()
                Title:draw()
                message:draw()
                address.isSelected = false
                Title.isSelected = false
                message.isSelected = false
                renderText(true)
            end
        elseif not redrawed then
            local x, y = term.getSize()
            paintutils.drawLine(x-10,y,x,y,colors.black)
            redrawed = true
        end

        sleep(0)
    end
end

function textBoxes()
    while true do
        if edit then
            box.getInput({address,Title,message})
            address:read()
            Title:read()
            message:read()
        end
        sleep(0)
    end
end

--login screen

local x, y = term.getSize()
button.newButton(term.native(),"login",1,4,"Not you?","change_email",colors.red,colors.black,colors.gray,false,8,0)

local resetUser = false



function loginScreen(shouldDrawButton)

    if shouldDrawButton == nil then
        shouldDrawButton = true
    end

    if shouldDrawButton then
        button.drawButtons("login")
    end

    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)
    term.setTextColor(colors.yellow)
    term.write("CMail Client - Login Screen")
    term.setTextColor(colors.white)

    local file = fs.open(".cmailclient/user.json","r")
    local data = ""
    if file ~= nil then
        data = file.readAll()
        file.close()
    end
    
    
    term.setCursorPos(1,2)
    term.write("Address: ")

    term.setCursorPos(1,3)
    term.write("Password: ")

    userData = textutils.unserialiseJSON(data)
    

    if type(userData) == "table" then
        term.setCursorPos(10,2)
        term.write(userData.user)
        term.setCursorPos(11,3)
        local password = ""
        if censorPassword then
            password = read("*")
        else
            password = read()
        end
        local bool = cmail.setAddress(userData.user,password)
        if not bool then
            term.clear()
            term.setCursorPos(1,1)
            term.write("Incorrect Password!")
            sleep(1)
            loginScreen()
        else
            button.deleteButton("login","change_email")
        end
    else
        local tbl = {}
        
        term.setCursorPos(10,2)
        local username = read()
        term.setCursorPos(11,3)
        local password = ""
        if censorPassword then
            password = read("*")
        else
            password = read()
        end
        local bool = cmail.setAddress(username,password)
        if not bool then
            term.clear()
            term.setCursorPos(1,1)
            term.write("Incorrect Address or Password!")
            sleep(1)
            loginScreen()
        else
            local file = fs.open(".cmailclient/user.json","w")
            tbl["user"] = username
            local userDataWrite = textutils.serialiseJSON(tbl)
            file.write(userDataWrite)
            file.close()
            button.deleteButton("login","change_email")
        end
    end
end

function loginButtonPress()
    while true do
        local x,y = term.getCursorPos()
        button.drawButtons("login")
        term.setCursorPos(x,y)
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)

        local event, click, x, y = os.pullEvent("mouse_click")
        local pressed = button.processButtons(x,y,"login",term.native())
        local pressed = pressed or ""

        local x,y = term.getCursorPos()
        button.drawButtons("login")
        term.setCursorPos(x,y)
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)

        if pressed == "change_email" then
            resetUser = true
            fs.delete(".cmailclient/user.json")
            break
        end

        sleep(0)
    end
end


--actually running the shit
parallel.waitForAny(loginScreen,loginButtonPress)

if resetUser then
    resetUser = false
    button.deleteButton("login","change_email")
    loginScreen(false)
end

setup()


parallel.waitForAll(main,scroll,ClickGUI,ClickEditGUI,textBoxes)
