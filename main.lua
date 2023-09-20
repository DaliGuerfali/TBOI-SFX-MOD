local Despair = RegisterMod("despairSfx",1)
local game = Game()
--local SaveState = {}
local sound = SFXManager()
---------------------------------------------------------------
---------------------------------------------------------------


--You can edit these settings directly from this file if you want
--If you want these settings to save across updates, I highly recommend you have Mod Config Menu installed

local DespairSettings = {
	["QualityThreshold"] = 1, --Maximum quality required for OH HELL NAW to play
	["DevilDealThreshold"] = 70, --Minimum DD chance required for SFX to play when missing the DD Spawn [0;100] interval
	["SFXonSuperGreedShop"] = true, --Choose as you please 
	["BlindBypass"] = false, --Bypass curse of the blind
	["IgnoreQuality"] = false, --Ignore items qualities altogether
}


--Below is a list of item names that the player will cry to.
--You can edit this list however you like, just remember to keep the format the same and the item names accurate
--(Set 1 for HELL NAW, set 2 for not bad (exempting the item from HELL NAW))

local CustomHellNawList = {
	--["insert item name in lowercase with no special characters"] = 1 or 2, 
	["the scooper"] = 1,
	["sissy longlegs"] = 1,
	["large zit"] = 1,
	["d8"] = 1,
	["urn of souls"] = 1,
	["antigravity"] = 1,
	["guillotine"] = 1,
	["iron bar"] = 1,
	["the peeper"] = 1,
	["epiphora"] = 1,
	["lil gurdy"] = 1,
	["lost fly"] = 1,
	["acid baby"] = 1,
	["jupiter"] = 1,
	["mars"] = 1,
	["montezumas revenge"] = 1,
	["demon baby"] = 1,
	["lil portal"] = 1,
	["sanguine bond"] = 1,
	["kidney stone"] = 1,
	["lil delirium"] = 1,
	["a quarter"] = 2,
	["spider mod"] = 2,
	["knife piece 1"] = 2,
	["knife piece 2"] = 2,
}



--Below is a list of bosses that sisiphenous will face
--You can edit this list however you like, just remember to keep the format the same and the boss names accurate
--Add a "boss name" for sisiphenous sfx to play
local CustomSisiphenousList = {
	"Bumbino"
}


local saveThisList = true --IMPORTANT: Set this to "true", and this list will replace the saved one in-game.

--btw if you see this reset at any point, it just means the mod updated. It should still be saved in-game though.


---------------------------------------------------------------
---------------------------Defaults----------------------------

local defaultsChanged = false

if DespairSettings["DevilDealThreshold"] ~= 70 or 
DespairSettings["QualityThreshold"] ~= 1 or 
DespairSettings["BlindBypass"] == true or 
DespairSettings["IgnoreQuality"] == true or 
DespairSettings["SFXonSuperGreedShop"] == false or 
saveThisList == true then
	defaultsChanged = true
end	

---------------------------------------------------------------
-------------------------Helpers-------------------------------

--Construct Real Item Name in Lowercase From Repentance's #[ITEM_NAME]
function GetRealItemName(name)
	local res = string.sub(name, 2)
	res = string.sub(res, 1, string.len(res) - 5)
	res = string.gsub(res, "_", " ")
	res = string.lower(res)
	return res
end

--Construct Real Boss Name in #BOSS_NAME format
function BossNameToEntityName(name)
	local res = string.upper(name)
	res = string.gsub(res, " ", "_")
	return "#"..res
end

function EntityToStringID(entity)
	return tostring(entity.Type).."."..tostring(entity.Variant)
end

