--// =========================
--// LennonXmodder - Login GUI (Slow Stars + Ordered Header)
--// =========================
local G = getgenv and getgenv() or _G
if G.__LENNONX_LOGIN_RUNNING then return end
G.__LENNONX_LOGIN_RUNNING = true

-- === Config ===
local REQUIRED_KEY  = "002288"               -- <— Version
local GET_KEY_LINK  = "https://zamasxmodder.github.io/LennonXmodderWebHub/" -- <— tu link real
local COPY_ON_GET   = true
local TOGGLE_KEY    = Enum.KeyCode.T

-- Fondo (estrellas)
local STAR_COUNT    = 38
local STAR_MIN_SPD  = 0.006
local STAR_MAX_SPD  = 0.012
local STAR_MIN_SIZE = 1
local STAR_MAX_SIZE = 3

-- Colores
local EDGE_COLOR    = Color3.fromRGB(140, 255, 190) -- Verde claro
local BG_OPACITY    = 0.35 -- 0..1 (0.35 recomendado)

-- === Services ===
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local LP           = Players.LocalPlayer

-- === Helpers ===
local function mk(t, p, kids)
    local o = Instance.new(t)
    for k,v in pairs(p or {}) do o[k] = v end
    for _,c in ipairs(kids or {}) do c.Parent = o end
    return o
end
local function safeClipboard(s)
    local ok=false
    pcall(function()
        if setclipboard then setclipboard(s); ok=true
        elseif syn and syn.write_clipboard then syn.write_clipboard(s); ok=true end
    end)
    return ok
end

-- === PlayerGui (cleanup) ===
local PG = LP:WaitForChild("PlayerGui")
for _,n in ipairs({"LennonXpremium_Login","LennonXmodder_Login"}) do
    local old = PG:FindFirstChild(n); if old then old:Destroy() end
end

-- === ScreenGui ===
local gui = mk("ScreenGui", {Name="LennonXmodder_Login", IgnoreGuiInset=true, ResetOnSpawn=false})
gui.Parent = PG

-- =========================================================
-- ================== BACKDROP (SLOW STARS) =================
-- =========================================================
-- Velo semitransparente
local backdrop = mk("Frame", {
    Parent=gui, Size=UDim2.fromScale(1,1),
    BackgroundColor3 = Color3.new(0,0,0),
    BackgroundTransparency = 1 - BG_OPACITY
})

-- Aurora suave
local aurora = mk("Frame", {Parent=backdrop, Size=UDim2.fromScale(1.25,1.25),
    AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5), BackgroundTransparency=1})
local auroraFill = mk("Frame", {Parent=aurora, Size=UDim2.fromScale(1,1), BackgroundTransparency=1})
local auroraGrad = mk("UIGradient", {
    Rotation = 0,
    Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(16,30,28)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(22,42,36)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(16,30,28))
    }
})
auroraGrad.Parent = auroraFill

-- Estrellas
local starFolder = mk("Folder", {Parent = backdrop, Name = "Stars"})
local stars = {}
math.randomseed(tick()%1*1e7)
local function newStar(startAbove)
    local sx = math.random()
    local sy = startAbove and (math.random()*-0.2) or math.random()
    local sp = STAR_MIN_SPD + math.random()*(STAR_MAX_SPD-STAR_MIN_SPD)
    local sz = STAR_MIN_SIZE + math.random(STAR_MAX_SIZE-STAR_MIN_SIZE)
    local tw = math.random()*math.pi*2
    local st = mk("Frame", {
        Parent = starFolder, BorderSizePixel=0,
        BackgroundColor3 = Color3.fromRGB(235,255,245),
        Size = UDim2.fromOffset(sz, sz),
        Position = UDim2.fromScale(sx, sy),
        BackgroundTransparency = 0.5
    }, { mk("UICorner",{CornerRadius=UDim.new(1,0)}) })
    return {inst=st, x=sx, y=sy, sp=sp, sz=sz, tw=tw}
end
for i=1,STAR_COUNT do stars[i] = newStar(false) end

