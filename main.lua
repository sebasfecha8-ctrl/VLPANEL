getgenv().LPD_ADMIN_SECRET = "NjCDceh6djcZy0asTJVNRaa2x62XG2qrGHGFbZsi" -- poné acá TU secret (solo en tu copia personal)
--[[
VLP PANEL v7 | Xeno
Key de 1 persona + Admin Panel + Blacklist + Feedback + Servers + Config guardada + THEMES
K = ocultar/mostrar | "-" = minimizar | arrastrable (no se sale de la pantalla)

ADMIN: para crear keys / blacklistear / borrar feedback, poné ESTA línea
arriba de todo SOLO en tu copia personal (NUNCA en la copia que compartas):
    getgenv().LPD_ADMIN_SECRET = "TU_DATABASE_SECRET"
]]

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UIS             = game:GetService("UserInputService")
local TS              = game:GetService("TweenService")
local CoreGui         = game:GetService("CoreGui")
local HttpService     = game:GetService("HttpService")
local Stats           = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local genv = (getgenv and getgenv()) or _G
if genv.LPD_Unload then pcall(genv.LPD_Unload) end
math.randomseed(tick() * 1000)

--// ================= CONFIGURACION =================
local DB_URL      = "https://blacklist-lester-panel-default-rtdb.firebaseio.com" -- sin "/" al final
local DISCORD     = "discord.com/users/yetsimlester"
local DISCORD2    = "discord.com/users/viejitofeo_01"
local KEYFILE     = "lpd_k.dat"
local FB_FILE     = "lpd_fb.dat"
local WEBHOOK     = "https://discord.com/api/webhooks/1557498131480846397/hXPEp_Q_flcLox3EFuuQU1prHLhHwFk6Gg_XNhCbWNyAVo96uU7ECwoboXJLQ0DJl5Es"
local CFG_FILE    = "lpd_cfg.json"
local SRV_FILE    = "lpd_srv.json"
local ADMIN_IDS   = {[5211336566] = true, [3392474417] = true}
local ADMIN_NAMES = {["lionelpepsiisok"] = true}
local isAdmin     = ADMIN_IDS[LP.UserId] or ADMIN_NAMES[LP.Name] or false

local ICON  = "rbxassetid://81376203365120"
local FONT  = Enum.Font.GothamMedium
local FONTB = Enum.Font.GothamBold
local TITLE = "VLP PANEL V7.00"

local Cfg = {
	Aimbot = false, Aimlock = false, HoldRMB = true,
	AimHead = true, AimTorso = false, AimLArm = false, AimRArm = false, AimLLeg = false, AimRLeg = false,
	Smooth = 5, FOV = 150, ShowFOV = true, TeamCheck = true, WallCheck = true, FriendCheck = false,
	AimMaxDist = 1000,
	Trigger = false, TrigDelay = 0, TrigHold = false,
	ESP = false, ESPBox = true, ESPTracer = true, ESPSkel = false, ESPName = true,
	ESPHealth = true, ESPDist = true, ESPItems = false, ESPVis = false, ESPMaxDist = 1000,
	ESPHPNum = true, ESPSpeed = true, ESPPing = true,
	Hitbox = false, HitSize = 8, HitTrans = 70,
	Noclip = false, Fly = false, FlySpeed = 60,
	InfJump = false, Evasive = false, SpeedWalk = false, WalkSpeed = 32,
	ThemeHue = 0, ThemeSat = 100, ThemeVal = 100, Theme = "VLP Red", UIScale = 100,
	Rainbow = false, RainbowSpeed = 60, PanelTrans = 0, FontName = "Gotham", TracerPos = "Arriba",
	FOVCam = false, FOVCamValue = 90, FPSBoost = false, Headless = false, Korblox = false,
	AnimIdle = "0", AnimWalk = "0", AnimRun = "0", AnimJump = "0", AnimFall = "0",
	AnimClimb = "0", AnimSwim = "0", AnimSwimIdle = "0", AnimSit = "0", AnimTool = "0",
}

--// ================= CONFIG GUARDADA =================
local Blacklist = {} -- [UserId] = nombre (jugadores ignorados: sin aimbot/ESP/hitbox/etc)
local Binds = {}     -- [claveCfg] = nombre de tecla
local dirty = false
local function markDirty() dirty = true end

local function loadCfg()
	local ok, raw = pcall(function() if isfile and isfile(CFG_FILE) then return readfile(CFG_FILE) end end)
	if not ok or type(raw) ~= "string" then return end
	local okd, data = pcall(HttpService.JSONDecode, HttpService, raw)
	if not okd or type(data) ~= "table" then return end
	if type(data.cfg) == "table" then
		for k, v in pairs(data.cfg) do
			if Cfg[k] ~= nil and type(Cfg[k]) == type(v) then Cfg[k] = v end
		end
	end
	if type(data.bl) == "table" then
		for _, e in ipairs(data.bl) do
			if type(e) == "table" and tonumber(e.id) then Blacklist[tonumber(e.id)] = tostring(e.name or "?") end
		end
	end
	if type(data.binds) == "table" then
		for k, v in pairs(data.binds) do
			if Cfg[k] ~= nil and type(Cfg[k]) == "boolean" and type(v) == "string" then Binds[k] = v end
		end
	end
end

local function saveNow()
	local bl = {}
	for id, n in pairs(Blacklist) do bl[#bl + 1] = {id = id, name = n} end
	pcall(function()
		if writefile then writefile(CFG_FILE, HttpService:JSONEncode({cfg = Cfg, bl = bl, binds = Binds})) end
	end)
end

loadCfg()
Cfg.UIScale  = math.clamp(Cfg.UIScale, 70, 200)
Cfg.PanelTrans = math.clamp(Cfg.PanelTrans, 0, 90)
Cfg.ThemeHue = Cfg.ThemeHue % 360
Cfg.ThemeSat = math.clamp(Cfg.ThemeSat, 2, 100)
Cfg.ThemeVal = math.clamp(Cfg.ThemeVal, 20, 100)

--// ================= THEMES PREDETERMINADOS =================
-- hue/sat/val = color base (el panel es rojo de fábrica y se rota a ese tono)
-- font = fuente | trans = transparencia del panel | radius = multiplicador de bordes redondeados
-- gloss = brillo de burbuja + resplandor central | shine = borde animado | rain = lluvia estilo Matrix
local THEMES = {
	{name = "VLP Red", desc = "El clásico de siempre", hue = 0, sat = 100, val = 100, font = "Gotham", trans = 0,
		radius = 1, gloss = false, shine = true, rain = false,
		c1 = Color3.fromRGB(255, 0, 5), c2 = Color3.fromRGB(81, 0, 2)},
	{name = "Bubble Glass", desc = "Vidrio azul con glow", hue = 214, sat = 90, val = 100, font = "Nunito", trans = 20,
		radius = 1.8, gloss = true, shine = false, rain = false,
		c1 = Color3.fromRGB(40, 120, 255), c2 = Color3.fromRGB(4, 10, 28)},
	{name = "Roblox Classic", desc = "Gris y negro clásico", hue = 0, sat = 2, val = 80, font = "Source Sans", trans = 5,
		radius = 0.3, gloss = false, shine = false, rain = false,
		c1 = Color3.fromRGB(125, 125, 125), c2 = Color3.fromRGB(25, 25, 25)},
	{name = "Matrix", desc = "Lluvia de código", hue = 125, sat = 100, val = 85, font = "Code", trans = 30,
		radius = 0.2, gloss = false, shine = true, rain = true,
		c1 = Color3.fromRGB(0, 230, 60), c2 = Color3.fromRGB(0, 35, 8)},
	{name = "Cyber Neon", desc = "Magenta y violeta", hue = 300, sat = 100, val = 100, font = "Ubuntu", trans = 10,
		radius = 0.8, gloss = false, shine = true, rain = false,
		c1 = Color3.fromRGB(255, 0, 210), c2 = Color3.fromRGB(55, 0, 110)},
	{name = "Sakura Pastel", desc = "Rosa pastel suave", hue = 335, sat = 55, val = 100, font = "Nunito", trans = 15,
		radius = 1.5, gloss = true, shine = true, rain = false,
		c1 = Color3.fromRGB(255, 160, 205), c2 = Color3.fromRGB(140, 50, 100)},
	{name = "Royal Gold", desc = "Negro y dorado", hue = 42, sat = 95, val = 95, font = "Oswald", trans = 5,
		radius = 0.7, gloss = false, shine = true, rain = false,
		c1 = Color3.fromRGB(255, 205, 60), c2 = Color3.fromRGB(70, 45, 0)},
}
local function themeByName(n) for _, t in ipairs(THEMES) do if t.name == n then return t end end return THEMES[1] end
local Style = {radius = 1, gloss = false, shine = true, rain = false}
do
	local t0 = themeByName(Cfg.Theme)
	Cfg.Theme = t0.name
	Style.radius, Style.gloss, Style.shine, Style.rain = t0.radius, t0.gloss, t0.shine, t0.rain
end

-- fuentes disponibles (regular, negrita)
local FAMS = {
	{"Gotham", Enum.Font.GothamMedium, Enum.Font.GothamBold},
	{"Source Sans", Enum.Font.SourceSans, Enum.Font.SourceSansBold},
	{"Ubuntu", Enum.Font.Ubuntu, Enum.Font.Ubuntu},
	{"Nunito", Enum.Font.Nunito, Enum.Font.Nunito},
	{"Oswald", Enum.Font.Oswald, Enum.Font.Oswald},
	{"Code", Enum.Font.Code, Enum.Font.Code},
	{"Michroma", Enum.Font.Michroma, Enum.Font.Michroma},
	{"SciFi", Enum.Font.SciFi, Enum.Font.SciFi},
	{"Arcade", Enum.Font.Arcade, Enum.Font.Arcade},
	{"Bangers", Enum.Font.Bangers, Enum.Font.Bangers},
	{"Fantasy", Enum.Font.Fantasy, Enum.Font.Fantasy},
}
local function famByName(n) for _, f in ipairs(FAMS) do if f[1] == n then return f end end return FAMS[1] end
local curFam = famByName(Cfg.FontName)
Cfg.FontName = curFam[1]
local FONT_NAMES = {}
for i, f in ipairs(FAMS) do FONT_NAMES[i] = f[1] end

--// ================= COLORES / TEMA =================
local function hueShift(c, h, s, v)
	local H, S, V = c:ToHSV()
	if S > .25 then return Color3.fromHSV((H + h) % 1, math.clamp(S * s, 0, 1), math.clamp(V * (v or 1), 0, 1)) end
	return c
end
local BASE = {
	Red = Color3.fromRGB(255, 0, 5), Mid = Color3.fromRGB(215, 0, 5), Dark = Color3.fromRGB(81, 0, 2),
	Darker = Color3.fromRGB(35, 0, 1), Pink = Color3.fromRGB(255, 150, 150),
}
local C = {White = Color3.new(1, 1, 1), Off = Color3.fromRGB(50, 50, 50), Green = Color3.fromRGB(60, 255, 110),
	Gold = Color3.fromRGB(255, 200, 50)}
local curHue, curSat, curVal = Cfg.ThemeHue, Cfg.ThemeSat, Cfg.ThemeVal
local function buildPalette() for k, v in pairs(BASE) do C[k] = hueShift(v, curHue / 360, curSat / 100, curVal / 100) end end
buildPalette()
local function T(r, g, b) return hueShift(Color3.fromRGB(r, g, b), curHue / 360, curSat / 100, curVal / 100) end

--// ================= HELPERS =================
local function rname(n) local t = {} for i = 1, n or 12 do t[i] = string.char(math.random(97, 122)) end return table.concat(t) end

local function clip(s, n)
	local len = utf8.len(s)
	if not len then return s:sub(1, n) end
	if len <= n then return s end
	return s:sub(1, utf8.offset(s, n + 1) - 1)
end

local conns, cleanups = {}, {}
local function bind(sig, fn) local c = sig:Connect(fn); conns[#conns + 1] = c; return c end

local function tw(o, t, p, style, dir)
	local tr = TS:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), p)
	tr:Play(); return tr
end

local function mk(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	if props.Font ~= nil then
		local b = (props.Font == FONTB)
		o:SetAttribute("FB", b)
		o.Font = b and curFam[3] or curFam[2]
	end
	o.Parent = parent
	return o
end

local function scaleR(r) if r >= 40 then return r end return math.max(1, math.floor(r * Style.radius + .5)) end
local function corner(p, r)
	local c = mk("UICorner", {CornerRadius = UDim.new(0, scaleR(r))}, p)
	c:SetAttribute("R", r)
	return c
end
local function redGrad(p, rot) return mk("UIGradient", {Rotation = rot or 90, Color = ColorSequence.new(C.Dark, C.Mid)}, p) end
local function noTheme(o) o:SetAttribute("NoTheme", true); return o end

-- brillo tipo burbuja + resplandor central (solo visible en themes con gloss = true)
local function gloss(p, strength, hFrac, glow)
	if glow ~= false then
		local gl = mk("Frame", {Name = "Gloss", Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = C.Red,
			BackgroundTransparency = .5, BorderSizePixel = 0, Visible = Style.gloss}, p)
		corner(gl, 8)
		noTheme(mk("UIGradient", {Rotation = 0, Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.5, 0), NumberSequenceKeypoint.new(1, 1)}}, gl))
	end
	local g = mk("Frame", {Name = "Gloss", Position = UDim2.fromOffset(3, 2), Size = UDim2.new(1, -6, hFrac or .5, -2),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Visible = Style.gloss}, p)
	noTheme(g)
	corner(g, 8)
	noTheme(mk("UIGradient", {Rotation = 90, Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, strength or .72), NumberSequenceKeypoint.new(1, 1)}}, g))
	return g
end

local shines = {}
local function shineStroke(p, th)
	local s = mk("UIStroke", {Thickness = th, Color = C.White, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, p)
	local g = mk("UIGradient", {Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, C.Dark), ColorSequenceKeypoint.new(0.35, C.Red),
		ColorSequenceKeypoint.new(0.5, T(255, 170, 170)),
		ColorSequenceKeypoint.new(0.65, C.Red), ColorSequenceKeypoint.new(1, C.Dark)}}, s)
	shines[#shines + 1] = g
	return s
end

local function val(x) return type(x) == "function" and x() or x end
local function fx(btn, target, base, hov)
	local sc = target:FindFirstChild("FX") or mk("UIScale", {Name = "FX"}, target)
	bind(btn.MouseEnter, function() tw(target, .15, {BackgroundTransparency = val(hov)}); tw(sc, .15, {Scale = 1.012}) end)
	bind(btn.MouseLeave, function() tw(target, .2, {BackgroundTransparency = val(base)}); tw(sc, .2, {Scale = 1}) end)
	bind(btn.MouseButton1Down, function() tw(sc, .08, {Scale = .95}) end)
	bind(btn.MouseButton1Up, function() tw(sc, .2, {Scale = 1.012}, Enum.EasingStyle.Back) end)
end

local container = CoreGui
pcall(function() if gethui then container = gethui() end end)
local Gui = mk("ScreenGui", {Name = rname(14), ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999}, container)
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)

local function setFont(name)
	curFam = famByName(name)
	for _, o in ipairs(Gui:GetDescendants()) do
		local b = o:GetAttribute("FB")
		if b ~= nil then o.Font = b and curFam[3] or curFam[2] end
	end
end

local rot = 0
bind(RunService.RenderStepped, function(dt)
	if Style.shine then rot = (rot + dt * 160) % 360 else rot = 90 end
	for _, g in ipairs(shines) do g.Rotation = rot end
end)

-- cambiar tono + saturación + brillo de TODO el panel en vivo
local function applyTheme(deg, sat, val)
	deg = deg % 360
	sat = math.clamp(sat or curSat, 2, 100)
	val = math.clamp(val or curVal, 20, 100)
	if deg == curHue and sat == curSat and val == curVal then return end
	local d = ((deg - curHue) % 360) / 360
	local curH = curHue / 360
	local sOld = curSat / 100
	local ratio = sat / curSat
	local vratio = val / curVal
	local function sh(c)
		local H, S, V = c:ToHSV()
		if S > .25 * sOld then
			local dist = math.abs(H - curH); dist = math.min(dist, 1 - dist)
			if dist < .06 then return Color3.fromHSV((H + d) % 1, math.clamp(S * ratio, 0, 1), math.clamp(V * vratio, 0, 1)) end
		end
		return c
	end
	for _, o in ipairs(Gui:GetDescendants()) do
		if not o:GetAttribute("NoTheme") then
			if o:IsA("GuiObject") then o.BackgroundColor3 = sh(o.BackgroundColor3) end
			if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then o.TextColor3 = sh(o.TextColor3) end
			if o:IsA("TextBox") then o.PlaceholderColor3 = sh(o.PlaceholderColor3) end
			if o:IsA("UIStroke") then o.Color = sh(o.Color) end
			if o:IsA("UIGradient") then
				local ks = {}
				for i, k in ipairs(o.Color.Keypoints) do ks[i] = ColorSequenceKeypoint.new(k.Time, sh(k.Value)) end
				o.Color = ColorSequence.new(ks)
			end
		end
	end
	curHue, curSat, curVal = deg, sat, val
	buildPalette()
end

-- aplica el estilo (bordes, brillo, borde animado, lluvia) de un theme
local function applyStyle(t)
	Style.radius, Style.gloss, Style.shine, Style.rain = t.radius, t.gloss, t.shine, t.rain
	for _, o in ipairs(Gui:GetDescendants()) do
		if o:IsA("UICorner") then
			local r = o:GetAttribute("R")
			if r then o.CornerRadius = UDim.new(0, scaleR(r)) end
		elseif o.Name == "Gloss" then
			o.Visible = Style.gloss
		end
	end
	if Style.hook then Style.hook() end
