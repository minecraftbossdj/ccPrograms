local file = fs.open(".rom/ip.txt","r")
if file == nil then
    error("no ip!")
end

local ip = file.readAll()
file.close()

_G.WS = http.websocket(ip..":5000")
_G.WS2 = http.websocket(ip..":5001")

if _G.WS == nil then
    print("websocket 1 did NOT connect. Retrying...")
    sleep(0.5)
    os.reboot()
end
if _G.WS2 == nil then
    print("Websocket 2 did NOT connect, Retrying...")
    sleep(0.5)
    os.reboot()
end
