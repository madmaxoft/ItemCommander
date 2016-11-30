-- CommandHandlers.lua

-- Implements the handlers for the in-game commands





function HandleCmdClear(a_Split, a_Player, a_EntireCmd)
	--[[ Possible invokations:
	/itemcommand (c|clear|r|remove) (l|left|r|right)
	/itemcommand (c|clear|r|remove)
	When used without left / right, it clears both commands
	--]]

	-- Get the ItemState for the current item:
	local inv = a_Player:GetInventory()
	local itemState = GetItemState(cItem(inv:GetEquippedItem()))
	if not(itemState) then
		a_Player:SendMessage("No commands bound to this item")
		return true
	end

	-- Remove the command(s):
	local which = a_Split[3]
	if not(which) then
		itemState:RemoveBothCommands()
	elseif ((which == "l") or (which == "left")) then
		itemState:RemoveLclkCommand()
	elseif ((which == "r") or (which == "right")) then
		itemState:RemoveRclkCommand()
	else
		a_Player:SendMessageFailure("Invalid removal specification: " .. which)
		return true
	end

	-- Use the modified item:
	local slotNum = inv:GetEquippedSlotNum()
	inv:SetHotbarSlot(slotNum, itemState:GetItem())
	return true, "Command has been cleared"
end





function HandleCmdSet(a_Split, a_Player, a_EntireCmd)
	--[[ Possible invokations:
	/itemcommand s{et} l{eft} somecmd someparam
	/itemcommand s{et} r{ight} somecmd someparam
	--]]
	local cmdToSet = a_EntireCmd:match("/itemcommand %S* %S* (.*)")
	if not(cmdToSet) then
		a_Player:SendMessage("Internal plugin error [cmdToSet]")
		LOG("ItemCommander: Failed to extract the command to set, please report this as an issue to plugin author")
		LOG("The command being processed: \"" .. a_EntireCmd .. "\".")
		return true
	end

	-- Apply the state modifications to the item:
	local inv = a_Player:GetInventory()
	local itemState = GetItemState(cItem(inv:GetEquippedItem()))
	if not(itemState) then
		a_Player:SendMessage("Internal plugin error [itemState]")
		LOG("ItemCommander: Failed to create an itemState for the currently held item.")
		return true
	end
	if ((a_Split[3] == "left") or (a_Split[3] == "l")) then
		itemState:SetLclkCommand(cmdToSet)
	else
		itemState:SetRclkCommand(cmdToSet)
	end

	-- Use the modified item:
	local slotNum = inv:GetEquippedSlotNum()
	inv:SetHotbarSlot(slotNum, itemState:GetItem())
	return true, "Command has been bound"
end




