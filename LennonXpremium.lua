--[[
  LennonXpremium - Panel Premium (botones visibles)
  - Título + avatar circular
  - Input grande de key
  - Fila de botones: Get Key / Submit (o apilados en móviles)
  - Borde rainbow sutil animado
  - Toasts y validación de key
--]]

-------------------- Config --------------------
local COPY_LINK = "https://zamasxmodder.github.io/SigmaStrawberryKey/"
local TITLE = "LennonXpremium"
local MIN_KEY_LEN = 6

-------------------- Services --------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-------------------- Utils --------------------
local function safeClipboard(s)
	if typeof(setclipboard) == "function" then
		local ok = pcall(setclipboard, s); if ok then return true end
	end
	if syn and typeof(syn.set_clipboard) == "function" then
		local ok = pcall(syn.set_clipboard, s); if ok then return true end
	end
	return false
end

local function isValidKey(s)
	return (type(s) == "string") and (#s >= MIN_KEY_LEN)
end

local RAINBOW = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 120, 120)),
	ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 190, 120)),
	ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 255, 140)),
	ColorSequenceKeypoint.new(0.60, Color3.fromRGB(120, 255, 180)),
	ColorSequenceKeypoint.new(0.80, Color3.fromRGB(130, 180, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(200, 140, 255)),
})

local function animateRainbow(uiGradient, period)
	period = period or 10
	task.spawn(function()
		while uiGradient.Parent do
			uiGradient.Rotation = 0
			local tw = TweenService:Create(uiGradient, TweenInfo.new(period, Enum.EasingStyle.Linear), {Rotation = 360})
			tw:Play(); tw.Completed:Wait()
		end
	end)
end

-- Toast apilable
local function makeToastHost(parent)
	local host = Instance.new("Frame")
	host.Name = "ToastHost"
	host.Parent = parent
	host.BackgroundTransparency = 1
	host.AnchorPoint = Vector2.new(0.5, 0)
	host.Position = UDim2.fromScale(0.5, 0.03)
	host.Size = UDim2.fromScale(1, 0)
	host.ZIndex = 2000

	local list = Instance.new("UIListLayout", host)
	list.FillDirection = Enum.FillDirection.Vertical
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.Padding = UDim.new(0, 6)

	local function push(msg, dur)
		dur = dur or 2.2
		local frame = Instance.new("Frame")
		frame.Parent = host
		frame.Size = UDim2.fromOffset(math.floor(parent.AbsoluteSize.X*0.86), 40)
		frame.BackgroundColor3 = Color3.fromRGB(22,22,26)
		frame.BorderSizePixel = 0
		frame.ClipsDescendants = true
		frame.ZIndex = 2001
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

		local border = Instance.new("Frame", frame)
		border.Size = UDim2.fromScale(1,1)
		border.BackgroundTransparency = 1
		local stroke = Instance.new("UIStroke", border)
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		local g = Instance.new("UIGradient", stroke)
		g.Color = RAINBOW; g.Rotation = 0
		animateRainbow(g, 12)

		local lbl = Instance.new("TextLabel", frame)
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.fromScale(1,1)
		lbl.Font = Enum.Font.GothamSemibold
		lbl.TextScaled = true
		lbl.TextColor3 = Color3.fromRGB(255,255,255)
		lbl.Text = msg
		lbl.ZIndex = 2002

		frame.Size = UDim2.fromOffset(frame.AbsoluteSize.X, 1)
		TweenService:Create(frame, TweenInfo.new(0.18), {Size = UDim2.fromOffset(frame.AbsoluteSize.X, 40)}):Play()
		task.delay(dur, function()
			local tw = TweenService:Create(frame, TweenInfo.new(0.18), {Size = UDim2.fromOffset(frame.AbsoluteSize.X, 1)})
			tw:Play(); tw.Completed:Connect(function() frame:Destroy() end)
		end)
	end

	host:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		for _,c in ipairs(host:GetChildren()) do
			if c:IsA("Frame") then
				c.Size = UDim2.fromOffset(math.floor(parent.AbsoluteSize.X*0.86), c.AbsoluteSize.Y)
			end
		end
	end)

	return {push = push}
