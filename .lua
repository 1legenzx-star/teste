-- Menu Mini Ajustado sem Click TP - Botões Centralizados com nomes atualizados
-- PC + Celular

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local task = task

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- CONFIG FLING
local TARGET_CFRAME = CFrame.new(-928327.25, 9555375.88, 280584.09)
local DISTANCIA_MAX = 6
local VIDA_MINIMA = 10

-- ESTADOS
local infiniteJump, infiniteFling, autoTPReset, randomTpDebounce, jaExecutou, debounceTPReset = false,false,false,false,false,false

-- ATUALIZA CHARACTER
local humanoid
local function updateCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
end
updateCharacter(character)
player.CharacterAdded:Connect(updateCharacter)

-- DETECTA ABRAÇO
local function estaAbracando(meuChar, alvoChar)
	for _, obj in ipairs(meuChar:GetDescendants()) do
		if obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("Motor6D") then
			if obj.Part0 and obj.Part1 then
				if obj.Part0:IsDescendantOf(alvoChar) or obj.Part1:IsDescendantOf(alvoChar) then
					return true
				end
			end
		end
	end
	return false
end

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 100

-- Frame principal com título
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 140, 0, 35)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(255,140,170)
frame.BorderSizePixel = 0

-- Título
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,1,0)
title.Text = "Menu bibi <3"
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.new(0,0,0)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center

-- Menu oculto
local menu = Instance.new("Frame", gui)
menu.Size = UDim2.new(0,140,0,140)
menu.Position = frame.Position + UDim2.new(0,0,0,35)
menu.BackgroundColor3 = Color3.fromRGB(255,170,190)
menu.BorderSizePixel = 0
menu.Visible = false

-- Função de botão ajustado
local function makeButton(text, y, color)
	local b = Instance.new("TextButton", menu)
	b.Size = UDim2.new(1,-10,0,22)
	b.Position = UDim2.new(0,5,0,y)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 12
	return b
end

-- Lista de botões com nomes atualizados
local buttonNames = {
	{"Inf Jump", Color3.fromRGB(255,110,150)},
	{"Fling", Color3.fromRGB(255,110,150)},
	{"Teleport", Color3.fromRGB(230,90,130)},
	{"AutoReset", Color3.fromRGB(180,60,60)},
	{"Rejoin", Color3.fromRGB(200,80,120)}
}

local buttons = {}
local buttonHeight = 22
local spacing = 5
local totalHeight = #buttonNames * buttonHeight + (#buttonNames-1) * spacing
local startY = (menu.Size.Y.Offset - totalHeight)/2

for i, info in ipairs(buttonNames) do
	local yPos = startY + (i-1)*(buttonHeight + spacing)
	local b = makeButton(info[1], yPos, info[2])
	table.insert(buttons, b)
end

-- Alterna menu ao tocar na aba
frame.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
		menu.Visible = not menu.Visible
	end
end)

-- ====================== INFINITE JUMP ======================
UserInputService.JumpRequest:Connect(function()
	if infiniteJump and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

buttons[1].MouseButton1Click:Connect(function() -- Inf Jump
	infiniteJump = not infiniteJump
	buttons[1].BackgroundColor3 = infiniteJump and Color3.fromRGB(60,180,80) or Color3.fromRGB(255,110,150)
end)

-- ====================== FLING ======================
RunService.Heartbeat:Connect(function()
	if not infiniteFling then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local alvo
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr~=player and plr.Character then
			local h=plr.Character:FindFirstChild("HumanoidRootPart")
			if h and (h.Position-hrp.Position).Magnitude<=DISTANCIA_MAX then alvo=h break end
		end
	end
	if not alvo then jaExecutou=false return end
	if not estaAbracando(character,alvo.Parent) then jaExecutou=false return end
	if jaExecutou then return end
	jaExecutou=true
	hrp.CFrame = alvo.CFrame*CFrame.new(0,0,-0.5)
	task.wait(0.05)
	hrp.CFrame = TARGET_CFRAME
	hrp.AssemblyLinearVelocity=Vector3.zero
end)

buttons[2].MouseButton1Click:Connect(function() -- Fling
	infiniteFling = not infiniteFling
	buttons[2].BackgroundColor3 = infiniteFling and Color3.fromRGB(60,180,80) or Color3.fromRGB(255,110,150)
end)

-- ====================== TELEPORT ======================
buttons[3].MouseButton1Click:Connect(function()
	if randomTpDebounce then return end
	randomTpDebounce=true
	task.delay(0.8,function() randomTpDebounce=false end)
	local list=Players:GetPlayers()
	if #list<=1 then return end
	local target
	repeat target=list[math.random(#list)] until target~=player
	local hrp=character:FindFirstChild("HumanoidRootPart")
	if hrp and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		hrp.AssemblyLinearVelocity=Vector3.zero
		hrp.Anchored=true
		task.wait(0.15)
		hrp.CFrame=target.Character.HumanoidRootPart.CFrame*CFrame.new(0,0,-3)
		task.wait(0.1)
		hrp.Anchored=false
	end
end)

-- ====================== AUTO RESET ======================
local SAFE_POS=Vector3.new(-87.28,859.34,110.26)
buttons[4].MouseButton1Click:Connect(function()
	autoTPReset=not autoTPReset
	buttons[4].BackgroundColor3=autoTPReset and Color3.fromRGB(60,180,80) or Color3.fromRGB(180,60,60)
end)
RunService.Heartbeat:Connect(function()
	if not autoTPReset then return end
	if not humanoid or humanoid.Health<=0 then return end
	if debounceTPReset then return end
	if humanoid.Health<=VIDA_MINIMA then
		debounceTPReset=true
		local hrp=character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame=CFrame.new(SAFE_POS); hrp.AssemblyLinearVelocity=Vector3.zero end
		task.delay(0.9,function()
			if humanoid and humanoid.Health>0 then humanoid.Health=0 end
			debounceTPReset=false
		end)
	end
end)

-- ====================== REJOIN ======================
buttons[5].MouseButton1Click:Connect(function()
	TeleportService:Teleport(game.PlaceId, player)
end)

-- ====================== ARRASTAR FRAME ======================
local dragging=false
local dragStart=Vector2.new()
local startPos=UDim2.new()
local inputType=nil

frame.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
		dragging=true
		dragStart=input.Position
		startPos=frame.Position
		inputType=input
		input.Changed:Connect(function()
			if input.UserInputState==Enum.UserInputState.End then dragging=false end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input==inputType then
		local delta=input.Position-dragStart
		frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
		menu.Position=frame.Position+UDim2.new(0,0,0,35)
	end
end)

UserInputService.TouchMoved:Connect(function(input)
	if dragging and input==inputType then
		local delta=input.Position-dragStart
		frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
		menu.Position=frame.Position+UDim2.new(0,0,0,35)
	end
end)
