local Despair = RegisterMod("despairSfx",1)
local game = Game()
local SaveState = {}
local sound = SFXManager()
---------------------------------------------------------------
---------------------------------------------------------------


--You can edit these settings directly from this file if you want
--If you want these settings to save across updates, I highly recommend you have Mod Config Menu installed

local DespairSettings = {
	["BlindBypass"] = false, --Bypass curse of the blind
	["QualityThreshold"] = 1, --Maximum quality required for OH HELL NAW to play
	["IgnoreQuality"] = false, --Ignore items qualities altogether
}


--Below is a list of item names that the player will cry to.
--You can edit this list however you like, just remember to keep the format the same and the item names accurate
--(Set 1 for HELL NAW, set 2 for not bad (exempting the item from HELL NAW))

local CustomHellNawList = {
	--["insert item name"] = 1 or 2, 
	["The Scooper"] = 1,
	["Sissy Longlegs"] = 1,
	["Large Zit"] = 1,
	["D8"] = 1,
	["Urn Of Souls"] = 1,
	["Anti-Gravity"] = 1,
	["Guillotine"] = 1,
	["Iron Bar"] = 1,
	["The Peeper"] = 1,
	["Epiphora"] = 1,
	["Lil Gurdy"] = 1,
	["Lost Fly"] = 1,
	["Acid Baby"] = 1,
	["Jupiter"] = 1,
	["Mars"] = 1,
	["Montezuma's Revenge"] = 1,
	["Demon Baby"] = 1,
	["Lil Portal"] = 1,
	["Sanguine Bond"] = 1,
	["Kidney Stone"] = 1,
}

local saveThisList = false --IMPORTANT: Set this to "true", and this list will replace the saved one in-game.

--btw if you see this reset at any point, it just means the mod updated. It should still be saved in-game though.


---------------------------------------------------------------
---------------------------Defaults----------------------------

local defaultsChanged = false

if DespairSettings["BlindBypass"] == true or 
DespairSettings["QualityThreshold"] ~= 1 or 
DespairSettings["IgnoreQuality"] == true or 
saveThisList == true then
	defaultsChanged = true
end	

---------------------------------------------------------------
-------------------------Mod Config----------------------------

