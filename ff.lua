--[[
    Finis Visual — стеклянное меню с 3D-интро "F" и 3D-превью Бекона (Delta / Roblox)
    Ключ для входа: @FinisOkek (регистр не важен)
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TextService      = game:GetService("TextService")
local GuiService       = game:GetService("GuiService")
local StarterGui       = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local ENV = (type(getgenv) == "function" and getgenv()) or _G

-- повторный запуск: убираем старую копию
if ENV.__FinisVisual and type(ENV.__FinisVisual.Destroy) == "function" then
    pcall(ENV.__FinisVisual.Destroy)
end

local App = { conns = {} }
ENV.__FinisVisual = App

local function bind(signal, fn)
    local c = signal:Connect(fn)
    App.conns[#App.conns + 1] = c
    return c
end

----------------------------------------------------------------------
-- ScreenGui
----------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "FinisVisualMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 2147483647
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)

do
    local parent
    if type(gethui) == "function" then
        local ok, r = pcall(gethui)
        if ok and r then parent = r end
    end
    if not parent then
        local ok, r = pcall(function() return game:GetService("CoreGui") end)
        if ok and r then parent = r end
    end
    if parent then pcall(function() gui.Parent = parent end) end
    if not gui.Parent then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

function App.Destroy()
    for _, c in ipairs(App.conns) do pcall(function() c:Disconnect() end) end
    App.conns = {}
    pcall(function() gui:Destroy() end)
    if ENV.__FinisVisual == App then ENV.__FinisVisual = nil end
end

----------------------------------------------------------------------
-- размеры и константы
----------------------------------------------------------------------
local WIN_W, WIN_H   = 1020, 620
local SIDE_W, HEAD_H = 173, 80
local PAGE_W, PAGE_H = WIN_W - SIDE_W, WIN_H - HEAD_H
local CARD_W, CARD_H = 495, 442
local KEY            = "@finisokek"

local V2 = Vector2.new
local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
local function off(x, y) return UDim2.fromOffset(x, y) end
local function sc(x, y) return UDim2.fromScale(x, y) end

local function atan2(y, x)
    if math.atan2 then return math.atan2(y, x) end
    return math.atan(y, x)
end

local function trim(s)
    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")
    return s
end

local C = {
    white = rgb(255, 255, 255),
    txt   = rgb(246, 248, 255),
    txt2  = rgb(184, 186, 216),
    txt3  = rgb(141, 141, 177),
    txt4  = rgb(112, 113, 148),
    dark  = rgb(22, 20, 46),
    panel = rgb(18, 17, 38),
    green = rgb(96, 226, 160),
    red   = rgb(255, 106, 140),
}

local theme = { a = rgb(160, 172, 250), b = rgb(192, 156, 250) }

local Quint, Quad, Back, Cubic =
    Enum.EasingStyle.Quint, Enum.EasingStyle.Quad, Enum.EasingStyle.Back, Enum.EasingStyle.Cubic
local Out, InOut, In = Enum.EasingDirection.Out, Enum.EasingDirection.InOut, Enum.EasingDirection.In

local FONT_R, FONT_M, FONT_B = Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold

local function tw(o, dur, props, style, dir)
    local t = TweenService:Create(o, TweenInfo.new(math.max(0.01, dur), style or Quint, dir or Out), props)
    t:Play()
    return t
end

local function animateValue(dur, a, b, fn)
    dur = math.max(0.02, dur)
    local t0 = os.clock()
    local done = false
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if done then return end
        local k = math.min(1, (os.clock() - t0) / dur)
        local e = 1 - (1 - k) ^ 3
        fn(a + (b - a) * e)
        if k >= 1 then
            done = true
            conn:Disconnect()
        end
    end)
    task.delay(dur + 0.05, function()
        if not done then
            done = true
            conn:Disconnect()
            fn(b)
        end
    end)
end

local function New(class, props, parent)
    local o = Instance.new(class)
    if props then
        for k, v in pairs(props) do o[k] = v end
    end
    if parent then o.Parent = parent end
    return o
end

local function Frame(parent, p)
    local t = { BorderSizePixel = 0, BackgroundColor3 = C.white }
    if p then for k, v in pairs(p) do t[k] = v end end
    return New("Frame", t, parent)
end

local function Group(parent, p)
    local t = { BorderSizePixel = 0, BackgroundTransparency = 1 }
    if p then for k, v in pairs(p) do t[k] = v end end
    return New("CanvasGroup", t, parent)
end

local function Label(parent, p)
    local t = {
        BorderSizePixel = 0, BackgroundTransparency = 1, Font = FONT_M,
        TextSize = 14, TextColor3 = C.txt, Text = "",
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
    }
    if p then for k, v in pairs(p) do t[k] = v end end
    t.TextSize = math.floor(t.TextSize + 0.5)
    return New("TextLabel", t, parent)
end

local function Button(parent, p)
    local t = {
        BorderSizePixel = 0, BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        Size = UDim2.fromScale(1, 1),
    }
    if p then for k, v in pairs(p) do t[k] = v end end
    return New("TextButton", t, parent)
end

local function Corner(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = (r == "full") and UDim.new(1, 0) or UDim.new(0, r)
    c.Parent = o
    return c
end

local function Stroke(o, color, tr, th)
    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color or C.white
    s.Transparency = tr or 0.88
    s.Thickness = th or 1
    s.Parent = o
    return s
end

local function Grad(o, c1, c2, rot, t1, t2)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 0
    if t1 ~= nil then g.Transparency = NumberSequence.new(t1, t2 or t1) end
    g.Parent = o
    return g
end

local function accentGradient(o, rot)
    return Grad(o, theme.a, theme.b, rot or 0)
end

local function viewport()
    local v = gui.AbsoluteSize
    if v.X < 50 or v.Y < 50 then
        local cam = workspace.CurrentCamera
        if cam then v = cam.ViewportSize end
    end
    if v.X < 50 or v.Y < 50 then v = V2(1280, 720) end
    return v
end

local function baseScale()
    local v = viewport()
    return math.max(0.3, math.min(v.Y * 0.83 / WIN_H, v.X * 0.62 / WIN_W))
end

local function measure(text, size, font)
    size = math.floor(size + 0.5)
    local ok, r = pcall(function()
        return TextService:GetTextSize(text, size, font or FONT_M, V2(3000, 200))
    end)
    if ok and r then return r.X end
    return #text * size * 0.58
end

-- единый обработчик перетаскивания
local Drag = { move = nil, finish = nil }
local function beginDrag(move, finish)
    if Drag.finish then pcall(Drag.finish) end
    Drag.move, Drag.finish = move, finish
end
bind(UserInputService.InputChanged, function(input)
    if Drag.move and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        Drag.move(input)
    end
end)
bind(UserInputService.InputEnded, function(input)
    if Drag.finish and (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
        local f = Drag.finish
        Drag.move, Drag.finish = nil, nil
        f()
    end
end)

local function isPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

----------------------------------------------------------------------
-- векторные иконки (без картинок)
----------------------------------------------------------------------
local ICONS = {
    eye       = { {"p",true, 2,12, 5,8.5, 8.5,6.3, 12,5.5, 15.5,6.3, 19,8.5, 22,12, 19,15.5, 15.5,17.7, 12,18.5, 8.5,17.7, 5,15.5}, {"c",12,12,3} },
    x         = { {"l",6,6,18,18}, {"l",18,6,6,18} },
    check     = { {"p",false, 5,12.5, 10,17.5, 19,7} },
    arrow     = { {"l",4,12,20,12}, {"p",false, 14,6, 20,12, 14,18} },
    key       = { {"c",6.2,12,3.6}, {"l",9.8,12,21.5,12}, {"l",18,12,18,15.5}, {"l",21.5,12,21.5,14.8} },
    clipboard = { {"r",5.5,4,13,17.5,2.5}, {"r",9,2,6,4,1.5}, {"l",9,12,15,12}, {"l",9,16,13,16} },
    sparkle   = { {"p",true, 12,2, 14,10, 22,12, 14,14, 12,22, 10,14, 2,12, 10,10} },
    search    = { {"c",10.5,10.5,6.5}, {"l",15.5,15.5,20.5,20.5} },
    undo      = { {"p",false, 3,4.5, 3,10, 8.5,10}, {"p",false, 3.8,10, 5,6.8, 8,4.5, 12,3.6, 16,4.6, 19.2,7.6, 20.4,11.6, 19.4,15.6, 16.4,18.8, 12.4,20.2, 8.4,19.4} },
    target    = { {"c",12,12,9.5}, {"c",12,12,5.5}, {"d",12,12,1.6} },
    bolt      = { {"p",true, 13,2, 3,14, 12,14, 11,22, 21,10, 12,10} },
}

local function mkLine(root, x1, y1, x2, y2, th, color)
    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    local f = Frame(root, {
        Name = "p", AnchorPoint = V2(0.5, 0.5),
        Position = off((x1 + x2) / 2, (y1 + y2) / 2),
        Size = off(len + th * 0.35, th),
        Rotation = math.deg(atan2(dy, dx)),
        BackgroundColor3 = color,
    })
    Corner(f, "full")
    return f
end

local function mkCircle(root, cx, cy, r, th, color, filled)
    local f = Frame(root, { AnchorPoint = V2(0.5, 0.5), Position = off(cx, cy), Size = off(r * 2, r * 2) })
    Corner(f, "full")
    if filled then
        f.Name = "p"
        f.BackgroundColor3 = color
    else
        f.Name = "o"
        f.BackgroundTransparency = 1
        Stroke(f, color, 0, th)
    end
    return f
end

local function mkRRect(root, x, y, w, h, rad, th, color)
    local f = Frame(root, { Name = "o", Position = off(x, y), Size = off(w, h), BackgroundTransparency = 1 })
    Corner(f, math.max(1, rad))
    Stroke(f, color, 0, th)
    return f
end

local function Icon(parent, name, size, color, props)
    local spec = ICONS[name] or ICONS.sparkle
    local root = Frame(parent, { Name = "Icon", BackgroundTransparency = 1, Size = off(size, size) })
    if props then for k, v in pairs(props) do root[k] = v end end
    local k = size / 24
    local th = math.max(1, size / 13)
    for _, s in ipairs(spec) do
        local t = s[1]
        if t == "l" then
            mkLine(root, s[2] * k, s[3] * k, s[4] * k, s[5] * k, th, color)
        elseif t == "p" then
            local pts = {}
            for i = 3, #s - 1, 2 do pts[#pts + 1] = { s[i] * k, s[i + 1] * k } end
            for i = 1, #pts - 1 do
                mkLine(root, pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], th, color)
            end
            if s[2] and #pts > 2 then
                mkLine(root, pts[#pts][1], pts[#pts][2], pts[1][1], pts[1][2], th, color)
            end
        elseif t == "c" then
            mkCircle(root, s[2] * k, s[3] * k, s[4] * k, th, color, false)
        elseif t == "d" then
            mkCircle(root, s[2] * k, s[3] * k, s[4] * k, th, color, true)
        elseif t == "r" then
            mkRRect(root, s[2] * k, s[3] * k, s[4] * k, s[5] * k, s[6] * k, th, color)
        end
    end
    return root
end

local function setIconColor(root, color, instant)
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("UIStroke") then
            if instant then d.Color = color else tw(d, 0.2, { Color = color }) end
        elseif d:IsA("Frame") and d.Name == "p" then
            if instant then d.BackgroundColor3 = color else tw(d, 0.2, { BackgroundColor3 = color }) end
        end
    end
end

local function setIconAlpha(root, a)
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("UIStroke") then
            d.Transparency = 1 - a
        elseif d:IsA("Frame") and d.Name == "p" then
            d.BackgroundTransparency = 1 - a
        end
    end
end

----------------------------------------------------------------------
-- логотип F (с орбитой и искрой в стиле Finis Visual)
----------------------------------------------------------------------
local sparks = {}

local function makeSpark(parent, s, color)
    local f = Frame(parent, { Name = "Spark", BackgroundTransparency = 1, AnchorPoint = V2(0.5, 0.5), Size = off(s, s) })
    local a = Frame(f, { AnchorPoint = V2(0.5, 0.5), Position = sc(0.5, 0.5), Size = UDim2.new(1, 0, 0, 1.5), BackgroundColor3 = color })
    Corner(a, "full")
    local b = Frame(f, { AnchorPoint = V2(0.5, 0.5), Position = sc(0.5, 0.5), Size = UDim2.new(0, 1.5, 1, 0), BackgroundColor3 = color })
    Corner(b, "full")
    local d = Frame(f, { AnchorPoint = V2(0.5, 0.5), Position = sc(0.5, 0.5), Size = off(s * 0.3, s * 0.3), BackgroundColor3 = C.white })
    Corner(d, "full")
    return f
end

local function makeLogoF(parent, size, ring, spark)
    local root = Frame(parent, { Name = "LogoF", BackgroundTransparency = 1, Size = off(size * 1.5, size) })
    local k = size / 40
    local cx, cy = size * 0.75, size * 0.5
    local thick = math.max(2.2, size / 9.2)
    local midTh = math.max(1.8, size / 11.2)
    local col = rgb(232, 224, 255)
    local A, B = size * 0.66, size * 0.17
    local phi = math.rad(-16)
    local rcy = cy + size * 0.07

    if ring then
        local N = 40
        local px, py
        local lt = math.max(1, size / 34)
        for i = 0, N do
            local t = (i / N) * math.pi * 2
            local ex, ey = A * math.cos(t), B * math.sin(t)
            local x = cx + ex * math.cos(phi) - ey * math.sin(phi)
            local y = rcy + ex * math.sin(phi) + ey * math.cos(phi)
            if px then
                local ln = mkLine(root, px, py, x, y, lt, rgb(206, 198, 255))
                ln.BackgroundTransparency = 0.45
            end
            px, py = x, y
        end
    end

    -- стилизованная наклонная буква F
    local ox, oy = cx - 20 * k, cy - 20 * k
    mkLine(root, ox + 15.5 * k, oy + 9.0 * k,  ox + 12.2 * k, oy + 32.5 * k, thick, col) -- стойка
    mkLine(root, ox + 15.5 * k, oy + 9.0 * k,  ox + 29.0 * k, oy + 9.0 * k,  thick, col) -- верх
    mkLine(root, ox + 14.0 * k, oy + 20.5 * k, ox + 25.0 * k, oy + 20.5 * k, midTh, col) -- середина

    if spark then
        local s = makeSpark(root, math.max(8, size * 0.3), C.white)
        s.Position = off(cx - A * 0.8, rcy + B * 0.5)
        sparks[#sparks + 1] = {
            f = s, s = math.max(8, size * 0.3),
            cx = cx, cy = rcy, a = A, b = B, phi = phi,
            th = math.random() * 6.28, sp = 0.55,
        }
    end
    return root
end

----------------------------------------------------------------------
-- UI компоненты
----------------------------------------------------------------------
local UI = {
    toast = function() end,
    pressFx = function() end,
    scrollLock = function() end,
    searchItems = {},
}

local function addPress(btn, target, amount)
    local us = Instance.new("UIScale")
    us.Parent = target
    amount = amount or 0.96
    btn.InputBegan:Connect(function(input)
        if isPress(input) then tw(us, 0.1, { Scale = amount }, Quad, Out) end
    end)
    btn.InputEnded:Connect(function(input)
        if isPress(input) then tw(us, 0.25, { Scale = 1 }, Back, Out) end
    end)
    return us
end

local function MakeButton(parent, x, y, w, h, text, iconName, style, onClick)
    local root = Frame(parent, { Name = "Btn", Position = off(x, y), Size = off(w, h), BackgroundColor3 = C.white })
    Corner(root, 14)
    local fg = C.txt
    if style == "primary" then
        accentGradient(root, 0)
        fg = C.dark
    else
        root.BackgroundColor3 = rgb(72, 72, 104)
        root.BackgroundTransparency = 0.72
        Stroke(root, C.white, 0.88, 1)
    end
    local tsize = 15
    local twd = measure(text, tsize, FONT_B)
    local iw = iconName and 17 or 0
    local gap = iconName and 8 or 0
    local sx = (w - (iw + gap + twd)) / 2
    if iconName then
        Icon(root, iconName, 17, fg, { Position = off(sx, (h - 17) / 2) })
    end
    local lb = Label(root, {
        Position = off(sx + iw + gap, 0), Size = off(twd + 6, h), Text = text,
        TextSize = tsize, Font = FONT_B, TextColor3 = fg,
    })
    local btn = Button(root, { ZIndex = 3 })
    addPress(btn, root, 0.97)
    btn.Activated:Connect(function()
        UI.pressFx(root)
        if onClick then onClick() end
    end)
    return root, lb, btn
end

local function Segmented(parent, x, y, w, options, selected, onSelect)
    local H, pad = 36, 4
    local n = #options
    local root = Frame(parent, {
        Name = "Segmented", Position = off(x, y), Size = off(w, H),
        BackgroundColor3 = C.panel, BackgroundTransparency = 0.45,
    })
    Corner(root, 12)
    Stroke(root, C.white, 0.88, 1)
    local segW = (w - pad * 2) / n
    local pill = Frame(root, {
        Name = "Pill", Size = off(segW, H - pad * 2), Position = off(pad, pad),
        BackgroundColor3 = C.white,
    })
    Corner(pill, 9)
    accentGradient(pill, 0)
    local labels = {}
    local obj = { frame = root, selected = selected }
    local function paint(i, instant)
        for k, l in ipairs(labels) do
            local goal = (k == i) and C.dark or rgb(176, 177, 206)
            if instant then l.TextColor3 = goal else tw(l, 0.2, { TextColor3 = goal }) end
        end
    end
    function obj.set(i, instant)
        obj.selected = i
        local goal = off(pad + (i - 1) * segW, pad)
        if instant then pill.Position = goal else tw(pill, 0.3, { Position = goal }, Quint, Out) end
        paint(i, instant)
    end
    for i, name in ipairs(options) do
        local b = Button(root, { Position = off(pad + (i - 1) * segW, pad), Size = off(segW, H - pad * 2), ZIndex = 2 })
        local l = Label(b, {
            Size = sc(1, 1), Text = name, TextSize = 13, Font = FONT_M,
            TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = rgb(176, 177, 206),
        })
        labels[i] = l
        b.Activated:Connect(function()
            UI.pressFx(b)
            obj.set(i, false)
            if onSelect then onSelect(i, name) end
        end)
    end
    obj.set(selected, true)
    return obj
end

local function Input(parent, x, y, w, h, icon, placeholder, size)
    local root = Frame(parent, {
        Name = "Input", Position = off(x, y), Size = off(w, h),
        BackgroundColor3 = rgb(16, 15, 34), BackgroundTransparency = 0.45,
    })
    Corner(root, 16)
    local stroke = Stroke(root, C.white, 0.9, 1)
    local ic = Icon(root, icon, 17, rgb(150, 150, 182), { Position = off(15, (h - 17) / 2) })
    local box = New("TextBox", {
        Name = "Box", BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = off(44, 0), Size = off(w - 56, h),
        Font = FONT_M, TextSize = size or 15, TextColor3 = C.txt,
        PlaceholderText = placeholder, PlaceholderColor3 = rgb(112, 113, 144),
        Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left,
        ClipsDescendants = true,
    }, root)
    box.Focused:Connect(function()
        tw(stroke, 0.2, { Transparency = 0.35, Color = theme.a })
        tw(root, 0.2, { BackgroundTransparency = 0.28 })
    end)
    box.FocusLost:Connect(function()
        tw(stroke, 0.2, { Transparency = 0.9, Color = C.white })
        tw(root, 0.2, { BackgroundTransparency = 0.45 })
    end)
    return root, box, stroke, ic
end

local function SectionHeader(parent, x, y, w, title, iconName, hint)
    local r = Frame(parent, { BackgroundTransparency = 1, Position = off(x, y), Size = off(w, 26) })
    local badge = Frame(r, { Size = off(26, 26), BackgroundColor3 = rgb(140, 130, 235), BackgroundTransparency = 0.78 })
    Corner(badge, "full")
    Stroke(badge, C.white, 0.9, 1)
    Icon(badge, iconName, 14, rgb(196, 188, 255), { Position = off(6, 6) })
    Label(r, { Position = off(36, 0), Size = off(w - 36, 26), Text = title, TextSize = 15 })
    if hint then
        Label(r, {
            AnchorPoint = V2(1, 0), Position = off(w, 0), Size = off(w * 0.55, 26),
            Text = hint, TextSize = 12, TextColor3 = C.txt3, TextXAlignment = Enum.TextXAlignment.Right,
        })
    end
    return r
end

----------------------------------------------------------------------
-- 3D ПРЕВЬЮ БЕКОНА (НАСТОЯЩИЕ АССЕТЫ ROBLOX + МАТЕРИАЛЫ)
----------------------------------------------------------------------
local function BuildBaconPreview(parent, x, y, w, h, isWindowVisibleFn)
    local card = Frame(parent, {
        Name = "BaconPreviewCard", Position = off(x, y), Size = off(w, h),
        BackgroundColor3 = rgb(14, 13, 28), BackgroundTransparency = 0.22, ClipsDescendants = true,
    })
    Corner(card, 18)
    Stroke(card, C.white, 0.86, 1)

    -- мягкий градиентный фон под 3D-персонажем
    local bgGrad = Frame(card, { Size = sc(1, 1), BackgroundTransparency = 0.65, ZIndex = 1 })
    Corner(bgGrad, 18)
    Grad(bgGrad, rgb(42, 36, 84), rgb(14, 13, 28), 90)

    -- верхняя плашка с ником и кнопками управления камерой
    local nameTag = Frame(card, {
        Position = off(12, 12), Size = off(114, 26),
        BackgroundColor3 = rgb(20, 18, 42), BackgroundTransparency = 0.25, ZIndex = 4,
    })
    Corner(nameTag, "full")
    Stroke(nameTag, C.white, 0.85, 1)
    local nDot = Frame(nameTag, { Position = off(9, 9), Size = off(8, 8), BackgroundColor3 = theme.a })
    Corner(nDot, "full")
    Label(nameTag, { Position = off(22, 0), Size = off(86, 26), Text = "Bacon Hair", TextSize = 12, TextColor3 = C.txt })

    local autoSpin = true

    local spinBtn = Frame(card, {
        Position = off(w - 72, 12), Size = off(28, 28),
        BackgroundColor3 = rgb(20, 18, 42), BackgroundTransparency = 0.25, ZIndex = 4,
    })
    Corner(spinBtn, "full")
    Stroke(spinBtn, C.white, 0.85, 1)
    local spinIcon = Icon(spinBtn, "undo", 14, theme.a, { Position = off(7, 7) })
    local spinHit = Button(spinBtn, { ZIndex = 5 })
    addPress(spinHit, spinBtn, 0.9)

    local resetBtn = Frame(card, {
        Position = off(w - 38, 12), Size = off(28, 28),
        BackgroundColor3 = rgb(20, 18, 42), BackgroundTransparency = 0.25, ZIndex = 4,
    })
    Corner(resetBtn, "full")
    Stroke(resetBtn, C.white, 0.85, 1)
    Icon(resetBtn, "target", 14, C.txt2, { Position = off(7, 7) })
    local resetHit = Button(resetBtn, { ZIndex = 5 })
    addPress(resetHit, resetBtn, 0.9)

    -- ViewportFrame (напрямую в обычном Frame, без CanvasGroup!)
    local vp = New("ViewportFrame", {
        Name = "BaconVP", Position = off(0, 36), Size = off(w, h - 62),
        BackgroundTransparency = 1,
        Ambient = rgb(210, 215, 225),
        LightColor = C.white,
        LightDirection = Vector3.new(-0.5, -1, 0.8),
        Active = true, ZIndex = 2,
    }, card)

    -- декоративная 2D-рамка поверх 3D-модели
    local espBox = Frame(vp, {
        AnchorPoint = V2(0.5, 0.5), Position = sc(0.5, 0.5),
        Size = off(132, 204), BackgroundTransparency = 1, ZIndex = 3,
    })
    Corner(espBox, 6)
    Stroke(espBox, theme.a, 0.35, 1.5)

    Label(card, {
        Position = off(0, h - 26), Size = off(w, 20),
        Text = "Потяни пальцем, чтобы крутить 3D-модель",
        TextSize = 11, TextColor3 = C.txt3, Font = FONT_R,
        TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4,
    })

    local world = New("WorldModel", {}, vp)
    local cam = New("Camera", { FieldOfView = 36 }, vp)
    vp.CurrentCamera = cam

    local visuals = { parts = {}, meshes = {}, decals = {}, clothes = {}, model = nil }
    local camDist = 9.0
    local currentMode = 1 -- 1=Обычный, 2=Glow, 3=Flat, 4=Glass

    local function applyMaterial(modeIdx)
        currentMode = modeIdx
        local chamsOn = (modeIdx ~= 1)
        for _, cl in ipairs(visuals.clothes) do
            if cl.obj then cl.obj.Parent = chamsOn and nil or visuals.model end
        end
        for _, dc in ipairs(visuals.decals) do
            if dc.decal then dc.decal.Transparency = chamsOn and 1 or dc.origTrans end
        end
        for _, ms in ipairs(visuals.meshes) do
            if ms.mesh then
                pcall(function()
                    if ms.mesh:IsA("SpecialMesh") then
                        ms.mesh.TextureId = chamsOn and "" or ms.origTex
                    elseif ms.mesh:IsA("MeshPart") then
                        ms.mesh.TextureID = chamsOn and "" or ms.origTex
                    end
                end)
            end
        end
        for _, info in ipairs(visuals.parts) do
            if info.part and info.part.Parent then
                if chamsOn then
                    info.part.Color = (modeIdx == 4) and theme.b or theme.a
                    if modeIdx == 2 then
                        info.part.Material = Enum.Material.Neon
                    elseif modeIdx == 3 then
                        info.part.Material = Enum.Material.SmoothPlastic
                    else
                        info.part.Material = Enum.Material.ForceField
                    end
                else
                    info.part.Color = info.origColor
                    info.part.Material = info.origMat
                end
                info.part.Transparency = info.origTrans
            end
        end
    end

    local function mountModel(model)
        for _, ch in ipairs(world:GetChildren()) do ch:Destroy() end
        table.clear(visuals.parts)
        table.clear(visuals.meshes)
        table.clear(visuals.decals)
        table.clear(visuals.clothes)
        visuals.model = model

        local hum = model:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            hum.PlatformStand = true
            hum.AutoRotate = false
        end

        model.Parent = world
        local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
        if hrp then
            hrp.Anchored = true
            model.PrimaryPart = hrp
            model:PivotTo(CFrame.new(0, 0, 0))
        end

        RunService.Heartbeat:Wait()

        local bbCF, bbSize = model:GetBoundingBox()
        if hrp then
            local shift = model:GetPivot().Position - bbCF.Position
            model:PivotTo(CFrame.new(shift))
        else
            for _, p in ipairs(model:GetDescendants()) do
                if p:IsA("BasePart") then p.CFrame = p.CFrame - bbCF.Position end
            end
        end

        camDist = math.clamp(bbSize.Y * 1.56, 8.0, 11.0)

        for _, obj in ipairs(model:GetDescendants()) do
            if obj:IsA("BasePart") then
                if obj.Name == "HumanoidRootPart" then
                    obj.Transparency = 1
                else
                    table.insert(visuals.parts, {
                        part = obj, origColor = obj.Color, origMat = obj.Material, origTrans = obj.Transparency,
                    })
                end
                if obj:IsA("MeshPart") and obj.TextureID ~= "" then
                    table.insert(visuals.meshes, { mesh = obj, origTex = obj.TextureID })
                end
            elseif obj:IsA("SpecialMesh") and obj.TextureId ~= "" then
                table.insert(visuals.meshes, { mesh = obj, origTex = obj.TextureId })
            elseif obj:IsA("Decal") then
                table.insert(visuals.decals, { decal = obj, origTrans = obj.Transparency })
            elseif obj:IsA("Shirt") or obj:IsA("Pants") then
                table.insert(visuals.clothes, { obj = obj })
            end
        end

        applyMaterial(currentMode)
    end

    -- загрузка официального 3D Бекона Roblox
    task.spawn(function()
        local skinGray = rgb(205, 206, 208)
        local okDesc, model = pcall(function()
            local desc = Instance.new("HumanoidDescription")
            desc.HairAccessory = "63690008"
            desc.Shirt = 144076358
            desc.Pants = 144076760
            desc.Face  = 144080495
            desc.HeadColor     = skinGray
            desc.TorsoColor    = skinGray
            desc.LeftArmColor  = skinGray
            desc.RightArmColor = skinGray
            desc.LeftLegColor  = skinGray
            desc.RightLegColor = skinGray
            return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
        end)

        if okDesc and model then
            mountModel(model)
            return
        end

        -- резерв для Delta через game:GetObjects
        local rig = New("Model", { Name = "BaconHairR6" })
        New("Humanoid", { RigType = Enum.HumanoidRigType.R6 }, rig)
        local function R6(name, sz, cf)
            local p = New("Part", {
                Name = name, Size = sz, CFrame = cf, Color = skinGray,
                Material = Enum.Material.SmoothPlastic, Anchored = true,
                TopSurface = Enum.SurfaceType.Smooth, BottomSurface = Enum.SurfaceType.Smooth,
            }, rig)
            return p
        end
        R6("HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(0, 0, 0)).Transparency = 1
        R6("Torso", Vector3.new(2, 2, 1), CFrame.new(0, 0, 0))
        local head = R6("Head", Vector3.new(2, 1, 1), CFrame.new(0, 1.5, 0))
        New("SpecialMesh", { MeshType = Enum.MeshType.Head, Scale = Vector3.new(1.25, 1.25, 1.25) }, head)
        R6("Left Arm",  Vector3.new(1, 2, 1), CFrame.new(-1.5, 0, 0))
        R6("Right Arm", Vector3.new(1, 2, 1), CFrame.new(1.5, 0, 0))
        R6("Left Leg",  Vector3.new(1, 2, 1), CFrame.new(-0.5, -2, 0))
        R6("Right Leg", Vector3.new(1, 2, 1), CFrame.new(0.5, -2, 0))
        New("Decal", { Name = "face", Face = Enum.NormalId.Front, Texture = "rbxasset://textures/face.png" }, head)

        pcall(function()
            local objs = game:GetObjects("rbxassetid://63690008")
            local acc = objs and objs[1]
            if acc then
                local handle = acc:FindFirstChild("Handle")
                if handle then
                    handle.Anchored = true
                    local att = handle:FindFirstChildOfClass("Attachment")
                    handle.CFrame = att and (head.CFrame * CFrame.new(0, 0.6, 0) * att.CFrame:Inverse())
                        or (head.CFrame * CFrame.new(0, 0.3, 0))
                end
                acc.Parent = rig
            end
        end)
        pcall(function()
            local objs = game:GetObjects("rbxassetid://144076358")
            if objs and objs[1] then objs[1].Parent = rig end
        end)
        pcall(function()
            local objs = game:GetObjects("rbxassetid://144076760")
            if objs and objs[1] then objs[1].Parent = rig end
        end)

        mountModel(rig)
    end)

    -- вращение пальцем / мышью
    local camYaw, camPitch = 16, 6
    local dragging3D = false

    spinHit.Activated:Connect(function()
        UI.pressFx(spinBtn)
        autoSpin = not autoSpin
        setIconColor(spinIcon, autoSpin and theme.a or C.txt3, false)
    end)

    resetHit.Activated:Connect(function()
        UI.pressFx(resetBtn)
        camYaw, camPitch = 0, 6
    end)

    vp.InputBegan:Connect(function(input)
        if not isPress(input) then return end
        dragging3D = true
        UI.scrollLock(true)
        local lastPos = V2(input.Position.X, input.Position.Y)
        beginDrag(function(i)
            local cur = V2(i.Position.X, i.Position.Y)
            local d = cur - lastPos
            lastPos = cur
            camYaw = camYaw - d.X * 0.9
            camPitch = math.clamp(camPitch + d.Y * 0.45, -28, 35)
        end, function()
            dragging3D = false
            UI.scrollLock(false)
        end)
    end)

    bind(RunService.RenderStepped, function(dt)
        if not isWindowVisibleFn() then return end
        if autoSpin and not dragging3D then
            camYaw = camYaw + dt * 24
        end
        local rotCF = CFrame.Angles(0, math.rad(camYaw), 0) * CFrame.Angles(math.rad(-camPitch), 0, 0)
        cam.CFrame = CFrame.lookAt(rotCF * Vector3.new(0, 0, -camDist), Vector3.zero)
    end)

    return {
        card = card,
        setMaterial = applyMaterial,
        getMaterial = function() return currentMode end,
    }
end

----------------------------------------------------------------------
-- ОБОЛОЧКА МЕНЮ (FINIS VISUAL)
----------------------------------------------------------------------
local function BuildShell()
    -- тосты сверху по центру
    local toastHost = Frame(gui, { Name = "Toasts", BackgroundTransparency = 1, Size = sc(1, 1), ZIndex = 60 })
    local curToast

    function UI.toast(text, iconName)
        if curToast then pcall(function() curToast:Destroy() end) end
        local w = measure(text, 15, FONT_M) + 84
        local pill = Frame(toastHost, {
            Name = "Toast", AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, -0.14, 0),
            Size = off(w, 46), BackgroundColor3 = rgb(15, 14, 32), BackgroundTransparency = 0.1,
        })
        curToast = pill
        Corner(pill, "full")
        Stroke(pill, C.white, 0.86, 1)
        New("UIScale", { Scale = baseScale() }, pill)
        local ic = Frame(pill, { Position = off(9, 9), Size = off(28, 28), BackgroundColor3 = rgb(150, 140, 235), BackgroundTransparency = 0.68 })
        Corner(ic, "full")
        Icon(ic, iconName or "check", 14, rgb(214, 206, 255), { Position = off(7, 7) })
        Label(pill, { Position = off(48, 0), Size = off(w - 60, 44), Text = text, TextSize = 15 })
        local bar = Frame(pill, { Position = off(48, 40), Size = off(w - 70, 2) })
        Corner(bar, "full")
        accentGradient(bar, 0)
        tw(pill, 0.5, { Position = UDim2.new(0.5, 0, 0.035, 0) }, Back, Out)
        TweenService:Create(bar, TweenInfo.new(1.7, Enum.EasingStyle.Linear), { Size = off(0, 2) }):Play()
        task.delay(1.85, function()
            if curToast == pill then
                tw(pill, 0.35, { Position = UDim2.new(0.5, 0, -0.14, 0) }, Quint, In)
                task.delay(0.4, function()
                    pcall(function() pill:Destroy() end)
                    if curToast == pill then curToast = nil end
                end)
            end
        end)
    end

    local userScale = 1
    local function curScale() return baseScale() * userScale end

    local winOpen, cardOpen, authed = false, false, false

    local topbarWas
    function UI.syncTopbar()
        local want = winOpen or cardOpen
        pcall(function()
            if want then
                if topbarWas == nil then topbarWas = StarterGui:GetCore("TopbarEnabled") end
                StarterGui:SetCore("TopbarEnabled", false)
            elseif topbarWas ~= nil then
                StarterGui:SetCore("TopbarEnabled", topbarWas)
                topbarWas = nil
            end
        end)
    end
    do
        local prevDestroy = App.Destroy
        function App.Destroy()
            winOpen, cardOpen = false, false
            UI.syncTopbar()
            prevDestroy()
        end
    end

    ------------------------------------------------------------------
    -- ШАР (ORB) С ЛОГОТИПОМ "F"
    ------------------------------------------------------------------
    local ORB = 74
    local function getOrbStartPos()
        local scr = viewport()
        local rad = (ORB * baseScale()) * 0.5
        local px = math.max(scr.X * 0.055, rad + 16)
        local py = math.min(scr.Y * 0.87, scr.Y - rad - 16)
        return UDim2.fromScale(px / scr.X, py / scr.Y), V2(px, py)
    end

    local orbPosUDim = getOrbStartPos()
    local orb = Frame(gui, {
        Name = "Orb", AnchorPoint = V2(0.5, 0.5), Position = orbPosUDim,
        Size = off(ORB, ORB), BackgroundColor3 = C.white, BackgroundTransparency = 0.1,
        Visible = false, ZIndex = 20,
    })
    Corner(orb, "full")
    Grad(orb, rgb(88, 78, 152), rgb(30, 27, 60), 135)
    Stroke(orb, rgb(190, 180, 255), 0.7, 1.5)
    local orbScale = New("UIScale", { Scale = 0.01 }, orb)

    local arc = Frame(orb, { Name = "Arc", AnchorPoint = V2(0.5, 0.5), Position = sc(0.5, 0.5), Size = off(ORB + 2, ORB + 2), BackgroundTransparency = 1 })
    Corner(arc, "full")
    local arcStroke = Stroke(arc, rgb(232, 224, 255), 0, 2.4)
    local arcGrad = New("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.26, 0.55),
            NumberSequenceKeypoint.new(0.34, 1), NumberSequenceKeypoint.new(1, 1),
        }),
    }, arcStroke)

    do
        local lg = makeLogoF(orb, 32, false, false)
        lg.Position = off((ORB - 48) / 2, (ORB - 32) / 2)
    end
    local orbBtn = Button(orb, { ZIndex = 5 })

    local function orbPress(k) tw(orbScale, 0.12, { Scale = baseScale() * k }, Quad, Out) end

    local function snapOrb()
        local scr = viewport()
        local a, sz = orb.AbsolutePosition, orb.AbsoluteSize
        local cx = a.X + sz.X / 2
        local goalX = (cx < scr.X / 2) and (sz.X / 2 + 14) or (scr.X - sz.X / 2 - 14)
        local cy = math.clamp(a.Y + sz.Y / 2, sz.Y / 2 + 10, scr.Y - sz.Y / 2 - 10)
        tw(orb, 0.45, { Position = UDim2.fromScale(goalX / scr.X, cy / scr.Y) }, Back, Out)
    end

    orbBtn.InputBegan:Connect(function(input)
        if not isPress(input) then return end
        local startPos = input.Position
        local a, sz = orb.AbsolutePosition, orb.AbsoluteSize
        local startCenter = V2(a.X + sz.X / 2, a.Y + sz.Y / 2)
        local moved = false
        orbPress(0.9)
        beginDrag(function(i)
            local dx, dy = i.Position.X - startPos.X, i.Position.Y - startPos.Y
            if not moved and (math.abs(dx) + math.abs(dy)) > 8 then moved = true end
            if moved then
                local scr = viewport()
                orb.Position = UDim2.fromScale(
                    math.clamp((startCenter.X + dx) / scr.X, 0.02, 0.98),
                    math.clamp((startCenter.Y + dy) / scr.Y, 0.04, 0.96))
            end
        end, function()
            orbPress(1)
            if moved then snapOrb() else UI.orbTap() end
        end)
    end)

    ------------------------------------------------------------------
    -- ГЛАВНОЕ ОКНО (FINIS VISUAL)
    ------------------------------------------------------------------
    local winBaseT = 0.13
    local win = Frame(gui, {
        Name = "Window", AnchorPoint = V2(0.5, 0.5), Position = sc(0.5, 0.5), Size = off(WIN_W, WIN_H),
        BackgroundColor3 = C.white, BackgroundTransparency = winBaseT, Visible = false,
        ClipsDescendants = true, Active = true, ZIndex = 12,
    })
    Corner(win, 28)
    Grad(win, rgb(86, 82, 146), rgb(32, 28, 64), 120)
    local winStroke = Stroke(win, C.white, 0.35, 1.5)
    New("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.08), NumberSequenceKeypoint.new(0.35, 0.62), NumberSequenceKeypoint.new(1, 0.82),
        }),
    }, winStroke)
    local winScale = New("UIScale", { Scale = 1 }, win)

    local particleLayer = Frame(win, { Name = "Particles", BackgroundTransparency = 1, Size = off(WIN_W, WIN_H), ClipsDescendants = true, ZIndex = 1 })
    -- обычный Frame вместо CanvasGroup, чтобы 3D-Бекон 100% рендерился на Android!
    local body = Frame(win, { Name = "Body", BackgroundTransparency = 1, Size = off(WIN_W, WIN_H), ZIndex = 2 })
    local fx   = Frame(win, { Name = "Fx", BackgroundTransparency = 1, Size = off(WIN_W, WIN_H), ZIndex = 30 })

    -- ШАПКА: логотип F, название Finis Visual, Поиск, Статус, Аватар Roblox, Закрыть
    local header = Frame(body, { Name = "Header", BackgroundTransparency = 1, Size = off(WIN_W, HEAD_H) })
    local headDrag = Button(header, { Name = "DragHandle", Size = off(WIN_W, HEAD_H), ZIndex = 1 })

    local hLogo = makeLogoF(header, 40, true, true)
    hLogo.Position = off(14, 19)
    hLogo.ZIndex = 2

    local hTitle = Label(header, {
        Position = off(83, 13), Size = off(220, 32), Text = "Finis Visual",
        TextSize = 25, Font = FONT_B, ZIndex = 2,
    })
    Grad(hTitle, rgb(255, 250, 255), rgb(212, 190, 255), 0)
    Label(header, {
        Position = off(84, 46), Size = off(240, 14), Text = "FINIS VISUAL  ·  ROBLOX",
        TextSize = 9.5, TextColor3 = C.txt4, ZIndex = 2,
    })

    -- Строка поиска в шапке
    local searchWrap, searchBox = Input(header, 320, 21, 355, 38, "search", "Поиск...", 14)
    searchWrap.ZIndex = 3

    -- Плашка статуса
    do
        local pill = Frame(header, {
            Position = off(WIN_W - 22 - 36 - 12 - 36 - 12 - 116, 26),
            Size = off(116, 28), BackgroundTransparency = 0.93, ZIndex = 3,
        })
        Corner(pill, "full")
        Stroke(pill, C.white, 0.88, 1)
        local halo = Frame(pill, { AnchorPoint = V2(0.5, 0.5), Position = off(18, 14), Size = off(14, 14), BackgroundColor3 = C.green, BackgroundTransparency = 0.75 })
        Corner(halo, "full")
        local d = Frame(pill, { AnchorPoint = V2(0.5, 0.5), Position = off(18, 14), Size = off(8, 8), BackgroundColor3 = C.green })
        Corner(d, "full")
        Label(pill, { Position = off(31, 0), Size = off(82, 28), Text = "Подключено", TextSize = 12.5 })
    end

    -- Аватарка аккаунта Roblox в шапке
    do
        local avFrame = Frame(header, {
            Position = off(WIN_W - 22 - 36 - 12 - 36, 22), Size = off(36, 36),
            BackgroundColor3 = rgb(24, 22, 48), BackgroundTransparency = 0.2, ZIndex = 3,
        })
        Corner(avFrame, "full")
        Stroke(avFrame, theme.a, 0.4, 1.4)
        local avImg = New("ImageLabel", {
            Size = sc(1, 1), BackgroundTransparency = 1, Image = "", ZIndex = 4,
        }, avFrame)
        Corner(avImg, "full")
        task.spawn(function()
            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if ok and thumb then avImg.Image = thumb end
        end)
    end

    -- Кнопка закрытия "×"
    do
        local x = Frame(header, { Position = off(WIN_W - 22 - 36, 22), Size = off(36, 36), BackgroundTransparency = 0.93, ZIndex = 3 })
        Corner(x, "full")
        Stroke(x, C.white, 0.88, 1)
        Icon(x, "x", 14, rgb(214, 214, 238), { Position = off(11, 11) })
        local xb = Button(x, { ZIndex = 4 })
        addPress(xb, x, 0.9)
        xb.Activated:Connect(function() UI.closeWindow() end)
    end
    Frame(body, { Name = "HeadLine", Position = off(0, HEAD_H - 1), Size = off(WIN_W, 1), BackgroundTransparency = 0.92 })

    -- БОКОВОЕ МЕНЮ (ТОЛЬКО 1 ВКЛАДКА: ВИЗУАЛ)
    local side = Frame(body, { Name = "Sidebar", BackgroundTransparency = 1, Position = off(0, HEAD_H), Size = off(SIDE_W, PAGE_H) })
    Frame(body, { Name = "SideLine", Position = off(SIDE_W - 1, HEAD_H), Size = off(1, PAGE_H), BackgroundTransparency = 0.93 })
    Label(side, { Position = off(20, PAGE_H - 36), Size = off(150, 14), Text = "FINIS VISUAL  ·  v1.0", TextSize = 9.5, TextColor3 = C.txt4 })

    local selPill = Frame(side, { Name = "Sel", Position = off(8, 13), Size = off(155, 50), BackgroundTransparency = 0.9 })
    Corner(selPill, 16)
    Stroke(selPill, C.white, 0.82, 1)
    local selBar = Frame(selPill, { Position = off(3, 16), Size = off(3, 18), BackgroundColor3 = theme.b })
    Corner(selBar, "full")
    Icon(side, "eye", 18, rgb(206, 196, 255), { Position = off(30, 29) })
    Label(side, { Position = off(63, 13), Size = off(100, 50), Text = "Визуал", TextSize = 16, TextColor3 = C.white })

    -- ЕДИНСТВЕННАЯ СТРАНИЦА: ВИЗУАЛ
    local pageHost = Frame(body, { Name = "Pages", BackgroundTransparency = 1, Position = off(SIDE_W, HEAD_H), Size = off(PAGE_W, PAGE_H), ClipsDescendants = true })
    local scroller = New("ScrollingFrame", {
        Name = "VisualScroll", BackgroundTransparency = 1, BorderSizePixel = 0, Size = off(PAGE_W, PAGE_H),
        CanvasSize = off(0, PAGE_H), ScrollBarThickness = 3, ScrollBarImageColor3 = rgb(206, 196, 255),
        ScrollBarImageTransparency = 0.45, ScrollingDirection = Enum.ScrollingDirection.Y,
    }, pageHost)

    function UI.scrollLock(locked)
        scroller.ScrollingEnabled = not locked
    end

    Label(scroller, { Position = off(26, 12), Size = off(400, 38), Text = "Визуал", TextSize = 28, Font = FONT_B, TextColor3 = rgb(236, 230, 255) })
    Label(scroller, { Position = off(26, 50), Size = off(480, 22), Text = "3D предпросмотр и визуальные функции", TextSize = 13.5, TextColor3 = C.txt2 })

    -- ЛЕВАЯ КОЛОНКА: 3D Бекон + переключение материалов (Обычный / Glow / Flat / Glass)
    local LX, RX, COLW = 26, 422, 372
    SectionHeader(scroller, LX, 92, COLW, "3D Предпросмотр", "eye", "Бекон 3D")
    local baconPreview = BuildBaconPreview(scroller, LX, 128, COLW, 326, function() return winOpen end)

    local matNames = { "Обычный", "Glow", "Flat", "Glass" }
    local matSeg = Segmented(scroller, LX, 466, COLW, matNames, 1, function(idx, name)
        baconPreview.setMaterial(idx)
        UI.toast("Материал: " .. name, "sparkle")
    end)

    -- ПРАВАЯ КОЛОНКА: только 1 кнопка "test" (готово к расширению)
    SectionHeader(scroller, RX, 92, COLW, "Функции", "bolt", "1 элемент")

    local testRow = Frame(scroller, { Name = "Row_test", BackgroundTransparency = 1, Position = off(RX, 128), Size = off(COLW, 56) })
    MakeButton(testRow, 0, 4, COLW, 46, "test", "sparkle", "primary", function()
        -- сюда добавляй свою функцию
        local nextMode = (baconPreview.getMaterial() % #matNames) + 1
        matSeg.set(nextMode, false)
        baconPreview.setMaterial(nextMode)
        UI.toast("test активирован (" .. matNames[nextMode] .. ")", "sparkle")
    end)

    -- Регистрируем кнопку в поиске (для новых кнопок просто добавляй сюда)
    table.insert(UI.searchItems, { row = testRow, text = "test" })

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = string.lower(trim(searchBox.Text))
        for _, item in ipairs(UI.searchItems) do
            item.row.Visible = (q == "" or string.find(item.text, q, 1, true) ~= nil)
        end
    end)

    -- уголок масштабирования окна
    local grip = Button(body, { Name = "Grip", Position = off(WIN_W - 34, WIN_H - 34), Size = off(30, 30), ZIndex = 5 })
    for r = 0, 2 do
        for c = 0, 2 - r do
            local d = Frame(grip, { Position = off(20 - c * 6, 20 - r * 6), Size = off(2.5, 2.5), BackgroundTransparency = 0.55 })
            Corner(d, "full")
        end
    end

    ------------------------------------------------------------------
    -- ЧАСТИЦЫ И ЭФФЕКТЫ НАЖАТИЙ
    ------------------------------------------------------------------
    local PN = 26
    local P = {}
    for i = 1, PN do
        local sz = 2 + math.random() * 2.4
        local f = Frame(particleLayer, { Size = off(sz, sz), BackgroundColor3 = rgb(212, 204, 255), BackgroundTransparency = 0.6 })
        Corner(f, "full")
        P[i] = { f = f, x = math.random(30, WIN_W - 30), y = math.random(30, WIN_H - 30), vy = 5 + math.random() * 12, vx = (math.random() - 0.5) * 8, ph = math.random() * 6.28 }
        f.Position = off(P[i].x, P[i].y)
    end

    local function guiToFx(pos)
        local a = fx.AbsolutePosition
        local k = math.max(0.05, winScale.Scale)
        return V2((pos.X - a.X) / k, (pos.Y - a.Y) / k)
    end

    local function burst(host, x, y, n, spread)
        for _ = 1, n do
            local d = Frame(host, { AnchorPoint = V2(0.5, 0.5), Position = off(x, y), Size = off(5, 5), BackgroundColor3 = theme.a, BackgroundTransparency = 0.1 })
            Corner(d, "full")
            local ang = math.random() * 6.283
            local dist = spread * (0.5 + math.random() * 0.8)
            tw(d, 0.55, { Position = off(x + math.cos(ang) * dist, y + math.sin(ang) * dist), BackgroundTransparency = 1, Size = off(2, 2) }, Quint, Out)
            task.delay(0.6, function() d:Destroy() end)
        end
    end

    function UI.pressFx(obj)
        if not winOpen then return end
        local a, sz = obj.AbsolutePosition, obj.AbsoluteSize
        local p = guiToFx(V2(a.X + sz.X / 2, a.Y + sz.Y / 2))
        burst(fx, p.X, p.Y, 6, 28)
    end

    local lastTrail = 0
    bind(UserInputService.InputChanged, function(input)
        if not winOpen then return end
        local touch = input.UserInputType == Enum.UserInputType.Touch
        local mouse = input.UserInputType == Enum.UserInputType.MouseMovement
            and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        if not (touch or mouse) then return end
        local now = os.clock()
        if now - lastTrail < 0.04 then return end
        lastTrail = now
        local inset = GuiService:GetGuiInset()
        local p = V2(input.Position.X, input.Position.Y + inset.Y)
        local a, sz = win.AbsolutePosition, win.AbsoluteSize
        if p.X < a.X or p.Y < a.Y or p.X > a.X + sz.X or p.Y > a.Y + sz.Y then return end
        local wpos = guiToFx(p)
        local d = Frame(fx, { AnchorPoint = V2(0.5, 0.5), Position = off(wpos.X, wpos.Y), Size = off(8, 8), BackgroundColor3 = theme.b, BackgroundTransparency = 0.3 })
        Corner(d, "full")
        tw(d, 0.45, { Size = off(2, 2), BackgroundTransparency = 1 }, Quad, Out)
        task.delay(0.5, function() d:Destroy() end)
    end)

    ------------------------------------------------------------------
    -- ПЕРЕТАСКИВАНИЕ И ОТКРЫТИЕ / ЗАКРЫТИЕ ОКНА
    ------------------------------------------------------------------
    local cardFrame
    local function applyScales()
        if winOpen then winScale.Scale = curScale() end
        if cardFrame and cardOpen then cardFrame.UIScale.Scale = curScale() end
        if orb.Visible then orbScale.Scale = baseScale() end
    end

    local function makeDraggable(target, handle, hooks)
        handle.InputBegan:Connect(function(input)
            if not isPress(input) then return end
            local startPos = input.Position
            local a, sz = target.AbsolutePosition, target.AbsoluteSize
            local startCenter = V2(a.X + sz.X / 2, a.Y + sz.Y / 2)
            local moved = false
            beginDrag(function(i)
                local dx, dy = i.Position.X - startPos.X, i.Position.Y - startPos.Y
                if not moved and (math.abs(dx) + math.abs(dy)) > 6 then
                    moved = true
                    if hooks and hooks.moved then hooks.moved() end
                end
                if moved then
                    local scr = viewport()
                    local cx = math.clamp(startCenter.X + dx, sz.X * 0.25, scr.X - sz.X * 0.25)
                    local cy = math.clamp(startCenter.Y + dy, math.min(sz.Y / 2, scr.Y / 2), scr.Y - 60)
                    target.Position = UDim2.fromScale(cx / scr.X, cy / scr.Y)
                end
            end, function()
                if hooks and hooks.ended then hooks.ended(moved) end
            end)
        end)
    end

    local winHome = sc(0.5, 0.5)
    makeDraggable(win, headDrag, {
        moved = function()
            tw(win, 0.2, { BackgroundTransparency = math.min(1, winBaseT + 0.12) })
        end,
        ended = function(moved)
            if moved then
                winHome = win.Position
                tw(win, 0.3, { BackgroundTransparency = winBaseT })
                winStroke.Transparency = 0
                tw(winStroke, 0.7, { Transparency = 0.35 })
            end
        end,
    })

    grip.InputBegan:Connect(function(input)
        if not isPress(input) then return end
        local startPos, startScale = input.Position, userScale
        UI.scrollLock(true)
        beginDrag(function(i)
            local d = ((i.Position.X - startPos.X) + (i.Position.Y - startPos.Y)) / 2
            userScale = math.floor(math.clamp(startScale + d / (WIN_W * curScale()), 0.6, 1.5) * 20 + 0.5) / 20
            applyScales()
        end, function() UI.scrollLock(false) end)
    end)

    function UI.openWindow()
        if winOpen then return end
        winOpen = true
        win.Visible = true
        win.Size = off(WIN_W, WIN_H)
        winScale.Scale = curScale() * 0.12
        win.Position = orb.Position
        tw(winScale, 0.52, { Scale = curScale() }, Back, Out)
        tw(win, 0.52, { Position = winHome }, Quint, Out)
        UI.syncTopbar()
    end

    function UI.closeWindow()
        if not winOpen then return end
        winOpen = false
        winHome = win.Position
        tw(winScale, 0.36, { Scale = curScale() * 0.12 }, Quint, In)
        tw(win, 0.36, { Position = orb.Position }, Quint, In)
        task.delay(0.38, function()
            if not winOpen then win.Visible = false end
        end)
        UI.syncTopbar()
    end

    ------------------------------------------------------------------
    -- КАРТОЧКА ВВОДА КЛЮЧА (FINIS VISUAL)
    ------------------------------------------------------------------
    local spinners = {}

    local card = Frame(gui, {
        Name = "KeyCard", AnchorPoint = V2(0.5, 0.5), Position = sc(0.5, 0.5), Size = off(CARD_W, CARD_H),
        BackgroundColor3 = C.white, BackgroundTransparency = 0.1, Visible = false, Active = true, ZIndex = 10,
    })
    cardFrame = card
    Corner(card, 34)
    Grad(card, rgb(70, 66, 122), rgb(24, 22, 50), 120)
    local cardStroke = Stroke(card, C.white, 0.35, 1.5)
    New("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.08), NumberSequenceKeypoint.new(0.4, 0.62), NumberSequenceKeypoint.new(1, 0.8),
        }),
    }, cardStroke)
    local cardScale = New("UIScale", { Scale = 1 }, card)
    local cardDrag = Button(card, { Name = "DragHandle", ZIndex = 1 })
    local cardBody = Group(card, { Name = "Body", Size = sc(1, 1), ZIndex = 2 })

    local kLogo = makeLogoF(cardBody, 78, true, true)
    kLogo.Position = off((CARD_W - 117) / 2, 36)
    local kTitle = Label(cardBody, {
        Position = off(0, 148), Size = off(CARD_W, 38), Text = "Finis Visual",
        TextSize = 32, Font = FONT_B, TextXAlignment = Enum.TextXAlignment.Center,
    })
    Grad(kTitle, rgb(255, 250, 255), rgb(214, 192, 255), 0)
    Label(cardBody, {
        Position = off(0, 194), Size = off(CARD_W, 22), Text = "Введи ключ, чтобы продолжить",
        TextSize = 15, TextColor3 = C.txt2, TextXAlignment = Enum.TextXAlignment.Center,
    })

    local inRoot, keyBox, inStroke, inIcon = Input(card, 35, 232, 425, 58, "key", "Ваш ключ", 18)
    inRoot.ZIndex = 3
    local function setInputAlpha(a)
        inRoot.BackgroundTransparency = 1 - 0.55 * a
        inStroke.Transparency = 1 - 0.1 * a
        keyBox.TextTransparency = 1 - a
        keyBox.PlaceholderText = (a > 0.6) and "Ваш ключ" or ""
        setIconAlpha(inIcon, a)
    end
    Label(cardBody, {
        Position = off(0, 396), Size = off(CARD_W, 16), Text = "FINIS VISUAL  ·  v1.0",
        TextSize = 9.5, TextColor3 = C.txt4, TextXAlignment = Enum.TextXAlignment.Center,
    })

    local function doPaste()
        local txt
        if type(getclipboard) == "function" then
            local ok, r = pcall(getclipboard)
            if ok and type(r) == "string" then txt = trim(r) end
        end
        if txt and txt ~= "" then
            keyBox.Text = txt
            tw(inStroke, 0.15, { Transparency = 0.2, Color = theme.a })
            task.delay(0.6, function() tw(inStroke, 0.3, { Transparency = 0.9, Color = C.white }) end)
            UI.toast("Вставлено", "clipboard")
            burst(inRoot, 396, 29, 9, 26)
        else
            UI.toast("Буфер обмена пуст", "clipboard")
        end
    end

    local pasteWrap = Group(cardBody, { Name = "PasteWrap", Position = off(35, 306), Size = off(141, 52) })
    MakeButton(pasteWrap, 0, 0, 141, 52, "Вставить", "clipboard", "ghost", doPaste)

    local login = Frame(cardBody, { Name = "Login", Position = off(188, 306), Size = off(272, 52), BackgroundColor3 = C.white })
    Corner(login, 16)
    accentGradient(login, 0)
    local lc = Group(login, { Name = "Content", Size = sc(1, 1) })
    do
        local lw = measure("Войти", 16, FONT_B)
        local lx = (272 - (lw + 10 + 16)) / 2
        Label(lc, { Position = off(lx, 0), Size = off(lw + 6, 52), Text = "Войти", TextSize = 16, Font = FONT_B, TextColor3 = C.dark })
        Icon(lc, "arrow", 16, C.dark, { Position = off(lx + lw + 12, 18) })
    end
    local spin = Frame(login, { Name = "Spinner", AnchorPoint = V2(0.5, 0.5), Position = sc(0.5, 0.5), Size = off(24, 24), BackgroundTransparency = 1, Visible = false })
    Corner(spin, "full")
    local spinStroke = Stroke(spin, C.dark, 0, 2.6)
    spinners[#spinners + 1] = New("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.6, 0.4),
            NumberSequenceKeypoint.new(0.68, 1), NumberSequenceKeypoint.new(1, 1),
        }),
    }, spinStroke)
    local chk = Icon(login, "check", 26, C.dark, { Name = "Check", AnchorPoint = V2(0.5, 0.5), Position = sc(0.5, 0.5), Visible = false })
    local chkScale = New("UIScale", {}, chk)
    local loginBtn = Button(login, { ZIndex = 4 })
    addPress(loginBtn, login, 0.97)

    local cardHome = sc(0.5, 0.5)
    local busy = false

    local function orbCenterPos()
        local scr = viewport()
        local a, sz = orb.AbsolutePosition, orb.AbsoluteSize
        return UDim2.fromScale((a.X + sz.X / 2) / scr.X, (a.Y + sz.Y / 2) / scr.Y)
    end

    local function openCard()
        if cardOpen then return end
        cardOpen = true
        UI.syncTopbar()
        card.Visible = true
        cardScale.Scale = curScale() * 0.18
        card.Position = orbCenterPos()
        card.BackgroundTransparency = 0.7
        cardBody.GroupTransparency = 1
        setInputAlpha(0)
        tw(cardScale, 0.58, { Scale = curScale() }, Back, Out)
        tw(card, 0.52, { Position = cardHome, BackgroundTransparency = 0.1 }, Quint, Out)
        task.delay(0.15, function()
            tw(cardBody, 0.38, { GroupTransparency = 0 }, Quad, Out)
            animateValue(0.38, 0, 1, setInputAlpha)
        end)
    end

    local function closeCard()
        if not cardOpen then return end
        cardOpen = false
        UI.syncTopbar()
        cardHome = card.Position
        tw(cardBody, 0.15, { GroupTransparency = 1 }, Quad, Out)
        animateValue(0.15, 1, 0, setInputAlpha)
        tw(cardScale, 0.38, { Scale = curScale() * 0.18 }, Quint, In)
        tw(card, 0.38, { Position = orbCenterPos(), BackgroundTransparency = 0.7 }, Quint, In)
        task.delay(0.4, function()
            if not cardOpen then card.Visible = false end
        end)
    end

    makeDraggable(card, cardDrag, {
        ended = function(moved) if moved then cardHome = card.Position end end,
    })

    local function shake()
        local p = card.Position
        local d = 0.008
        for i, o in ipairs({ d, -d, d * 0.6, -d * 0.6, 0 }) do
            task.delay((i - 1) * 0.06, function()
                tw(card, 0.06, { Position = UDim2.new(p.X.Scale + o, 0, p.Y.Scale, 0) }, Quad, InOut)
            end)
        end
    end

    local function ripple(delay)
        task.delay(delay, function()
            local ring = Frame(cardBody, {
                AnchorPoint = V2(0.5, 0.5), Position = off(35 + 425 / 2, 332), Size = off(56, 56), BackgroundTransparency = 1,
            })
            Corner(ring, "full")
            local rs = Stroke(ring, C.white, 0.35, 1.6)
            tw(ring, 0.9, { Size = off(236, 236) }, Quint, Out)
            tw(rs, 0.9, { Transparency = 1 }, Quad, Out)
            task.delay(1, function() ring:Destroy() end)
        end)
    end

    local function resetLogin()
        spin.Visible = false
        chk.Visible = false
        tw(login, 0.4, { Size = off(272, 52), Position = off(188, 306) }, Quint, Out)
        tw(pasteWrap, 0.3, { GroupTransparency = 0 }, Quad, Out)
        tw(lc, 0.3, { GroupTransparency = 0 }, Quad, Out)
    end

    local function flyShared(winCenter)
        local scr = viewport()
        local k = curScale()
        local function center(o)
            local a, s = o.AbsolutePosition, o.AbsoluteSize
            return V2(a.X + s.X / 2, a.Y + s.Y / 2)
        end
        local fromLogo, fromTitle = center(kLogo), center(kTitle)
        local topLeft = V2(winCenter.X - WIN_W * k / 2, winCenter.Y - WIN_H * k / 2)
        local toLogo  = V2(topLeft.X + 44 * k, topLeft.Y + 39 * k)
        local toTitle = V2(topLeft.X + 165 * k, topLeft.Y + 29 * k)

        local host = Frame(gui, { Name = "Fly", BackgroundTransparency = 1, Size = sc(1, 1), ZIndex = 40 })
        local fl = Frame(host, {
            AnchorPoint = V2(0.5, 0.5), BackgroundTransparency = 1,
            Size = off(117, 78), Position = UDim2.fromScale(fromLogo.X / scr.X, fromLogo.Y / scr.Y),
        })
        local fls = New("UIScale", { Scale = k }, fl)
        makeLogoF(fl, 78, true, false)

        local ft = Label(host, {
            AnchorPoint = V2(0.5, 0.5), Size = off(240, 40), Text = "Finis Visual", TextSize = 32, Font = FONT_B,
            TextXAlignment = Enum.TextXAlignment.Center, Position = UDim2.fromScale(fromTitle.X / scr.X, fromTitle.Y / scr.Y),
        })
        Grad(ft, rgb(255, 250, 255), rgb(214, 192, 255), 0)
        local fts = New("UIScale", { Scale = k }, ft)

        kLogo.Visible = false
        kTitle.Visible = false
        tw(fl, 0.62, { Position = UDim2.fromScale(toLogo.X / scr.X, toLogo.Y / scr.Y) }, Quint, InOut)
        tw(fls, 0.62, { Scale = k * 0.51 }, Quint, InOut)
        tw(ft, 0.62, { Position = UDim2.fromScale(toTitle.X / scr.X, toTitle.Y / scr.Y) }, Quint, InOut)
        tw(fts, 0.62, { Scale = k * 0.78 }, Quint, InOut)
        task.delay(0.75, function() host:Destroy() end)
    end

    local function goMain()
        authed = true
        local scr = viewport()
        local k = curScale()
        local c = card.AbsolutePosition + card.AbsoluteSize / 2
        local hw, hh = WIN_W * k / 2, WIN_H * k / 2
        local px = math.clamp(c.X, hw, math.max(hw, scr.X - hw))
        local py = math.clamp(c.Y, hh, math.max(hh, scr.Y - hh))
        winHome = UDim2.fromScale(px / scr.X, py / scr.Y)
        winOpen = true
        UI.syncTopbar()
        win.Visible = true
        winScale.Scale = k
        win.Size = off(CARD_W, CARD_H)
        win.Position = card.Position
        flyShared(V2(px, py))
        tw(win, 0.58, { Size = off(WIN_W, WIN_H), Position = winHome }, Quint, Out)
        tw(cardBody, 0.24, { GroupTransparency = 1 }, Quad, Out)
        animateValue(0.24, 1, 0, setInputAlpha)
        task.delay(0.28, function()
            card.Visible = false
            cardOpen = false
            busy = false
        end)
    end

    local function doLogin()
        if busy then return end
        local txt = trim(keyBox.Text)
        if txt == "" then
            UI.toast("Введи ключ", "key")
            shake()
            return
        end
        busy = true
        keyBox:ReleaseFocus()
        tw(pasteWrap, 0.25, { GroupTransparency = 1 }, Quad, Out)
        tw(lc, 0.2, { GroupTransparency = 1 }, Quad, Out)
        tw(login, 0.45, { Size = off(56, 52), Position = off(35 + (425 - 56) / 2, 306) }, Quint, Out)
        task.delay(0.28, function() if busy then spin.Visible = true end end)
        task.delay(1.05, function()
            if string.lower(txt) == KEY then
                spin.Visible = false
                chk.Visible = true
                chkScale.Scale = 0.2
                tw(chkScale, 0.4, { Scale = 1 }, Back, Out)
                ripple(0)
                ripple(0.22)
                task.delay(0.85, goMain)
            else
                resetLogin()
                tw(inStroke, 0.15, { Color = C.red, Transparency = 0.1 })
                task.delay(0.9, function() tw(inStroke, 0.3, { Color = C.white, Transparency = 0.9 }) end)
                shake()
                UI.toast("Неверный ключ", "x")
                busy = false
            end
        end)
    end

    loginBtn.Activated:Connect(doLogin)
    keyBox.FocusLost:Connect(function(enter) if enter then doLogin() end end)

    function UI.orbTap()
        if not authed then
            if busy then return end
            if cardOpen then closeCard() else openCard() end
        else
            if winOpen then UI.closeWindow() else UI.openWindow() end
        end
    end

    -- Горячая клавиша RightShift на ПК
    bind(UserInputService.InputBegan, function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.RightShift and orb.Visible then
            UI.orbTap()
        end
    end)

    ------------------------------------------------------------------
    -- ГЛАВНЫЙ ЦИКЛ (СВЕЧЕНИЕ ШАРА, ИСКРЫ, ЧАСТИЦЫ)
    ------------------------------------------------------------------
    bind(RunService.Heartbeat, function(dt)
        local now = os.clock()
        arcGrad.Rotation = (now * 240) % 360
        for _, g in ipairs(spinners) do g.Rotation = (now * 420) % 360 end
        for _, sp in ipairs(sparks) do
            if sp.f.Parent then
                sp.th = sp.th + dt * sp.sp
                local x, y = sp.a * math.cos(sp.th), sp.b * math.sin(sp.th)
                local cph, sph = math.cos(sp.phi), math.sin(sp.phi)
                sp.f.Position = off(sp.cx + x * cph - y * sph, sp.cy + x * sph + y * cph)
                local k = 0.65 + 0.35 * math.sin(now * 3.2 + sp.th * 2)
                sp.f.Size = off(sp.s * k, sp.s * k)
            end
        end
        if winOpen then
            for i = 1, PN do
                local p = P[i]
                p.y = p.y - p.vy * dt
                p.x = p.x + (p.vx + math.sin(now * 0.7 + p.ph) * 5) * dt
                if p.y < 24 then
                    p.y = WIN_H - 24
                    p.x = math.random(30, WIN_W - 30)
                end
                p.f.Position = off(p.x, p.y)
                p.f.BackgroundTransparency = 0.45 + 0.4 * (0.5 + 0.5 * math.sin(now * 1.4 + p.ph))
            end
        end
    end)

    gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyScales)

    ------------------------------------------------------------------
    -- 3D-ИНТРО БУКВЫ "F" С ПЕРЕЛЁТОМ ТОЧНО В ШАР (ORB)
    ------------------------------------------------------------------
    local DimOverlay = Frame(gui, {
        Name = "IntroDim", Size = sc(1, 1),
        BackgroundColor3 = rgb(6, 7, 16), BackgroundTransparency = 1, ZIndex = 48,
    })

    local IntroVP = New("ViewportFrame", {
        Name = "Intro3DF", Size = sc(1, 1), BackgroundTransparency = 1,
        Ambient = rgb(160, 168, 210), LightColor = C.white,
        LightDirection = Vector3.new(-1, -1, 1), ZIndex = 50,
    }, gui)

    local IntroWorld = New("WorldModel", {}, IntroVP)
    local IntroCam = New("Camera", {
        FieldOfView = 42,
        CFrame = CFrame.lookAt(Vector3.new(0, 0, -13.5), Vector3.zero),
    }, IntroVP)
    IntroVP.CurrentCamera = IntroCam

    local introBars = {}
    local function Create3DBar(w, h, targetCF, startCF)
        local rim = New("Part", {
            Size = Vector3.new(w, h, 0.58), Color = rgb(225, 222, 255),
            Material = Enum.Material.SmoothPlastic, Anchored = true,
        }, IntroWorld)
        local face = New("Part", {
            Size = Vector3.new(w - 0.14, h - 0.14, 0.10), Color = rgb(118, 114, 178),
            Material = Enum.Material.SmoothPlastic, Anchored = true,
        }, IntroWorld)
        local back = New("Part", {
            Size = Vector3.new(w - 0.14, h - 0.14, 0.10), Color = rgb(118, 114, 178),
            Material = Enum.Material.SmoothPlastic, Anchored = true,
        }, IntroWorld)
        table.insert(introBars, { rim = rim, face = face, back = back, target = targetCF, start = startCF })
    end

    -- 3 объёмных элемента буквы "F"
    Create3DBar(0.88, 4.30, CFrame.new(1.15, 0.0, 0),  CFrame.new(5.8, -3.5, 4.0) * CFrame.Angles(1.2, -1.6, 0.8))
    Create3DBar(2.95, 0.88, CFrame.new(-0.35, 1.71, 0), CFrame.new(-5.5, 4.8, 3.0) * CFrame.Angles(-1.4, 1.3, -0.9))
    Create3DBar(2.35, 0.84, CFrame.new(-0.05, 0.08, 0), CFrame.new(-6.2, -2.8, -2.5) * CFrame.Angles(0.9, 1.8, 0.7))

    local function PlaceBar(bar, worldCF)
        bar.rim.CFrame  = worldCF
        bar.face.CFrame = worldCF * CFrame.new(0, 0, -0.26)
        bar.back.CFrame = worldCF * CFrame.new(0, 0, 0.26)
    end

    local function EaseOutBack(x)
        local c1 = 1.45
        local c3 = c1 + 1
        return 1 + c3 * ((x - 1) ^ 3) + c1 * ((x - 1) ^ 2)
    end

    local function EaseInOutCubic(x)
        return x < 0.5 and 4 * x ^ 3 or 1 - ((-2 * x + 2) ^ 3) / 2
    end

    local function ScreenToWorldPos(sx, sy, pxH, W, H)
        local halfTan = math.tan(math.rad(IntroCam.FieldOfView * 0.5))
        local dist = (4.3 * H) / (2 * math.max(pxH, 1) * halfTan)
        local halfH = dist * halfTan
        local halfW = halfH * (W / math.max(H, 1))
        local nx = (sx / math.max(W, 1)) * 2 - 1
        local ny = 1 - (sy / math.max(H, 1)) * 2
        local cf = IntroCam.CFrame
        return cf.Position + cf.LookVector * dist + cf.RightVector * (nx * halfW) + cf.UpVector * (ny * halfH)
    end

    -- Запуск интро
    tw(DimOverlay, 0.35, { BackgroundTransparency = 0.52 })

    local startClock = os.clock()
    local baseTilt = CFrame.Angles(0, 0, math.rad(-22))
    local faceBase = rgb(118, 114, 178)
    local faceFlash = rgb(248, 246, 255)
    local dimCleared = false
    local landed = false

    local introConn
    introConn = bind(RunService.RenderStepped, function()
        local elapsed = os.clock() - startClock

        -- 1. Сборка 3D "F"
        if elapsed < 0.90 then
            for i, bar in ipairs(introBars) do
                local alpha = math.clamp((elapsed - (i - 1) * 0.10) / 0.65, 0, 1)
                PlaceBar(bar, baseTilt * bar.start:Lerp(bar.target, EaseOutBack(alpha)))
            end

        -- 2. Покачивание + металлический блик
        elseif elapsed < 1.90 then
            local t = (elapsed - 0.90) / 1.0
            local hoverCF = baseTilt * CFrame.Angles(math.sin(t * math.pi) * 0.08, math.sin(t * math.pi * 2) * 0.14, 0)
            local sheen = 0
            if elapsed > 1.12 and elapsed < 1.78 then
                local p = (elapsed - 1.12) / 0.66
                sheen = math.sin(p * math.pi)
                IntroVP.LightDirection = Vector3.new(-2 + p * 4, -1.5 + p * 2.5, 1)
            end
            IntroVP.Ambient = rgb(160, 168, 210):Lerp(C.white, sheen * 0.9)
            for _, bar in ipairs(introBars) do
                PlaceBar(bar, hoverCF * bar.target)
                bar.face.Color = faceBase:Lerp(faceFlash, sheen * 0.92)
            end

        -- 3. Полёт 3D "F" точно в центр шара Orb
        elseif elapsed < 2.65 then
            local p = math.clamp((elapsed - 1.90) / 0.75, 0, 1)
            local e = EaseInOutCubic(p)

            if not dimCleared then
                dimCleared = true
                tw(DimOverlay, 0.45, { BackgroundTransparency = 1 })
            end

            local scr = viewport()
            local W, H = scr.X, scr.Y
            local targetUDim, targetPxPos = getOrbStartPos()
            orb.Position = targetUDim

            local halfTan = math.tan(math.rad(IntroCam.FieldOfView * 0.5))
            local startPx = (4.3 * H) / (2 * 13.5 * halfTan)
            local targetPx = 28 * baseScale()

            local curX = (W * 0.5) + (targetPxPos.X - W * 0.5) * e
            local curY = (H * 0.5) + (targetPxPos.Y - H * 0.5) * e - math.sin(p * math.pi) * (35 * baseScale())
            local curPx = startPx + (targetPx - startPx) * e

            local worldPos = ScreenToWorldPos(curX, curY, curPx, W, H)
            local spinRot = CFrame.Angles(0, math.sin(p * math.pi) * 1.1, math.rad(-22 + 6 * e))
            local worldCF = CFrame.new(worldPos) * spinRot

            local fade = math.clamp((p - 0.91) / 0.09, 0, 1)
            for _, bar in ipairs(introBars) do
                PlaceBar(bar, worldCF * bar.target)
                bar.rim.Transparency  = fade
                bar.face.Transparency = fade
                bar.back.Transparency = fade
            end

            if p >= 0.91 and not landed then
                landed = true
                orb.Visible = true
                orbScale.Scale = baseScale() * 0.25
                tw(orbScale, 0.55, { Scale = baseScale() }, Back, Out)
                UI.toast("Finis Visual готов — нажми на шар F", "sparkle")
            end
        else
            introConn:Disconnect()
            if not landed then
                orb.Visible = true
                tw(orbScale, 0.5, { Scale = baseScale() }, Back, Out)
            end
            IntroVP:Destroy()
            DimOverlay:Destroy()
        end
    end)
end

BuildShell()