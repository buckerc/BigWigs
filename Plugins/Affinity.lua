
assert( BigWigs, "BigWigs not found!")

-----------------------------------------------------------------------
--      Are you local?
-----------------------------------------------------------------------

local L = AceLibrary("AceLocale-2.2"):new("BigWigsAffinity")

local anchor = nil
local AffinityBuffs = {}

local hexColors = {}

for k, v in pairs(RAID_CLASS_COLORS) do
	hexColors[k] = string.format("|cff%02x%02x%02x ", v.r * 255, v.g * 255, v.b * 255)
end

-- Helper table to cache colored player names.
local coloredNames = setmetatable({}, {__index =
	function(self, unit)
		if type(unit) == "nil" then return nil end
		local _, class = UnitClass(unit)
		local name, _ = UnitName(unit)
		if class then
			self[name] = hexColors[class] .. name .. "|r"
			return self[name]
		else
			return name
		end
	end
})

-----------------------------------------------------------------------
--      Localization
-----------------------------------------------------------------------

L:RegisterTranslations("enUS", function() return {
	["Affinity"] = true,
	["Options for the Affinity frame."] = true,
	["Lock frame"] = true,
	["Lock the affinity frame."] = true,

	["Disabled"] = true,
	["Disable the affinity display."] = true,

	font = "Fonts\\FRIZQT__.TTF",

	["Color Names"] = true,
	["Class colored names."] = true,
	["Color Bars"] = true,
	["Class colored bars."] = true,

	["Test"] = true,
	["Perform a Affinity test."] = true,

	["Reset position"] = true,
	["Reset the anchor position, moving it to the center of your screen."] = true,

	["Offline"] = true,
	["Dead"] = true,
} end)

-----------------------------------------------------------------------
--      Module Declaration
-----------------------------------------------------------------------

BigWigsAffinity = BigWigs:NewModule("Affinity")
BigWigsAffinity.revision = 20001
BigWigsAffinity.defaultDB = {
	posx = nil,
	posy = nil,
	lock = false,
	disabled = false,
	names = false,
	bars = true,
}
BigWigsAffinity.external = true

BigWigsAffinity.consoleCmd = L["Affinity"]
BigWigsAffinity.consoleOptions = {
	type = "group",
	name = L["Affinity"],
	desc = L["Options for the Affinity frame."],
	args = {
		lock = {
			type = "toggle",
			name = L["Lock frame"],
			desc = L["Lock the affinity frame."],
			order = 99,
			get = function()
				return BigWigsAffinity.db.profile.lock
			end,
			set = function(v)
				BigWigsAffinity.db.profile.lock = v
				if v then
					BigWigsAffinity:Lock()
				else
					BigWigsAffinity:Unlock()
				end
			end,
		},
		reset = {
			type = "execute",
			name = L["Reset position"],
			desc = L["Reset the anchor position, moving it to the center of your screen."],
			order = 100,
			func = function() BigWigsAffinity:ResetAnchor() end,
		},
		disabled = {
			type = "toggle",
			name = L["Disabled"],
			desc = L["Disable the affinity display."],
			order = 101,
			get = function() return BigWigsAffinity.db.profile.disabled end,
			set = function(v)
				BigWigsAffinity.db.profile.disabled = v
				if BigWigsAffinity.db.profile.disabled then
					BigWigsAffinity:AClose()
				end
			end,
		},
		spacer = {
			type = "header",
			name = " ",
			order = 103,
		},
		names = {
			type = "toggle",
			name = L["Color Names"],
			desc = L["Class colored names."],
			order = 104,
			get = function() return BigWigsAffinity.db.profile.names end,
			set = function(v) BigWigsAffinity.db.profile.names = v end,
		},
		bars = {
			type = "toggle",
			name = L["Color Bars"],
			desc = L["Class colored bars."],
			order = 105,
			get = function() return BigWigsAffinity.db.profile.bars end,
			set = function(v) BigWigsAffinity.db.profile.bars = v end,
		},
		spacer = {
			type = "header",
			name = " ",
			order = 113,
		},
		[L["Test"]] = {
			type = "execute",
			name = L["Test"],
			desc = L["Perform a Affinity test."],
			order = 114,
			handler = BigWigsAffinity,
			func = "TestAFrame",
		},
	}
}