-- Animación fondo
RunService.RenderStepped:Connect(function(dt)
    -- aurora lenta
    auroraGrad.Rotation = (auroraGrad.Rotation + 4*dt*60) % 360
    aurora.Size = UDim2.fromScale(1.22 + 0.03*math.sin(tick()*0.35), 1.22 + 0.03*math.sin(tick()*0.35))
    -- estrellas
    for i,st in ipairs(stars) do
        st.x = st.x + st.sp*0.15*dt*0.5 * math.sin(tick()*0.2 + i) -- drift leve
        st.y = st.y + st.sp*dt                                    -- caída suave
        st.tw = st.tw + dt*0.7
        local a = 0.45 + 0.35*math.abs(math.sin(st.tw))
        st.inst.BackgroundTransparency = 1 - a
        if st.y > 1.05 or st.x < -0.05 or st.x > 1.05 then
            st.inst:Destroy(); stars[i] = newStar(true); st = stars[i]
        end
        st.inst.Position = UDim2.new(st.x, 0, st.y, 0)
    end
end)

-- =========================================================
-- =======================  PANEL  =========================
-- =========================================================
local card = mk("Frame", {
    Parent=gui, AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
    Size=UDim2.fromOffset(560, 540), BackgroundColor3=Color3.fromRGB(22,22,26),
    ClipsDescendants = true
}, {
    mk("UICorner",{CornerRadius=UDim.new(0,22)}),
    mk("UIStroke",{Thickness=2, Transparency=0.08, Color=EDGE_COLOR}),
    mk("UISizeConstraint",{MinSize=Vector2.new(340,460), MaxSize=Vector2.new(820,680)})
})
mk("ImageLabel",{
    Parent=card, BackgroundTransparency=1, AnchorPoint=Vector2.new(0.5,0.5),
    Position=UDim2.fromScale(0.5,0.5), Size=UDim2.fromScale(1,1),
    Image="rbxassetid://5028857084", ImageTransparency=0.58, ZIndex=0
})

-- Contenido
local content = mk("Frame", {
    Parent = card, BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), ZIndex = 10
}, {
    mk("UIPadding",{PaddingTop=UDim.new(0,20), PaddingBottom=UDim.new(0,20), PaddingLeft=UDim.new(0,20), PaddingRight=UDim.new(0,20)}),
    mk("UIListLayout",{
        FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,12),
        HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
})

-- 1) Título (arriba del todo)
local title = mk("TextLabel",{
    Parent=content, BackgroundTransparency=1, Size=UDim2.new(1,0,0,34),
    Font=Enum.Font.GothamBlack, TextSize=30, TextColor3=Color3.fromRGB(235,255,245),
    TextXAlignment=Enum.TextXAlignment.Center, Text="LennonXmodder"
})
title.LayoutOrder = 1

-- 2) Logo debajo del título
local logo = mk("ImageLabel", {
    Parent=content, BackgroundTransparency=1, Image = "rbxassetid://129925821571667",
    Size = UDim2.fromOffset(96,96)
},{
    mk("UICorner",{CornerRadius=UDim.new(1,0)}),
    mk("UIStroke",{Thickness=2,Transparency=0.1, Color=EDGE_COLOR})
})
logo.LayoutOrder = 2

