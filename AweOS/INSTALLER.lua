local startURL = "https://raw.githubusercontent.com/minecraftbossdj/ccPrograms/refs/heads/main/AweOS/"

local function download(url)
    shell.run("wget "..startURL..url.." "..url)
end

local toDownload = {
    "AweOS/boot.lua",
    "AweOS/login.lua",
    "AweOS/APIs/Menyuu.lua",
    "AweOS/APIs/filesystem.lua",
    "AweOS/APIs/minilogger.lua",
    "AweOS/APIs/sha2.lua",
    "AweOS/APIs/thread.lua",
    "AweOS/APIs/util.lua",
    "AweOS/programs/fileExplorer.lua",
    "AweOS/programs/multishell.lua",
    "AweOS/programs/taskManager.lua",
    "AweOS/programs/aukit/aukit.lua",
    "AweOS/programs/aukit/austream.lua",
    "AweOS/users/admin/password.txt"
}

for _, v in pairs(toDownload) do
    download(v)
end