BigWigsAffinity.affinityType = ""
affinityUpdateInterval = 0.2; -- How often the OnUpdate code will run (in seconds)
timeLastUpdate = GetTime()

-----------------------------------------------------------------------
--      Initialization
-----------------------------------------------------------------------

function BigWigsAffinity:OnRegister()
end

function BigWigsAffinity:OnEnable()
	self:RegisterEvent("Ace2_AddonDisabled")
end

function BigWigsAffinity:OnDisable()
	self:AClose()
end

-----------------------------------------------------------------------
--      Event Handlers
-----------------------------------------------------------------------
function BigWigsAffinity:Lock()
	if anchor then
		anchor:EnableMouse(false)
		anchor:SetMovable(false)
	end
end

function BigWigsAffinity:Unlock()
	if anchor then
		anchor:EnableMouse(true)
		anchor:SetMovable(true)
	end
end

function BigWigsAffinity:Ace2_AddonDisabled()
	self:AClose()
end

-----------------------------------------------------------------------
--      Util
-----------------------------------------------------------------------

function BigWigsAffinity:AClose()
	if anchor then anchor:Hide() end
	self:StopAffinityUpdate()
end

function BigWigsAffinity:AShow()
	self:SetupFrames()
	if anchor then anchor:Show() end
end

function BigWigsAffinity:SavePosition()
	if not anchor then self:SetupFrames() end

	local s = anchor:GetEffectiveScale()
	self.db.profile.posx = anchor:GetLeft() * s
	self.db.profile.posy = anchor:GetTop() * s
end

function BigWigsAffinity:TestAFrame()
	if not anchor then self:SetupFrames() end
	anchor:Show()
	for i=1,10 do
		anchor.bar[i].unit="player"
		anchor.bar[i].status:SetScript("OnUpdate", self.OnUpdate)
		anchor.bar[i]:Show()
	end
	self:ScheduleEvent("bwStopAffinityUpdate", self.StopAffinityUpdate, 6, self)
end

function BigWigsAffinity:FindPlayerUnitByName(name)
	if UnitExists("player") and (UnitName("player")==name) then
		return "player";
	end
	if GetNumRaidMembers()==0 then
		return nil
	end
	for i=1,GetNumRaidMembers() do
		if UnitExists("raid"..i) and (UnitName("raid"..i)==name) then
			return "raid"..i;
		end
	end
	return nil;
end

function BigWigsAffinity:AddAffinityTarget(unit)
	local check
	for k, v in AffinityBuffs do
		if UnitName(v) == UnitName(unit) then
			check = true
			break
		end
	end
	if not check then
		if unit then
			tinsert(AffinityBuffs,unit);
			self:AffinityUpdate()
		end
	end
end

function BigWigsAffinity:RemoveAffinityTarget(name)	
	for i=1, getn(AffinityBuffs) do
		if AffinityBuffs[i] and UnitName(AffinityBuffs[i]) == name then
			tremove(AffinityBuffs,i);
			self:AffinityUpdate()
		end
	end
end

function BigWigsAffinity:AffinityUpdate()
	if not anchor then self:SetupFrames() anchor:Show() end
	local numEntries = getn(AffinityBuffs)
	local barCount = 1
	for i=1,numEntries do
		if AffinityBuffs[i] then
			anchor.bar[barCount].unit=AffinityBuffs[i];
			anchor.bar[barCount].text:SetText(UnitName(AffinityBuffs[i]))
			anchor.bar[barCount].textVal:SetText(UnitClass(AffinityBuffs[i]))
			--anchor.bar[i].status:SetScript("OnUpdate", self.OnUpdate)
			anchor.bar[barCount]:Show()
			barCount = barCount + 1
			if barCount > 10 then break end;
		end
	end
	if barCount < 10 then
		for i=barCount, 10 do
			anchor.bar[i].text:SetText("")
			anchor.bar[i].textVal:SetText("")
			anchor.bar[i]:Hide()
		end
	end
