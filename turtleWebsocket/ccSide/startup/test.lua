local wsmodem = require("/APIs/modemWS")
local config = require("/APIs/configAPI")
config.registerName("configs/hivemind-main")
local autoReboot = config.getConfigOption("autoReboot")
if autoReboot then print("rebooting...") end
sleep(1)
if wsmodem.modem then wsmodem.modem.closeAll() end
if autoReboot then os.reboot() end