end

-- Envoltorio con borde rainbow
local function gradientBorderWrap(parent, cornerRadius, thickness)
	thickness = thickness or 2
	local wrap = Instance.new("Frame")
	wrap.Parent = parent
	wrap.BackgroundColor3 = Color3.fromRGB(10,10,14)
	wrap.BorderSizePixel = 0

	local wrapCorner = Instance.new("UICorner", wrap)
	wrapCorner.CornerRadius = UDim.new(0, cornerRadius)

	local border = Instance.new("Frame", wrap)
	border.Size = UDim2.fromScale(1,1)
	border.BackgroundColor3 = Color3.fromRGB(255,255,255)
	border.BorderSizePixel = 0
	local borderCorner = Instance.new("UICorner", border)
	borderCorner.CornerRadius = UDim.new(0, cornerRadius)

	local grad = Instance.new("UIGradient", border)
	grad.Color = RAINBOW
	grad.Rotation = 0
	animateRainbow(grad, 14)

	local inner = Instance.new("Frame", wrap)
	inner.BackgroundColor3 = Color3.fromRGB(22,22,28)
	inner.BorderSizePixel = 0
	inner.Position = UDim2.fromOffset(thickness, thickness)
	inner.Size = UDim2.new(1, -thickness*2, 1, -thickness*2)
	local innerCorner = Instance.new("UICorner", inner)
	innerCorner.CornerRadius = UDim.new(0, math.max(0, cornerRadius-1))

	return wrap, inner
end

-------------------- GUI root --------------------
local screen = Instance.new("ScreenGui")
screen.Name = "LennonXpremium_FixedButtons"
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Parent = playerGui

local toasts = makeToastHost(screen)

-- Fondo
local backdrop = Instance.new("Frame", screen)
backdrop.Size = UDim2.fromScale(1,1)
backdrop.BackgroundColor3 = Color3.fromRGB(10,10,14)
local bgGrad = Instance.new("UIGradient", backdrop)
bgGrad.Rotation = 35
bgGrad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(12,10,24)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(8,10,18)),
}

-- Card principal
local cardWrap, card = gradientBorderWrap(screen, 16, 2)
cardWrap.AnchorPoint = Vector2.new(0.5, 0.5)
cardWrap.Position = UDim2.fromScale(0.5, 0.5)
cardWrap.Size = UDim2.fromScale(0.64, 0.52)
local minC = Instance.new("UISizeConstraint", cardWrap)
minC.MinSize = Vector2.new(560, 360)
local maxC = Instance.new("UISizeConstraint", cardWrap)
maxC.MaxSize = Vector2.new(980, 600)

-- Animación entrada
cardWrap.Position = UDim2.fromScale(0.5, 1.2)
TweenService:Create(cardWrap, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.fromScale(0.5,0.5)}):Play()

-- Layout vertical
local pad = Instance.new("UIPadding", card)
pad.PaddingTop = UDim.new(0, 16)
pad.PaddingBottom = UDim.new(0, 16)
pad.PaddingLeft = UDim.new(0, 16)
pad.PaddingRight = UDim.new(0, 16)

local vlist = Instance.new("UIListLayout", card)
vlist.FillDirection = Enum.FillDirection.Vertical
vlist.SortOrder = Enum.SortOrder.LayoutOrder
vlist.Padding = UDim.new(0, 16)

-------------------- Header --------------------
local header = Instance.new("Frame", card)
header.BackgroundTransparency = 1
header.Size = UDim2.new(1,0,0,84)
header.LayoutOrder = 1

local hlist = Instance.new("UIListLayout", header)
hlist.FillDirection = Enum.FillDirection.Horizontal
hlist.VerticalAlignment = Enum.VerticalAlignment.Center
hlist.Padding = UDim.new(0, 14)

local avHolder = Instance.new("Frame", header)
avHolder.BackgroundTransparency = 1
avHolder.Size = UDim2.fromOffset(72,72)

