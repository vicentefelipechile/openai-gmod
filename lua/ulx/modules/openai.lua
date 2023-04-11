OpenAI = OpenAI or {}
OpenAI.Access = OpenAI.Access or {}

if ULib then
    ULib.ucl.registerAccess("OpenAI.chat", {"superadmin", "admin"}, "Allows players to use OpenAI Chat module", "OpenAI")
    ULib.ucl.registerAccess("OpenAI.image", {"superadmin", "admin"}, "Allows players to use OpenAI Dalle module", "OpenAI")
end