end

local function fmtT(s)
	s = math.floor(s)
	if s <= 0 then return "Permanente" end
	local d, h, m = math.floor(s / 86400), math.floor(s % 86400 / 3600), math.floor(s % 3600 / 60)
	if d > 0 then return d .. "d " .. h .. "h" elseif h > 0 then return h .. "h " .. m .. "m" end
	return m .. "m " .. (s % 60) .. "s"
end

local function copy(t)
	local ok = pcall(function() if setclipboard then setclipboard(t) elseif toclipboard then toclipboard(t) else error("x") end end)
	return ok
end

-- notificaciones
local notifCount = 0
local function notify(msg)
	local k = notifCount; notifCount += 1
	local n = mk("Frame", {AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 300, 1, -20 - k * 52),
		Size = UDim2.fromOffset(250, 42), BackgroundColor3 = C.White, BackgroundTransparency = .1, BorderSizePixel = 0}, Gui)
	corner(n, 8); redGrad(n, 0); shineStroke(n, 1.5)
	mk("TextLabel", {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.fromOffset(8, 0), BackgroundTransparency = 1,
		Text = msg, Font = FONTB, TextSize = 12, TextColor3 = C.White, TextWrapped = true}, n)
	tw(n, .4, {Position = UDim2.new(1, -20, 1, -20 - k * 52)}, Enum.EasingStyle.Back)
	task.delay(2.4, function()
		tw(n, .3, {Position = UDim2.new(1, 300, 1, -20 - k * 52)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		task.delay(.35, function() n:Destroy(); notifCount -= 1 end)
	end)
end

-- pop in/out (respeta la escala elegida por el usuario)
local tokens = {}
local function popIn(o)
	tokens[o] = (tokens[o] or 0) + 1
	o.Pop.Scale = .01; o.Visible = true
	tw(o.Pop, .4, {Scale = o:GetAttribute("BaseScale") or 1}, Enum.EasingStyle.Back)
end
local function popOut(o)
	tokens[o] = (tokens[o] or 0) + 1
	local tk = tokens[o]
	tw(o.Pop, .22, {Scale = .01}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	task.delay(.23, function() if tokens[o] == tk then o.Visible = false end end)
end

-- limitar posición para que nunca se salga de la pantalla (frames con AnchorPoint .5,.5)
local function clampPos(frame, pos)
	local vp = Camera.ViewportSize
	local sc = frame:GetAttribute("BaseScale") or 1
	local hw, hh = frame.Size.X.Offset * sc / 2, frame.Size.Y.Offset * sc / 2
	local cx = math.clamp(pos.X.Scale * vp.X + pos.X.Offset, hw, math.max(hw, vp.X - hw))
	local cy = math.clamp(pos.Y.Scale * vp.Y + pos.Y.Offset, hh, math.max(hh, vp.Y - hh))
	return UDim2.fromOffset(cx, cy)
end

-- arrastrar con inercia + límites de pantalla
local function draggable(handle, frame, onClick)
	local dragging, active, moved = false, false, false
	local sm, sp, target
	bind(handle.InputBegan, function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging, active, moved = true, true, false
			frame.Position = clampPos(frame, frame.Position)
			sm, sp, target = i.Position, frame.Position, frame.Position
		end
	end)
	bind(UIS.InputChanged, function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - sm
			if d.Magnitude > 5 then moved = true end
			if moved then target = clampPos(frame, UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)) end
		end
	end)
	bind(UIS.InputEnded, function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			if not moved and onClick then onClick() end
		end
	end)
	bind(RunService.RenderStepped, function()
		if not active or not target then return end
		frame.Position = frame.Position:Lerp(target, .35)
		if not dragging and math.abs(frame.Position.X.Offset - target.X.Offset) < .5
			and math.abs(frame.Position.Y.Offset - target.Y.Offset) < .5 then
			frame.Position = target; active = false
		end
	end)
end

local function circleBtn(parent, txt, xoff)
	local b = mk("TextButton", {AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -xoff, .5, 0),
		Size = UDim2.fromOffset(26, 26), BackgroundColor3 = C.Dark, BackgroundTransparency = .2, Text = txt,
		Font = FONTB, TextSize = 15, TextColor3 = C.White, AutoButtonColor = false}, parent)
	corner(b, 99); mk("UIStroke", {Color = C.Red, Thickness = 1}, b)
	fx(b, b, .2, 0)
	return b
end

local function fancyBtn(parent, text, size, pos, anchor)
	local f = mk("Frame", {AnchorPoint = anchor or Vector2.zero, Position = pos, Size = size, BackgroundColor3 = C.White,
		BackgroundTransparency = .15, BorderSizePixel = 0}, parent)
	corner(f, 10); redGrad(f, 90); shineStroke(f, 1.5); gloss(f)
	local b = mk("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = text, Font = FONTB,
		TextSize = 15, TextColor3 = C.White, AutoButtonColor = false}, f)
	fx(b, f, .15, 0)
	return f, b
end

local function fancyBox(parent, ph, size, pos, anchor)
	local f = mk("Frame", {AnchorPoint = anchor or Vector2.zero, Position = pos, Size = size, BackgroundColor3 = C.White,
		BackgroundTransparency = .05, BorderSizePixel = 0}, parent)
	corner(f, 99)
	mk("UIGradient", {Rotation = 90, Color = ColorSequence.new(T(18, 0, 1), T(75, 0, 3))}, f)
	local st = shineStroke(f, 1.5)
	local sc = mk("UIScale", {}, f)
	local tb = mk("TextBox", {Size = UDim2.new(1, -24, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1,
		Text = "", PlaceholderText = ph, PlaceholderColor3 = T(190, 110, 110), Font = FONTB, TextSize = 15,
		TextColor3 = C.White, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Center}, f)
	bind(tb.Focused, function() tw(st, .2, {Thickness = 3}); tw(sc, .25, {Scale = 1.03}, Enum.EasingStyle.Back) end)
	bind(tb.FocusLost, function() tw(st, .2, {Thickness = 1.5}); tw(sc, .25, {Scale = 1}, Enum.EasingStyle.Back) end)
	return f, tb
end

local function smallBtn(parent, text, w, xoff)
	local f = mk("Frame", {AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -xoff, .5, 0), Size = UDim2.fromOffset(w, 26),
		BackgroundColor3 = C.Red, BackgroundTransparency = .2, BorderSizePixel = 0}, parent)
	corner(f, 7); mk("UIStroke", {Color = C.White, Transparency = .6}, f)
	local b = mk("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = text, Font = FONTB,
		TextSize = 12, TextColor3 = C.White, AutoButtonColor = false}, f)
	fx(b, f, .2, 0)
	return b
end

local function Unload()
	pcall(saveNow)
	for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
	for _, f in ipairs(cleanups) do pcall(f) end
	pcall(function() Gui:Destroy() end)
	genv.LPD_Unload = nil
end
genv.LPD_Unload = Unload

