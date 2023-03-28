-- Client-side

local PANEL = {}

function PANEL:Init()

    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)

    -- Panel de fondo
    self.background = vgui.Create("DPanel", self)
    self.background:SetSize(ScrW(), ScrH())
    self.background:SetBackgroundColor(Color(0, 0, 0, 200))

    -- Panel de historial de chats
    self.chatHistory = vgui.Create("DListView", self.background)
    self.chatHistory:SetPos(10, ScrH() * 0.1)
    self.chatHistory:SetSize(ScrW() * 0.25, ScrH() * 0.8)
    self.chatHistory:SetMultiSelect(false)
    self.chatHistory:AddColumn("Fecha")

    local fileExists = false

    -- Mostrar lista de archivos en la carpeta de chats
    for k, v in pairs(file.Find("openai_chats/*.json", "DATA")) do
        local fileName = string.gsub(v, ".json", "")
        local fileDate = os.date("%Y-%m-%d %H:%M:%S", fileName)
        self.chatHistory:AddLine(fileDate)
        fileExists = true
    end

    if not fileExists then
        self.chatHistory:AddLine("No tienes conversaciones pasadas.")
    end

    -- Boton para iniciar nueva conversacion
    self.newChatButton = vgui.Create("DButton", self.background)
    self.newChatButton:SetText("+ Iniciar nueva conversación")
    self.newChatButton:SetSize(ScrW() * 0.25, 50)
    self.newChatButton:SetPos(10, 10)
end

vgui.Register("openai_chat_interface", PANEL)