end

function BigWigsAffinity:StartAffinityUpdate(affType)
	affinityType = affType
	for i=1,GetNumRaidMembers() do
		raidClass = UnitClass("raid"..i)
		if raidClass then
			if affinityType == "green" and (raidClass == "Shaman" or raidClass == "Druid" or raidClass == "Hunter") or 
			   affinityType == "black" and (raidClass == "Priest" or raidClass == "Warlock") or 
			   affinityType == "red" and (raidClass == "Mage" or raidClass == "Warlock" or raidClass == "Shaman") or 
			   affinityType == "blue" and (raidClass == "Mage" or raidClass == "Shaman") or 
			   affinityType == "mana" and (raidClass == "Mage" or raidClass == "Druid") or 
			   affinityType == "crystal" and (raidClass == "Warrior" or raidClass == "Rogue" or raidClass == "Paladin" or raidClass == "Hunter") then
			
				self:AddAffinityTarget("raid"..i)
			end
		end
	end

	self:ScheduleEvent("bwStopAffinityUpdate", self.StopAffinityUpdate, 15, self)
end

function BigWigsAffinity:StopAffinityUpdate()
	if anchor then
		for i=1,10 do
			anchor.bar[i].unit=nil;
			--anchor.bar[i].status:SetScript("OnUpdate", nil)
			anchor.bar[i]:Hide()
		end
	end
	AffinityBuffs = {}
	affinityType = ""
end


------------------------------
--    Create the Anchor     --
------------------------------

