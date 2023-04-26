--[[----------------------------------------------------------------------------
                                Core OpenAI
----------------------------------------------------------------------------]]--

OpenAI = OpenAI or {}

if SERVER then
    AddCSLuaFile("openai/shared.lua")
    AddCSLuaFile("openai/cl_init.lua")
    AddCSLuaFile("openai/util/enum_color.lua")
    AddCSLuaFile("openai/util/httpcode.lua")
    include("openai/util/enum_color.lua")
    include("openai/util/httpcode.lua")
    include("openai/shared.lua")
    include("openai/init.lua")
else
    include("openai/util/enum_color.lua")
    include("openai/util/httpcode.lua")
    include("openai/shared.lua")
    include("openai/cl_init.lua")
end

--[[
MsgC(Color(255, 255, 255), "===================================================================================\n", SERVER and Color(0, 200, 255) or Color(255, 221, 102),
[ [
     _____ ____  ____ _   _     _____ _
    |  _  |  _ \|  __| \ | |\  |  _  | |\
    | | | | |_) | |__|  \| | | | |_| | | |
    | | | |  __/|  __|     | | |  _  | | |
    | |_| | |  _| |__| |\  | | | |\| | | |
    |_____|_| | |____|_| \_| | |_| |_|_| |
     \_____\_\|  \____\_|\__\|  \_\.\_\_\| By vicentefelipechile
] ],
COLOR_WHITE, "===================================================================================\n")
--]]

--[[------------------------
        Load Modules
------------------------]]--

local function AddFile(luafile)
    if SERVER then
        AddCSLuaFile(luafile)
    end
    include(luafile)

    MsgC( COLOR_WHITE, "[", COLOR_CYAN, "OpenAI", COLOR_WHITE, "] ", SERVER and COLOR_SERVER or COLOR_CLIENT, "Added Module: ", string.GetFileFromFilename(luafile), "\n")
end

local function AddDir(dir)
    dir = dir .. "/"

    local files, directories = file.Find(dir .. "*", "LUA")
    for _, v in ipairs(files) do
        if string.GetExtensionFromFilename(v) == "lua" then
            AddFile(dir .. v)
        end
    end

    for _, v in ipairs(directories) do AddDir(dir .. v) end
end

AddDir("openai/modules")