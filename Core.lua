--local n2k_placement = {x=0, y=800}
--
--
--
local n2k_placement = {x=0, y=800}
local all_track = {{}, {}, {}, {}, {}, {}, {}, {}}

-- table for current role (points to a table in all_track)
local track = nil

-- number of combo points 
local combo = 0

-- Enable/disable combo point tracking, dunno how to do this automatically, maybe look at name of class?
local do_combo = false
local max_time = 8

-- ui context
local context = UI.CreateContext("HUD")

-- icons for combo points
local combo_icons = {}

local combos = nil

-- id of the player's unit
local player_id = Inspect.Unit.Lookup("player")

-- id of the current target
local target_id = nil

local function make_name(detail, t)
	local s = detail.name
	if t.also then
		s = s .. " " .. t.also
	end
	if detail.stack then
		s = s .. string.format("[%d]", detail.stack)
	end
	return s
end

local function create()
	bar = UI.CreateFrame("Frame", "Bar", context)

	bar:SetPoint("TOP", UIParent, "TOP")

	bar.text = UI.CreateFrame("Text", "Text", bar)
	bar.timer = UI.CreateFrame("Text", "Timer", bar)

	bar.solid = UI.CreateFrame("Frame", "Solid", bar)
	bar.solid:SetLayer(-1)

	bar.timer:SetText("-")
	bar.timer:SetPoint("TOPRIGHT", bar, "TOPRIGHT")

	bar.text:SetHeight(bar.text:GetHeight())
	bar.text:SetPoint("TOPLEFT", bar, "TOPLEFT")
	bar.text:SetPoint("RIGHT", bar.timer, "LEFT")

	bar.solid:SetPoint("TOPLEFT", bar, "TOPLEFT")
	bar.solid:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")

	bar:SetWidth(400)
	bar:SetHeight(16)

	bar:SetBackgroundColor(0.0, 0.0, 0.0, 0.9)
	bar.text:SetFontSize(12)
	bar.timer:SetFontSize(12)
	bar.text:SetHeight(bar.text:GetHeight())
	bar.text:SetVisible(true)
	bar.text:SetEffectGlow({colorR = 0, colorB = 0, colorG = 0, blurX = 0, blurY = 0})
	bar.solid:SetVisible(false)

	bar:SetVisible(true)

	return bar
end

local function deinit_track()
	for name,t in pairs(track) do
		if t.bar then t.bar:SetVisible(false) end
	end
end

local function init_track()
	local last = nil
	if not track then track = {} end
	for name,t in pairs(track) do
		if not t.bar then
			local bar = create()
			t.bar = bar
			if not last then
				bar:SetPoint("TOPCENTER", UIParent, "TOPCENTER", n2k_placement.x, n2k_placement.y)
			else
				bar:SetPoint("TOPCENTER", last, "BOTTOMCENTER", 0, 1)
			end
			bar.solid:SetBackgroundColor(unpack(t.color))
			bar.text:SetText(name)
			last = bar
		end
		t.bar:SetVisible(true)
	end
end

local function fini(handle, addon)
	if addon == "need2know" then
		for _,t in pairs(all_track) do
			for _,d in pairs(t) do
				d.bar = nil
				d.completion = 0
			end
		end
		tracked_skills = all_track
	end
end

local function init(handle, addon)
	if addon == "need2know" then
		if tracked_skills ~= nil then
			all_track = tracked_skills
			track = all_track[Inspect.TEMPORARY.Role()]
			init_track()
		end
	end
end

Command.Event.Attach(Event.Addon.SavedVariables.Load.End, init, "init")
Command.Event.Attach(Event.Addon.SavedVariables.Save.Begin, fini, "fini")


local function refresh(time)
end

local function enable(t, id, completion)
	t.id = id
	t.valid = true
	t.completion = completion
	t.bar.solid:SetVisible(true)
	t.bar.text:SetVisible(true)
	t.bar.timer:SetVisible(true)
end

local function disable(t)
	t.bar.solid:SetVisible(false)
	t.valid = false
end