function BigWigsAffinity:SetupFrames()
	if anchor then return end

	local frame = CreateFrame("Frame", "BigWigsAffinityAnchor", UIParent)
	frame:Hide()

	frame:SetWidth(200)
	frame:SetHeight(32)

	frame:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\AddOns\\BigWigs\\Textures\\otravi-semi-full-border", edgeSize = 32,
		--edgeFile = "", edgeSize = 32,
		insets = {left = 1, right = 1, top = 20, bottom = 1},
	})
	frame:SetBackdropBorderColor(1.0,1.0,1.0)
	frame:SetBackdropColor(24/255, 24/255, 24/255)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 300, 500)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetMovable(true)
	frame:SetFrameStrata("BACKGROUND")
	if self.db.profile.lock then
		frame:EnableMouse(false)
		frame:SetMovable(false)
	end
	frame:SetScript("OnDragStart", function() this:StartMoving() end)
	frame:SetScript("OnDragStop", function()
		this:StopMovingOrSizing()
		self:SavePosition()
	end)

	local cheader = frame:CreateFontString(nil, "OVERLAY")
	cheader:ClearAllPoints()
	cheader:SetWidth(190)
	cheader:SetHeight(15)
	cheader:SetPoint("TOP", frame, "TOP", 0, -14)
	cheader:SetFont(L["font"], 12)
	cheader:SetJustifyH("LEFT")
	cheader:SetText("No Affinity Buff")
	cheader:SetShadowOffset(.8, -.8)
	cheader:SetShadowColor(0, 0, 0, 1)
	frame.cheader = cheader

	--Bar1
	frame.bar = {}
	for i=1, 10 do
		local bar = CreateFrame("Button", "ATargetBar_"..i, UIParent)
		bar:ClearAllPoints()
		if i==1 then
			bar:SetPoint( "TOP", frame.cheader, "BOTTOM", 0, -2)
		else
			bar:SetPoint("TOP", frame.bar[i-1], "BOTTOM", 0, -2)
		end
		bar:SetFrameStrata("LOW")
		bar:SetWidth(198)
		bar:SetHeight(20)
		bar:SetToplevel(true)
		bar.unit = nil
		bar:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp", "Button4Up", "Button5Up")
		bar:SetScript("OnClick", function() if this.unit then TargetUnit(this.unit) end end)
		bar.status = CreateFrame("StatusBar",nil, bar)
		bar.status:ClearAllPoints()
		bar.status:SetPoint("CENTER", bar)
		bar.status:SetStatusBarTexture("Interface\\AddOns\\BigWigs\\textures\\smooth")
		bar.status:SetMinMaxValues(0, 100)
		bar.status:SetValue(100)
		bar.status:SetWidth(196)
		bar.status:SetHeight(20)
		bar.status:SetStatusBarColor(0,1,0)
		bar.status:SetScript("OnUpdate", nil)
		bar.text = bar.status:CreateFontString(nil, "OVERLAY")
		bar.text:ClearAllPoints()
		bar.text:SetPoint("LEFT", bar, "LEFT",4,0)
		bar.text:SetShadowOffset(1, -1)
		bar.text:SetShadowColor(0, 0, 0)
		bar.text:SetTextColor(1, 1, 1, 0.9)
		bar.text:SetJustifyH("LEFT")
		bar.text:SetFont(L["font"], 12)
		bar.text:SetText("None")
		bar.textVal = bar.status:CreateFontString(nil, "OVERLAY")
		bar.textVal:ClearAllPoints()
		bar.textVal:SetPoint("RIGHT", bar, "RIGHT",-4,0)
		bar.textVal:SetShadowOffset(1, -1)
		bar.textVal:SetShadowColor(0, 0, 0)
		bar.textVal:SetTextColor(1, 1, 1, 0.9)
		bar.textVal:SetJustifyH("RIGHT")
		bar.textVal:SetFont(L["font"], 12)
		bar.textVal:SetText(100)
		bar.bg = CreateFrame("Frame",nil, bar)
		bar.bg:ClearAllPoints()
		bar.bg:SetPoint("CENTER", bar, "CENTER")
		bar.bg:SetWidth(198)
		bar.bg:SetHeight(22)
		bar.bg:SetBackdrop({
			bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeSize = 1,
			insets = {left = -1, right = -1, top = -1, bottom = -1},
		})
		bar.bg:SetBackdropColor(87/255, 24/255, 24/255)
		bar.bg:SetFrameLevel(bar.bg:GetFrameLevel() - 1)
		bar.bg:SetBackdropBorderColor(0.9, 0.9, 0.9, 0.6)
		bar.bg:SetBackdropColor(0.3, 0.3, 0.3, 0.6)


		frame.bar[i] = bar
		frame.bar[i]:Hide()
	end

	local close = frame:CreateTexture(nil, "ARTWORK")
	close:SetTexture("Interface\\AddOns\\BigWigs\\Textures\\otravi-close")
	close:SetTexCoord(0, .625, 0, .9333)
	close:SetWidth(20)
	close:SetHeight(14)
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -7, -15)

	local closebutton = CreateFrame("Button", nil)
	closebutton:SetParent( frame )
	closebutton:SetWidth(20)
	closebutton:SetHeight(14)
	closebutton:SetPoint("CENTER", close, "CENTER")
	closebutton:SetScript( "OnClick", function() self:AClose() end )

	anchor = frame

	local x = self.db.profile.posx
	local y = self.db.profile.posy
	if x and y then
		local s = anchor:GetEffectiveScale()
		anchor:ClearAllPoints()
		anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / s, y / s)
	else
		self:ResetAnchor()
	end
end

function BigWigsAffinity:ResetAnchor()
	if not anchor then self:SetupFrames() end
	anchor:ClearAllPoints()
	anchor:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 300, 500)
	self.db.profile.posx = nil
	self.db.profile.posy = nil
end