--// ================= CENSURA DE FEEDBACK =================
-- Reemplaza insultos / links por asteriscos. Detecta letras estiradas (puuuta),
-- leet (p0rn, m13rd4) y respeta límites de palabra (no censura "computadora" ni "pijama").
local LEET = {["0"] = "o", ["1"] = "i", ["3"] = "e", ["4"] = "a", ["5"] = "s", ["7"] = "t", ["@"] = "a", ["$"] = "s"}
local BAD_WORDS = {
	-- español
	"puta", "puto", "putita", "putito", "hijo de puta", "hija de puta", "hdp", "hijueputa", "hijoeputa",
	"mierda", "mierdas", "carajo", "pija", "pijudo", "verga", "vergon", "concha", "conchudo", "conchuda",
	"conchatumadre", "ctm", "ctmr", "sorete", "pendejo", "pendeja", "culiado", "culiao", "culo", "orto",
	"chupapija", "chupamedias", "mamaguevo", "mamaverga", "gilipollas", "cabron", "cabrona", "coño",
	"marica", "maricon", "mariconazo", "trolo", "trola", "forro", "forra", "malparido", "malparida",
	"hijo de mil puta", "andate a la mierda", "la puta que te pario", "lpqtp", "lpm", "rctm",
	"retrasado", "retrasada", "mongolico", "mongolica", "subnormal", "sidoso", "sidosa",
	"negro de mierda", "sudaca", "bolita", "paragua", "villero de mierda",
	"violar", "violador", "violacion", "matate", "suicidate", "morite", "que te mueras",
	"nazi", "hitler",
	-- inglés
	"fuck", "fucker", "fucking", "motherfucker", "shit", "bullshit", "bitch", "cunt", "dick", "cock",
	"asshole", "whore", "slut", "pussy", "nigger", "nigga", "faggot", "fag", "retard", "retarded",
	"rape", "kys", "kill yourself", "porn", "porno", "sex", "sexo", "nude", "nudes",
}
local BAD_PATS = {}
for _, w in ipairs(BAD_WORDS) do
	local p = {}
	for ch in w:gmatch(".") do
		if ch == " " then p[#p + 1] = "%s+" else p[#p + 1] = ch .. "+" end
	end
	BAD_PATS[#BAD_PATS + 1] = "%f[%a]" .. table.concat(p) .. "s*%f[%A]"
end
local LINK_PATS = {"https?://%S+", "discord%.gg%S*", "discordapp%.com%S*", "discord%.com%S*", "www%.%S+", "%S+%.gg/%S*"}

local function censorText(s)
	s = tostring(s or "")
	if s == "" then return s end
	local norm = (s:lower():gsub("[01345@$7]", function(c) return LEET[c] end))
	local mask = {}
	local function mark(pat)
		local init = 1
		while init <= #norm do
			local a, b = norm:find(pat, init)
			if not a then break end
			for i = a, b do mask[i] = true end
			init = b + 1
		end
	end
	for _, pat in ipairs(LINK_PATS) do mark(pat) end
	for _, pat in ipairs(BAD_PATS) do mark(pat) end
	if next(mask) == nil then return s end
	local out = {}
	for i = 1, #s do out[i] = mask[i] and "*" or s:sub(i, i) end
	return table.concat(out)
end

--// ================= BASE DE DATOS / KEYS =================
local rawReq = (syn and syn.request) or (http and http.request) or http_request or request

-- PUT/PATCH/DELETE se mandan como POST + X-HTTP-Method-Override (Firebase lo soporta)
-- porque varios executors (Xeno) devuelven 404 con esos metodos.
local function db(method, path, body, admin)
	if DB_URL:find("TU%-PROYECTO") then return false, "Base de datos sin configurar" end
	if not rawReq then return false, "Tu executor no soporta requests" end

	local q = ""
	if admin then
		local s = genv.LPD_ADMIN_SECRET
		if not s or s == "" then
			return false, "Falta LPD_ADMIN_SECRET (ponelo antes de ejecutar el script)"
		end
		q = "?auth=" .. s
	end

	local headers = {["Content-Type"] = "application/json"}
	local realMethod = method
	if method ~= "GET" and method ~= "POST" then
		headers["X-HTTP-Method-Override"] = method
		realMethod = "POST"
	end

	local ok, res = pcall(rawReq, {
		Url = DB_URL .. "/" .. path .. ".json" .. q,
		Method = realMethod,
		Headers = headers,
		Body = body ~= nil and HttpService:JSONEncode(body) or (realMethod == "POST" and "null" or nil),
	})
	if not ok or type(res) ~= "table" then return false, "Sin conexión" end

	if res.StatusCode ~= 200 then
		local msg = ""
		pcall(function() msg = HttpService:JSONDecode(res.Body).error or "" end)
		return false, "Error " .. tostring(res.StatusCode) .. (msg ~= "" and (": " .. msg) or "")
	end

	local okd, d = pcall(HttpService.JSONDecode, HttpService, res.Body)
	if okd then return true, d end
	return true, nil
end

local function avatarUrl(uid)
	if not rawReq then return nil end
	local ok, res = pcall(rawReq, {Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. uid .. "&size=150x150&format=Png&isCircular=false", Method = "GET"})
	if ok and type(res) == "table" and res.StatusCode == 200 then
		local okd, d = pcall(HttpService.JSONDecode, HttpService, res.Body)
		if okd and type(d) == "table" and d.data and d.data[1] and d.data[1].imageUrl then return d.data[1].imageUrl end
	end
end

local function sendFeedbackWebhook(stars, text)
	if not rawReq then return false, "Tu executor no soporta requests" end
	local embed = {
		title = LP.Name,
		description = string.rep("★", stars) .. string.rep("☆", 5 - stars) .. "  (" .. stars .. "/5)",
		color = 16711685,
		author = {name = "Nuevo feedback • VLP PANEL", icon_url = avatarUrl(LP.UserId)},
		fields = {{name = "Opinión", value = text}},
		footer = {text = "UserId: " .. LP.UserId},
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	}
	local ok, res = pcall(rawReq, {
		Url = WEBHOOK, Method = "POST", Headers = {["Content-Type"] = "application/json"},
		Body = HttpService:JSONEncode({embeds = {embed}, allowed_mentions = {parse = {}}}),
	})
	if not ok or type(res) ~= "table" then return false, "Sin conexión" end
	if res.StatusCode < 200 or res.StatusCode >= 300 then return false, "Error " .. tostring(res.StatusCode) end
	return true
end

local rng = Random.new()
local function genKey()
	local ch, parts = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789", {}
	for p = 1, 3 do
		local s = ""
		for _ = 1, 4 do local n = rng:NextInteger(1, #ch); s ..= ch:sub(n, n) end
		parts[p] = s
	end
	return table.concat(parts, "-")
end

local function readSaved()
	local ok, v = pcall(function() if isfile and isfile(KEYFILE) then return readfile(KEYFILE) end end)
	return ok and v or nil
end
local function saveKey(k) pcall(function() if writefile then writefile(KEYFILE, k) end end) end

local function validateKey(raw)
	local key = (raw:gsub("%s", ""))
	if #key < 6 or not key:match("^[%w%-]+$") then return false, "Ingresá una key válida" end
	local ok, rec = db("GET", "keys/" .. key)
	if not ok then return false, rec end
	if type(rec) ~= "table" then return false, "Key inválida" end
	local uid = LP.UserId
	if rec.user and rec.user ~= uid then return false, "Esta key ya está en uso por otra persona" end
	if rec.user and rec.exp and rec.exp > 0 and os.time() >= rec.exp then return false, "Key expirada" end
	if not rec.user then
		local exp = (rec.dur and rec.dur > 0) and (os.time() + rec.dur) or 0
		local ok2 = db("PATCH", "keys/" .. key, {user = uid, uname = LP.Name, act = os.time(), exp = exp})
		if not ok2 then return false, "No se pudo activar la key" end
		local ok3, rec2 = db("GET", "keys/" .. key)
		if not ok3 or type(rec2) ~= "table" or rec2.user ~= uid then return false, "Esta key ya está en uso por otra persona" end
		rec = rec2
	end
	return true, rec, key
end

--// ================= SERVERS (historial para no repetir) =================
local visited = {}
do
	local ok, raw = pcall(function() if isfile and isfile(SRV_FILE) then return readfile(SRV_FILE) end end)
	if ok and type(raw) == "string" then
		local okd, d = pcall(HttpService.JSONDecode, HttpService, raw)
		if okd and type(d) == "table" then
			for _, id in ipairs(d) do if type(id) == "string" then visited[#visited + 1] = id end end
		end
	end
end
local function saveVisited()
	pcall(function() if writefile then writefile(SRV_FILE, HttpService:JSONEncode(visited)) end end)
end
local function isVisited(id)
	for _, v in ipairs(visited) do if v == id then return true end end
	return false
end
local function markVisited(id)
	if not id or id == "" or isVisited(id) then return end
	visited[#visited + 1] = id
	while #visited > 25 do table.remove(visited, 1) end
	saveVisited()
end

local function fetchServers()
	if not rawReq then return nil, "Tu executor no soporta requests" end
	local list, cursor = {}, ""
	for _ = 1, 3 do
		local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100"):format(game.PlaceId)
		if cursor ~= "" then url ..= "&cursor=" .. cursor end
		local ok, res = pcall(rawReq, {Url = url, Method = "GET"})
		if not ok or type(res) ~= "table" then return (#list > 0 and list or nil), "Sin conexión" end
		if res.StatusCode ~= 200 then
			return (#list > 0 and list or nil), (res.StatusCode == 429 and "Muchas consultas, esperá unos segundos" or ("Error " .. tostring(res.StatusCode)))
		end
		local okd, d = pcall(HttpService.JSONDecode, HttpService, res.Body)
		if not okd or type(d) ~= "table" or type(d.data) ~= "table" then break end
		for _, s in ipairs(d.data) do list[#list + 1] = s end
		if type(d.nextPageCursor) == "string" then cursor = d.nextPageCursor else break end
	end
	return list
end

--// ================= PANEL PRINCIPAL =================
local function StartMain(isAdm, keyName, keyRec)
	--// ---------- LOGICA ----------
	local hasDraw = pcall(function() local t = Drawing.new("Line"); t:Remove() end)

	local FovCircle = mk("Frame", {AnchorPoint = Vector2.new(.5, .5), BackgroundTransparency = 1, Visible = false,
		Size = UDim2.fromOffset(300, 300)}, Gui)
	corner(FovCircle, 9999); shineStroke(FovCircle, 1.5)

	local function getChar(plr)
		local ch = plr.Character; if not ch then return end
		local hum = ch:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then return ch, hum end
	end

	-- amigos (Friend Check)
	local friends = {}
	local function checkFriend(p)
		if p == LP then return end
		task.spawn(function()
			local ok, r = pcall(LP.IsFriendsWith, LP, p.UserId)
			if ok then friends[p.UserId] = r end
		end)
	end
	for _, p in ipairs(Players:GetPlayers()) do checkFriend(p) end
	bind(Players.PlayerAdded, checkFriend)

	-- enemigo = objetivo valido. Blacklist y amigos (si Friend Check esta activo) NUNCA son objetivo
	local function isEnemy(plr)
		if plr == LP then return false end
		if Blacklist[plr.UserId] then return false end
		if Cfg.FriendCheck and friends[plr.UserId] then return false end
		if not Cfg.TeamCheck then return true end
		return plr.Team == nil or LP.Team == nil or plr.Team ~= LP.Team
	end
	local rayP = RaycastParams.new(); rayP.FilterType = Enum.RaycastFilterType.Exclude
	local function visible(part, ch)
		local ig = {ch}; if LP.Character then ig[2] = LP.Character end
		rayP.FilterDescendantsInstances = ig
		local o = Camera.CFrame.Position
		return workspace:Raycast(o, part.Position - o, rayP) == nil
	end
	local function inAimRange(ch)
		local hrp = ch:FindFirstChild("HumanoidRootPart")
		return hrp ~= nil and (hrp.Position - Camera.CFrame.Position).Magnitude <= Cfg.AimMaxDist
	end

	-- partes a apuntar (seleccion multiple desde el rig)
	local PARTS = {
		AimHead  = {"Head"},
		AimTorso = {"UpperTorso", "LowerTorso", "Torso"},
		AimLArm  = {"LeftUpperArm", "LeftLowerArm", "LeftHand", "Left Arm"},
		AimRArm  = {"RightUpperArm", "RightLowerArm", "RightHand", "Right Arm"},
		AimLLeg  = {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg"},
		AimRLeg  = {"RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg"},
	}
	local function aimCandidates(ch)
		local list = {}
		for flag, names in pairs(PARTS) do
			if Cfg[flag] then
				for _, n in ipairs(names) do
					local pt = ch:FindFirstChild(n)
					if pt then list[#list + 1] = pt end
				end
			end
		end
		if #list == 0 then
			local h = ch:FindFirstChild("Head")
			if h then list[1] = h end
		end
		return list
	end
	local function pickPart(ch, m, limit, noWall)
		local bestPart, bd = nil, limit
		for _, part in ipairs(aimCandidates(ch)) do
			local sp, on = Camera:WorldToViewportPoint(part.Position)
			if on then
				local d = (Vector2.new(sp.X, sp.Y) - m).Magnitude
				if d < bd and (noWall or not Cfg.WallCheck or visible(part, ch)) then bd = d; bestPart = part end
			end
		end
		return bestPart, bd
	end
	local function getTarget()
		local best, bpart, bd = nil, nil, Cfg.FOV
		local m = UIS:GetMouseLocation()
		for _, p in ipairs(Players:GetPlayers()) do
			if isEnemy(p) then
				local ch = getChar(p)
				if ch and inAimRange(ch) then
					local part, d = pickPart(ch, m, bd, false)
					if part then bd = d; best = p; bpart = part end
				end
			end
		end
		return best, bpart
	end

	local locked
	bind(RunService.RenderStepped, function(dt)
		Camera = workspace.CurrentCamera
		FovCircle.Visible = Cfg.Aimbot and Cfg.ShowFOV
		if FovCircle.Visible then
			local m = UIS:GetMouseLocation()
			FovCircle.Position = UDim2.fromOffset(m.X, m.Y)
			FovCircle.Size = UDim2.fromOffset(Cfg.FOV * 2, Cfg.FOV * 2)
		end
		if not Cfg.Aimbot then locked = nil return end
		local aiming = (not Cfg.HoldRMB) or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		if not aiming then locked = nil return end
		local part
		if Cfg.Aimlock and locked then
			local ch = getChar(locked)
			if ch and isEnemy(locked) and inAimRange(ch) then part = pickPart(ch, UIS:GetMouseLocation(), math.huge, true) end
			if not part then locked = nil end
		end
		if not part then
			local p, pt = getTarget()
			if p then part = pt; if Cfg.Aimlock then locked = p end end
		end
		if part then
			local a = 1 - (1 - 1 / Cfg.Smooth) ^ (dt * 60)
			Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), a)
		end
	end)

	-- TRIGGERBOT (rapido por frame + modo mantener apretado)
	local mouse, lastShot, trigHeld = LP:GetMouse(), 0, false
	local function releaseTrig()
		if trigHeld then
			trigHeld = false
			if mouse1release then pcall(mouse1release) end
		end
	end
	cleanups[#cleanups + 1] = releaseTrig
	bind(RunService.RenderStepped, function()
		if not Cfg.Trigger then releaseTrig() return end
		local t = mouse.Target
		local p
		if t then
			local ch = t:FindFirstAncestorOfClass("Model")
			p = ch and Players:GetPlayerFromCharacter(ch)
		end
		if p and isEnemy(p) and getChar(p) then
			if Cfg.TrigHold then
				if not trigHeld then
					trigHeld = true
					if mouse1press then pcall(mouse1press) elseif mouse1click then pcall(mouse1click) end
				end
			elseif tick() - lastShot >= Cfg.TrigDelay / 1000 then
				lastShot = tick()
				if mouse1click then pcall(mouse1click)
				elseif mouse1press and mouse1release then pcall(mouse1press); pcall(mouse1release) end
			end
		else
			releaseTrig()
		end
	end)

	-- HITBOX
	local orig = {}
	local function restoreOne(part)
		local o = orig[part]
		if o and part.Parent then part.Size = o[1]; part.Transparency = o[2]; part.CanCollide = o[3]; part.Color = o[4] end
		orig[part] = nil
	end
	local function restoreHitboxes() for part in pairs(orig) do restoreOne(part) end end
	cleanups[#cleanups + 1] = restoreHitboxes
	local hbT = 0
	bind(RunService.Heartbeat, function(dt)
		hbT += dt; if hbT < .1 then return end; hbT = 0
		if not Cfg.Hitbox then if next(orig) then restoreHitboxes() end return end
		local s = Vector3.new(Cfg.HitSize, Cfg.HitSize, Cfg.HitSize)
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LP then
				local ch = getChar(p)
				local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
				if hrp then
					if isEnemy(p) then
						if not orig[hrp] then orig[hrp] = {hrp.Size, hrp.Transparency, hrp.CanCollide, hrp.Color} end
						hrp.Size = s; hrp.Transparency = Cfg.HitTrans / 100
						hrp.CanCollide = false; hrp.Color = C.Red
					elseif orig[hrp] then restoreOne(hrp) end
				end
			end
		end
	end)

	-- ESP (Drawing API): Box 2D, Tracers (desde arriba), Skeleton, nombre, vida, distancia, items
	local esp = {}
	local R15 = {
		{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
		{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
		{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
		{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
		{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
	}
	local R6 = {
		{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
		{"Torso", "Left Leg"}, {"Torso", "Right Leg"},
	}
	local MAX_ITEMS = 6
	-- ping de otro jugador: Roblox solo lo da para vos; se intenta igual y se buscan atributos/leaderstats del juego
	local function getPlayerPing(p)
		local ok, v = pcall(function() return p:GetNetworkPing() end)
		if ok and type(v) == "number" then return math.floor(v * 2000) end
		local a = p:GetAttribute("Ping")
		if type(a) == "number" then return math.floor(a) end
		local ls = p:FindFirstChild("leaderstats")
		local pv = ls and ls:FindFirstChild("Ping")
		if pv and type(pv.Value) == "number" then return math.floor(pv.Value) end
		return nil
	end
	local function newD(class, props)
		local o = Drawing.new(class)
		o.Visible = false
		for k, v in pairs(props) do o[k] = v end
		return o
	end
	local function makeESP()
		local e, all = {}, {}
		local function add(o) all[#all + 1] = o; return o end
		local black = Color3.new(0, 0, 0)
		e.boxO   = add(newD("Square", {Thickness = 3, Color = black, Filled = false, Transparency = 1}))
		e.box    = add(newD("Square", {Thickness = 1.5, Color = C.Red, Filled = false, Transparency = 1}))
		e.tracer = add(newD("Line",   {Thickness = 1.5, Color = C.Red, Transparency = 1}))
		e.name   = add(newD("Text",   {Size = 13, Center = true, Outline = true, Color = C.White, Transparency = 1, Font = 2}))
		e.dist   = add(newD("Text",   {Size = 12, Center = true, Outline = true, Color = C.Pink, Transparency = 1, Font = 2}))
		e.info   = add(newD("Text",   {Size = 12, Center = true, Outline = true, Color = C.White, Transparency = 1, Font = 2}))
		e.hpBg   = add(newD("Square", {Filled = true, Color = black, Transparency = .6}))
		e.hp     = add(newD("Square", {Filled = true, Color = C.Green, Transparency = 1}))
		e.skel = {}
		for i = 1, #R15 do
			e.skel[i] = add(newD("Line", {Thickness = 1.5, Color = C.Red, Transparency = 1}))
		end
		e.items = {}
		for i = 1, MAX_ITEMS do
			e.items[i] = add(newD("Text", {Size = 12, Center = false, Outline = true, Color = C.White, Transparency = 1, Font = 2}))
		end
		e.all = all
		return e
	end
	local function hideESP(e) for _, o in ipairs(e.all) do o.Visible = false end end
	local function removeESP(p)
		local e = esp[p]
		if e then
			for _, o in ipairs(e.all) do pcall(function() o:Remove() end) end
			esp[p] = nil
		end
	end
	local function clearESP() for p in pairs(esp) do removeESP(p) end end
	cleanups[#cleanups + 1] = clearESP

	local function updateESP(e, p, ch, hum, hrp, vp)
		local pos = hrp.Position
		local dist = (pos - Camera.CFrame.Position).Magnitude
		if dist > Cfg.ESPMaxDist then hideESP(e) return end
		local top = Camera:WorldToViewportPoint(pos + Vector3.new(0, 2.7, 0))
		local bot = Camera:WorldToViewportPoint(pos - Vector3.new(0, 3.2, 0))
		if top.Z <= 0 or bot.Z <= 0 or (Cfg.ESPVis and not visible(hrp, ch)) then hideESP(e) return end

		local h = math.abs(bot.Y - top.Y)
		local w = h * .55
		local cx = (top.X + bot.X) / 2
		local x, y = cx - w / 2, top.Y
		local col = C.Red

		-- box 2D
		local on = Cfg.ESPBox
		e.boxO.Visible = on; e.box.Visible = on
		if on then
			e.boxO.Position = Vector2.new(x, y); e.boxO.Size = Vector2.new(w, h)
			e.box.Position = Vector2.new(x, y);  e.box.Size = Vector2.new(w, h); e.box.Color = col
		end

		-- tracer (linea desde ARRIBA de la pantalla hasta la cabeza)
		e.tracer.Visible = Cfg.ESPTracer
		if Cfg.ESPTracer then
			if Cfg.TracerPos == "Abajo" then
				e.tracer.From = Vector2.new(vp.X / 2, vp.Y)
				e.tracer.To = Vector2.new(cx, y + h)
			else
				e.tracer.From = Vector2.new(vp.X / 2, 0)
				e.tracer.To = Vector2.new(cx, y)
			end
			e.tracer.Color = col
		end

		-- nombre
		e.name.Visible = Cfg.ESPName
		if Cfg.ESPName then e.name.Text = p.Name; e.name.Position = Vector2.new(cx, y - 17) end

		-- distancia + vida exacta (misma linea)
		local parts = {}
		if Cfg.ESPDist then parts[#parts + 1] = "[" .. math.floor(dist) .. "m]" end
		if Cfg.ESPHPNum then parts[#parts + 1] = math.floor(hum.Health + .5) .. "/" .. math.floor(hum.MaxHealth + .5) .. " HP" end
		e.dist.Visible = #parts > 0
		if #parts > 0 then
			e.dist.Text = table.concat(parts, "  ")
			e.dist.Position = Vector2.new(cx, y + h + 2)
		end

		-- velocidad + ping (linea de abajo)
		local parts2 = {}
		if Cfg.ESPSpeed then
			local v = hrp.AssemblyLinearVelocity
			parts2[#parts2 + 1] = math.floor(Vector3.new(v.X, 0, v.Z).Magnitude + .5) .. " st/s"
		end
		if Cfg.ESPPing then
			local nowP = tick()
			if not e.pingT or nowP - e.pingT > 1 then e.pingT = nowP; e.pingV = getPlayerPing(p) end
			parts2[#parts2 + 1] = e.pingV and (e.pingV .. " ms") or "ping N/A"
		end
		e.info.Visible = #parts2 > 0
		if #parts2 > 0 then
			e.info.Text = table.concat(parts2, "  •  ")
			e.info.Position = Vector2.new(cx, y + h + (#parts > 0 and 15 or 2))
		end

		-- barra de vida (a la izquierda de la box)
		e.hpBg.Visible = Cfg.ESPHealth; e.hp.Visible = Cfg.ESPHealth
		if Cfg.ESPHealth then
			local r = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
			local bx = x - 7
			e.hpBg.Position = Vector2.new(bx - 1, y - 1); e.hpBg.Size = Vector2.new(5, h + 2)
			e.hp.Position = Vector2.new(bx, y + h - h * r); e.hp.Size = Vector2.new(3, h * r)
			e.hp.Color = Color3.fromHSV(r * .33, 1, 1)
		end

		-- items / tools (a la DERECHA de la box; la equipada en verde)
		local showItems = Cfg.ESPItems
		if showItems then
			local now = tick()
			if not e.itemT or now - e.itemT > .25 then
				e.itemT = now
				local list = {}
				for _, t in ipairs(ch:GetChildren()) do
					if t:IsA("Tool") then list[#list + 1] = {t.Name, true} end
				end
				local bp = p:FindFirstChildOfClass("Backpack")
				if bp then
					for _, t in ipairs(bp:GetChildren()) do
						if t:IsA("Tool") then list[#list + 1] = {t.Name, false} end
					end
				end
				e.itemList = list
			end
		end
		for i = 1, #e.items do
			local tx = e.items[i]
			local it = showItems and e.itemList and e.itemList[i]
			if it then
				tx.Text = it[1]
				tx.Color = it[2] and C.Green or C.White
				tx.Position = Vector2.new(x + w + 6, y + (i - 1) * 13)
				tx.Visible = true
			elseif showItems and i == 1 and e.itemList and #e.itemList == 0 then
				tx.Text = "Sin items"
				tx.Color = Color3.fromRGB(160, 160, 160)
				tx.Position = Vector2.new(x + w + 6, y)
				tx.Visible = true
			else
				tx.Visible = false
			end
		end

		-- skeleton
		local list = ch:FindFirstChild("UpperTorso") and R15 or R6
		for i = 1, #e.skel do
			local ln = e.skel[i]
			local pr = Cfg.ESPSkel and list[i]
			local a = pr and ch:FindFirstChild(pr[1])
			local b = pr and ch:FindFirstChild(pr[2])
			if a and b then
				local pa = Camera:WorldToViewportPoint(a.Position)
				local pb = Camera:WorldToViewportPoint(b.Position)
				if pa.Z > 0 and pb.Z > 0 then
					ln.From = Vector2.new(pa.X, pa.Y); ln.To = Vector2.new(pb.X, pb.Y)
					ln.Color = col; ln.Visible = true
				else ln.Visible = false end
			else ln.Visible = false end
		end
	end

	bind(RunService.RenderStepped, function()
		if not hasDraw then return end
		if not Cfg.ESP then if next(esp) then clearESP() end return end
		local vp = Camera.ViewportSize
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LP then
				local ch, hum = getChar(p)
				local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
				local e = esp[p]
				if ch and hrp and isEnemy(p) then
					if not e then e = makeESP(); esp[p] = e end
					updateESP(e, p, ch, hum, hrp, vp)
				elseif e then hideESP(e) end
			end
		end
	end)
	bind(Players.PlayerRemoving, removeESP)

	bind(RunService.Stepped, function()
		if Cfg.Noclip and LP.Character then
			for _, v in ipairs(LP.Character:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide = false end
			end
		end
	end)

	local flyBV
	local function stopFly() if flyBV then flyBV:Destroy(); flyBV = nil end end
	cleanups[#cleanups + 1] = stopFly
	bind(RunService.Heartbeat, function()
		local ch = LP.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		if Cfg.Fly and hrp then
			if not flyBV or flyBV.Parent ~= hrp then
				stopFly()
				flyBV = mk("BodyVelocity", {Name = rname(8), MaxForce = Vector3.new(1e9, 1e9, 1e9), Velocity = Vector3.zero}, hrp)
			end
			local cf, d = Camera.CFrame, Vector3.zero
			if UIS:IsKeyDown(Enum.KeyCode.W) then d += cf.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then d -= cf.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then d += cf.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then d -= cf.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.yAxis end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d -= Vector3.yAxis end
			flyBV.Velocity = (d.Magnitude > 0 and d.Unit or d) * Cfg.FlySpeed
		else stopFly() end
	end)

	-- SPEED WALK
	local wsOrig = setmetatable({}, {__mode = "k"})
	bind(RunService.Heartbeat, function()
		local ch = LP.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		if Cfg.SpeedWalk then
			if wsOrig[hum] == nil then wsOrig[hum] = hum.WalkSpeed end
			hum.WalkSpeed = Cfg.WalkSpeed
		elseif wsOrig[hum] ~= nil then
			hum.WalkSpeed = wsOrig[hum]; wsOrig[hum] = nil
		end
	end)
	cleanups[#cleanups + 1] = function()
		local ch = LP.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hum and wsOrig[hum] ~= nil then hum.WalkSpeed = wsOrig[hum] end
	end

	-- INFINITE JUMP (saltar sin cooldown)
	bind(UIS.JumpRequest, function()
		if not Cfg.InfJump then return end
		local ch = LP.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)

	-- MODO EVASIVO: orbita alrededor del enemigo mas cercano (ignora blacklist / amigos)
	local evaTarget
	bind(RunService.Heartbeat, function()
		evaTarget = nil
		if not Cfg.Evasive then return end
		local myChar = LP.Character
		local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
		if not myHRP then return end

		local closest, shortest = nil, math.huge
		for _, p in ipairs(Players:GetPlayers()) do
			if isEnemy(p) then
				local ch = getChar(p)
				local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
				if hrp then
					local d = (myHRP.Position - hrp.Position).Magnitude
					if d < shortest then shortest = d; closest = hrp end
				end
			end
		end

		if closest then
			local time = tick() * 12
			local radius = 7 + math.sin(tick() * 4) * 2
			local offsetX = math.cos(time) * radius
			local offsetZ = math.sin(time) * radius
			local offsetY = math.sin(time * 0.8) * 2.5
			local evasionPos = closest.Position + Vector3.new(offsetX, offsetY, offsetZ)
			myHRP.CFrame = CFrame.new(evasionPos, closest.Position)
			evaTarget = closest
		end
	end)
	bind(RunService.RenderStepped, function()
		if Cfg.Evasive and evaTarget and evaTarget.Parent then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, evaTarget.Position)
		end
	end)

	--// ---------- UI PRINCIPAL ----------
	local Panel = mk("Frame", {Name = "Panel", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(.5, 0, .5, 0),
		Size = UDim2.fromOffset(580, 360), BackgroundColor3 = C.White, BackgroundTransparency = .06,
		BorderSizePixel = 0, Visible = false}, Gui)
	corner(Panel, 12)
	mk("UIGradient", {Rotation = 90, Color = ColorSequence.new(T(28, 0, 1), T(120, 0, 3))}, Panel)
	shineStroke(Panel, 2)
	gloss(Panel, .8, .14, false)
	mk("UIScale", {Name = "Pop", Scale = .01}, Panel)

	-- lluvia de código (solo themes con rain = true, ej: Matrix)
	local Rain = mk("Frame", {Name = "Rain", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
		ClipsDescendants = true, Visible = Style.rain}, Panel)
	corner(Rain, 12)
	local rainCols = {}
	do
		local RCH = "0123456789ABCDEF$#@%&*+<>=/"
		local function rainText()
			local t = {}
			for i = 1, 30 do local k = math.random(1, #RCH); t[i] = RCH:sub(k, k) end
			return table.concat(t, "\n")
		end
		for i = 1, 16 do
			local lbl = mk("TextLabel", {Size = UDim2.fromOffset(36, 420), Position = UDim2.fromOffset((i - 1) * 36, -420),
				BackgroundTransparency = 1, Text = rainText(), Font = FONT, TextSize = 12, TextColor3 = C.Red,
				TextTransparency = .45, TextYAlignment = Enum.TextYAlignment.Top}, Rain)
			mk("UIGradient", {Rotation = 90, Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.7, .3), NumberSequenceKeypoint.new(1, 0)}}, lbl)
			rainCols[i] = {lbl = lbl, y = -math.random(0, 420), speed = math.random(50, 130)}
		end
		local acc = 0
		bind(RunService.Heartbeat, function(dt)
			if not Style.rain or not Panel.Visible then return end
			acc += dt
			local reroll = acc > .15
			if reroll then acc = 0 end
			for _, c in ipairs(rainCols) do
				c.y += c.speed * dt
				if c.y > 360 then c.y = -420; c.speed = math.random(50, 130); c.lbl.Text = rainText() end
				c.lbl.Position = UDim2.fromOffset(c.lbl.Position.X.Offset, c.y)
			end
			if reroll then
				local c = rainCols[math.random(1, #rainCols)]
				c.lbl.Text = rainText()
			end
		end)
	end
	Style.hook = function() Rain.Visible = Style.rain end
	cleanups[#cleanups + 1] = function() Style.hook = nil end

	Panel:SetAttribute("BaseScale", Cfg.UIScale / 100)
	local state, hidden = "panel", false

	local TopBar = mk("Frame", {Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1}, Panel)
	local icon = mk("ImageLabel", {Image = ICON, Position = UDim2.fromOffset(12, 8), Size = UDim2.fromOffset(26, 26),
		BackgroundTransparency = 1}, TopBar)
	corner(icon, 6)
	mk("TextLabel", {Position = UDim2.fromOffset(48, 0), Size = UDim2.new(1, -230, 1, 0), BackgroundTransparency = 1,
		Text = TITLE, Font = FONTB, TextSize = 16, TextColor3 = C.White,
		TextXAlignment = Enum.TextXAlignment.Left}, TopBar)
	local info = mk("TextLabel", {AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -82, .5, 0), Size = UDim2.fromOffset(130, 20),
		BackgroundTransparency = 1, Font = FONTB, TextSize = 11, TextColor3 = C.Pink, TextXAlignment = Enum.TextXAlignment.Right}, TopBar)
	local line = mk("Frame", {Position = UDim2.new(0, 12, 0, 42), Size = UDim2.new(1, -24, 0, 1), BackgroundColor3 = C.Red,
		BorderSizePixel = 0}, Panel)
	mk("UIGradient", {Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.5, 0),
		NumberSequenceKeypoint.new(1, 1)}}, line)
	local BtnClose = circleBtn(TopBar, "X", 12)
	local BtnMin   = circleBtn(TopBar, "-", 46)

	local Side = mk("ScrollingFrame", {Position = UDim2.fromOffset(10, 52), Size = UDim2.fromOffset(130, 278),
		BackgroundColor3 = C.White, BackgroundTransparency = .55, BorderSizePixel = 0, ScrollBarThickness = 2,
		ScrollBarImageColor3 = C.Red, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ClipsDescendants = true}, Panel)
	corner(Side, 10); redGrad(Side, 90); mk("UIStroke", {Color = C.Red, Transparency = .5}, Side)
	mk("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, Side)
	mk("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, Side)
	mk("TextLabel", {Position = UDim2.fromOffset(14, 336), Size = UDim2.fromOffset(122, 16), BackgroundTransparency = 1,
		Text = "[K] Mostrar / Ocultar", Font = FONT, TextSize = 11, TextColor3 = C.Pink}, Panel)

	local Content = mk("Frame", {Position = UDim2.fromOffset(150, 52), Size = UDim2.fromOffset(420, 298),
		BackgroundColor3 = C.White, BackgroundTransparency = .6, BorderSizePixel = 0, ClipsDescendants = true}, Panel)
	corner(Content, 10); redGrad(Content, 90); mk("UIStroke", {Color = C.Red, Transparency = .5}, Content)

	local function applyPanelTrans(v)
		local f = v / 100
		Panel.BackgroundTransparency = .06 + (1 - .06) * f
		Side.BackgroundTransparency = .55 + (1 - .55) * f
		Content.BackgroundTransparency = .6 + (1 - .6) * f
	end
	applyPanelTrans(Cfg.PanelTrans)

	--// ---------- WIDGETS ----------
	local ord = 0
	local function row(sf, h)
		ord += 1
		local r = mk("Frame", {Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = C.White, BackgroundTransparency = .35,
			BorderSizePixel = 0, LayoutOrder = ord, ClipsDescendants = true}, sf)
		corner(r, 8); redGrad(r, 90); mk("UIStroke", {Color = C.Red, Transparency = .6}, r); gloss(r)
		return r
	end
	local function label(p, text, h)
		return mk("TextLabel", {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(.6, 0, 0, h or 38), BackgroundTransparency = 1,
			Text = text, Font = FONT, TextSize = 14, TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Left}, p)
	end
	local function Section(sf, text)
		ord += 1
		local l = mk("TextLabel", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = string.upper(text),
			Font = FONTB, TextSize = 12, TextColor3 = T(255, 110, 110),
			TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = ord}, sf)
		mk("UIPadding", {PaddingLeft = UDim.new(0, 4)}, l)
	end
	local function listFrame(sf)
		ord += 1
		local l = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
			LayoutOrder = ord}, sf)
		mk("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, l)
		return l
	end
	local function clearList(l) for _, c in ipairs(l:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end end
	local function empty(l, txt)
		ord += 1
		mk("TextLabel", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = txt, Font = FONT, TextSize = 12,
			TextColor3 = C.Pink, LayoutOrder = ord, TextWrapped = true}, l)
	end

	-- keybinds: tocá el botón, apretá una tecla y esa tecla activa/desactiva la opción (aunque el panel esté cerrado)
	local toggleSetters = {}
	local listening
	local function endListen()
		if listening then
			listening.btn.Text = Binds[listening.key] or "None"
			listening = nil
		end
	end

	local function Toggle(sf, text, key, kb)
		local r = row(sf, 38); label(r, text)
		local sw = mk("Frame", {AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -12, .5, 0),
			Size = UDim2.fromOffset(44, 22), BackgroundColor3 = C.Off, BorderSizePixel = 0}, r)
		corner(sw, 99)
		local knob = mk("Frame", {AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 3, .5, 0),
			Size = UDim2.fromOffset(16, 16), BackgroundColor3 = C.White, BorderSizePixel = 0}, sw)
		corner(knob, 99)
		local btn = mk("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""}, r)
		local function set(v, silent)
			Cfg[key] = v
			tw(sw, .2, {BackgroundColor3 = v and C.Red or C.Off})
			tw(knob, .3, {Position = v and UDim2.new(1, -19, .5, 0) or UDim2.new(0, 3, .5, 0)}, Enum.EasingStyle.Back)
			if not silent then markDirty(); notify(text .. (v and ": ON" or ": OFF")) end
		end
		bind(btn.MouseButton1Click, function() set(not Cfg[key]) end)
		fx(btn, r, .35, .2)
		set(Cfg[key], true)
		toggleSetters[key] = set
		if kb then
			local kbBtn = mk("TextButton", {AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -64, .5, 0),
				Size = UDim2.fromOffset(58, 22), BackgroundColor3 = C.Darker, BackgroundTransparency = .2,
				Text = Binds[key] or "None", Font = FONTB, TextSize = 11, TextColor3 = C.Pink, AutoButtonColor = false}, r)
			corner(kbBtn, 6); mk("UIStroke", {Color = C.Red, Thickness = 1}, kbBtn)
			bind(kbBtn.MouseButton1Click, function()
				endListen()
				listening = {key = key, btn = kbBtn}
				kbBtn.Text = "..."
			end)
		end
	end
	local function Slider(sf, text, key, min, max, step, suffix, cb)
		local r = row(sf, 54); label(r, text, 32)
		local vl = mk("TextLabel", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.fromOffset(80, 32),
			BackgroundTransparency = 1, Font = FONTB, TextSize = 13, TextColor3 = T(255, 130, 130),
			TextXAlignment = Enum.TextXAlignment.Right}, r)
		local bar = mk("Frame", {Position = UDim2.new(0, 12, 0, 38), Size = UDim2.new(1, -24, 0, 6),
			BackgroundColor3 = C.Off, BorderSizePixel = 0}, r)
		corner(bar, 99)
		local fill = mk("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = C.White, BorderSizePixel = 0}, bar)
		corner(fill, 99); redGrad(fill, 0)
		local knob = mk("Frame", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(0, 0, .5, 0), Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = C.White, BorderSizePixel = 0, ZIndex = 2}, bar)
		corner(knob, 99); mk("UIStroke", {Color = C.Red, Thickness = 2}, knob)
		local hit = mk("TextButton", {Position = UDim2.new(0, 12, 0, 30), Size = UDim2.new(1, -24, 0, 22),
			BackgroundTransparency = 1, Text = ""}, r)
		local dragging = false
		local function setv(v, fire)
			v = math.clamp(math.floor(v / step + .5) * step, min, max)
			Cfg[key] = v
			local a = (v - min) / (max - min)
			tw(fill, .08, {Size = UDim2.new(a, 0, 1, 0)}); tw(knob, .08, {Position = UDim2.new(a, 0, .5, 0)})
			vl.Text = tostring(v) .. (suffix or "")
			if fire then markDirty(); if cb then cb(v) end end
		end
		local function fromX(x) setv(min + (max - min) * math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1), true) end
		bind(hit.InputBegan, function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true; tw(knob, .15, {Size = UDim2.fromOffset(19, 19)}, Enum.EasingStyle.Back); fromX(i.Position.X)
			end
		end)
		bind(UIS.InputChanged, function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then fromX(i.Position.X) end
		end)
		bind(UIS.InputEnded, function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
				dragging = false; tw(knob, .2, {Size = UDim2.fromOffset(14, 14)}, Enum.EasingStyle.Back)
			end
		end)
		setv(Cfg[key], false)
		return function(v) setv(v, true) end
	end
	local function Button(sf, text, cb)
		local r = row(sf, 38)
		local b = mk("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = text, Font = FONTB,
			TextSize = 14, TextColor3 = C.White}, r)
		fx(b, r, .35, .15)
		bind(b.MouseButton1Click, cb)
		return b
	end

	-- boton que va rotando entre opciones
	local function Cycle(sf, text, key, options, cb)
		local r = row(sf, 38); label(r, text)
		local b = mk("TextButton", {AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -12, .5, 0),
			Size = UDim2.fromOffset(130, 24), BackgroundColor3 = C.Darker, BackgroundTransparency = .2,
			Text = tostring(Cfg[key]) .. "  >", Font = FONTB, TextSize = 12, TextColor3 = C.White, AutoButtonColor = false}, r)
		corner(b, 6); mk("UIStroke", {Color = C.Red, Thickness = 1}, b)
		bind(b.MouseButton1Click, function()
			local idx = 1
			for i, o in ipairs(options) do if o == Cfg[key] then idx = i end end
			local nv = options[idx % #options + 1]
			Cfg[key] = nv; b.Text = nv .. "  >"; markDirty()
			if cb then cb(nv) end
		end)
		return b
	end


	-- selector de partes del cuerpo (rig de Roblox con TextButtons, seleccion multiple)
	local function RigPicker(sf)
		local r = row(sf, 178); label(r, "Parte a apuntar", 28)
		local btns = {}
		local function countSel()
			local n = 0
			for flag in pairs(btns) do if Cfg[flag] then n += 1 end end
			return n
		end
		local function refresh()
			for flag, b in pairs(btns) do tw(b, .2, {BackgroundColor3 = Cfg[flag] and C.Red or C.Darker}) end
		end
		local function part(flag, txt, dx, y, w, h)
			local b = mk("TextButton", {AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, dx, 0, y), Size = UDim2.fromOffset(w, h),
				BackgroundColor3 = Cfg[flag] and C.Red or C.Darker, BackgroundTransparency = .1, Text = txt, Font = FONTB, TextSize = 10,
				TextColor3 = C.White, AutoButtonColor = false}, r)
			corner(b, 6); mk("UIStroke", {Color = C.Red, Thickness = 1}, b)
			btns[flag] = b
			bind(b.MouseButton1Click, function()
				if Cfg[flag] and countSel() <= 1 then notify("Dejá al menos una parte seleccionada") return end
				Cfg[flag] = not Cfg[flag]; markDirty(); refresh()
			end)
		end
		part("AimHead",  "Cabeza", 0,   30,  30, 28)
		part("AimTorso", "Torso",  0,   61,  46, 50)
		part("AimLArm",  "BI",    -35,  61,  18, 50)
		part("AimRArm",  "BD",     35,  61,  18, 50)
		part("AimLLeg",  "PI",    -12,  114, 21, 52)
		part("AimRLeg",  "PD",     12,  114, 21, 52)

		local allB = smallBtn(r, "Todo", 64, 10)
		allB.Parent.AnchorPoint = Vector2.new(1, 0); allB.Parent.Position = UDim2.new(1, -10, 0, 40)
		local noneB = smallBtn(r, "Solo cabeza", 84, 10)
		noneB.Parent.AnchorPoint = Vector2.new(1, 0); noneB.Parent.Position = UDim2.new(1, -10, 0, 74)
		mk("TextLabel", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 110), Size = UDim2.fromOffset(120, 40),
			BackgroundTransparency = 1, Text = "BI/BD: brazos\nPI/PD: piernas\nElegí las que quieras", Font = FONT, TextSize = 10,
			TextColor3 = C.Pink, TextXAlignment = Enum.TextXAlignment.Right, TextYAlignment = Enum.TextYAlignment.Top}, r)
		bind(allB.MouseButton1Click, function()
			for flag in pairs(btns) do Cfg[flag] = true end
			markDirty(); refresh()
		end)
		bind(noneB.MouseButton1Click, function()
			for flag in pairs(btns) do Cfg[flag] = (flag == "AimHead") end
			markDirty(); refresh()
		end)
	end

	-- estrellas (solo visual)
	local function starsLabels(parent, n, pos)
		for i = 1, 5 do
			mk("TextLabel", {Position = UDim2.new(pos.X.Scale, pos.X.Offset + (i - 1) * 15, pos.Y.Scale, pos.Y.Offset),
				Size = UDim2.fromOffset(14, 14), BackgroundTransparency = 1, Text = "★", Font = FONTB, TextSize = 14,
				TextColor3 = i <= n and C.Gold or Color3.fromRGB(90, 90, 90)}, parent):SetAttribute("NoTheme", true)
		end
	end

	--// ---------- TABS ----------
	local tabs, current = {}, nil
	local function newPage()
		local cg = mk("CanvasGroup", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, GroupTransparency = 1, Visible = false}, Content)
		local sf = mk("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0,
			ScrollBarThickness = 3, ScrollBarImageColor3 = C.Red, CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y}, cg)
		mk("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, sf)
		mk("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 12)}, sf)
		return cg, sf
	end
	local function selectTab(name)
		if current == name then return end
		current = name
		for n, t in pairs(tabs) do
			if n == name then
				t.page.Position = UDim2.new(0, 0, 0, 18); t.page.GroupTransparency = 1; t.page.Visible = true
				tw(t.page, .35, {GroupTransparency = 0, Position = UDim2.new()}, Enum.EasingStyle.Quint)
				tw(t.frame, .2, {BackgroundTransparency = .1})
				tw(t.bar, .3, {Size = UDim2.new(0, 3, .6, 0)}, Enum.EasingStyle.Back)
				tw(t.btn, .2, {TextTransparency = 0})
			else
				if t.page.Visible then
					tw(t.page, .15, {GroupTransparency = 1})
					task.delay(.16, function() if current ~= n then t.page.Visible = false end end)
				end
				tw(t.frame, .2, {BackgroundTransparency = .6})
				tw(t.bar, .2, {Size = UDim2.new(0, 3, 0, 0)})
				tw(t.btn, .2, {TextTransparency = .35})
			end
		end
	end
	local names = {"Aimbot", "ESP", "Hitbox", "Misc", "Visuals", "Apariencia", "Servers", "Feedback", "Info"}
	if isAdm then names[#names + 1] = "Admin" end
	for idx, name in ipairs(names) do
		local f = mk("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = C.White, BackgroundTransparency = .6,
			BorderSizePixel = 0, LayoutOrder = idx}, Side)
		corner(f, 8); redGrad(f, 0)
		local bar = mk("Frame", {AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, 4, .5, 0), Size = UDim2.new(0, 3, 0, 0),
			BackgroundColor3 = C.White, BorderSizePixel = 0}, f)
		corner(bar, 2)
		local b = mk("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = name == "Admin" and "Admin Panel" or name,
			Font = FONTB, TextSize = 14, TextColor3 = C.White, TextTransparency = .35}, f)
		fx(b, f, function() return current == name and .1 or .6 end, function() return current == name and .05 or .35 end)
		local page, sf = newPage()
		tabs[name] = {frame = f, bar = bar, btn = b, page = page, sf = sf}
		bind(b.MouseButton1Click, function() selectTab(name) end)
	end

	do -- AIMBOT
		local sf = tabs.Aimbot.sf
		Section(sf, "Aimbot")
		Toggle(sf, "Activar Aimbot", "Aimbot", true)
		Toggle(sf, "Aimlock (fijar objetivo)", "Aimlock", true)
		Toggle(sf, "Solo con click derecho", "HoldRMB")
		RigPicker(sf)
		Slider(sf, "Suavidad", "Smooth", 1, 20, 1, "")
		Slider(sf, "Tamaño FOV", "FOV", 30, 500, 5, " px")
		Slider(sf, "Distancia máxima", "AimMaxDist", 50, 3000, 50, " studs")
		Toggle(sf, "Mostrar círculo FOV", "ShowFOV")
		Section(sf, "Filtros (globales)")
		Toggle(sf, "Team Check", "TeamCheck")
		Toggle(sf, "Wall Check", "WallCheck")
		Toggle(sf, "Friend Check (ignorar amigos)", "FriendCheck", true)
		Toggle(sf, "FPS Boost (sin texturas)", "FPSBoost", true)
		Section(sf, "TriggerBot")
		Toggle(sf, "Activar TriggerBot", "Trigger", true)
		Toggle(sf, "Mantener click apretado", "TrigHold")
		Slider(sf, "Reaction Time (0 = instantáneo)", "TrigDelay", 0, 300, 5, " ms")
	end
	do -- ESP
		local sf = tabs.ESP.sf
		Section(sf, "ESP (Drawing API)")
		Toggle(sf, "Activar ESP", "ESP", true)
		Toggle(sf, "Box 2D", "ESPBox")
		Toggle(sf, "Tracers (Lines)", "ESPTracer")
		Cycle(sf, "Posición de tracers", "TracerPos", {"Arriba", "Abajo"})
		Toggle(sf, "Skeleton", "ESPSkel")
		Toggle(sf, "Nombre", "ESPName")
		Toggle(sf, "Barra de vida", "ESPHealth")
		Toggle(sf, "Distancia", "ESPDist")
		Toggle(sf, "Vida exacta (HP)", "ESPHPNum")
		Toggle(sf, "Velocidad", "ESPSpeed")
		Toggle(sf, "Ping del jugador", "ESPPing")
		Toggle(sf, "Mirar Items (tools)", "ESPItems")
		Toggle(sf, "Solo visibles (WallCheck)", "ESPVis")
		Slider(sf, "Distancia máxima", "ESPMaxDist", 50, 3000, 50, " studs")
		if not hasDraw then
			empty(sf, "Tu executor no soporta Drawing: el ESP no funcionará")
		end
	end
	do -- HITBOX
		local sf = tabs.Hitbox.sf
		Section(sf, "Hitbox Expander")
		Toggle(sf, "Activar Hitbox", "Hitbox", true)
		Slider(sf, "Tamaño", "HitSize", 2, 25, 1, " studs")
		Slider(sf, "Transparencia", "HitTrans", 0, 100, 5, " %")
	end
	do -- MISC
		local sf = tabs.Misc.sf
		Section(sf, "Movimiento")
		Toggle(sf, "Noclip", "Noclip", true)
		Toggle(sf, "Fly (WASD / Espacio / Ctrl)", "Fly", true)
		Slider(sf, "Velocidad Fly", "FlySpeed", 10, 150, 5, "")
		Toggle(sf, "Infinite Jump", "InfJump", true)
		Toggle(sf, "Speed Walk", "SpeedWalk", true)
		Slider(sf, "Velocidad al caminar", "WalkSpeed", 16, 150, 1, "")
		Toggle(sf, "Modo Evasivo", "Evasive", true)

		-- ===== BLACKLIST DE JUGADORES =====
		Section(sf, "Blacklist (ignorar jugadores)")
		local hr = row(sf, 38)
		local hb = mk("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "Jugadores del servidor  [-]",
			Font = FONTB, TextSize = 14, TextColor3 = C.White}, hr)
		fx(hb, hr, .35, .15)
		local srvList = listFrame(sf)
		Section(sf, "Blacklisteados")
		local blList = listFrame(sf)

		local function playerRow(parent, uid, name, status, btnText, cb)
			local rr = row(parent, 48)
			local img = mk("ImageLabel", {Position = UDim2.fromOffset(8, 6), Size = UDim2.fromOffset(36, 36), BackgroundColor3 = C.Darker,
				BorderSizePixel = 0, Image = "rbxthumb://type=AvatarHeadShot&id=" .. uid .. "&w=150&h=150"}, rr)
			corner(img, 99); mk("UIStroke", {Color = C.Red, Thickness = 1.5}, img)
			mk("TextLabel", {Position = UDim2.fromOffset(54, 6), Size = UDim2.new(1, -140, 0, 18), BackgroundTransparency = 1, Text = name,
				Font = FONTB, TextSize = 14, TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd}, rr)
			mk("TextLabel", {Position = UDim2.fromOffset(54, 26), Size = UDim2.new(1, -140, 0, 16), BackgroundTransparency = 1, Text = status,
				Font = FONT, TextSize = 11, TextColor3 = C.Pink, TextXAlignment = Enum.TextXAlignment.Left}, rr)
			local b = smallBtn(rr, btnText, 64, 10)
			bind(b.MouseButton1Click, cb)
		end

		local refreshBLUI
		refreshBLUI = function()
			clearList(srvList); clearList(blList)
			local n = 0
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LP and not Blacklist[p.UserId] then
					n += 1
					playerRow(srvList, p.UserId, p.Name, "En el servidor", "Agregar", function()
						Blacklist[p.UserId] = p.Name; markDirty()
						notify(p.Name .. " agregado a la blacklist"); refreshBLUI()
					end)
				end
			end
			if n == 0 then empty(srvList, "No hay más jugadores en el servidor") end

			local arr = {}
			for uid, name in pairs(Blacklist) do arr[#arr + 1] = {uid = uid, name = name} end
			table.sort(arr, function(a, b) return a.name:lower() < b.name:lower() end)
			for _, e in ipairs(arr) do
				local inSrv = Players:GetPlayerByUserId(e.uid) ~= nil
				playerRow(blList, e.uid, e.name, inSrv and "En el servidor  •  Ignorado" or "Fuera del servidor  •  Ignorado", "Quit", function()
					Blacklist[e.uid] = nil; markDirty()
					notify(e.name .. " sacado de la blacklist"); refreshBLUI()
				end)
			end
			if #arr == 0 then empty(blList, "Nadie en la blacklist") end
		end

		local srvOpen = true
		bind(hb.MouseButton1Click, function()
			srvOpen = not srvOpen
			srvList.Visible = srvOpen
			hb.Text = "Jugadores del servidor  " .. (srvOpen and "[-]" or "[+]")
		end)
		local pending = false
		local function schedule()
			if pending then return end
			pending = true
			task.delay(.4, function() pending = false; refreshBLUI() end)
		end
		bind(Players.PlayerAdded, schedule)
		bind(Players.PlayerRemoving, schedule)
		refreshBLUI()


		-- ===== PANEL =====
		Section(sf, "Panel")
		Button(sf, "Guardar configuración ahora", function() saveNow(); dirty = false; notify("Configuración guardada") end)
		Button(sf, "Descargar panel (Unload)", function()
			tw(Panel.Pop, .25, {Scale = .01}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			task.delay(.3, Unload)
		end)
	end

	do -- FPS BOOST (solo local: quita texturas/efectos para ganar FPS, y lo restaura al apagar)
		local Lighting = game:GetService("Lighting")
		local saved = setmetatable({}, {__mode = "k"}) -- [instancia] = {propiedad = valorOriginal}
		local lightSaved, qualitySaved
		local on, gen, conn = false, 0, nil

		-- no tocar personajes (jugadores / NPCs) para que se vean normales
		local function inCharacter(inst)
			local m = inst:FindFirstAncestorOfClass("Model")
			while m do
				if m:FindFirstChildOfClass("Humanoid") then return true end
				m = m.Parent and m.Parent:FindFirstAncestorOfClass("Model") or nil
			end
			return false
		end

		local function store(inst, prop, newVal)
			local s = saved[inst]
			if not s then s = {}; saved[inst] = s end
			if s[prop] == nil then s[prop] = inst[prop] end
			inst[prop] = newVal
		end

		local function boostInst(inst)
			if inst:IsA("Terrain") then return end
			if inst:IsA("BasePart") then
				if inCharacter(inst) then return end
				store(inst, "Material", Enum.Material.Plastic)
				store(inst, "Reflectance", 0)
				store(inst, "CastShadow", false)
			elseif inst:IsA("Decal") or inst:IsA("Texture") then
				if not inCharacter(inst) then store(inst, "Transparency", 1) end
			elseif inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("Fire")
				or inst:IsA("Smoke") or inst:IsA("Sparkles") or inst:IsA("PostEffect") then
				store(inst, "Enabled", false)
			end
		end

		local function lightingBoost()
			if not lightSaved then
				lightSaved = {GlobalShadows = Lighting.GlobalShadows, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart}
			end
			Lighting.GlobalShadows = false
			Lighting.FogEnd = 9e9
			for _, e in ipairs(Lighting:GetDescendants()) do
				pcall(function()
					if e:IsA("PostEffect") then store(e, "Enabled", false)
					elseif e:IsA("Atmosphere") then store(e, "Density", 0); store(e, "Haze", 0) end
				end)
			end
			pcall(function()
				local t = workspace:FindFirstChildOfClass("Terrain")
				if t then
					store(t, "WaterWaveSize", 0); store(t, "WaterWaveSpeed", 0)
					store(t, "WaterReflectance", 0); store(t, "Decoration", false)
				end
			end)
			pcall(function()
				if qualitySaved == nil then qualitySaved = settings().Rendering.QualityLevel end
				settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			end)
		end

		local function enable()
			gen += 1; local my = gen
			lightingBoost()
			conn = workspace.DescendantAdded:Connect(function(d) pcall(boostInst, d) end)
			task.spawn(function()
				local n = 0
				for _, d in ipairs(workspace:GetDescendants()) do
					if gen ~= my then return end
					pcall(boostInst, d)
					n += 1
					if n % 400 == 0 then task.wait() end -- no congela el juego en mapas grandes
				end
			end)
		end

		local function disable()
			gen += 1
			if conn then conn:Disconnect(); conn = nil end
			for inst, props in pairs(saved) do
				if inst.Parent then
					for p, v in pairs(props) do pcall(function() inst[p] = v end) end
				end
			end
			table.clear(saved)
			if lightSaved then
				for p, v in pairs(lightSaved) do pcall(function() Lighting[p] = v end) end
				lightSaved = nil
			end
			if qualitySaved ~= nil then
				pcall(function() settings().Rendering.QualityLevel = qualitySaved end)
				qualitySaved = nil
			end
		end

		-- se activa/desactiva mirando Cfg.FPSBoost (sirve con el switch, la tecla asignada y la config guardada)
		bind(RunService.Heartbeat, function()
			if Cfg.FPSBoost and not on then on = true; enable()
			elseif not Cfg.FPSBoost and on then on = false; disable() end
		end)
		cleanups[#cleanups + 1] = function() if on then on = false; disable() end end
	end

	do -- VISUALS (TODO es local: los demás jugadores NO ven nada de esto)
		local sf = tabs.Visuals.sf

		-- ================= FOV CAMERA =================
		local origFov
		bind(RunService.RenderStepped, function()
			local cam = workspace.CurrentCamera
			if not cam then return end
			if Cfg.FOVCam then
				if origFov == nil then origFov = cam.FieldOfView end
				cam.FieldOfView = Cfg.FOVCamValue
			elseif origFov ~= nil then
				cam.FieldOfView = origFov; origFov = nil
			end
		end)
		cleanups[#cleanups + 1] = function()
			if origFov and workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = origFov end
		end

		-- ================= AVATAR (Headless + Korblox) =================
		local avChar, hlApplied, kbApplied = nil, false, false
		local hlSaved = {}

		local function applyHeadless(ch, want)
			local head = ch:FindFirstChild("Head")
			if not head then return false end
			local face = head:FindFirstChildOfClass("Decal")
			if want then
				if hlSaved.head == nil then hlSaved.head = head.Transparency end
				head.Transparency = 1
				if face then
					if hlSaved.face == nil then hlSaved.face = face.Transparency end
					face.Transparency = 1
				end
			else
				if hlSaved.head ~= nil then head.Transparency = hlSaved.head end
				if face and hlSaved.face ~= nil then face.Transparency = hlSaved.face end
				hlSaved = {}
			end
			return true
		end

		-- ---------- KORBLOX (asset 139607718, pierna derecha) ----------
		-- 1) carga el asset con GetObjects y busca las piezas de la pierna derecha
		-- 2) intenta cambiar MeshId/TextureID directo
		-- 3) si el executor no deja, CLONA las piezas, las suelda encima de las originales y oculta las originales
		-- Se re-aplica cada 0.25 s mientras esté activo (por si el juego lo resetea).
		local KORBLOX_ID = 139607718
		local KB_NAMES = {RightUpperLeg = true} -- la Korblox es SOLO la pieza de arriba
		local KB_HIDE_LOWER = true -- true = oculta la pierna de abajo + pie original (como la Korblox real). false = los deja visibles.
		local KB_LOWER = {"RightLowerLeg", "RightFoot"}
		local kbSrc = nil
		local kbClones, kbOrigTrans, kbMeshSaved = {}, {}, {}

		local function loadKorbloxSrc()
			if kbSrc then return kbSrc end
			local ok, objs = pcall(function() return game:GetObjects("rbxassetid://" .. KORBLOX_ID) end)
			if not ok or type(objs) ~= "table" then return nil end
			local found = {}
			for _, o in ipairs(objs) do
				if o:IsA("MeshPart") and KB_NAMES[o.Name] then found[o.Name] = o end
				for _, d in ipairs(o:GetDescendants()) do
					if d:IsA("MeshPart") and KB_NAMES[d.Name] then found[d.Name] = d end
				end
			end
			if next(found) then kbSrc = found end
			return kbSrc
		end

		-- true (ok) | false (el personaje todavía carga) | "r6" | "fail"
		local function applyKorblox(ch, want)
			if not ch:FindFirstChild("RightUpperLeg") then
				if ch:FindFirstChild("Right Leg") then return "r6" end
				return false
			end

			if not want then
				for name, clone in pairs(kbClones) do pcall(function() clone:Destroy() end) end
				for name, v in pairs(kbMeshSaved) do
					local p = ch:FindFirstChild(name)
					if p then pcall(function() p.MeshId = v[1]; p.TextureID = v[2] end) end
				end
				for name, t in pairs(kbOrigTrans) do
					local p = ch:FindFirstChild(name)
					if p then p.Transparency = t end
				end
				kbClones, kbOrigTrans, kbMeshSaved = {}, {}, {}
				return true
			end

			local src = loadKorbloxSrc()
			if not src then return "fail" end

			for name, s in pairs(src) do
				local p = ch:FindFirstChild(name)
				if p and p:IsA("MeshPart") then
					local clone = kbClones[name]
					if not clone or clone.Parent ~= ch then
						-- 1) intento directo (no funciona en todos los executors)
						if not kbMeshSaved[name] then kbMeshSaved[name] = {p.MeshId, p.TextureID} end
						pcall(function() p.MeshId = s.MeshId; p.TextureID = s.TextureID end)
						if p.MeshId == s.MeshId then
							kbClones[name] = nil
						else
							-- 2) forzado: clonar la pieza y soldarla encima de la original
							kbMeshSaved[name] = nil
							if kbOrigTrans[name] == nil then kbOrigTrans[name] = p.Transparency end
							clone = s:Clone()
							clone.Name = "KB_" .. name
							for _, d in ipairs(clone:GetDescendants()) do
								if d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("Motor6D") or d:IsA("Script")
									or d:IsA("LocalScript") then
									pcall(function() d:Destroy() end)
								end
							end
							clone.Anchored = false; clone.CanCollide = false; clone.CanTouch = false
							clone.CanQuery = false; clone.Massless = true; clone.Transparency = 0
							clone.CFrame = p.CFrame
							local w = Instance.new("Weld")
							w.Part0 = p; w.Part1 = clone; w.C0 = CFrame.new(); w.C1 = CFrame.new()
							w.Parent = clone
							clone.Parent = ch
							kbClones[name] = clone
						end
					end
					if kbClones[name] then p.Transparency = 1 end
				end
			end
			-- las dos piezas de abajo NO llevan mesh de Korblox: solo se ocultan las originales
			for _, n in ipairs(KB_LOWER) do
				local lp = ch:FindFirstChild(n)
				if lp and lp:IsA("BasePart") then
					if KB_HIDE_LOWER then
						if kbOrigTrans[n] == nil then kbOrigTrans[n] = lp.Transparency end
						lp.Transparency = 1
					elseif kbOrigTrans[n] ~= nil then
						lp.Transparency = kbOrigTrans[n]; kbOrigTrans[n] = nil
					end
				end
			end
			return true
		end

		-- RightLowerLeg + RightFoot siempre invisibles mientras Korblox esté activo (cada frame, por si el juego los resetea)
		bind(RunService.RenderStepped, function()
			if not Cfg.Korblox or not KB_HIDE_LOWER then return end
			local ch = LP.Character
			if not ch then return end
			for _, n in ipairs(KB_LOWER) do
				local lp = ch:FindFirstChild(n)
				if lp and lp:IsA("BasePart") and lp.Transparency ~= 1 then
					if kbOrigTrans[n] == nil then kbOrigTrans[n] = lp.Transparency end
					lp.Transparency = 1
				end
			end
		end)

		-- ================= ANIMACIONES =================
		-- {claveCfg, texto, carpeta dentro de "Animate", {nombres de las Animation}}
		local ANIMS = {
			{"AnimIdle",     "Idle (quieto)",  "idle",     {"Animation1", "Animation2"}},
			{"AnimWalk",     "Caminar",        "walk",     {"WalkAnim"}},
			{"AnimRun",      "Correr",         "run",      {"RunAnim"}},
			{"AnimJump",     "Saltar",         "jump",     {"JumpAnim"}},
			{"AnimFall",     "Caer",           "fall",     {"FallAnim"}},
			{"AnimClimb",    "Escalar",        "climb",    {"ClimbAnim"}},
			{"AnimSwim",     "Nadar",          "swim",     {"Swim"}},
			{"AnimSwimIdle", "Nadar quieto",   "swimidle", {"SwimIdle"}},
			{"AnimSit",      "Sentarse",       "sit",      {"SitAnim"}},
			{"AnimTool",     "Sostener item",  "toolnone", {"ToolNoneAnim"}},
		}
		local animOrig = setmetatable({}, {__mode = "k"}) -- [Animation] = id original
		local restarting, pendingRestart = false, false

		local function restartAnimate(ch)
			if restarting then pendingRestart = true return end
			restarting = true
			task.spawn(function()
				repeat
					pendingRestart = false
					local animate = ch:FindFirstChild("Animate")
					local hum = ch:FindFirstChildOfClass("Humanoid")
					if animate then
						animate.Disabled = true
						local animator = hum and hum:FindFirstChildOfClass("Animator")
						if animator then
							for _, t in ipairs(animator:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end
						end
						task.wait(.1)
						animate.Disabled = false
					end
				until not pendingRestart
				restarting = false
			end)
		end

		-- aplica los IDs de Cfg al script Animate; devuelve true si cambió algo
		local function applyAnims(ch)
			local animate = ch:FindFirstChild("Animate")
			if not animate then return false end
			local changed = false
			for _, a in ipairs(ANIMS) do
				local folder = animate:FindFirstChild(a[3])
				if folder then
					for _, n in ipairs(a[4]) do
						local an = folder:FindFirstChild(n)
						if an and an:IsA("Animation") then
							if animOrig[an] == nil then animOrig[an] = an.AnimationId end
							local id = Cfg[a[1]]
							local want = (id ~= "0" and id ~= "") and ("rbxassetid://" .. id) or animOrig[an]
							if an.AnimationId ~= want then an.AnimationId = want; changed = true end
						end
					end
				end
			end
			return changed
		end

		-- ================= LOOP (aplica todo, y re-aplica al respawnear) =================
		local acc = 0
		bind(RunService.Heartbeat, function(dt)
			acc += dt; if acc < .25 then return end; acc = 0
			local ch = LP.Character
			if ch ~= avChar then
				avChar = ch; hlApplied, kbApplied = false, false
				hlSaved = {}
				kbClones, kbOrigTrans, kbMeshSaved = {}, {}, {}
			end
			if not ch then return end

			if Cfg.Headless ~= hlApplied then
				if applyHeadless(ch, Cfg.Headless) then hlApplied = Cfg.Headless end
			end

			-- Korblox: se re-aplica en cada tick mientras esté activo
			if Cfg.Korblox then
				local r = applyKorblox(ch, true)
				if (r == "r6" or r == "fail") and not kbApplied then
					kbApplied = true -- avisa una sola vez
					notify(r == "r6" and "Korblox solo funciona con avatar R15"
						or "No se pudo cargar el asset (¿GetObjects soportado?)")
				end
			else
				if next(kbClones) or next(kbMeshSaved) or next(kbOrigTrans) then applyKorblox(ch, false) end
				kbApplied = false
			end

			if applyAnims(ch) then restartAnimate(ch) end
		end)

		cleanups[#cleanups + 1] = function()
			local ch = LP.Character
			if ch then
				if hlApplied then pcall(applyHeadless, ch, false) end
				pcall(applyKorblox, ch, false)
			end
			local any = false
			for an, orig in pairs(animOrig) do
				if an.Parent and an.AnimationId ~= orig then an.AnimationId = orig; any = true end
			end
			if any and ch then restartAnimate(ch) end
		end

		-- ================= UI =================
		local function IdBox(sf, text, key)
			local r = row(sf, 38); label(r, text)
			local f = mk("Frame", {AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -12, .5, 0), Size = UDim2.fromOffset(130, 24),
				BackgroundColor3 = C.Darker, BackgroundTransparency = .2, BorderSizePixel = 0}, r)
			corner(f, 6); mk("UIStroke", {Color = C.Red, Thickness = 1}, f)
			local tb = mk("TextBox", {Size = UDim2.new(1, -10, 1, 0), Position = UDim2.fromOffset(5, 0), BackgroundTransparency = 1,
				Text = Cfg[key], PlaceholderText = "0 = default", PlaceholderColor3 = T(190, 110, 110), Font = FONTB, TextSize = 12,
				TextColor3 = C.White, ClearTextOnFocus = false}, f)
			bind(tb.FocusLost, function()
				local id = tb.Text:match("%d+") or "0" -- acepta "123", "rbxassetid://123" o el link completo
				if tonumber(id) == 0 then id = "0" end
				tb.Text = id; Cfg[key] = id; markDirty()
				notify(text .. (id == "0" and ": predeterminada" or (": " .. id)))
			end)
			return tb
		end

		local nr = row(sf, 46)
		mk("TextLabel", {Position = UDim2.fromOffset(12, 4), Size = UDim2.new(1, -24, 1, -8), BackgroundTransparency = 1,
			Text = "TODO lo de esta pestaña es SOLO VISUAL: lo ves únicamente vos, los demás jugadores NO ven nada de esto.",
			Font = FONT, TextSize = 12, TextColor3 = C.Pink, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top}, nr)

		Section(sf, "Cámara")
		Toggle(sf, "FOV Camera", "FOVCam", true)
		Slider(sf, "Campo de visión (FOV)", "FOVCamValue", 60, 120, 1, " °")

		Section(sf, "Avatar")
		Toggle(sf, "Headless (sin cabeza)", "Headless", true)
		Toggle(sf, "Korblox (pierna derecha)", "Korblox", true)

		Section(sf, "Animaciones (0 = predeterminada)")
		local boxes = {}
		for _, a in ipairs(ANIMS) do boxes[a[1]] = IdBox(sf, a[2], a[1]) end
		Button(sf, "Restablecer todas las animaciones", function()
			for _, a in ipairs(ANIMS) do Cfg[a[1]] = "0"; boxes[a[1]].Text = "0" end
			markDirty(); notify("Animaciones restablecidas")
		end)
	end

	do -- APARIENCIA
		local sf = tabs.Apariencia.sf
		local transSet, fontBtn, placeCursor, stopRainbow, valSet

		-- ===== THEMES PREDETERMINADOS =====
		Section(sf, "Themes")
		local rowsN = math.ceil(#THEMES / 2)
		ord += 1
		local grid = mk("Frame", {Size = UDim2.new(1, 0, 0, rowsN * 50), BackgroundTransparency = 1, LayoutOrder = ord}, sf)
		mk("UIGridLayout", {CellSize = UDim2.new(.5, -4, 0, 44), CellPadding = UDim2.fromOffset(8, 6),
			SortOrder = Enum.SortOrder.LayoutOrder}, grid)
		local cards = {}
		local function paintCards()
			for name, c in pairs(cards) do
				local sel = (name == Cfg.Theme)
				c.stroke.Thickness = sel and 2.5 or 1
				c.stroke.Transparency = sel and 0 or .55
			end
		end
		local function applyPreset(t)
			stopRainbow()
			Cfg.Theme = t.name
			Cfg.ThemeHue, Cfg.ThemeSat, Cfg.ThemeVal = t.hue, t.sat, t.val
			applyTheme(t.hue, t.sat, t.val)
			placeCursor()
			Cfg.FontName = t.font; setFont(t.font)
			if fontBtn then fontBtn.Text = t.font .. "  >" end
			if transSet then transSet(t.trans) end
			if valSet then valSet(t.val) end
			applyStyle(t)
			markDirty(); paintCards()
			notify("Theme: " .. t.name)
		end
		for i, t in ipairs(THEMES) do
			local card = noTheme(mk("TextButton", {BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Text = "",
				AutoButtonColor = false, LayoutOrder = i}, grid))
			corner(card, 10)
			noTheme(mk("UIGradient", {Rotation = 0, Color = ColorSequence.new(t.c1, t.c2)}, card))
			local st = noTheme(mk("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 1, Transparency = .55,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, card))
			noTheme(mk("TextLabel", {Position = UDim2.fromOffset(10, 4), Size = UDim2.new(1, -20, 0, 18), BackgroundTransparency = 1,
				Text = t.name, Font = FONTB, TextSize = 13, TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = .6,
				TextXAlignment = Enum.TextXAlignment.Left}, card))
			noTheme(mk("TextLabel", {Position = UDim2.fromOffset(10, 23), Size = UDim2.new(1, -20, 0, 16), BackgroundTransparency = 1,
				Text = t.desc, Font = FONT, TextSize = 10, TextColor3 = Color3.new(1, 1, 1), TextTransparency = .1,
				TextStrokeTransparency = .7, TextXAlignment = Enum.TextXAlignment.Left}, card))
			cards[t.name] = {stroke = st}
			bind(card.MouseButton1Click, function() applyPreset(t) end)
		end
		paintCards()

		Section(sf, "Color del panel")

		-- paleta gradiente: X = color (arcoiris), Y = saturación
		local padRow = row(sf, 130)
		label(padRow, "Color del panel", 20)
		local pad = noTheme(mk("Frame", {Position = UDim2.fromOffset(12, 24), Size = UDim2.new(1, -24, 0, 96),
			BackgroundColor3 = C.White, BorderSizePixel = 0}, padRow))
		corner(pad, 8)
		noTheme(mk("UIGradient", {Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)), ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6, 1, 1)),
			ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6, 1, 1)), ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6, 1, 1)),
			ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6, 1, 1)), ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1))}}, pad))
		local wash = noTheme(mk("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = C.White, BorderSizePixel = 0}, pad))
		corner(wash, 8)
		noTheme(mk("UIGradient", {Rotation = 90, Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, .15)}}, wash))
		local cursor = noTheme(mk("Frame", {AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(14, 14),
			BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 3}, pad))
		corner(cursor, 99)
		noTheme(mk("UIStroke", {Color = C.White, Thickness = 2}, cursor))
		local padHit = mk("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", ZIndex = 4}, pad)

		placeCursor = function()
			cursor.Position = UDim2.new(math.clamp(Cfg.ThemeHue / 359, 0, 1), 0, math.clamp((100 - Cfg.ThemeSat) / 75, 0, 1), 0)
		end
		placeCursor()
		stopRainbow = function()
			if Cfg.Rainbow and toggleSetters.Rainbow then toggleSetters.Rainbow(false, true) end
		end
		local padDrag, lastApply = false, 0
		local function fromPad(pos, force)
			local x = math.clamp((pos.X - pad.AbsolutePosition.X) / pad.AbsoluteSize.X, 0, 1)
			local y = math.clamp((pos.Y - pad.AbsolutePosition.Y) / pad.AbsoluteSize.Y, 0, 1)
			Cfg.ThemeHue = math.floor(x * 359)
			Cfg.ThemeSat = math.floor(100 - y * 75)
			cursor.Position = UDim2.new(x, 0, y, 0)
			markDirty()
			if force or tick() - lastApply > .05 then
				lastApply = tick()
				applyTheme(Cfg.ThemeHue, Cfg.ThemeSat)
			end
		end
		bind(padHit.InputBegan, function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				stopRainbow()
				padDrag = true; fromPad(i.Position, true)
			end
		end)
		bind(UIS.InputChanged, function(i)
			if padDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				fromPad(i.Position, false)
			end
		end)
		bind(UIS.InputEnded, function(i)
			if padDrag and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
				padDrag = false
				applyTheme(Cfg.ThemeHue, Cfg.ThemeSat)
			end
		end)

		-- colores rapidos
		local pr = row(sf, 40)
		local presets = {0, 20, 45, 70, 120, 160, 185, 210, 240, 270, 300, 330}
		for i, h in ipairs(presets) do
			local b = noTheme(mk("TextButton", {Position = UDim2.fromOffset(12 + (i - 1) * 31, 8), Size = UDim2.fromOffset(26, 24),
				BackgroundColor3 = Color3.fromHSV(h / 360, .9, .9), Text = "", AutoButtonColor = false}, pr))
			corner(b, 8); mk("UIStroke", {Color = C.White, Transparency = .5}, b)
			bind(b.MouseButton1Click, function()
				stopRainbow()
				Cfg.ThemeHue = h; Cfg.ThemeSat = 100; markDirty()
				applyTheme(h, 100); placeCursor()
			end)
		end

		-- rainbow
		Toggle(sf, "Panel Rainbow", "Rainbow")
		Slider(sf, "Velocidad rainbow", "RainbowSpeed", 10, 180, 5, " °/s")
		local rbT, wasRb = 0, false
		bind(RunService.Heartbeat, function(dt)
			if Cfg.Rainbow then
				wasRb = true
				rbT += dt
				if rbT < .12 then return end
				local step = Cfg.RainbowSpeed * rbT
				rbT = 0
				applyTheme((curHue + step) % 360, curSat)
			elseif wasRb then
				wasRb = false; rbT = 0
				Cfg.ThemeHue = math.floor(curHue + .5) % 360
				placeCursor(); markDirty()
			end
		end)

		Section(sf, "Transparencia y tamaño")
		valSet = Slider(sf, "Brillo del color", "ThemeVal", 20, 100, 5, " %", function(v) applyTheme(curHue, curSat, v) end)
		transSet = Slider(sf, "Transparencia del panel", "PanelTrans", 0, 90, 5, " %", function(v) applyPanelTrans(v) end)
		Slider(sf, "Tamaño de la interfaz", "UIScale", 70, 200, 5, " %", function(v)
			Panel:SetAttribute("BaseScale", v / 100)
			if state == "panel" and not hidden and Panel.Visible then tw(Panel.Pop, .15, {Scale = v / 100}) end
			Panel.Position = clampPos(Panel, Panel.Position)
		end)

		Section(sf, "Fuente")
		fontBtn = Cycle(sf, "Fuente del texto", "FontName", FONT_NAMES, function(v) setFont(v) end)
	end

	do -- SERVERS
		local sf = tabs.Servers.sf
		local busy = false

		Section(sf, "Servidores")
		local ir = row(sf, 62)
		mk("TextLabel", {Position = UDim2.fromOffset(12, 4), Size = UDim2.new(1, -24, 1, -8), BackgroundTransparency = 1,
			Text = "Join Other: entra a un server bastante lleno pero con lugar para vos (no repite servers donde ya estuviste).\nRejoin: vuelve a entrar al mismo server donde estás ahora.",
			Font = FONT, TextSize = 12, TextColor3 = C.Pink, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top}, ir)

		local function go(s)
			markVisited(game.JobId)
			notify("Entrando al server (" .. s.playing .. "/" .. s.maxPlayers .. ")...")
			local ok, err = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, s.id, LP)
			if not ok then notify("No se pudo teletransportar: " .. tostring(err)); busy = false end
		end

		bind(TeleportService.TeleportInitFailed, function(_, _, msg)
			busy = false
			notify("Falló el teleport: " .. tostring(msg))
		end)

		Button(sf, "Join Other Server (lleno pero no tanto)", function()
			if busy then return end
			busy = true
			task.spawn(function()
				local list, err = fetchServers()
				if not list then notify(tostring(err)); busy = false return end
				local pick
				for _, s in ipairs(list) do -- ya viene ordenado de más lleno a menos lleno
					if s.id ~= game.JobId and not isVisited(s.id) and s.playing and s.maxPlayers
						and s.playing >= 2 and s.playing <= s.maxPlayers - 2 then
						pick = s; break
					end
				end
				if not pick then notify(err or "No encontré un server adecuado"); busy = false return end
				go(pick)
			end)
		end)

		Button(sf, "Rejoin Server", function()
			if busy then return end
			busy = true
			notify("Reentrando al server...")
			local ok, err = pcall(function()
				if #Players:GetPlayers() <= 1 then
					TeleportService:Teleport(game.PlaceId, LP) -- solo en el server: el server se cierra, entra a uno nuevo
				else
					TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
				end
			end)
			if not ok then notify("No se pudo reentrar: " .. tostring(err)); busy = false end
		end)

		Section(sf, "Historial")
		local hist = row(sf, 38)
		local hl = mk("TextLabel", {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -110, 1, 0), BackgroundTransparency = 1,
			Font = FONT, TextSize = 13, TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Left}, hist)
		local function refreshHist() hl.Text = "Servers en la lista negra: " .. #visited end
		refreshHist()
		local clr = smallBtn(hist, "Limpiar", 80, 10)
		bind(clr.MouseButton1Click, function()
			table.clear(visited); saveVisited(); refreshHist(); notify("Historial de servers borrado")
		end)
		task.spawn(function()
			while Gui.Parent do task.wait(2); refreshHist() end
		end)
	end

	do -- FEEDBACK
		local sf = tabs.Feedback.sf
		local useAdm = function() return isAdm and (genv.LPD_ADMIN_SECRET or "") ~= "" end
		local fbStars = 0
		local refreshFeedback

		Section(sf, "Dejá tu feedback")
		local fr = row(sf, 132)
		label(fr, "Tu puntuación", 28)
		local starBtns = {}
		local function paintStars()
			for i, b in ipairs(starBtns) do b.TextColor3 = i <= fbStars and C.Gold or Color3.fromRGB(90, 90, 90) end
		end
		for i = 1, 5 do
			local b = noTheme(mk("TextButton", {Position = UDim2.fromOffset(150 + (i - 1) * 30, 4), Size = UDim2.fromOffset(28, 24),
				BackgroundTransparency = 1, Text = "★", Font = FONTB, TextSize = 22, TextColor3 = Color3.fromRGB(90, 90, 90)}, fr))
			starBtns[i] = b
			bind(b.MouseButton1Click, function() fbStars = i; paintStars() end)
		end
		local boxF = mk("Frame", {Position = UDim2.fromOffset(12, 34), Size = UDim2.new(1, -24, 0, 66), BackgroundColor3 = C.Darker,
			BackgroundTransparency = .1, BorderSizePixel = 0}, fr)
		corner(boxF, 8); mk("UIStroke", {Color = C.Red, Thickness = 1}, boxF)
		-- (sin MaxLength: TextBox no tiene esa propiedad; el limite de 150 se aplica abajo con clip)
		local fbBox = mk("TextBox", {Position = UDim2.fromOffset(8, 4), Size = UDim2.new(1, -16, 1, -8), BackgroundTransparency = 1,
			Text = "", PlaceholderText = "Escribí tu opinión (máx. 150 caracteres)", PlaceholderColor3 = T(190, 110, 110),
			Font = FONT, TextSize = 13, TextColor3 = C.White, ClearTextOnFocus = false, MultiLine = true, TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top}, boxF)
		local counter = mk("TextLabel", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 104), Size = UDim2.fromOffset(80, 20),
			BackgroundTransparency = 1, Text = "0/150", Font = FONT, TextSize = 11, TextColor3 = C.Pink,
			TextXAlignment = Enum.TextXAlignment.Right}, fr)
		bind(fbBox:GetPropertyChangedSignal("Text"), function()
			if utf8.len(fbBox.Text) and utf8.len(fbBox.Text) > 150 then fbBox.Text = clip(fbBox.Text, 150) end
			counter.Text = (utf8.len(fbBox.Text) or #fbBox.Text) .. "/150"
		end)

		local function fbSentLocal()
			local ok, v = pcall(function() if isfile and isfile(FB_FILE) then return readfile(FB_FILE) end end)
			return ok and v == tostring(LP.UserId)
		end
		local function markFbSent() pcall(function() if writefile then writefile(FB_FILE, tostring(LP.UserId)) end end) end

		Button(sf, "Enviar feedback", function()
			local raw = fbBox.Text:gsub("[\r\n]+", " ")
			raw = clip(raw:match("^%s*(.-)%s*$") or "", 150)
			if fbStars == 0 then notify("Elegí tus estrellas primero") return end
			if #raw < 3 then notify("Escribí tu opinión") return end
			-- censura de insultos / links (se guarda y se envía ya censurado)
			local txt = censorText(raw)
			local wasCensored = (txt ~= raw)
			task.spawn(function()
				if not isAdm and fbSentLocal() then notify("Ya enviaste tu feedback") return end
				local okG, ex = db("GET", "feedback/" .. LP.UserId)
				if okG and ex ~= nil and not isAdm then notify("Ya enviaste tu feedback") return end
				local okW, errW = sendFeedbackWebhook(fbStars, txt)
				if not okW then notify("No se pudo enviar: " .. tostring(errW)) return end
				local ok2, err = db("PUT", "feedback/" .. LP.UserId, {
					uid = LP.UserId, name = LP.Name, stars = fbStars, text = txt, at = os.time()}, useAdm())
				markFbSent()
				if ok2 then
					notify(wasCensored and "¡Gracias! (se censuraron palabras no permitidas)" or "¡Gracias por tu feedback!")
				else
					notify("¡Gracias! Enviado, pero no se pudo guardar en la lista: " .. tostring(err))
				end
				fbBox.Text = ""; fbStars = 0; paintStars()
				refreshFeedback()
			end)
		end)

		Section(sf, "Feedback de la comunidad")
		Button(sf, "Actualizar lista", function() refreshFeedback() end)
		local fbList = listFrame(sf)

		local function feedbackCard(parent, e)
			ord += 1
			local card = mk("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.White,
				BackgroundTransparency = .35, BorderSizePixel = 0, LayoutOrder = ord}, parent)
			corner(card, 8); redGrad(card, 90); mk("UIStroke", {Color = C.Red, Transparency = .6}, card)
			mk("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8)}, card)
			mk("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, card)

			local head = mk("Frame", {Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, LayoutOrder = 1}, card)
			local img = mk("ImageLabel", {Position = UDim2.fromOffset(0, 1), Size = UDim2.fromOffset(36, 36), BackgroundColor3 = C.Darker,
				BorderSizePixel = 0, Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(e.uid) .. "&w=150&h=150"}, head)
			corner(img, 99); mk("UIStroke", {Color = C.Red, Thickness = 1.5}, img)
			mk("TextLabel", {Position = UDim2.fromOffset(44, 2), Size = UDim2.new(1, -130, 0, 18), BackgroundTransparency = 1,
				Text = tostring(e.name), Font = FONTB, TextSize = 14, TextColor3 = C.White,
				TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, head)
			starsLabels(head, math.clamp(tonumber(e.stars) or 0, 0, 5), UDim2.fromOffset(44, 21))
			mk("TextLabel", {Position = UDim2.fromOffset(124, 21), Size = UDim2.fromOffset(40, 14), BackgroundTransparency = 1,
				Text = (tonumber(e.stars) or 0) .. "/5", Font = FONT, TextSize = 11, TextColor3 = C.Pink,
				TextXAlignment = Enum.TextXAlignment.Left}, head)
			-- se censura también al MOSTRAR (por si hay feedback viejo guardado sin censurar)
			mk("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
				Text = censorText(tostring(e.text)), Font = FONT, TextSize = 13, TextColor3 = C.White, TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = 2}, card)

			if isAdm then
				local del = smallBtn(head, "Eliminar", 68, 0)
				bind(del.MouseButton1Click, function()
					task.spawn(function()
						local ok, err = db("DELETE", "feedback/" .. tostring(e.uid), nil, true)
						notify(ok and "Feedback eliminado" or ("Error: " .. tostring(err))); refreshFeedback()
					end)
				end)
			end
		end

		refreshFeedback = function()
			task.spawn(function()
				local ok, data = db("GET", "feedback", nil, useAdm())
				clearList(fbList)
				if not ok then
					empty(fbList, "No se pudo cargar la lista (" .. tostring(data) .. "). Si dice 401 / Permission denied: falta permitir lectura de 'feedback' en las reglas de Firebase.")
					return
				end
				local arr = {}
				if type(data) == "table" then
					for k, v in pairs(data) do
						if type(v) == "table" and v.text then
							if v.uid == nil then v.uid = tonumber(k) or 0 end
							if v.name == nil then v.name = "?" end
							arr[#arr + 1] = v
						end
					end
				end
				table.sort(arr, function(a, b) return (tonumber(a.at) or 0) > (tonumber(b.at) or 0) end)
				if #arr == 0 then empty(fbList, "Todavía no hay feedback") end
				for _, e in ipairs(arr) do feedbackCard(fbList, e) end
			end)
		end
		refreshFeedback()
	end

	do -- INFO
		local sf = tabs.Info.sf
		Section(sf, TITLE)
		local function textRow(h, text, size, font)
			local r = row(sf, h)
			mk("TextLabel", {Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -24, 1, -12), BackgroundTransparency = 1,
				Text = text, Font = font or FONT, TextSize = size or 13, TextColor3 = C.White, TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top}, r)
			return r
		end
		textRow(86, "VLP PANEL V7.00\nHecho 100% a mano, línea por línea, por sus creadores. Nada de copy-paste ni scripts ajenos: cada función, cada botón y cada detalle fue escrito desde cero.", 13)
		Section(sf, "Creadores")
		for _, dc in ipairs({DISCORD, DISCORD2}) do
			local r = row(sf, 38)
			mk("TextLabel", {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -100, 1, 0), BackgroundTransparency = 1,
				Text = dc, Font = FONTB, TextSize = 13, TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd}, r)
			local b = smallBtn(r, "Copiar", 64, 10)
			bind(b.MouseButton1Click, function() notify(copy(dc) and "Link copiado" or "Tu executor no puede copiar") end)
		end
		Section(sf, "Derechos")
		textRow(128, "© VLP PANEL. Todos los derechos reservados.\nEste panel fue creado y escrito a mano por sus creadores. Queda prohibido copiarlo, editarlo, revenderlo o redistribuirlo sin permiso. Quien lo robe o lo venda como propio será blacklisteado y perderá el acceso.", 12)
		textRow(48, "Gracias por usar VLP PANEL. Si tenés dudas o problemas, hablales por Discord.", 12)
	end

	--// ---------- ADMIN PANEL ----------
	if isAdm then
		local sf = tabs.Admin.sf
		local refreshKeys, refreshBL

		-- crear key
		Section(sf, "Crear Key")
		local r = row(sf, 72)
		local function small(t, x) return mk("TextLabel", {Position = UDim2.fromOffset(x, 4), Size = UDim2.fromOffset(90, 18), BackgroundTransparency = 1,
			Text = t, Font = FONT, TextSize = 12, TextColor3 = C.Pink, TextXAlignment = Enum.TextXAlignment.Left}, r) end
		small("Cantidad", 14); small("Duración", 118)
		local _, amountTB = fancyBox(r, "1", UDim2.fromOffset(90, 34), UDim2.fromOffset(12, 28)); amountTB.Text = "1"
		local units = {{id = "Min", t = "Min", m = 60}, {id = "Horas", t = "Horas", m = 3600}, {id = "Dias", t = "Días", m = 86400}, {id = "Perm", t = "Perm", m = 0}}
		local unit, segs = "Horas", {}
		for i, u in ipairs(units) do
			local f = mk("Frame", {Position = UDim2.fromOffset(116 + (i - 1) * 70, 28), Size = UDim2.fromOffset(66, 34),
				BackgroundColor3 = (u.id == unit) and C.Red or C.Darker, BorderSizePixel = 0}, r)
			corner(f, 8); mk("UIStroke", {Color = C.Red, Thickness = 1}, f)
			local b = mk("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = u.t, Font = FONTB,
				TextSize = 13, TextColor3 = C.White}, f)
			segs[u.id] = f
			bind(b.MouseButton1Click, function()
				unit = u.id
				for id, fr in pairs(segs) do tw(fr, .2, {BackgroundColor3 = (id == unit) and C.Red or C.Darker}) end
			end)
		end
		Button(sf, "+ Crear Key", function()
			local secs = 0
			if unit ~= "Perm" then
				local n = tonumber(amountTB.Text)
				if not n or n <= 0 then notify("Cantidad inválida") return end
				for _, u in ipairs(units) do if u.id == unit then secs = math.floor(n * u.m) end end
			end
			task.spawn(function()
				local k = genKey()
				local ok, err = db("PUT", "keys/" .. k, {dur = secs, created = os.time(), by = LP.Name}, true)
				if ok then
					copy(k); notify("Key creada y copiada: " .. k); refreshKeys()
				else notify("Error: " .. tostring(err)) end
			end)
		end)

		-- lista de keys
		Section(sf, "Keys creadas")
		Button(sf, "Actualizar lista", function() refreshKeys() end)
		local keyList = listFrame(sf)
		local function addKeyRow(k, v)
			local rr = row(keyList, 48)
			mk("TextLabel", {Position = UDim2.fromOffset(12, 4), Size = UDim2.new(.55, 0, 0, 20), BackgroundTransparency = 1, Text = k,
				Font = FONTB, TextSize = 14, TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Left}, rr)
			local st
			if not v.user then st = "Libre • " .. fmtT(v.dur or 0)
			elseif v.exp and v.exp > 0 and os.time() >= v.exp then st = "Expirada • " .. tostring(v.uname)
			else st = "En uso: " .. tostring(v.uname) .. " • " .. ((v.exp and v.exp > 0) and ("quedan " .. fmtT(v.exp - os.time())) or "Permanente") end
			mk("TextLabel", {Position = UDim2.fromOffset(12, 25), Size = UDim2.new(.6, 0, 0, 16), BackgroundTransparency = 1, Text = st,
				Font = FONT, TextSize = 11, TextColor3 = v.user and Color3.fromRGB(255, 190, 120) or C.Green, TextXAlignment = Enum.TextXAlignment.Left}, rr)
			local del = smallBtn(rr, "X", 26, 8)
			local cp = smallBtn(rr, "Copiar", 56, 40)
			bind(cp.MouseButton1Click, function() notify(copy(k) and "Key copiada" or "Tu executor no puede copiar") end)
			bind(del.MouseButton1Click, function()
				task.spawn(function()
					local ok, err = db("DELETE", "keys/" .. k, nil, true)
					notify(ok and "Key eliminada" or ("Error: " .. tostring(err))); refreshKeys()
				end)
			end)
		end
		refreshKeys = function()
			task.spawn(function()
				local ok, data = db("GET", "keys", nil, true)
				if not ok then notify("Error: " .. tostring(data)) return end
				clearList(keyList)
				local arr = {}
				for k, v in pairs(type(data) == "table" and data or {}) do if type(v) == "table" then arr[#arr + 1] = {k = k, v = v} end end
				table.sort(arr, function(a, b) return (a.v.created or 0) > (b.v.created or 0) end)
				if #arr == 0 then empty(keyList, "No hay keys creadas") end
				for _, e in ipairs(arr) do addKeyRow(e.k, e.v) end
			end)
		end

		-- blacklist (base de datos: banea a alguien del script)
		Section(sf, "Blacklist (ban del script)")
		local br = row(sf, 50)
		local _, blTB = fancyBox(br, "Usuario o UserId", UDim2.fromOffset(240, 32), UDim2.fromOffset(10, 9))
		local addBtn = smallBtn(br, "Agregar", 84, 10)
		Button(sf, "Actualizar blacklist", function() refreshBL() end)
		local dbList = listFrame(sf)
		bind(addBtn.MouseButton1Click, function()
			task.spawn(function()
				local txt = (blTB.Text:gsub("%s", ""))
				if txt == "" then return end
				local uid, name
				if tonumber(txt) then
					uid = tonumber(txt)
					local ok, n = pcall(Players.GetNameFromUserIdAsync, Players, uid); name = ok and n or "?"
				else
					local ok, id = pcall(Players.GetUserIdFromNameAsync, Players, txt)
					if ok then uid = id; name = txt end
				end
				if not uid then notify("Usuario no encontrado") return end
				if ADMIN_IDS[uid] then notify("No podés blacklistear a un admin") return end
				local ok, err = db("PUT", "blacklist/" .. uid, {name = name, by = LP.Name, at = os.time()}, true)
				if ok then blTB.Text = ""; notify(name .. " fue blacklisteado"); refreshBL()
				else notify("Error: " .. tostring(err)) end
			end)
		end)
		refreshBL = function()
			task.spawn(function()
				local ok, data = db("GET", "blacklist", nil, true)
				if not ok then notify("Error: " .. tostring(data)) return end
				clearList(dbList)
				local n = 0
				for uid, v in pairs(type(data) == "table" and data or {}) do
					n += 1
					local rr = row(dbList, 44)
					mk("TextLabel", {Position = UDim2.fromOffset(12, 4), Size = UDim2.new(.6, 0, 0, 20), BackgroundTransparency = 1,
						Text = tostring(type(v) == "table" and v.name or "?"), Font = FONTB, TextSize = 14, TextColor3 = C.White,
						TextXAlignment = Enum.TextXAlignment.Left}, rr)
					mk("TextLabel", {Position = UDim2.fromOffset(12, 24), Size = UDim2.new(.6, 0, 0, 16), BackgroundTransparency = 1,
						Text = "ID: " .. uid, Font = FONT, TextSize = 11, TextColor3 = C.Pink, TextXAlignment = Enum.TextXAlignment.Left}, rr)
					local q = smallBtn(rr, "Quitar", 64, 10)
					bind(q.MouseButton1Click, function()
						task.spawn(function()
							local ok2, err = db("DELETE", "blacklist/" .. uid, nil, true)
							notify(ok2 and "Quitado de la blacklist" or ("Error: " .. tostring(err))); refreshBL()
						end)
					end)
				end
				if n == 0 then empty(dbList, "Blacklist vacía") end
			end)
		end
		refreshKeys(); refreshBL()
	end

	--// ---------- MINIMIZADO ----------
	local Mini = mk("Frame", {Name = "Mini", AnchorPoint = Vector2.new(.5, .5), Position = Panel.Position, Size = UDim2.fromOffset(60, 60),
		BackgroundColor3 = C.White, BorderSizePixel = 0, Visible = false}, Gui)
	corner(Mini, 16)
	mk("UIGradient", {Rotation = 45, Color = ColorSequence.new(C.Red, T(110, 0, 3))}, Mini)
	shineStroke(Mini, 3)
	mk("UIScale", {Name = "Pop", Scale = .01}, Mini)
	local miniIcon = mk("ImageLabel", {AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(.5, 0, .5, 0), Size = UDim2.fromOffset(36, 36),
		Image = ICON, BackgroundTransparency = 1}, Mini)
	corner(miniIcon, 8)
	bind(Mini.MouseEnter, function() tw(miniIcon, .25, {Rotation = 10, Size = UDim2.fromOffset(42, 42)}, Enum.EasingStyle.Back) end)
	bind(Mini.MouseLeave, function() tw(miniIcon, .25, {Rotation = 0, Size = UDim2.fromOffset(36, 36)}, Enum.EasingStyle.Back) end)

	local function minimize()
		if state ~= "panel" or hidden then return end
		state = "mini"; Mini.Position = clampPos(Mini, Panel.Position)
		popOut(Panel); task.delay(.15, function() if state == "mini" and not hidden then popIn(Mini) end end)
	end
	local function restore()
		if state ~= "mini" or hidden then return end
		state = "panel"; Panel.Position = clampPos(Panel, Mini.Position)
		popOut(Mini); task.delay(.15, function() if state == "panel" and not hidden then popIn(Panel) end end)
	end
	draggable(TopBar, Panel)
	draggable(Mini, Mini, restore)
	bind(BtnMin.MouseButton1Click, minimize)
	bind(BtnClose.MouseButton1Click, function() popOut(Panel); task.delay(.3, Unload) end)

	local StatusUI
	-- teclas: K (mostrar/ocultar) y keybinds de cada opcion
	bind(UIS.InputBegan, function(input, gp)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		local kc = input.KeyCode
		if listening then
			if kc == Enum.KeyCode.Escape then
				endListen()
			elseif kc == Enum.KeyCode.Backspace or kc == Enum.KeyCode.Delete then
				Binds[listening.key] = nil; markDirty(); endListen(); notify("Tecla borrada")
			elseif kc == Enum.KeyCode.K then
				notify("La tecla K está reservada para mostrar/ocultar"); endListen()
			elseif kc ~= Enum.KeyCode.Unknown then
				Binds[listening.key] = kc.Name; markDirty()
				local nm = kc.Name
				endListen(); notify("Tecla asignada: " .. nm)
			end
			return
		end
		if gp then return end
		if kc == Enum.KeyCode.K then
			local obj = (state == "panel") and Panel or Mini
			hidden = not hidden
			if hidden then popOut(obj) else popIn(obj) end
			if StatusUI then if hidden then popOut(StatusUI) else popIn(StatusUI) end end
			return
		end
		for key, kn in pairs(Binds) do
			if kn == kc.Name and toggleSetters[key] then toggleSetters[key](not Cfg[key]) end
		end
	end)

	--// ---------- MINI PANEL DE ESTADO (movible, minimizable, se oculta con K) ----------
	do
		local H = mk("Frame", {Name = "Status", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset(155, 116),
			Size = UDim2.fromOffset(290, 108), BackgroundColor3 = C.White, BackgroundTransparency = .1,
			BorderSizePixel = 0, ClipsDescendants = true}, Gui)
		corner(H, 10)
		mk("UIGradient", {Rotation = 90, Color = ColorSequence.new(T(28, 0, 1), T(120, 0, 3))}, H)
		shineStroke(H, 1.5)
		mk("UIScale", {Name = "Pop", Scale = .01}, H)
		StatusUI = H

		local bar = mk("Frame", {Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1}, H)
		mk("TextLabel", {Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -44, 1, 0), BackgroundTransparency = 1,
			Text = "ESTADO", Font = FONTB, TextSize = 11, TextColor3 = C.Pink, TextXAlignment = Enum.TextXAlignment.Left}, bar)
		local mb = mk("TextButton", {AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -6, .5, 0), Size = UDim2.fromOffset(20, 20),
			BackgroundColor3 = C.Dark, BackgroundTransparency = .2, Text = "-", Font = FONTB, TextSize = 14,
			TextColor3 = C.White, AutoButtonColor = false}, bar)
		corner(mb, 99); fx(mb, mb, .2, 0)

		local function sline(i)
			return mk("TextLabel", {Position = UDim2.fromOffset(10, 30 + (i - 1) * 20), Size = UDim2.new(1, -20, 0, 18), BackgroundTransparency = 1,
				Text = "", Font = FONTB, TextSize = 12, TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd}, H)
		end
		local lPing, lReg, lFps = sline(1), sline(2), sline(3)
		noTheme(lPing)
		local jobId = (game.JobId ~= "" and game.JobId) or "Studio"
		local lId = mk("TextButton", {Position = UDim2.fromOffset(10, 90), Size = UDim2.new(1, -20, 0, 18), BackgroundTransparency = 1,
			Text = "Server Id: " .. jobId, Font = FONTB, TextSize = 11, TextColor3 = C.Pink, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, AutoButtonColor = false}, H)
		bind(lId.MouseButton1Click, function() notify(copy(jobId) and "Server Id copiado" or "Tu executor no puede copiar") end)

		-- minimizar / expandir
		local open = true
		bind(mb.MouseButton1Click, function()
			open = not open
			local top = H.Position.Y.Offset - H.Size.Y.Offset / 2
			local nh = open and 108 or 26
			mb.Text = open and "-" or "+"
			tw(H, .2, {Size = UDim2.fromOffset(290, nh), Position = UDim2.fromOffset(H.Position.X.Offset, top + nh / 2)})
		end)
		draggable(bar, H)

		-- region (estimada: Roblox no le muestra al cliente donde esta el server)
		local CN = {AR = "Argentina", BR = "Brazil", US = "USA", CL = "Chile", UY = "Uruguay", PY = "Paraguay", BO = "Bolivia",
			PE = "Peru", CO = "Colombia", EC = "Ecuador", VE = "Venezuela", MX = "Mexico", CA = "Canada", ES = "Spain",
			FR = "France", DE = "Germany", IT = "Italy", GB = "UK", PT = "Portugal", NL = "Netherlands", PL = "Poland"}
		local SA = {AR = 1, BR = 1, CL = 1, UY = 1, PY = 1, BO = 1, PE = 1, CO = 1, EC = 1, VE = 1}
		local NA = {US = 1, CA = 1, MX = 1}
		local EU = {ES = 1, FR = 1, DE = 1, IT = 1, GB = 1, PT = 1, NL = 1, PL = 1}
		local function regionFor(cc, ping)
			local own = CN[cc] or cc or "?"
			if SA[cc] then
				if ping <= 35 then return own end
				return ping <= 100 and "~Brazil" or "~USA"
			elseif NA[cc] then
				if ping <= 60 then return own end
				return ping <= 140 and "~USA" or "~Europe"
			elseif EU[cc] then
				if ping <= 60 then return own end
				return ping <= 140 and "~Europe" or "~USA"
			end
			return ping <= 60 and own or ("~" .. own)
		end

		local country
		task.spawn(function()
			local ok, cc = pcall(function() return game:GetService("LocalizationService"):GetCountryRegionForPlayerAsync(LP) end)
			if ok and type(cc) == "string" then country = cc end
		end)
		local function getPing()
			local ok, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
			if ok and type(v) == "number" then return math.floor(v) end
			local ok2, p = pcall(function() return LP:GetNetworkPing() end)
			return ok2 and math.floor(p * 2000) or 0
		end
		local frames = 0
		bind(RunService.RenderStepped, function() frames += 1 end)
		task.spawn(function()
			local last = tick()
			while Gui.Parent do
				task.wait(.5)
				local now = tick()
				local fps = math.floor(frames / math.max(now - last, .001) + .5)
				frames = 0; last = now
				local ping = getPing()
				lPing.Text = "Ping: " .. ping .. " ms"
				lPing.TextColor3 = ping < 80 and C.Green or (ping < 150 and Color3.fromRGB(255, 220, 90) or Color3.fromRGB(255, 80, 80))
				lReg.Text = "Región: " .. regionFor(country, ping)
				lFps.Text = "FPS: " .. fps
			end
		end)

		popIn(H)
	end

	--// ---------- MONITOR DE SESION ----------
	task.spawn(function() -- contador de key
		while Gui.Parent do
			if isAdm then info.Text = "ADMIN"
			elseif keyRec and keyRec.exp and keyRec.exp > 0 then info.Text = "Key: " .. fmtT(math.max(1, keyRec.exp - os.time()))
			else info.Text = "Key: Permanente" end
			task.wait(1)
		end
	end)
	task.spawn(function() -- autoguardado de la configuracion
		while Gui.Parent do
			task.wait(1)
			if dirty then dirty = false; saveNow() end
		end
	end)
	if not isAdm then
		task.spawn(function() -- blacklist + key revocada/expirada
			while Gui.Parent do
				task.wait(20)
				if not Gui.Parent then break end
				local okb, bl = db("GET", "blacklist/" .. LP.UserId)
				if okb and bl ~= nil then LP:Kick("Estás en la blacklist de VLP PANEL. No podés usar este script.") return end
				if keyName then
					local ok2, rec = db("GET", "keys/" .. keyName)
					if ok2 and (type(rec) ~= "table" or rec.user ~= LP.UserId or (rec.exp and rec.exp > 0 and os.time() >= rec.exp)) then
						notify("Tu key expiró o fue revocada"); task.wait(1.8); Unload() return
					end
				end
			end
		end)
	end

	selectTab("Aimbot")
	popIn(Panel)
	notify(isAdm and "Bienvenido admin  |  K = ocultar/mostrar" or "Acceso concedido  |  K = ocultar/mostrar")
	if not hasDraw then task.delay(1.2, function() notify("Drawing API no disponible: el ESP no va a funcionar") end) end
