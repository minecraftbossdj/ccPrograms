shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/AweOS/AweOS/startup.lua startup.lua")


--apis
fs.makeDir("AweOS/APIs/")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/AweOS/AweOS/AweOS/APIs/roundAPI.lua AweOS/APIs/roundAPI.lua")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/AweOS/AweOS/AweOS/APIs/sha2.lua AweOS/APIs/sha2.lua")

--configs
fs.makeDir("AweOS/configs/")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/AweOS/AweOS/AweOS/configs/quotes.txt AweOS/configs/quotes.txt")

--users
fs.makeDir("AweOS/users/admin")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/AweOS/AweOS/AweOS/users/admin/pass.txt AweOS/users/admin/pass.txt")

--main files
fs.makeDir("AweOS/")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/AweOS/AweOS/AweOS/AweOS.lua AweOS/AweOS.lua")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/AweOS/AweOS/AweOS/boot.lua AweOS/boot.lua")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/AweOS/AweOS/AweOS/randomQuote.lua AweOS/randomQuote.lua")
shell.run("wget https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/AweOS/AweOS/AweOS/PasswordSys.lua AweOS/PasswordSys.lua")