local ringWrap, ringInner = gradientBorderWrap(avHolder, 36, 2)
ringWrap.Size = UDim2.fromScale(1,1)
ringInner.BackgroundColor3 = Color3.fromRGB(18,18,24)

local avatar = Instance.new("ImageLabel", ringInner)
avatar.BackgroundTransparency = 1
avatar.Size = UDim2.fromScale(1,1)
avatar.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1,0)

task.spawn(function()
	for i=1,12 do
		local ok, url, ready = pcall(function()
			local content, isReady = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180)
			return content, isReady
		end)
		if ok and ready and url then
			avatar.Image = url
			return
		end
		task.wait(0.2)
	end
	avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
end)

local titleWrap = Instance.new("Frame", header)
titleWrap.BackgroundTransparency = 1
titleWrap.Size = UDim2.new(1, -86, 1, 0)

local titleLbl = Instance.new("TextLabel", titleWrap)
titleLbl.BackgroundTransparency = 1
titleLbl.Text = TITLE
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextScaled = true
titleLbl.TextColor3 = Color3.fromRGB(255,230,180)
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.Size = UDim2.fromScale(1, 0.6)
titleLbl.Position = UDim2.fromScale(0,0)

local subLbl = Instance.new("TextLabel", titleWrap)
subLbl.BackgroundTransparency = 1
subLbl.Text = "Premium Access"
subLbl.Font = Enum.Font.Gotham
subLbl.TextScaled = true
subLbl.TextColor3 = Color3.fromRGB(190,190,210)
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.Size = UDim2.fromScale(1, 0.36)
subLbl.Position = UDim2.fromScale(0,0.62)

-------------------- Body --------------------
local body = Instance.new("Frame", card)
body.BackgroundTransparency = 1
body.Size = UDim2.new(1,0,1,-(84+80+16)) -- header + buttons + padding
body.LayoutOrder = 2

local blist = Instance.new("UIListLayout", body)
blist.FillDirection = Enum.FillDirection.Vertical
blist.Padding = UDim.new(0, 12)

-- Input key
local keyWrap, keyInner = gradientBorderWrap(body, 12, 2)
keyWrap.Size = UDim2.new(1,0,0,64)

local keyBox = Instance.new("TextBox", keyInner)
keyBox.BackgroundTransparency = 1
keyBox.Size = UDim2.fromScale(1,1)
keyBox.ClearTextOnFocus = false
keyBox.PlaceholderText = "Enter your key here"
keyBox.Text = ""
keyBox.Font = Enum.Font.GothamSemibold
keyBox.TextScaled = true
keyBox.TextColor3 = Color3.fromRGB(235,235,245)
keyBox.PlaceholderColor3 = Color3.fromRGB(160,160,180)

-- Hint
local hint = Instance.new("TextLabel", body)
hint.BackgroundTransparency = 1
hint.Text = "Press Ctrl+K to Get Key · Press Enter to Submit"
hint.Font = Enum.Font.Gotham
hint.TextScaled = true
hint.TextColor3 = Color3.fromRGB(175,175,195)
hint.Size = UDim2.new(1,0,0,24)

-------------------- Buttons Row (¡AQUÍ ESTÁN!) --------------------
local buttonsRow = Instance.new("Frame", card)
buttonsRow.BackgroundTransparency = 1
buttonsRow.Size = UDim2.new(1,0,0,80)
buttonsRow.LayoutOrder = 3
buttonsRow.ZIndex = 50

local rowList = Instance.new("UIListLayout", buttonsRow)
rowList.FillDirection = Enum.FillDirection.Horizontal
rowList.Padding = UDim.new(0, 14)
rowList.HorizontalAlignment = Enum.HorizontalAlignment.Center
rowList.VerticalAlignment = Enum.VerticalAlignment.Center

