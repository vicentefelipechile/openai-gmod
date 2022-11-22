openai = openai or {}
openai.Access = openai.Access or {}

if ULib then
    ULib.ucl.registerAccess("OpenAI", {"user", "admin", "superadmin"}, "Permite el acceso al OpenAI", "OpenAI")
end