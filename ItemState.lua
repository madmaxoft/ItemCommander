-- ItemState.lua

-- Implements the ItemState class wrapping the functionality of storing the command in a cItem




--[[
Usage:
local slotNum = a_Player:GetInventory():GetEquippedSlotNum()
local item = cItem(a_Player:GetInventory():GetEquippedItem())  -- Get a writable cItem instance
local itemState = GetItemState(item)                           -- Create an ItemState object
itemState:SetRclkCommand(...)                                  -- Manipulate the ItemState object
  -- ^ This writes the changes to the underlying item immediately
a_Player:GetInventory():SetHotbarSlot(slotNum, item)           -- Use the modified item


The object mirrors the commands from the item, but performs lazy initialization - it reads the commands only
when needed. The actual serialization into and from Cuberite cItem object is done only in two functions,
ApplyCommands() and InitIfNeeded(). All the other functions manipulate the internal state of the object.
--]]





--- Text that is used as custom name for items that have commands attached to them:
local CUSTOM_NAME_ITEM_COMMANDER = "Item commander"





--- Wraps a command at a 40-char boundary with back-apostrophes
local function WrapCommand(a_Command)
	local charCount = 0
	local lastSpace = 0
	local res = ""
	a_Command = a_Command .. " "  -- Append a space which is used for parsing but not output
	for i = 1, string.len(a_Command) do
		local chr = string.sub(a_Command, i, i)
		if (chr <= " ") then
			-- Space, check if current word will still fit:
			if (charCount + i - lastSpace < 40) then
				-- Fits, add it:
				res = res .. string.sub(a_Command, lastSpace, i - 1)
				charCount = charCount + lastSpace - i
			else
				-- Doesn't fit, move to next line:
				res = res .. "`" .. string.sub(a_Command, lastSpace + 1, i - 1)
				charCount = i - lastSpace
			end
			lastSpace = i
		end
	end
	return res
	--[[
	-- The following doesn't work for consecutive spaces:
	return a_Command:gsub("%g*",
		function(a_Word)
			charCount = charCount + string.len(a_Word)
			if (charCount > 40) then
				charCount = string.len(a_Word)
				return "`" .. a_Word
			else
				charCount = charCount + 1
				return a_Word
			end
		end
	)
	--]]
end





local ItemState = {}





--- Applies the data in the object to the underlying cItem instance
function ItemState:ApplyCommands()
	assert(self)
	assert(self.m_IsInitialized)
	assert(self.m_Item)

	if (self.m_LclkCommand) or (self.m_RclkCommand) then
		-- Serialize the commands into cItem's m_Lore, add a "flag" in cItem.m_CustomName
		self.m_Item.m_CustomName = CUSTOM_NAME_ITEM_COMMANDER
		self.m_Item.m_Lore = string.format("Left:`%s` `Right:`%s",
			WrapCommand(self.m_LclkCommand or ""), WrapCommand(self.m_RclkCommand or "")
		)
	else
		self.m_Item.m_CustomName = ""
		self.m_Item.m_Lore = ""
		self.m_Item.m_Color = 0
	end
end





function ItemState:GetItem()
	-- Check params:
	assert(self)

	return self.m_Item
end





--- Returns the command to execute on lclk, or nil if no command bound
function ItemState:GetLclkCommand()
	-- Check params:
	assert(self)

	self:InitIfNeeded()
	return self.m_LclkCommand
end





--- Returns the command to execute on rclk, or nil if no command bound
function ItemState:GetRclkCommand()
	-- Check params:
	assert(self)

	self:InitIfNeeded()
	return self.m_RclkCommand
end





--- Lazy-initializes the object
-- Reads the commands, if any, from m_Item
function ItemState:InitIfNeeded()
	-- Check params:
	assert(self)

	-- Initialize only once:
	if (self.m_IsInitialized) then
		return
	end
	self.m_IsInitialized = true

	-- Read the commands
	if (self.m_Item.m_CustomName ~= CUSTOM_NAME_ITEM_COMMANDER) then
		-- No commands bound to this item
		return
	end
	local cmdLeft, cmdRight = string.match(self.m_Item.m_Lore, "Left:`(.*)` `Right:`(.*)")
	if not(cmdLeft) or not(cmdRight) then
		-- Invalid bindings
		LOG("ItemCommander: Invalid command bindings detected while parsing string \"" .. self.m_Item.m_Lore .. "\".")
		return
	end
	self.m_LclkCommand = cmdLeft
	self.m_RclkCommand = cmdRight
end





--- Clears the commands to be used on both lclk and rclk
function ItemState:RemoveBothCommands()
	-- Check params:
	assert(self)

	self:InitIfNeeded()
	self.m_LclkCommand = nil
	self.m_RclkCommand = nil
	self:ApplyCommands()
end





--- Clears the command to be used on lclk
function ItemState:RemoveLclkCommand()
	-- Check params:
	assert(self)

	self:InitIfNeeded()
	self.m_LclkCommand = nil
	self:ApplyCommands()
end





--- Clears the command to be used on rclk
function ItemState:RemoveRclkCommand()
	-- Check params:
	assert(self)

	self:InitIfNeeded()
	self.m_RclkCommand = nil
	self:ApplyCommands()
end





--- Sets the command to be used on lclk
function ItemState:SetLclkCommand(a_Command)
	-- Check the params
	assert(self)
	assert(type(a_Command) == "string")

	self:InitIfNeeded()
	self.m_LclkCommand = a_Command
	self:ApplyCommands()
end





--- Sets the command to be used on rclk
function ItemState:SetRclkCommand(a_Command)
	-- Check the params
	assert(self)
	assert(type(a_Command) == "string")

	self:InitIfNeeded()
	self.m_RclkCommand = a_Command
	self:ApplyCommands()
end





function GetItemState(a_Item)
	-- Check params:
	local itemType = tolua.type(a_Item)
	assert((itemType == "cItem") or (itemType == "const cItem"))

	local is =
	{
		m_Item = a_Item,
	}
	setmetatable(is, ItemState)
	ItemState.__index = ItemState
	return is
end