-- Factores responsive
local function makeButton(parent, text)
	local wrap, inner = gradientBorderWrap(parent, 12, 2)
	wrap.BackgroundTransparency = 0 -- visible
	inner.BackgroundColor3 = Color3.fromRGB(34,34,44)

	local btn = Instance.new("TextButton", inner)
	btn.Size = UDim2.fromScale(1,1)
	btn.BackgroundTransparency = 1
	btn.Text = text
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(255,255,255)

	-- Hover micro-glow
	local glow = Instance.new("UIStroke", inner)
	glow.Thickness = 0.6
	glow.Color = Color3.fromRGB(255,255,255)
	glow.Transparency = 0.85

	btn.MouseEnter:Connect(function()
		TweenService:Create(glow, TweenInfo.new(0.12), {Transparency = 0.6}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(glow, TweenInfo.new(0.12), {Transparency = 0.85}):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		inner.BackgroundColor3 = Color3.fromRGB(40,40,52)
		TweenService:Create(inner, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(34,34,44)}):Play()
	end)

	return wrap, inner, btn
end

local getKeyWrap, _, getKeyBtn = makeButton(buttonsRow, "Get Key")
local submitWrap, _, submitBtn = makeButton(buttonsRow, "Submit")

-- Tamaños visibles por defecto
getKeyWrap.Size = UDim2.fromScale(0.48, 1)
submitWrap.Size = UDim2.fromScale(0.48, 1)

-- Responsive: apilar si estrecho
local function updateResponsive()
	if screen.AbsoluteSize.X < 760 then
		rowList.FillDirection = Enum.FillDirection.Vertical
		buttonsRow.Size = UDim2.new(1,0,0,140)
		getKeyWrap.Size = UDim2.fromScale(1, 0.48)
		submitWrap.Size = UDim2.fromScale(1, 0.48)
	else
		rowList.FillDirection = Enum.FillDirection.Horizontal
		buttonsRow.Size = UDim2.new(1,0,0,80)
		getKeyWrap.Size = UDim2.fromScale(0.48, 1)
		submitWrap.Size = UDim2.fromScale(0.48, 1)
	end
end
updateResponsive()
screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateResponsive)

-------------------- Lógica --------------------
local toastsHost = toasts
local submitting = false

local function setSubmitEnabled(on)
	submitBtn.Active = on
	submitBtn.AutoButtonColor = on
	submitWrap.BackgroundTransparency = on and 0 or 0.06
end
setSubmitEnabled(false)

keyBox:GetPropertyChangedSignal("Text"):Connect(function()
	setSubmitEnabled(isValidKey(keyBox.Text))
end)

local function bounce(wrapFrame)
	local s = wrapFrame.Size
	wrapFrame:TweenSize(UDim2.new(s.X.Scale, s.X.Offset, s.Y.Scale, s.Y.Offset - 4), "Out", "Quad", 0.07, true)
	task.delay(0.08, function()
		if wrapFrame and wrapFrame.Parent then
			wrapFrame:TweenSize(s, "Out", "Quad", 0.07, true)
		end
	end)
end

getKeyBtn.MouseButton1Click:Connect(function()
	bounce(getKeyWrap)
	if safeClipboard(COPY_LINK) then
		toastsHost.push("enlace copiado al portapapeles!")
	else
		toastsHost.push("No se pudo copiar automáticamente. Copia este enlace:")
		task.delay(0.55, function() toastsHost.push(COPY_LINK, 3) end)
	end
end)

local function doSubmit()
	if submitting then return end
	if not isValidKey(keyBox.Text) then
		toastsHost.push("Ingresa una key válida antes de enviar.")
		return
	end
	submitting = true
	setSubmitEnabled(false)
	bounce(submitWrap)

	local old = "Submit"; submitBtn.Text = "Submitting..."
	task.delay(0.6, function()
		print("[LennonXpremium] Key enviada:", keyBox.Text)
		toastsHost.push("Key enviada. ¡Listo!")
		submitBtn.Text = old
		setSubmitEnabled(isValidKey(keyBox.Text))
		submitting = false
	end)
end
submitBtn.MouseButton1Click:Connect(doSubmit)

-- Atajos
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
		doSubmit()
	elseif input.KeyCode == Enum.KeyCode.K and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
		getKeyBtn:Activate()
	end
end)
