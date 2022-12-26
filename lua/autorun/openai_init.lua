if SERVER then
    include("openai/sh_openai.lua")
    include("openai/sv_openai.lua")
    AddCSLuaFile("openai/cl_openai.lua")
    AddCSLuaFile("openai/sh_openai.lua")
else
    include("openai/cl_openai.lua")
    include("openai/sh_openai.lua")
end