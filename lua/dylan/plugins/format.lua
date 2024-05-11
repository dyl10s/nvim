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
					cpp = { { "clang-format" } },
					cc = { { "clang-format" } },
					h = { { "clang-format" } },
				}
			})

			local format_augroup = vim.api.nvim_create_augroup("format", { clear = true })

			vim.api.nvim_create_autocmd("BufWritePre", {
				group = format_augroup,
				pattern = "*.ts",
				callback = function()
					vim.cmd([[:TSToolsAddMissingImports sync]])
					vim.cmd([[:TSToolsOrganizeImports sync]])
				end,
			})

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
