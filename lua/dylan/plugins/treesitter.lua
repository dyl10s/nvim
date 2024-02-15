return {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = { "typescript", "lua", "javascript", "html" },
				sync_install = false,
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
				autotag = { enable = true }
			})
		end
	}
}
