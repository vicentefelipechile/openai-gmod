if SERVER then
    AddCSLuaFile("openai/sh_openai.lua")
    AddCSLuaFile("openai/cl_openai.lua")
    include("openai/sh_openai.lua")
    include("openai/sv_openai.lua")

    openai.print("Loaded: openai/sh_openai.lua")
    openai.print("Loaded: openai/sv_openai.lua")
else
    include("openai/sh_openai.lua")
    include("openai/cl_openai.lua")

    openai.print("Loaded: openai/sh_openai.lua")
    openai.print("Loaded: openai/cl_openai.lua")
end