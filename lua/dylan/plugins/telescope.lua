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
			}
		},
		config = function()
			require("telescope").load_extension("fzf")
			local telescope = require("telescope.builtin")

			vim.keymap.set("n", "<leader><leader>",
				function()
					telescope.find_files({
						path_display = { "smart" }
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
			vim.keymap.set("n", "<leader>sr", telescope.resume, { desc = "[S]serch [R]esume" })
		end
	}
}
