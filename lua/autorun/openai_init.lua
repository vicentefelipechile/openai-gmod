OpenAI = OpenAI or {}

if SERVER then
    AddCSLuaFile("openai/shared.lua")
    AddCSLuaFile("openai/cl_init.lua")
    include("openai/shared.lua")
    include("openai/init.lua")
else
    include("openai/shared.lua")
    include("openai/cl_init.lua")
end