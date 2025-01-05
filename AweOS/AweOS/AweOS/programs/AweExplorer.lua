button = require("buttonAPI")

function setup()
    x, y = term.getSize()

    files = window.create(term.current(),x/5,1,(x/5)*4,y,true)

    xF, yF = files.getSize()

    for i=1,y do 
        term.setCursorPos(x/8,i)
        term.write("\149")
    end

    for i=1,y do 
        term.setCursorPos(((x-(x/5))+1),i)
        term.write("\149")
    end
end

function renderSetup()
    --paintutils.drawFilledBox(1,1,x,y,colors.lightGray)
    oldt = term.redirect(files)
    paintutils.drawFilledBox(1,1,x,y,colors.lightGray)
    for i=1,yF do
        print("file yeah cool")
    end
    term.redirect(oldt)
end

setup()
renderSetup()