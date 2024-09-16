return {
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.5',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build =
				"cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
			},
			'nvim-telescope/telescope-ui-select.nvim'
		},
		config = function()
			local actions = require('telescope.actions')

			require("telescope").setup({
				pickers = {
					git_branches = {
						mappings = {
							i = { ["<cr>"] = actions.git_switch_branch },
						},
					},
				},
			})

			require("telescope").load_extension("fzf")
			require("telescope").load_extension("ui-select")

			local telescope = require("telescope.builtin")

			vim.keymap.set("n", "<leader><leader>",
				function()
					telescope.find_files({
						path_display = { truncate = 3 }
					})
				end,
				{
					desc = "Find files"
				}
			)

			vim.keymap.set("n", "<leader>sg", telescope.live_grep, { desc = "[S]earch [G]rep" })
			vim.api.nvim_set_keymap('n', '<Leader>gb', [[:Telescope git_branches<CR>]],
				{ noremap = true, silent = true, desc = "Switch Branch" })
			vim.keymap.set("n", "<leader>sw", telescope.grep_string, { desc = "[S]earch For Current [W]ord" })
			vim.keymap.set("n", "<leader>sr", telescope.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>sh", telescope.help_tags, { desc = "[S]earch [H]elp" })
		end
	}
}
