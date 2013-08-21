local n2k_placement = {x=0, y=800}

local all_track = {{}, {}, {}, {}, {}, {}, {}, {}}
local track = nil
local combo = 0
local do_combo = false

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
--
all_track[2]["Precept of Refuge"] = {who="player", kind="buff", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[2]["Bolt of Radiance"] = {who="player", kind="cd", id=nil, valid=false, color={0.7, 0.7, 0.0}, completion=0}

all_track[1]["Lightning"] = {who="target", kind="buff", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[1]["Massive Blow"] = {who="player", kind="cd", id=nil, valid=false, color={0.8, 0.0, 0.0}, completion=0}
all_track[1]["Bolt of Radiance"] = {who="player", kind="cd", id=nil, valid=false, color={0.7, 0.7, 0.0}, completion=0}
all_track[1]["Frostbite"] = {who="player", kind="buff", id=nil, valid=false, color={0.1, 0.1, 0.3}, completion=0}

all_track[5]["Eruption of Life"] = {who="player", kind="buff", id=nil, valid=false, color={0.0, 0.4, 0.1}, completion=0}
all_track[5]["Thorns of Ire"] = {who="target", kind="buff", id=nil, valid=false, color={0.0, 0.0, 0.4}, completion=0}
all_track[5]["Essence Strike"] = {who="player", kind="cd", id=nil, valid=false, color={0.8, 0.0, 0.0}, completion=0}
all_track[5]["Combined Effort"] = {who="player", kind="cd", id=nil, valid=false, color={0.7, 0.7, 0.0}, completion=0}

track = all_track[Inspect.TEMPORARY.Role()]
print(Inspect.TEMPORARY.Role())
print(track)

local max_time = 8

local context = UI.CreateContext("HUD")
local combo_icons = {}
local combos = nil
local player_id = Inspect.Unit.Lookup("player")
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
			bar:SetVisible(true)
			last = bar
		end
	end
end




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
local function set_combo_indicator(val)
	for i=1,5 do
		combo_icons[i]:SetVisible(i <= val)
		combo_icons[i]:SetBackgroundColor(unpack(cols[i]))

	end
end

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

local function cd_end(handle, cooldowns)
end

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

local function PlayerChanged(handle, id)
	player_id = id
	local details = Inspect.Unit.Detail(player_id)
	if do_combo then
		set_combo_indicator(details.combo)
	end
end

local function UnitUnavailable(handle, tab)
	if tab[player_id] then
		PlayerChanged({}, player_id)
	end
end

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


local function role_changed(handle, slot)
	deinit_track()
	track = all_track[slot]
	init_track()
end


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
	refresh(0)

end


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


init_track()