local function tick(handle)
	local time = Inspect.Time.Frame()
	local printed = false
	for name,t in pairs(track) do
		if t.valid then
			local r = t.completion - time
			if r <= 0 then
				disable(t)
			else
				local proportion = r / max_time
				if proportion > 1 then proportion = 1 end
				t.bar.solid:SetPoint("RIGHT", t.bar, proportion, nil)
				t.bar.timer:SetText(string.format("%.1f", r))
			end
		end
	end
end

local cols = { 
	{1.0, 0.0, 0.0},
	{1.0, 0.0, 0.0},
	{0.0, 0.0, 1.0},
	{1.0, 1.0, 0.0},
	{0.0, 1.0, 0.0},
}

--[[
Show/hide the correct number of combo icons.
We use a special color for each combo icon indicating how close we are to capping.
--]]
local function set_combo_indicator(val)
	for i=1,5 do
		combo_icons[i]:SetVisible(i <= val)
		combo_icons[i]:SetBackgroundColor(unpack(cols[i]))

	end
end

--[[
Called when an ability goes on cooldown.
If we're tracking this cd make the bar visible and calculate when it will complete.
--]]
local function cd_start(handle, cooldowns)
	local now = Inspect.Time.Frame()
	local details = Inspect.Ability.New.Detail(cooldowns)
	for id,detail in pairs(details) do
		local cd = cooldowns[id]
		local t = track[detail.name]
		if t and t.kind == "cd" and cd > 1.5 then
			enable(t, detail.id, now + cd)
		end
	end
end

--[[
Probably should disable the bar in this function
--]]
local function cd_end(handle, cooldowns)
end

--[[
Called when a buff is added to a unit.
If it's a unit we care about and a buff we care about and we cast it:
Enable the bar, make it visible, calculate when the buf will fall off.
--]]
local function add_buffs(handle, id, buffs)
	if id ~= player_id and id ~= target_id then
		return
	end
	local now = Inspect.Time.Frame()
	local who = id == player_id and "player" or "target"
	local details = Inspect.Buff.Detail(id, buffs)
	for id,detail in pairs(details) do
		local t = track[detail.name]
		if t and t.kind == "buff" and (who == "player" or (detail.caster == player_id)) then
			enable(t, detail.id, now + detail.remaining)
			t.bar.text:SetText(make_name(detail, t))
			t.stacks = detail.stack
		end
	end

end

--[[
Called when a buff is removed from a unit.
If we're tracking it, disable that bar.
--]]
local function remove_buffs(handle, id, buffs)
	if id ~= player_id and id ~= target_id then
		return
	end
	local who = id == player_id and "player" or "target"
	for id,_ in pairs(buffs) do
		for _,t in pairs(track) do
			if t.id == id then
				disable(t)
			end
		end
	end
end

--[[
Called when something about a buff changes. Note: New stacks will call remove_buffs; add_buffs not this function.
If we are tracking this buff, ensure all details we care about displaying are updated.
--]]
local function buffs_changed(handle, id, buffs)
	if id ~= player_id and id ~= target_id then
		return
	end

	local now = Inspect.Time.Frame()
	local who = id == player_id and "player" or "target"
	local details = Inspect.Buff.Detail(id, buffs)
	for id,detail in pairs(details) do
		local t = track[detail.name]
		if t and t.kind == "buff" then
			if detail.stack ~= t.stacks then
				t.bar.text:SetText(make_name(detail, t))
				t.stacks = detail.stack
			end
		end
	end
end

--[[
Update who are target is, update the buffs/debuffs that we are tracking on "target" as well.
--]]
local function TargetChanged(handle, id)
	target_id = id
	for name,t in pairs(track) do
		if t.who == "target" then
			disable(t)
		end
	end

	if id then
		add_buffs({}, id, Inspect.Buff.List(id) or {})
	end
end

--[[
Player id has changed, so update player_id and combo_points
--]]
local function PlayerChanged(handle, id)
	player_id = id
	local details = Inspect.Unit.Detail(player_id)
	if do_combo then
		set_combo_indicator(details.combo)
	end
end

