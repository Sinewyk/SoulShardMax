local addonname = ...
local f = CreateFrame("Frame", addonname, UIParent)
f:RegisterEvent("ADDON_LOADED")
f:Hide()

SoulShardMax_max = 0
SoulBagType = 4

f:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
	if event == "ADDON_LOADED" and arg1 == addonname then
    print("SoulShardMax is enabled, current max:", SoulShardMax_max)
	end
end)

SLASH_SOULSHARDMAX1 = "/soulshardmax"
SLASH_SOULSHARDMAX2 = "/ssm"
SlashCmdList["SOULSHARDMAX"] = function(msg)
	local tokens = SSM_Tokenize(msg)

	if table.getn(tokens) > 0 then
    argument = tonumber(tokens[1])

    if argument and argument == math.floor(argument) and argument >= 0 then
      SSM_SetMaxShards(argument)
      print("SoulShardMax: Max number of Soul Shards to keep set to ", SoulShardMax_max)
    end
  else
    SSM_DeleteExcessShards()
  end
end

local SoulShardItemID = 6265

function SSM_Tokenize(str)
	local tbl = {};
	for v in string.gmatch(str, "[^ ]+") do
		tinsert(tbl, v);
	end
	return tbl;
end

function SSM_DeleteExcessShards()
	if SoulShardMax_max == 0 then return 0 end

	local insertLeftToRight = GetInsertItemsLeftToRight()

	local bags = {}

	local numShards = 0

	-- Where is the soul bag if there are some ?
	tinsert(bags, {bagIndex=0, isSoulBag=false}) -- backpack
	tinsert(bags, {bagIndex=1, isSoulBag=select(2, GetContainerNumFreeSlots(1)) == SoulBagType})
	tinsert(bags, {bagIndex=2, isSoulBag=select(2, GetContainerNumFreeSlots(2)) == SoulBagType})
	tinsert(bags, {bagIndex=3, isSoulBag=select(2, GetContainerNumFreeSlots(3)) == SoulBagType})
	tinsert(bags, {bagIndex=4, isSoulBag=select(2, GetContainerNumFreeSlots(4)) == SoulBagType})

	-- soul bags first, but always take into account insertLeftToRight
	table.sort(bags, function(a,b)
		-- if they are different, first is the soulbag one
		if a["isSoulBag"] ~= b["isSoulBag"] then
			return a["isSoulBag"]
		end
		-- if they are the same, depends on insertLeftToRight
		if insertLeftToRight then
			return a["bagIndex"] > b["bagIndex"]
		else
			return a["bagIndex"] < b["bagIndex"]
		end
	end)

	for i=1,5,1 do
		local numShardsInThisBag = SSM_DeleteExcessShardsOneBag(bags[i]["bagIndex"], numShards)
		numShards = numShards + numShardsInThisBag
	end
end

function SSM_DeleteExcessShardsOneBag(bagId, previousShards)
	local numShardsInThisBag = 0

	-- count from start of bag to the end, so it will start to delete latest items
	for slot=1,GetContainerNumSlots(bagId),1 do
		if GetContainerItemID(bagId, slot) == SoulShardItemID then
			if numShardsInThisBag + previousShards >= SoulShardMax_max then
				PickupContainerItem(bagId, slot)
				_, cursorItemID = GetCursorInfo()
				if cursorItemID == SoulShardItemID then
					DeleteCursorItem()
				else
					ClearCursor()
				end
			else
				numShardsInThisBag = numShardsInThisBag+1
			end
		end
	end

	return numShardsInThisBag
end

function SSM_SetMaxShards(count)
	SoulShardMax_max = count;
end