function NameToStringID(name)
	local bossName = BossNameToEntityName(name)
	return tostring(Isaac.GetEntityTypeByName(bossName)).."."..tostring(Isaac.GetEntityVariantByName(bossName))
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
		local id = CollectibleType.NUM_COLLECTIBLES - 1
		local step = 16
		while step > 0 do
			if Isaac.GetItemConfig():GetCollectible(id + step) ~= nil then
				id = id + step
			else
				step = step // 2
			end
		end

		return id
	end

	local DespairName = "OH HELL NAW"

	ModConfigMenu.UpdateCategory(DespairName, {
		Info = { "OH HELL NAW for Mid Items settings.", }
	})

	--Title

	ModConfigMenu.AddText(DespairName, "Settings", function() return "OH HELL NAW for Mid Items" end)
	ModConfigMenu.AddSpace(DespairName, "Settings")

	-- Settings
	ModConfigMenu.AddSetting(DespairName, "Settings",
		{
			Type = ModConfigMenu.OptionType.NUMBER,
			CurrentSetting = function()
				return DespairSettings["DevilDealThreshold"]
			end,
			Minimum = 0,
			Maximum = 100,
			Display = function()
				return "Devil Deal Chance Check: " .. DespairSettings["DevilDealThreshold"] .. "%"
			end,
			OnChange = function(currentNum)
				DespairSettings["DevilDealThreshold"] = currentNum
			end,
			Info = { "The minimum Devil Deal chance needed for SFX to play when missing the DD" }
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
			Info = { "The maximum item quality needed for SFX to play" }
		})

	ModConfigMenu.AddSetting(DespairName, "Settings", {
		Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return DespairSettings["SFXonSuperGreedShop"]
			end,
			Display = function()
				local onOff = "True"
				if not DespairSettings["SFXonSuperGreedShop"] then
					onOff = "False"
				end
				return 'Super Greed Shop Check: ' .. onOff
			end,
			OnChange = function(currentBool)
				DespairSettings["SFXonSuperGreedShop"] = currentBool
			end,
			Info = { "Play SFX When Super Greed In Shop." }
	})

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
			Info = { "SFX will play during Curse of the Blind" }
		})

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
			Info = { "SFX will ignore the quality system altogether." }
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
			local itemName = GetRealItemName(item.Name)
			if CustomHellNawList[itemName] == nil then
				table.insert(CustomHellNawList, itemName)
				CustomHellNawList[itemName] = 0
			end

			ModConfigMenu.AddSetting(DespairName, ctgName,
				{
					Type = ModConfigMenu.OptionType.NUMBER,
					CurrentSetting = function()
						return CustomHellNawList[itemName]
					end,
					Minimum = 0,
					Maximum = 2,
					Display = function()
						local nChoice = "Default"
						if CustomHellNawList[itemName] == 1 then
							nChoice = "OH HELL NAW"
						elseif CustomHellNawList[itemName] == 2 then
							nChoice = "Good Item"
						end
						return id .. '     ' .. itemName .. ': ' .. nChoice
					end,
					OnChange = function(currentNum)
						CustomHellNawList[itemName] = currentNum
					end,
					Info = { itemName .. " (Quality " .. item.Quality .. ")" }
				})
		end
	end
end
---------------------------------------------------------------

---------------------------------------------------------------
------------------------------Main-----------------------------

Despair.SOUND_DESPAIR_SFX = Isaac.GetSoundIdByName("DespairSFX")
Despair.SOUND_SISIPHENOUS_SFX = Isaac.GetSoundIdByName("SisiphenousSFX")

---------------------------------------------------------------



--Play Hell Naw SFX
function Despair:PlayHELLNAW()
    sound:Play(Despair.SOUND_DESPAIR_SFX, 1 , 0, false, 1, 0)
end

--PLay Sisiphenous SFX
function Despair:PlaySisiphenous()
	sound:Play(Despair.SOUND_SISIPHENOUS_SFX,0.5,0,false,1.0)
end


--SFX processing
function Despair:OnHellNawMoment(itemCount)
	if Despair:BlindCheck() then
	
		local altRoomItems = 0

		--alt path treasure room
		local isRepStage = game:GetLevel():GetStageType() >= StageType.STAGETYPE_REPENTANCE	
		if game:GetRoom():GetType() == RoomType.ROOM_TREASURE and isRepStage then
			altRoomItems = itemCount
		end
			
		--print ("isRepStage=",isRepStage,"  roomItems=",roomItems)
		local bestItem = 0
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
					local itemName = GetRealItemName(item.Name)
					print(itemName)
					--check visibility
					if visible and item.Quality ~= nil then
						--Check HELL NAW list or ignore quality option
						if CustomHellNawList[itemName] == 1 or DespairSettings["IgnoreQuality"] == true then
							Despair:PlayHELLNAW()
							return
						elseif CustomHellNawList[itemName] == 2 then 
							bestItem = DespairSettings["QualityThreshold"] + 1
						elseif item.Quality > bestItem	then
							bestItem = item.Quality
						end
					end				
				end
			end
		end
		--if there is at least one item with a quality above the threshold, don't play the sfx
		if bestItem <= DespairSettings["QualityThreshold"] then
			Despair:PlayHELLNAW()
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