end

--// ================= PANTALLA DE KEY =================
local function BuildLogin(saved)
	local Dim = mk("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
		BorderSizePixel = 0}, Gui)
	tw(Dim, .5, {BackgroundTransparency = .45})

	local L = mk("Frame", {Name = "Login", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
		Size = UDim2.fromOffset(440, 296), BackgroundColor3 = C.White, BorderSizePixel = 0, Visible = false}, Gui)
	corner(L, 14)
	mk("UIGradient", {Rotation = 90, Color = ColorSequence.new(T(28, 0, 1), T(120, 0, 3))}, L)
	shineStroke(L, 2.5)
	mk("UIScale", {Name = "Pop", Scale = .01}, L)

	local top = mk("Frame", {Size = UDim2.new(1, 0, 0, 54), BackgroundTransparency = 1}, L)
	local ic = mk("ImageLabel", {Image = ICON, Position = UDim2.fromOffset(16, 11), Size = UDim2.fromOffset(32, 32), BackgroundTransparency = 1}, top)
	corner(ic, 8)
	TS:Create(ic, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Position = UDim2.fromOffset(16, 15)}):Play()
	mk("TextLabel", {Position = UDim2.fromOffset(58, 0), Size = UDim2.new(1, -110, 1, 0), BackgroundTransparency = 1,
		Text = TITLE, Font = FONTB, TextSize = 18, TextColor3 = C.White,
		TextXAlignment = Enum.TextXAlignment.Left}, top)
	local xb = circleBtn(top, "X", 14)
	local ln = mk("Frame", {Position = UDim2.new(0, 14, 0, 54), Size = UDim2.new(1, -28, 0, 1), BackgroundColor3 = C.Red, BorderSizePixel = 0}, L)
	mk("UIGradient", {Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.5, 0),
		NumberSequenceKeypoint.new(1, 1)}}, ln)

	mk("TextLabel", {Position = UDim2.fromOffset(0, 64), Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1,
		Text = "Insertá tu key para acceder", Font = FONT, TextSize = 14, TextColor3 = C.Pink}, L)
	local box, tb = fancyBox(L, "INSERTAR KEY", UDim2.fromOffset(380, 54), UDim2.new(.5, 0, 0, 96), Vector2.new(.5, 0))
	tb.TextSize = 18

	local _, vb = fancyBtn(L, "Validar Key", UDim2.fromOffset(185, 46), UDim2.fromOffset(30, 172))
	local _, gb = fancyBtn(L, "Get Key", UDim2.fromOffset(185, 46), UDim2.fromOffset(225, 172))
	local st = mk("TextLabel", {Position = UDim2.fromOffset(0, 230), Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1,
		Text = "", Font = FONTB, TextSize = 13, TextColor3 = C.White, TextWrapped = true}, L)
	mk("TextLabel", {Position = UDim2.fromOffset(0, 266), Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
		Text = "1 key = 1 persona  •  No compartas tu key", Font = FONT, TextSize = 11,
		TextColor3 = T(190, 110, 110)}, L)

	local function status(t, col) st.Text = t; st.TextColor3 = col; st.TextTransparency = 1; tw(st, .25, {TextTransparency = 0}) end
	local function shake()
		local p = box.Position
		for _, dx in ipairs({10, -10, 7, -7, 3, 0}) do
			tw(box, .045, {Position = UDim2.new(p.X.Scale, p.X.Offset + dx, p.Y.Scale, p.Y.Offset)}); task.wait(.045)
		end
	end

	bind(tb:GetPropertyChangedSignal("Text"), function()
		local u = tb.Text:upper(); if u ~= tb.Text then tb.Text = u end
	end)

	local busy = false
	local function attempt(raw)
		if busy then return end
		busy = true
		local alive = true
		task.spawn(function()
			local n = 0
			while alive do n = n % 3 + 1; vb.Text = "Validando" .. string.rep(".", n); task.wait(.3) end
		end)
		local ok, res, nk = validateKey(raw)
		alive = false
		vb.Text = "Validar Key"
		if ok then
			saveKey(nk)
			status("✓ Key válida, bienvenido!", C.Green)
			task.wait(.8)
			popOut(L); tw(Dim, .4, {BackgroundTransparency = 1})
			task.wait(.4); Dim:Destroy(); L:Destroy()
			StartMain(false, nk, res)
		else
			status("✗ " .. tostring(res), Color3.fromRGB(255, 70, 70)); shake()
			busy = false
		end
	end

	bind(vb.MouseButton1Click, function() attempt(tb.Text) end)
	bind(tb.FocusLost, function(enter) if enter then attempt(tb.Text) end end)
	bind(gb.MouseButton1Click, function()
		if copy(DISCORD) then status("Link copiado: " .. DISCORD, C.Green)
		else status("Contactá a: " .. DISCORD, Color3.fromRGB(255, 220, 90)) end
	end)
	bind(xb.MouseButton1Click, function()
		popOut(L); tw(Dim, .35, {BackgroundTransparency = 1}); task.delay(.4, Unload)
	end)
	draggable(top, L)

	popIn(L)
	if saved and saved ~= "" then
		tb.Text = saved
		status("Verificando key guardada...", C.Pink)
		task.delay(1, function() attempt(saved) end)
	end
end

--// ================= INICIO =================
task.spawn(function()
	if isAdmin then StartMain(true) return end
	local okb, bl = db("GET", "blacklist/" .. LP.UserId)
	if okb and bl ~= nil then LP:Kick("Estás en la blacklist de VLP PANEL. No podés usar este script.") return end
	BuildLogin(readSaved())
end)
