return {
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					typescript = { { "prettierd", "prettier" } },
					typescriptreact = { { "prettierd", "prettier" } },
					html = { { "prettierd", "prettier" } },
					javascript = { { "prettierd", "prettier" } },
					javascriptreact = { { "prettierd", "prettier" } },
					css = { { "prettierd", "prettier" } },
					scss = { { "prettierd", "prettier" } },
					json = { { "prettierd", "prettier" } },
				}
			})

			local format_augroup = vim.api.nvim_create_augroup("format", { clear = true })

			vim.api.nvim_create_autocmd("BufWritePost", {
				group = format_augroup,
				pattern = "*",
				callback = function(args)
					require("conform").format({
						bufnr = args.buf,
						lsp_fallback = true
					})
				end,
			})
		end
	}
}