if ModConfigMenu then

	--[[local categoryToChange = ModConfigMenu.GetCategoryIDByName(DespairName)
	if categoryToChange then
	ModConfigMenu.MenuData[categoryToChange] = {}
	ModConfigMenu.MenuData[categoryToChange].Name = tostring(DespairName)
	ModConfigMenu.MenuData[categoryToChange].Subcategories = {}
	end]]
	
	--Get max collectible id
	function Despair:GetMaxCollectibleID()
		local id = CollectibleType.NUM_COLLECTIBLES-1
		local step = 16
		while step > 0 do
			if Isaac.GetItemConfig():GetCollectible(id+step) ~= nil then
				id = id + step
			else
				step = step // 2
			end
		end

		return id
	end

	local DespairName = "OH HELL NAW"

	ModConfigMenu.UpdateCategory(DespairName, {
		Info = {"OH HELL NAW for Mid Items settings.",}
	})
	
	--Title
	
	ModConfigMenu.AddText(DespairName, "Settings", function() return "OH HELL NAW for Mid Items" end)
	ModConfigMenu.AddSpace(DespairName, "Settings")

	-- Settings
	ModConfigMenu.AddSetting(DespairName, "Settings", 
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return DespairSettings["BlindBypass"]
			end,
			Display = function()
				local onOff = "False"
				if DespairSettings["BlindBypass"] then
					onOff = "True"
				end
				return 'Bypass "Curse of the Blind": ' .. onOff
			end,
			OnChange = function(currentBool)
				DespairSettings["BlindBypass"] = currentBool
			end,
			Info = {"OH HELL NAW will play during Curse of the Blind"}
		})
	
	ModConfigMenu.AddSetting(DespairName, "Settings", 
		{
			Type = ModConfigMenu.OptionType.NUMBER,
			CurrentSetting = function()
				return DespairSettings["QualityThreshold"]
			end,
			Minimum = 0,
			Maximum = 4,
			Display = function()
				return "Quality Check: " .. DespairSettings["QualityThreshold"]
			end,
			OnChange = function(currentNum)
				DespairSettings["QualityThreshold"] = currentNum
			end,
			Info = {"The maximum item quality needed for OH HELL NAW to play"}
		})
		
	ModConfigMenu.AddSpace(DespairName, "Settings")
	
	ModConfigMenu.AddSetting(DespairName, "Settings", 
		{
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return DespairSettings["IgnoreQuality"]
			end,
			Display = function()
				local onOff = "False"
				if DespairSettings["IgnoreQuality"] then
					onOff = "True"
				end
				return 'Ignore Quality: ' .. onOff
			end,
			OnChange = function(currentBool)
				DespairSettings["IgnoreQuality"] = currentBool
			end,
			Info = {"OH HELL NAW will ignore the quality system altogether."}
		})
		
		
	--Customization options
	
	local savePos = 0
	local hunPos = 1 
	
	for id = 1, Despair:GetMaxCollectibleID() do
	
		local item = Isaac.GetItemConfig():GetCollectible(id)
		--print(id)
		
		savePos = savePos + 1 
		if savePos == 101 then
			hunPos = hunPos + 1
			savePos = 1
		end
		
		local ctgName = tostring(hunPos * 100 - 99) .. '-' .. tostring(hunPos * 100)
		
		if id == 1 then
		ModConfigMenu.AddText(DespairName, ctgName, function() return "Customize settings for any item" end)
		ModConfigMenu.AddSpace(DespairName, ctgName)
		end
		
		if item ~= nil then

			--print(item.Name)
			if CustomHellNawList[item.Name] == nil then
				table.insert(CustomHellNawList,item.Name)
				CustomHellNawList[item.Name] = 0
			end
			
			ModConfigMenu.AddSetting(DespairName, ctgName, 
			{
				Type = ModConfigMenu.OptionType.NUMBER,
				CurrentSetting = function()
					return CustomHellNawList[item.Name]
				end,
				Minimum = 0,
				Maximum = 2,
				Display = function()
					local nChoice = "default"
					if CustomHellNawList[item.Name] == 1 then
						nChoice = "OH HELL NAW"
					elseif CustomHellNawList[item.Name] == 2 then
						nChoice = "POG"
					end
					return id .. '     ' .. item.Name .. ': ' .. nChoice
				end,
				OnChange = function(currentNum)
					CustomHellNawList[item.Name] = currentNum
				end,
				Info = {item.Name .. " (quality " .. item.Quality .. ")"}
			})
		end
	end
end

---------------------------------------------------------------
---------------------------Savedata----------------------------

local json = require("json")

function Despair:SaveGame()
	--print("save")
	SaveState.Settings = {}
	SaveState.Items = {}
	
	for i, v in pairs(DespairSettings) do
		SaveState.Settings[tostring(i)] = DespairSettings[i]
	end
	for i, v in pairs(CustomHellNawList) do
		SaveState.Items[tostring(i)] = CustomHellNawList[i]
	end
    Despair:SaveData(json.encode(SaveState))
end
Despair:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, Despair.SaveGame)

function Despair:OnGameStart(isSave)
	
	--If the defaults were changed directly from this file, overwrite the existing save data
	if defaultsChanged then
		Despair:SaveGame()
	end	
	
    if Despair:HasData() then
	
		SaveState = json.decode(Despair:LoadData())	
		
        for i, v in pairs(SaveState.Settings) do
			DespairSettings[tostring(i)] = SaveState.Settings[i]
		end
		for i, v in pairs(SaveState.Items) do
			CustomHellNawList[tostring(i)] = SaveState.Items[i]
		end
    end
end
Despair:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Despair.OnGameStart)

---------------------------------------------------------------
------------------------------Main-----------------------------

Despair.SOUND_DESPAIR_SFX = Isaac.GetSoundIdByName("DespairSFX")

