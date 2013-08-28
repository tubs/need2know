local n2k_placement = {x=0, y=800}

-- table of tables for each role.
local all_track = {{}, {}, {}, {}, {}, {}, {}, {}}

-- table for current role (points to a table in all_track)
local track = nil

-- number of combo points 
local combo = 0

-- Enable/disable combo point tracking, dunno how to do this automatically, maybe look at name of class?
local do_combo = false

--[[
Configuration:

all_track[ROLE_NUMBER][ABILITY_NAME] = {
	who = "player" | "target"
	kind = "cd" | "buff"
	color = {r, g, b}

	valid = false
	completion = 0
	id = nil
}

To configure a new spell to be tracked, add a line here. ROLE_NUMBER is the 1-based id of the role you want
to track for. This should match the list of roles you see when you press "n" in game.

ABILITY_NAME is the name of the spell, buff, or debuff you want to track.

who: "player" = you, "target" = current target
kind: "cd" = cooldown, "buff" = debuff or buff
color: {r, g, b} = rgb color of the bar, should be values in the range 0.0 - 1.0
--]]


--[[
all_track[1]["Empowered Shot"] = {who="player", kind="cd", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[1]["Shadow Fire"] = {who="player", kind="cd", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[1]["Splinter Shot"] = {who="target", kind="buff", id=nil, valid=false, color={0.8, 0.0, 0.4}, completion=0}
all_track[1]["Ace Shot"] = {who="target", kind="buff", id=nil, valid=false, color={0.7, 0.2, 0.0}, completion=0}

all_track[4]["Motif of Bravery"] = {who="player", kind="buff", id=nil, valid=false, color={0.0, 0.8, 0.0}, completion=0}

all_track[3]["Backstab"] = {who="player", kind="cd", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[3]["Puncture"] = {who="target", kind="buff", id=nil, valid=false, color={0.5, 0.0, 0.0}, completion=0}
all_track[3]["Impale"] = {who="target", kind="buff", id=nil, valid=false, color={0.8, 0.0, 0.0}, completion=0}
all_track[3]["Expose Weakness"] = {who="player", kind="cd", id=nil, valid=false, color={0.5, 0.0, 0.5}, completion=0}
all_track[3]["Thread of Death"] = {who="player", kind="cd", id=nil, valid=false, color={0.5, 0.1, 0.3}, completion=0}

all_track[2]["Shadow Assault"] = {who="player", kind="cd", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[2]["Shadow Blitz"] = {who="player", kind="cd", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[2]["Phantom Blow"] = {who="player", kind="cd", id=nil, valid=false, color={0.4, 0.0, 0.4}, completion=0}
all_track[2]["Rift Disturbance"] = {who="player", kind="cd", id=nil, valid=false, color={0.0, 0.4, 0.4}, completion=0}
all_track[2]["Planar Vortex"] = {who="player", kind="buff", id=nil, valid=false, color={0.2, 0.4, 0.2}, completion=0}

all_track[5]["Coda of Jeopardy"] = {also="<5>", who="target", kind="buff", id=nil, valid=false, color={0.9, 0.4, 0.0}, completion=0}
all_track[5]["Coda of Cowardice"] = {also="<G>", who="target", kind="buff", id=nil, valid=false, color={0.8, 0.0, 0.3}, completion=0}
all_track[5]["Coda of Distress"] = {also="<2>", who="target", kind="buff", id=nil, valid=false, color={0.7, 0.2, 0.2}, completion=0}
all_track[5]["Riff"] = {who="player", kind="cd", id=nil, valid=false, color={0.0, 0.8, 0.8}, completion=0}
all_track[5]["Verse of Agony"] = {who="player", kind="cd", id=nil, valid=false, color={0.0, 0.8, 0.0}, completion=0}
--]]

---[[
all_track[2]["Precept of Refuge"] = {who="player", kind="buff", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[2]["Bolt of Radiance"] = {who="player", kind="cd", id=nil, valid=false, color={0.7, 0.7, 0.0}, completion=0}

all_track[1]["Curse of Discord"] = {who="target", kind="buff", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[1]["Vex"] = {who="target", kind="buff", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[1]["Scourge"] = {who="target", kind="buff", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[1]["Sanction Heretic"] = {who="player", kind="cd", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}

all_track[3]["Blessing of Flame"] = {who="target", kind="buff", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[3]["Healing Breath"] = {who="player", kind="cd", id=nil, valid=false, color={0.8, 0.0, 0.0}, completion=0}

all_track[5]["Eruption of Life"] = {who="player", kind="buff", id=nil, valid=false, color={0.0, 0.4, 0.1}, completion=0}
all_track[5]["Thorns of Ire"] = {who="target", kind="buff", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[5]["Essence Strike"] = {who="player", kind="cd", id=nil, valid=false, color={0.8, 0.0, 0.0}, completion=0}
all_track[5]["Combined Effort"] = {who="player", kind="cd", id=nil, valid=false, color={0.7, 0.7, 0.0}, completion=0}
all_track[5]["Resounding Blow"] = {who="player", kind="cd", id=nil, valid=false, color={0.2, 0.4, 0.2}, completion=0}
--]]


-- the duration/cd to stop increasing the bar at - ie/anything above this time will appear as a full bar
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

--[[
create the ui stuff for a single bar.
--]]
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

--[[
Hide a set of bars, used when changing away from a role.
--]]
local function deinit_track()
	for name,t in pairs(track) do
		if t.bar then t.bar:SetVisible(false) end
	end
end

--[[
When a new role is selected, make sure we have bars created for each spell that is tracked.
Make the bars visible (they may have been created previously so we just need to show them)
--]]
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

--[[
Enable a single bar
--]]
local function enable(t, id, completion)
	t.id = id
	t.valid = true
	t.completion = completion
	t.bar.solid:SetVisible(true)
	t.bar.text:SetVisible(true)
	t.bar.timer:SetVisible(true)
end

--[[
Disable a single bar (bar is still visible, but its time and "fullness" is empty
--]]
local function disable(t)
	t.bar.solid:SetVisible(false)
	t.valid = false
end


--[[
This should be removed as everything could be handled in cd_changed
--]]
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
	print("role changed")
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

Command.Event.Attach(Command.Slash.Register("n2k"), config, "config")

--init the current tracked spells to the player's current role.
track = all_track[Inspect.TEMPORARY.Role()]
init_track()