--Room/Reroll update
function Despair:OnRoomUpdate()
	lastItemCount = 0
	--print("OH MA GAD CHECK BEGIN")
end

function Despair:OnItemCountUpdate(currentItemCount)
	lastItemCount = currentItemCount
end

--Game update
function Despair:OnGameUpdate()
	local currentItemCount = Despair:ScanItems()
	
	if currentItemCount > lastItemCount then
		--print("OH MA GAD CHECK MID ROOM")
		Despair:OnItemCountUpdate(currentItemCount)	
		Despair:OnHellNawMoment(currentItemCount)
	elseif currentItemCount < lastItemCount then
		Despair:OnItemCountUpdate(currentItemCount)	
	end
end

--When entering Shop
function Despair:EnterShop()
	if Game():GetRoom():GetType() ~= RoomType.ROOM_SHOP and DespairSettings["SFXonSuperGreedShop"] ~= false then
		return
	end
	for i, entity in ipairs(Isaac.GetRoomEntities()) do
		--Play sisiphenous when Super Greed
		if entity.Type == EntityType.ENTITY_GREED and entity.Variant == 1 then
			Despair:PlaySisiphenous()
		end
	end
end

--When entering Boss Room
function Despair:EnterBoss()
	if Game():GetRoom():GetType() ~= RoomType.ROOM_BOSS then 
		return
	end
	--Check for devil deal scam only when in boss room
	if Game():GetLevel():CanSpawnDevilRoom() == true and Game():GetRoom():IsClear() == false and Game():GetRoom():GetDevilRoomChance() >= (DespairSettings["DevilDealThreshold"]%100)/100 then
		Despair:AddCallback(ModCallbacks.MC_POST_UPDATE, Despair.CheckDevilDealScam)
	end
	--Check for Custom Bosses to play SFX
	for i, entity in ipairs(Isaac.GetRoomEntities()) do
		if entity.IsBoss(entity) then
			local entityID = EntityToStringID(entity)
			for j, boss in ipairs(CustomSisiphenousList) do
				if NameToStringID(boss) == entityID then
					Despair:PlaySisiphenous()
				end
			end
		end
	end
end


local DD_SCAM_CHANCE = 0
-- :'(
function Despair:CheckDevilDealScam()
	if Game():GetRoom():GetType() ~= RoomType.ROOM_BOSS or Game():GetRoom():IsClear() == true then
		if Game():GetRoom():GetType() == RoomType.ROOM_BOSS and Game():GetLevel():IsDevilRoomDisabled() == true  then
			Despair:PlaySisiphenous()
		end
		Despair:RemoveCallback(ModCallbacks.MC_POST_UPDATE, Despair.CheckDevilDealScam)
	else
		DD_SCAM_CHANCE = Game():GetRoom():GetDevilRoomChance()
	end
end

--When entering Devil Deal
function Despair:EnterDevilDeal()
	if Game():GetRoom():GetType() ~= RoomType.ROOM_DEVIL then 
		return
	end
	local currentItemCount = Despair:ScanItems()
	if currentItemCount == 0 then
		Despair:PlayHELLNAW()
	end
end


Despair:AddCallback(ModCallbacks.MC_POST_UPDATE,Despair.OnGameUpdate)
Despair:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Despair.EnterShop)
Despair:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Despair.EnterBoss)
Despair:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Despair.EnterDevilDeal)
Despair:AddCallback(ModCallbacks.MC_POST_NEW_ROOM,Despair.OnRoomUpdate)
Despair:AddCallback(ModCallbacks.MC_USE_ITEM,Despair.OnRoomUpdate, CollectibleType.COLLECTIBLE_D6)
Despair:AddCallback(ModCallbacks.MC_USE_ITEM,Despair.OnRoomUpdate, CollectibleType.COLLECTIBLE_SPINDOWN_DICE)