-- 3) Info del jugador (headshot + textos)
local header = mk("Frame",{Parent=content, BackgroundTransparency=1, Size=UDim2.new(1,0,0,92)})
header.LayoutOrder = 3
mk("UIListLayout",{
    Parent=header, FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,12),
    VerticalAlignment=Enum.VerticalAlignment.Center, HorizontalAlignment=Enum.HorizontalAlignment.Left
})
local avatar = mk("ImageLabel", {
    Parent=header, Size=UDim2.fromOffset(84,84), BackgroundTransparency=1, Image="rbxassetid://0"
},{
    mk("UICorner",{CornerRadius=UDim.new(1,0)}),
    mk("UIStroke",{Thickness=2,Transparency=0.1, Color=EDGE_COLOR})
})
local nb = mk("Frame", {Parent=header, BackgroundTransparency=1, Size=UDim2.new(1,-(84+12),1,0)})
mk("UIListLayout",{
    Parent=nb, FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,2),
    VerticalAlignment=Enum.VerticalAlignment.Center, HorizontalAlignment=Enum.HorizontalAlignment.Left
})
local lDisplay = mk("TextLabel",{Parent=nb, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y, Size=UDim2.new(1,0,0,0), Font=Enum.Font.GothamBold, TextSize=22, TextColor3=Color3.fromRGB(240,255,245), TextXAlignment=Enum.TextXAlignment.Left, Text="DisplayName"})
local lUser    = mk("TextLabel",{Parent=nb, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y, Size=UDim2.new(1,0,0,0), Font=Enum.Font.Gotham, TextSize=16, TextColor3=Color3.fromRGB(180,220,200), TextXAlignment=Enum.TextXAlignment.Left, Text="@username"})
local lStatus  = mk("TextLabel",{Parent=nb, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y, Size=UDim2.new(1,0,0,0), Font=Enum.Font.GothamMedium, TextSize=14, TextColor3=Color3.fromRGB(140,220,140), TextXAlignment=Enum.TextXAlignment.Left, Text="Status: Ready"})

-- 4) Input de key
local keyBox = mk("TextBox",{Parent=content, PlaceholderText="Enter key...", ClearTextOnFocus=false, Text="", Font=Enum.Font.Gotham, TextSize=18, TextColor3=Color3.fromRGB(230,245,240), BackgroundColor3=Color3.fromRGB(24,30,28), Size=UDim2.new(1,0,0,46)},{mk("UICorner",{CornerRadius=UDim.new(0,14)}), mk("UIStroke",{Thickness=2,Transparency=0.1, Color=EDGE_COLOR})})
keyBox.LayoutOrder = 4

-- 5) Botones debajo del input
local row = mk("Frame",{Parent=content, BackgroundTransparency=1, Size=UDim2.new(1,0,0,46)})
row.LayoutOrder = 5
mk("UIListLayout",{Parent=row, FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,10), HorizontalAlignment=Enum.HorizontalAlignment.Center})
local btnGet = mk("TextButton",{Parent=row, Text="Get Key", Font=Enum.Font.GothamMedium, TextSize=18, TextColor3=Color3.new(1,1,1), BackgroundColor3=Color3.fromRGB(28,36,32), AutoButtonColor=false, Size=UDim2.new(0.5,-5,1,0)},{mk("UICorner",{CornerRadius=UDim.new(0,14)}), mk("UIStroke",{Thickness=2,Transparency=0.1, Color=EDGE_COLOR})})
local btnSubmit = mk("TextButton",{Parent=row, Text="Submit", Font=Enum.Font.GothamMedium, TextSize=18, TextColor3=Color3.new(1,1,1), BackgroundColor3=Color3.fromRGB(28,36,32), AutoButtonColor=false, Size=UDim2.new(0.5,-5,1,0)},{mk("UICorner",{CornerRadius=UDim.new(0,14)}), mk("UIStroke",{Thickness=2,Transparency=0.1, Color=EDGE_COLOR})})

-- Toast al final
local toast = mk("Frame",{Parent=content, BackgroundColor3=Color3.fromRGB(28,34,32), Size=UDim2.new(1,0,0,36), Visible=false, LayoutOrder=999},{mk("UICorner",{CornerRadius=UDim.new(0,12)}), mk("UIStroke",{Thickness=2,Transparency=0.1, Color=EDGE_COLOR})})
local toastText = mk("TextLabel",{Parent=toast, BackgroundTransparency=1, Size=UDim2.fromScale(1,1), Font=Enum.Font.Gotham, TextSize=16, TextColor3=Color3.fromRGB(230,245,240), Text="..."})

-- === Player Info ===
local function fillInfo()
    local ok,img = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and img then avatar.Image = img end
    lDisplay.Text = LP.DisplayName or "Player"
    lUser.Text    = "@" .. (LP.Name or "username")
    lStatus.Text  = "Status: Enter key"; lStatus.TextColor3 = Color3.fromRGB(240,120,120)
