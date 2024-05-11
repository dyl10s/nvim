return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	event = "VeryLazy",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		local obsidian = require("obsidian")
		obsidian.setup({
			workspaces = {
				{
					name = "merch",
					path = "/home/dylan/Documents/Merch",
				},
			},
			ui = {
				enable = false
			},
			completion = {
				nvim_cmp = true,
				min_chars = 1
			},
			mappings = {
				["gf"] = {
					action = function()
						return require("obsidian").util.gf_passthrough()
					end,
					opts = { noremap = false, expr = true, buffer = true },
				}
			}
		})

		vim.keymap.set("n", "<leader>od", [[:ObsidianToday<CR>]], { desc = "Open daily obsidian note" })
		vim.keymap.set("n", "<leader>oy", [[:ObsidianYesterday<CR>]], { desc = "Open yesterday's obsidian note" })
		vim.keymap.set("n", "<leader>os", [[:ObsidianQuickSwitch<CR>]], { desc = "Search obsidian notes" })
	end
}
