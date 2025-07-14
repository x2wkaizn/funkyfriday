-- 👑 Made by Lê Huyền Huy
-- Ultimate Auto Play Funky Friday – Auto Detect Everything

local vim = game:GetService("VirtualInputManager")
local runService = game:GetService("RunService")
local plr = game.Players.LocalPlayer

-- UI
loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/UiLib/main/KavoUiLib.lua"))()
local ui = Library:CreateLib("🎵 Funky Auto | Detect Mode", "Ocean")
local main = ui:NewTab("Auto")
local sec = main:NewSection("Chế độ")

-- Biến
local autoPlay = false
local threshold = 10
local keybinds = {}
local currentRate = "1.0x"
local keyCount = "4K"

-- Toggle
sec:NewToggle("Bật Auto Play", "Tự động chơi note", function(v)
    autoPlay = v
end)

-- Độ nhạy
sec:NewSlider("Độ nhạy", "Sai số phát hiện arrow", 25, 10, function(v)
    threshold = v
end)

-- Detect keybind
local function detectKeybinds()
    local settings = require(game.ReplicatedStorage.RobeatsGameCore.Config.KeybindSettings)
    for k,v in pairs(settings.Settings.Keybinds) do
        keybinds[k] = v.Name
    end
end

-- Detect Rate & KeyCount
local function detectRateAndKeys()
    local ui = plr:WaitForChild("PlayerGui"):WaitForChild("Main"):FindFirstChild("SongRate")
    if ui then
        currentRate = ui.Text:match("%d+%.?%d*").."x"
    end

    local gameUI = plr.PlayerGui.Main:FindFirstChild("Game")
    if gameUI then
        local ng = gameUI:FindFirstChild("NoteGui") or gameUI:FindFirstChild("ArrowGui")
        if ng then
            local count = 0
            for _,v in pairs(ng:GetChildren()) do
                if v:IsA("Frame") then count += 1 end
            end
            keyCount = tostring(count).."K"
        end
    end
end

-- Noti
task.delay(2, function()
    detectKeybinds()
    detectRateAndKeys()
    sec:NewLabel("/discord")
    sec:NewLabel("🎵 Song Rate: "..currentRate)
    sec:NewLabel("🎹 Keys: "..keyCount)
end)

-- Nhấn phím
local function pressKey(k)
    vim:SendKeyEvent(true, k, false, game)
    task.wait(0.008)
    vim:SendKeyEvent(false, k, false, game)
end

-- Lấy GUI note
local function getNoteFrame()
    local gui = plr:FindFirstChild("PlayerGui")
    local main = gui and gui:FindFirstChild("Main")
    local gameUI = main and main:FindFirstChild("Game")
    return gameUI and (gameUI:FindFirstChild("NoteGui") or gameUI:FindFirstChild("ArrowGui"))
end

-- Auto Play
runService.RenderStepped:Connect(function()
    if not autoPlay then return end
    local frame = getNoteFrame()
    if not frame then return end

    for _, arrow in pairs(frame:GetDescendants()) do
        if arrow:IsA("ImageLabel") and arrow.Visible and arrow.Name:find("Arrow") then
            local posY = arrow.AbsolutePosition.Y
            local goalY = frame.AbsolutePosition.Y + 10

            if math.abs(posY - goalY) <= threshold then
                local dir = arrow.Name:match("Arrow(.+)")
                local key = keybinds[dir]
                if key then
                    pressKey(key)
                end
            end
        end
    end
end)