end
fillInfo()

-- Hovers
local function hoverify(b)
    local base=b.BackgroundColor3
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = base:Lerp(Color3.fromRGB(60,80,72),0.25)
        }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.18), {BackgroundColor3 = base}):Play()
    end)
    b.MouseButton1Down:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.06), {Size = b.Size + UDim2.fromOffset(-2,-2)}):Play()
    end)
    b.MouseButton1Up:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.06), {Size = UDim2.new(b.Size.X.Scale, b.Size.X.Offset+2, b.Size.Y.Scale, b.Size.Y.Offset+2)}):Play()
    end)
end
hoverify(btnGet); hoverify(btnSubmit)

-- Toast helper
local busy=false
local function showToast(msg, t)
    if busy then return end; busy=true
    toastText.Text = msg; toast.Visible = true
    toast.Position = UDim2.new(0,0,1,6)
    TweenService:Create(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,1,-(36+0))}):Play()
    task.wait(t or 1.6)
    TweenService:Create(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0,0,1,6)}):Play()
    task.wait(0.22); toast.Visible=false; busy=false
end

-- Submit
local function setStatus(ok,msg)
    lStatus.Text = "Status: " .. (msg or (ok and "Authenticated" or "Invalid key"))
    lStatus.TextColor3 = ok and Color3.fromRGB(120,230,150) or Color3.fromRGB(240,120,120)
end
btnSubmit.MouseButton1Click:Connect(function()
    local k = (keyBox.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if k=="" then setStatus(false,"Enter key"); showToast("Please enter your key.",1.4); return end
    if k==REQUIRED_KEY then
        setStatus(true,"Authenticated"); showToast("Login successful!", 1.2)
        TweenService:Create(card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size=UDim2.fromOffset(560,0)}):Play()
        task.wait(0.25); card.Visible=false
    else
        setStatus(false,"Invalid key"); showToast("Invalid key. Try again.",1.4)
        local p = keyBox.Position
        for _=1,2 do
            TweenService:Create(keyBox, TweenInfo.new(0.06), {Position = p + UDim2.fromOffset(6,0)}):Play(); task.wait(0.06)
            TweenService:Create(keyBox, TweenInfo.new(0.06), {Position = p + UDim2.fromOffset(-6,0)}):Play(); task.wait(0.06)
        end
        TweenService:Create(keyBox, TweenInfo.new(0.06), {Position = p}):Play()
    end
end)

-- Get Key
btnGet.MouseButton1Click:Connect(function()
    local ok=false; if COPY_ON_GET and GET_KEY_LINK~="" then ok=safeClipboard(GET_KEY_LINK) end
    if ok then showToast("Link copied! Paste it in Chrome.",1.8) else showToast("Open your key page.",1.6) end
end)

-- Toggle (panel NO arrastrable)
UIS.InputBegan:Connect(function(i,gpe)
    if gpe then return end
    if i.KeyCode==TOGGLE_KEY then
        if card.Visible then
            TweenService:Create(card, TweenInfo.new(0.18), {Size=UDim2.fromOffset(560,0)}):Play(); task.wait(0.18); card.Visible=false
        else
            card.Size=UDim2.fromOffset(560,0); card.Visible=true
            TweenService:Create(card, TweenInfo.new(0.22), {Size=UDim2.fromOffset(560,540)}):Play()
        end
    end
end)

-- Responsive
local scale = mk("UIScale",{Parent=card, Scale=1})
local function rescale()
    local cam=workspace.CurrentCamera; if not cam then return end
    local v=cam.ViewportSize
    scale.Scale = math.clamp(math.min(v.X/560, v.Y/540), 0.85, 1.20)
end
RunService.Heartbeat:Connect(rescale); rescale()

-- Bienvenida
task.defer(function()
    local ok,img = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and img then avatar.Image = img end
    showToast("Welcome, "..(LP.DisplayName or LP.Name).."!",1.2)
end)
