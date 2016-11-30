-- ItemCommander.lua

-- Implements the main plugin entrypoint





--- Map of messages that are sent to the player based on the command result
-- Maps cPluginManager.crXXX constants to message strings. No mapping means no message will be sent.
local g_CommandResultMessageText =
{
	[cPluginManager.crBlocked] = "The command has been blocked by another plugin",
	[cPluginManager.crError] = "There was an error while executing that command",
	[cPluginManager.crNoPermission] = "You don't have permission to execute that command",
	[cPluginManager.crUnknownCommand] = "No such command",
}





local function OnLeftClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_Action)
	-- Get the command bound to this item, if any:
	local itemState = GetItemState(a_Player:GetInventory():GetEquippedItem())
	local cmd = itemState:GetLclkCommand()
	if not(cmd) then
		-- No command bound to lclk
		return false
	end

	-- Execute the command:
	local cmdResult = cPluginManager:Get():ExecuteCommand(a_Player, cmd)
	local msgText = g_CommandResultMessageText[cmdResult]
	if (msgText) then
		a_Player:SendMessage(msgText)
	end
	return true
end





local function OnRightClick(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_CursorX, a_CursorY, a_CursorZ)
	-- Get the command bound to this item, if any:
	local itemState = GetItemState(a_Player:GetInventory():GetEquippedItem())
	local cmd = itemState:GetRclkCommand()
	if not(cmd) then
		-- No command bound to rclk
		return false
	end

	-- Execute the command:
	local cmdResult = cPluginManager:Get():ExecuteCommand(a_Player, cmd)
	local msgText = g_CommandResultMessageText[cmdResult]
	if (msgText) then
		a_Player:SendMessage(msgText)
	end
	return true
end





function Initialize()
	-- Bind all the commands:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoCommands(g_PluginInfo)
	RegisterPluginInfoConsoleCommands(g_PluginInfo)

	-- Register hook handlers:
	local pm = cPluginManager
	pm:AddHook(pm.HOOK_PLAYER_LEFT_CLICK,  OnLeftClick)
	pm:AddHook(pm.HOOK_PLAYER_RIGHT_CLICK, OnRightClick)

	return true
end
