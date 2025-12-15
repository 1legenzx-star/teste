-- Menu de Testes (refatorado + Auto Reset)
-- PC + Celular
-- Click TP, Infinite Jump, Fling, TP Aleatório, Auto Reset, Rejoin

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()

-- ======================
-- ESTADOS
-- ======================

local clickTP = false
local infiniteJump = false
local infiniteFling = false
local autoReset = false

local VIDA_MINIMA = 10
local FORCA_FLING = 50000
local FLING_INTERVAL = 0.12
local randomTpDebounce = false

-- ======================
-- ATUALIZA CHARACTER
-- ======================

local humanoid

local function updateCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
end

updateCharacter(character)
player.CharacterAdded:Connect(updateCharacter)

-- ======================
-- GUI
-- ======================

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 230, 0, 300)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(255,170,190)
frame.BorderSizePixel = 0
frame.Active = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Menu do bibi <3"
title.BackgroundColor3 = Color3.fromRGB(255,140,170)
title.TextColor3 = Color3.new(0,0,0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Active = true

-- FECHAR
local closeBtn = Instance.new("TextButton", title)
closeBtn.Size = UDim2.new(0,30,1,0)
closeBtn.Position = UDim2.new(1,-30,0,0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- MINIMIZAR
local minimizeBtn = Instance.new("TextButton", title)
minimizeBtn.Size = UDim2.new(0,30,1,0)
minimizeBtn.Position = UDim2.new(1,-60,0,0)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50,180,50)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 18

local function makeButton(text, y, color)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1,-20,0,34)
	b.Position = UDim2.new(0,10,0,y)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 16
	return b
end

local btnColor = Color3.fromRGB(255,110,150)

local tpButton       = makeButton("Ativar Click TP", 40, btnColor)
local jumpButton     = makeButton("Ativar Infinite Jump", 80, btnColor)
local flingButton    = makeButton("Ativar Fling Players", 120, btnColor)
local randomTPBtn    = makeButton("TP Aleatório", 160, Color3.fromRGB(230,90,130))
local autoResetBtn   = makeButton("Auto Reset (OFF)", 200, Color3.fromRGB(180,60,60))
local rejoinButton   = makeButton("Rejoin (sair e entrar)", 240, Color3.fromRGB(200,80,120))

local buttons = {tpButton, jumpButton, flingButton, randomTPBtn, autoResetBtn, rejoinButton}

-- ======================
-- CLICK TP (PC + MOBILE)
-- ======================

local function getTouchWorldPosition(screenPos)
	local cam = Workspace.CurrentCamera
	local ray = cam:ScreenPointToRay(screenPos.X, screenPos.Y)
	local result = Workspace:Raycast(ray.Origin, ray.Direction * 5000)
	return result and result.Position
end

local function teleportTo(pos)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
	end
end

mouse.Button1Down:Connect(function()
	if clickTP and mouse.Hit then
		teleportTo(mouse.Hit.Position)
	end
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp or not clickTP then return end
	if input.UserInputType == Enum.UserInputType.Touch then
		local pos = getTouchWorldPosition(input.Position)
		if pos then teleportTo(pos) end
	end
end)

tpButton.MouseButton1Click:Connect(function()
	clickTP = not clickTP
	tpButton.Text = clickTP and "Desativar Click TP" or "Ativar Click TP"
end)

-- ======================
-- INFINITE JUMP
-- ======================

UserInputService.JumpRequest:Connect(function()
	if infiniteJump and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

jumpButton.MouseButton1Click:Connect(function()
	infiniteJump = not infiniteJump
	jumpButton.Text = infiniteJump and "Desativar Infinite Jump" or "Ativar Infinite Jump"
end)

-- ======================
-- FLING PLAYERS
-- ======================

local acc = 0

RunService.Heartbeat:Connect(function(dt)
	-- FLING
	if infiniteFling then
		acc += dt
		if acc >= FLING_INTERVAL then
			acc = 0
			local myHrp = character:FindFirstChild("HumanoidRootPart")
			if myHrp then
				for _, plr in pairs(Players:GetPlayers()) do
					if plr ~= player and plr.Character then
						local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
						if hrp and (hrp.Position - myHrp.Position).Magnitude <= 6 then
							hrp.AssemblyLinearVelocity =
								(hrp.Position - myHrp.Position).Unit * FORCA_FLING
						end
					end
				end
			end
		end
	end

	-- AUTO RESET
	if autoReset and humanoid and humanoid.Health > 0 and humanoid.Health <= VIDA_MINIMA then
		humanoid.Health = 0
	end
end)

flingButton.MouseButton1Click:Connect(function()
	infiniteFling = not infiniteFling
	flingButton.Text = infiniteFling and "Desativar Fling Players" or "Ativar Fling Players"
end)

-- ======================
-- TP ALEATÓRIO
-- ======================

randomTPBtn.MouseButton1Click:Connect(function()
	if randomTpDebounce then return end
	randomTpDebounce = true
	task.delay(0.8, function() randomTpDebounce = false end)

	local list = Players:GetPlayers()
	if #list <= 1 then return end

	local target
	repeat target = list[math.random(#list)] until target ~= player

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.Anchored = true
		task.wait(0.15)
		hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
		task.wait(0.1)
		hrp.Anchored = false
	end
end)

-- ======================
-- AUTO RESET BOTÃO
-- ======================

autoResetBtn.MouseButton1Click:Connect(function()
	autoReset = not autoReset
	autoResetBtn.Text = autoReset and "Auto Reset (ON)" or "Auto Reset (OFF)"
end)

-- ======================
-- REJOIN
-- ======================

rejoinButton.MouseButton1Click:Connect(function()
	TeleportService:Teleport(game.PlaceId, player)
end)

-- ======================
-- MINIMIZAR
-- ======================

local minimized = false

minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	for _, b in pairs(buttons) do
		b.Visible = not minimized
	end
	frame.Size = minimized and UDim2.new(0,230,0,30) or UDim2.new(0,230,0,300)
end)

-- ======================
-- ARRASTAR (PC + MOBILE)
-- ======================

local dragging, dragStart, startPos

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

title.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)