--[[
No idea :-(
--]]
local function UnitUnavailable(handle, tab)
	if tab[player_id] then
		PlayerChanged({}, player_id)
	end
end

--[[
Units are entering or exiting combat, add config to show bars only in combat.
--]]
local function combat_changed(handle, units)
	--[[
	for id,val in pairs(units) do
		if id == player_id then
			for _,t in pairs(track) do
				t.bar:SetVisible(val)
			end
		end
	end
	--]]
end

--[[
Called when the current role changes (including on initialisation), deinit the current role
and init the new role.
--]]
local function role_changed(handle, slot)
	deinit_track()
	track = all_track[slot]
	init_track()
end

--[[
Number of combo points have changed
--]]
local function combo_changed(handle, id)
	for id,val in pairs(id) do
		if id == player_id then
			set_combo_indicator(val)
		end
	end
end

Command.Event.Attach(Event.Ability.New.Cooldown.Begin, cd_start, "add_cd")
Command.Event.Attach(Event.Ability.New.Cooldown.End, cd_end, "add_cd")
Command.Event.Attach(Event.Buff.Add, add_buffs, "add_buffs")
Command.Event.Attach(Event.Buff.Change, buffs_changed, "buffs_changed")
Command.Event.Attach(Event.Buff.Remove, remove_buffs, "remove_buffs")
Command.Event.Attach(Event.Unit.Detail.Combo, combo_changed, "combo_changed")

Command.Event.Attach(Library.LibUnitChange.Register("player.target"), TargetChanged, "targetchange")
Command.Event.Attach(Library.LibUnitChange.Register("player"), PlayerChanged, "unitchange")

Command.Event.Attach(Event.Unit.Availability.Full, UnitUnavailable, "unitavailable")
Command.Event.Attach(Event.Unit.Detail.Combat, combat_changed, "combat_changed")
Command.Event.Attach(Event.TEMPORARY.Role, role_changed, "role_changed")

Command.Event.Attach(Event.System.Update.Begin, tick, "refresh")

local function config(handle, cmd)
	local x, y = cmd:match("(%d+) (%d+)")
	x, y = tonumber(x), tonumber(y)
	if not x or not y then
		print("Example: /n2k 100 100")
		return
	end

	n2k_placement.x = x
	n2k_placement.y = y
	resync = true

end


--Create the combopoint icons.
for i=1,5 do
	combos = UI.CreateFrame("Frame", "combo_icons", context)
	combos:SetPoint("TOPCENTER", UIParent, "TOPCENTER", n2k_placement.x, n2k_placement.y - 30)

	c = UI.CreateFrame("Texture", "combo_icon", combos)
	c:SetWidth(40)
	c:SetHeight(20)
	c:SetTexture("need2know", "cat.png")

	c:SetBackgroundColor(1.0, 1.0, 0.0, 1.0)
	c:SetPoint("TOPCENTER", combos, "TOPCENTER", 42 * (i - 3), 0)
	--c:SetPoint("LEFT", UIParent, "LEFT", 0 * i * 20, 0)
	c:SetVisible(false)

	combo_icons[i] = c
end

local function del_buff(handle, cmd)
	local name = cmd
	if track[name] then
		track[name] = nil
		print("removed")
	end
end

local function add_buff(handle, cmd)
	local name, bar_type, who, rs, gs, bs = cmd:match("([^;]+);(%w+);(%w+);([%d%.]+);([%d%.]+);([%d%.]+)")
	if name == nil or bar_type == nil or who == nil or rs == nil or gs == nil or bs == nil then
		print(name)
		print(bar_type)
		print(who)
		print(rs)
		print(gs)
		print(bs)

		print("USAGE: /n2k_add name bar_type who red green blue")
		return
	end

	local r = tonumber(rs)
	local g = tonumber(gs)
	local b = tonumber(bs)

	if r == nil or g == nil or b == nil then
		print("USAGE: /n2k_add name bar_type who red green blue")
		return
	end

	if bar_type ~= "buff" and bar_type ~= "cd" then
		print("bar_type = buff|cd")
		return
	end

	if who ~= "player" and who ~= "target" then
		print("player = player|target")
		return
	end

	track[name] = {["kind"] = bar_type, ["who"] = who, ["color"] = {r, g, b}}
	init_track()
end

Command.Event.Attach(Command.Slash.Register("n2k"), config, "config")
Command.Event.Attach(Command.Slash.Register("n2k_add"), add_buff, "add_buff")
Command.Event.Attach(Command.Slash.Register("n2k_del"), del_buff, "del_buff")

--init the current tracked spells to the player's current role.
track = all_track[Inspect.TEMPORARY.Role()]

