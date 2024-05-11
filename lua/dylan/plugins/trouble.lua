return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle("document_diagnostics") end, {
			desc = "Open Exception List"
		})
		vim.keymap.set("n", "<leader>xn", function() require("trouble").next({ skip_groups = true, jump = true }); end,
			{ desc = "Next Exception" })
	end
}
