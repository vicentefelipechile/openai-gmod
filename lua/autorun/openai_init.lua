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
    include("openai/shared.lua")
    include("openai/cl_init.lua")
end

MsgC(COLOR_WHITE, [[
===================================================================================
     ________ ______  ______ __   __      ________ __
    |   __   |   __ \|   ___|  \ |  |\   |   __   |  |\
    |  |  |  |  |__) |  |___|   \|  | |  |  |__|  |  | |
    |  |  |  |  ____/|   ___|       | |  |   __   |  | |
    |  |__|  |  |  __|  |___|  |\   | |  |  | \|  |  | |
    |________|__| |  |______|__| \__| |  |__| ||__|__| |
     \________\__\|   \______\__|\___\|   \__\. \__\__\| By vicentefelipechile
===================================================================================
]], "\n")


--[[------------------------
        Load Modules
------------------------]]--

local function AddFile(luafile)
    if SERVER then
        AddCSLuaFile(luafile)
    end
    include(luafile)

    MsgC( COLOR_WHITE, "[", COLOR_CYAN, "OpenAI", COLOR_WHITE, "] ", COLOR_SERVER, "Added Module: ", string.GetFileFromFilename(luafile), "\n")
end

local function AddDir(dir)
    dir = dir .. "/"

    local files, directories = file.Find(dir .. "*", "LUA")
    for _, v in ipairs(files) do
        if string.GetExtensionFromFilename(v) == "lua" then
            AddFile(v .. dir)
        end
    end

    for _, v in ipairs(directories) do AddDir(dir .. v) end
end