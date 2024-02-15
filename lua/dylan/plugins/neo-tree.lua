return {
	"nvim-neo-tree/neo-tree.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		local tree = require("neo-tree")

		tree.setup({
			filesystem = {
				follow_current_file = {
					enabled = true
				}
			},
			buffers = {
				follow_current_file = {
					enabled = true
				}
			}
		})
	end
}
