-- Info.lua

-- Declares the plugin's metadata






g_PluginInfo =
{
	Name = "ItemCommander",
	Description = "Allows users to bind commands to items, then executes the command when the player clicks with the item in hand.",

	Commands =
	{
		["/itemcommand"] =
		{
			Subcommands =
			{
				clear =
				{
					Alias = {"c", "remove", "r"},
					Subcommands =
					{
						left =
						{
							Alias = "l",
							Permission = "itemcommand.clear",
							Handler = HandleCmdClear,
							HelpString = "Clears the command to execute when left-clicking with the current item in hand",
						},  -- left
						right =
						{
							Alias = "r",
							Permission = "itemcommand.clear",
							Handler = HandleCmdClear,
							HelpString = "Clears the command to execute when right-clicking with the current item in hand",
						},  -- right
					},
				},  -- clear

				set =
				{
					Alias = "s",
					Subcommands =
					{
						left =
						{
							Alias = "l",
							Permission = "itemcommand.set",
							Handler = HandleCmdSet,
							HelpString = "Sets the command to execute when left-clicking with the current item in hand",
						},  -- left
						right =
						{
							Alias = "r",
							Permission = "itemcommand.set",
							Handler = HandleCmdSet,
							HelpString = "Sets the command to execute when right-clicking with the current item in hand",
						},  -- right
					},  -- Subcommands
				},  -- set
			},  -- Subcommands
		}  -- "/itemcommand"
	},  -- Commands
}





return g_PluginInfo
