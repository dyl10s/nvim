return {
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					typescript = { "prettierd", "prettier", stop_after_first = true },
					typescriptreact = { "prettierd", "prettier", stop_after_first = true },
					html = { "prettierd", "prettier", stop_after_first = true },
					javascript = { "prettierd", "prettier", stop_after_first = true },
					javascriptreact = { "prettierd", "prettier", stop_after_first = true },
					css = { "prettierd", "prettier", stop_after_first = true },
					scss = { "prettierd", "prettier", stop_after_first = true },
					json = { "prettierd", "prettier", stop_after_first = true },
					cpp = { "clang-format", stop_after_first = true },
					cc = { "clang-format", stop_after_first = true },
					h = { "clang-format", stop_after_first = true }
				}
			})

			local format_augroup = vim.api.nvim_create_augroup("format", { clear = true })

			vim.api.nvim_create_autocmd("BufWritePre", {
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