--Play SFX
function Despair:PlaySFX()
    sound:Play(Despair.SOUND_DESPAIR_SFX, 1 , 0, false, 1, 0)
end
---------------------------------------------------------------


--Pog costume processing
function Despair:OnHellNawMoment(itemCount)
	if Despair:BlindCheck() then
	
		local altRoomItems = 0

		--alt path treasure room
		local isRepStage = game:GetLevel():GetStageType() >= StageType.STAGETYPE_REPENTANCE	
		if game:GetRoom():GetType() == RoomType.ROOM_TREASURE and isRepStage then
			altRoomItems = itemCount
		end
			
		--print ("isRepStage=",isRepStage,"  roomItems=",roomItems)
		local itemArr = {}
		--Scan entities in room
		for i, entity in ipairs(Isaac.FindInRadius(Vector(640, 580), 875, EntityPartition.PICKUP)) do
			
			--Only pedestal items
			if entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
				
				local id = entity.SubType
				local item = Isaac.GetItemConfig():GetCollectible(id)
				
				if item ~= nil then
					local visible = true
					
					--alt path blind
					if altRoomItems > 0 then
						visible = Despair:AltBlindCheck(entity,item,altRoomItems)
					end
					
					--print(item.Name)
					--print(visible)
					
					if visible and item.Quality ~= nil and CustomHellNawList[item.Name] ~= 2 then
						--Check HELL NAW list or ignore quality option
						if CustomHellNawList[item.Name] == 1 or DespairSettings["IgnoreQuality"] == true then
                            Despair:PlaySFX()
							break
						else	
							table.insert(itemArr, item.Quality)
						end
					end				
				end
			end
		end
		--if there is at least one item with a quality above the threshold, don't play the sfx
		table.sort(itemArr)
		if itemArr[#itemArr] <= DespairSettings["QualityThreshold"]  then
			Despair:PlaySFX()
		end
	end
end

---------------------------------------------------------------

--Scan items
function Despair:ScanItems()
	local number = 0
	for i, entity in ipairs(Isaac.FindInRadius(Vector(640, 580), 875, EntityPartition.PICKUP)) do
		if entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and entity.SubType > 0 then
			number = number + 1
		end
	end
	return number
end

--Check for curse of the blind
function Despair:BlindCheck()
	if DespairSettings["BlindBypass"] then
		return true
	end
	
	if game:GetLevel():GetCurses() & 64 ~= 0 then
		return false
	end
	return true
end

--Check for alt path blind items
function Despair:AltBlindCheck(entity,item,roomItems)
	if DespairSettings["BlindBypass"] then
		return true
	end
	
	local result = false
	--print(item.Name)
	--print(entity.Position)
	local centerX = 320
	local centerY = 280
	
	--two items
	if roomItems == 2 then
		if (entity.Position).X <= centerX and (entity.Position).Y <= centerY then
			--print("not blind")
			result = true
		end
	--three items
	elseif roomItems > 2 then
		if (entity.Position).X <= centerX and not ((entity.Position).Y == centerY and (entity.Position).X == centerX) then
			--print("not blind")
			result = true
		end
	end
	return result
end

---------------------------------------------------------------

local lastItemCount = 0
--Room/Item/Card update
function Despair:OnRoomUpdate()
	lastItemCount = 0
	print("OH MA GAD CHECK BEGIN")
end

--Game update
function Despair:OnGameUpdate()

	local currentItemCount = Despair:ScanItems()

	if currentItemCount > lastItemCount then
		lastItemCount = currentItemCount
		print("OH MA GAD CHECK MID ROOM")
		Despair:OnHellNawMoment(currentItemCount)
	elseif currentItemCount < lastItemCount then
		Despair:OnRoomUpdate()	
	end
	
end

Despair:AddCallback(ModCallbacks.MC_POST_UPDATE,Despair.OnGameUpdate)
Despair:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,Despair.OnRoomUpdate)
Despair:AddCallback(ModCallbacks.MC_USE_ITEM,Despair.OnRoomUpdate)
Despair:AddCallback(ModCallbacks.MC_USE_CARD,Despair.OnRoomUpdate)