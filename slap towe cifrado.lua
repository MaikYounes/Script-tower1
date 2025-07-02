--// Mejora del GUI para FreeSlap con diseño compacto, más funciones y anti-colisión + control de sonido

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function setupCharacter(Character)
	local Tool = Character:WaitForChild("FreeSlap", 5)
	if not Tool then return end

	local Handle = Tool:WaitForChild("Handle", 5)
	local Power = Tool:FindFirstChild("Power")
	local Speed = Tool:FindFirstChild("Speed")
	local Smack = Handle:FindFirstChild("Smack") -- el sonido
	local event = Tool:FindFirstChild("Event")

	Handle.CanCollide = false
	Handle.Massless = true

	Handle.Touched:Connect(function(hit)
		local char = hit:FindFirstAncestorOfClass("Model")
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		local player = char and Players:GetPlayerFromCharacter(char)
		if humanoid and player and player ~= LocalPlayer and event and Power then
			local dir = Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * Power.Value
			event:FireServer("slash", char, dir)
		end
	end)

	local function makeHitboxPart()
		local hb = Instance.new("SelectionBox")
		hb.Adornee = Handle
		hb.Parent = Handle
		hb.LineThickness = 0.08
		hb.Color3 = Color3.fromRGB(255, 100, 100)
		return hb
	end
	makeHitboxPart()

	local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
	local oldGui = PlayerGui:FindFirstChild("HitboxControl")
	if oldGui then oldGui:Destroy() end

	local Gui = Instance.new("ScreenGui", PlayerGui)
	Gui.Name = "HitboxControl"
	Gui.ResetOnSpawn = false

	local Frame = Instance.new("Frame", Gui)
	Frame.Size = UDim2.new(0, 250, 0, 255)
	Frame.Position = UDim2.new(1, -260, 0.4, 0)
	Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Frame.BorderSizePixel = 0
	Frame.Active = true
	Frame.Draggable = true
	Frame.Visible = true

	local toggleBtn = Instance.new("TextButton", Gui)
	toggleBtn.Text = "⚙ GUI"
	toggleBtn.Size = UDim2.new(0, 50, 0, 30)
	toggleBtn.Position = UDim2.new(1, -60, 0.35, 0)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	toggleBtn.TextColor3 = Color3.new(1, 1, 1)
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextScaled = true

	toggleBtn.MouseButton1Click:Connect(function()
		Frame.Visible = not Frame.Visible
	end)

	local function showNotification(text)
		local notif = Instance.new("TextLabel", Gui)
		notif.Size = UDim2.new(0, 250, 0, 40)
		notif.Position = UDim2.new(0.5, -125, 0.5, -20)
		notif.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		notif.TextColor3 = Color3.new(1, 1, 1)
		notif.Font = Enum.Font.GothamBold
		notif.TextScaled = true
		notif.Text = text
		notif.BackgroundTransparency = 0.3
		notif.ZIndex = 10
		game:GetService("Debris"):AddItem(notif, 2)
	end

	local function createButton(text, y, color, callback)
		local btn = Instance.new("TextButton", Frame)
		btn.Text = text
		btn.Size = UDim2.new(0.9, 0, 0, 30)
		btn.Position = UDim2.new(0.05, 0, 0, y)
		btn.BackgroundColor3 = color
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.GothamBold
		btn.TextScaled = true
		btn.MouseButton1Click:Connect(callback)
	end

	local function createInput(labelText, prop, y)
		local lbl = Instance.new("TextLabel", Frame)
		lbl.Text = labelText
		lbl.Size = UDim2.new(0.5, 0, 0, 25)
		lbl.Position = UDim2.new(0.05, 0, 0, y)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.Font = Enum.Font.Gotham
		lbl.TextScaled = true

		local box = Instance.new("TextBox", Frame)
		box.Size = UDim2.new(0.25, 0, 0, 25)
		box.Position = UDim2.new(0.55, 0, 0, y)
		box.PlaceholderText = tostring(prop and prop.Value or "0")
		box.Text = ""

		local apply = Instance.new("TextButton", Frame)
		apply.Text = "✔"
		apply.Size = UDim2.new(0.15, 0, 0, 25)
		apply.Position = UDim2.new(0.82, 0, 0, y)
		apply.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
		apply.TextColor3 = Color3.new(1, 1, 1)
		apply.Font = Enum.Font.GothamBold
		apply.TextScaled = true
		apply.MouseButton1Click:Connect(function()
			local val = tonumber(box.Text)
			if val and prop then
				prop.Value = val
				showNotification(labelText .. " a " .. val)
			else
				showNotification("Valor inválido")
			end
		end)
	end

	createButton("🔺 Agrandar Hitbox", 5, Color3.fromRGB(0,200,100), function()
		Handle.Size = Handle.Size * 1.5
		Handle.CanCollide = false
	end)

	createButton("🔻 Achicar Hitbox", 40, Color3.fromRGB(200,100,100), function()
		Handle.Size = Handle.Size * 0.7
		Handle.CanCollide = false
	end)

	createButton("✨ Transparente + No colisión", 75, Color3.fromRGB(100,100,200), function()
		Handle.Transparency = 0.5
		Handle.CanCollide = false
		showNotification("Handle transparente + sin colisión")
	end)

	createButton("🔇 Alternar sonido 'Smack'", 110, Color3.fromRGB(180, 120, 255), function()
		if Smack then
			Smack.Playing = false
			Smack.Volume = Smack.Volume == 0 and 1 or 0
			showNotification("Sonido 'Smack': " .. (Smack.Volume == 0 and "Desactivado" or "Activado"))
		else
			showNotification("Sonido 'Smack' no encontrado")
		end
	end)

	createInput("Fuerza:", Power, 150)
	createInput("Velocidad:", Speed, 185)
end

LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(1)
	setupCharacter(char)
end)

if LocalPlayer.Character then
	setupCharacter(LocalPlayer.Character)
end
