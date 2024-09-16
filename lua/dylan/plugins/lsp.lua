local function organize_imports()
	local params = {
		command = "_typescript.organizeImports",
		arguments = { vim.api.nvim_buf_get_name(0) },
		title = ""
	}
	vim.lsp.buf.execute_command(params)
end

return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
			'hrsh7th/cmp-nvim-lsp',
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
			"yioneko/nvim-vtsls"
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup()
			local telescope = require("telescope.builtin")

			-- Set up lspconfig.
			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			local lspconfig = require("lspconfig")
			local util = require("lspconfig.util")
			local userLspAuGroup = vim.api.nvim_create_augroup('UserLspConfig', {})

			require("mason-lspconfig").setup_handlers {
				function(server_name) -- default handler (optional)
					lspconfig[server_name].setup {
						capabilities = capabilities,
					}
				end,
				["lua_ls"] = function()
					lspconfig.lua_ls.setup {
						capabilities = capabilities,
						diagnostics = {
							globals = {
								'vim'
							}
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true)
						}
					}
				end,
				["clangd"] = function()
					lspconfig.clangd.setup {
						cmd = {
							-- see clangd --help-hidden
							"clangd",
							"--background-index",
							-- by default, clang-tidy use -checks=clang-diagnostic-*,clang-analyzer-*
							-- to add more checks, create .clang-tidy file in the root directory
							-- and add Checks key, see https://clang.llvm.org/extra/clang-tidy/
							"--clang-tidy",
							"--completion-style=bundled",
							"--cross-file-rename",
							"--header-insertion=iwyu",
						},
						capabilities = capabilities,
						init_options = {
							clangdFileStatus = true, -- Provides information about activity on clangd’s per-file worker thread
							usePlaceholders = true,
							completeUnimported = true,
							semanticHighlighting = true,
						},
					}
				end,
				["tsserver"] = function()
					-- skip for now and use vtsls
					if false then
						lspconfig.tsserver.setup {
							capabilities = capabilities,
							lint_options = {
								preferences = {
									importModuleSpecifierPreference = 'relative',
									importModuleSpecifierEnding = 'minimal'
								}
							},
							commands = {
								OrganizeImports = {
									organize_imports,
									description = "Organize Imports"
								}
							}
						}
					end
				end,
				["angularls"] = function()
					lspconfig.angularls.setup {
						capabilities = capabilities,
						single_file_support = false,
						root_dir = util.root_pattern(".git"),
						filetypes = { 'typescript', 'html', 'typescriptreact', 'typescript.tsx', 'htmlangular' }
					}
				end,
				["vtsls"] = function()
					lspconfig.vtsls.setup {
						root_dir = util.root_pattern(".git"),
						settings = {
							complete_function_calls = true,
							experimental = {
								completion = {
									enableServerSideFuzzyMatch = true
								}
							},
							typescript = {
								tsserver = {
									maxTsServerMemory = 8192
								},
								suggest = {
									completeFunctionCalls = false
								},
								inlayHints = {
									parameterNames = { enabled = "all" },
									includeInlayParameterNameHintsWhenArgumentMatchesName = { enabled = false }
								}
							}
						}
					}
				end
			}

			local lsp_augroup = vim.api.nvim_create_augroup("lsp", { clear = true })

			local vtsls = require("vtsls");

			vim.api.nvim_create_autocmd("BufWritePre", {
				group = lsp_augroup,
				pattern = "*.ts",
				callback = function()
					local isDone = false;

					vtsls.commands["add_missing_imports"](0, function()
						vtsls.commands["organize_imports"](0, function()
							isDone = true;
						end)
					end)

					vim.wait(5000, function()
						return isDone;
					end)
				end,
			})

			-- Global mappings.
			-- See `:help vim.diagnostic.*` for documentation on any of the below functions
			vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
			vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
			vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
			vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			vim.api.nvim_create_autocmd('LspAttach', {
				group = userLspAuGroup,
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

					local function createBufferBind(mode, keymap, action, desc)
						vim.keymap.set(mode, keymap, action, { buffer = ev.buf, desc = desc })
					end

					createBufferBind('n', 'ch', function()
						-- Enable inlay hints
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
					end, "Toggle [C]ode [H]ints");

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					createBufferBind('n', 'gD', vim.lsp.buf.declaration, "Goto declaration")
					createBufferBind('n', 'gd', vim.lsp.buf.definition, "Goto definition")
					createBufferBind('n', 'K', vim.lsp.buf.hover, "Code hover")
					createBufferBind('n', '<leader>cr', vim.lsp.buf.rename, "Rename")
					createBufferBind('n', 'gr', telescope.lsp_references, "Goto references")
					createBufferBind('n', 'gi', vim.lsp.buf.implementation, "Goto implementation")
					createBufferBind('n', '<leader>D', vim.lsp.buf.type_definition, "Type definition")
					createBufferBind('n', '<leader>ca', vim.lsp.buf.code_action, "Code action")
					createBufferBind('n', '<leader>oi', organize_imports, "Organize imports")
					createBufferBind('n', '<leader>f', function()
						vim.lsp.buf.format { async = true }
					end, "Format")
				end,
			})
		end
	}
}
