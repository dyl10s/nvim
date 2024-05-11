return {
	'tveskag/nvim-blame-line',
	config = function()
		vim.keymap.set("n", "<leader>gB", [[:ToggleBlameLine<CR>]], { desc = "Toggle Git Line Blame" })
	end
}
