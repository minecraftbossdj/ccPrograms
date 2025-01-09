_G.WS = http.websocket("68.42.130.37:5000")
_G.WS2 = http.websocket("68.42.130.37:5001")

if _G.WS == nil then
    print("websocket did NOT connect. Retrying...")
    sleep(0.5)
    os.reboot()
end
if _G.WS2 == nil then
    print("ws didnt connect, retrying")
    sleep(0.5)
    os.reboot()
end