return {
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"neovim/nvim-lspconfig",
			'hrsh7th/cmp-nvim-lsp'
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup()

			-- Set up lspconfig.
			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			local lspconfig = require("lspconfig")
			local util = require("lspconfig.util")

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
				["tsserver"] = function()
					lspconfig.tsserver.setup {
						capabilities = capabilities,
						root_dir = util.root_pattern("package.json", ".git")
					}
				end,
				["eslint"] = function()
					lspconfig.eslint.setup {
						capabilities = capabilities,
						root_dir = util.root_pattern("package.json", ".git")
					}
				end,
				["angularls"] = function()
					lspconfig.angularls.setup {
						capabilities = capabilities,
						root_dir = util.root_pattern("project.json", "angular.json", "package.json", ".git")
					}
				end,
			}


			-- Global mappings.
			-- See `:help vim.diagnostic.*` for documentation on any of the below functions
			vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
			vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
			vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
			vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('UserLspConfig', {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

					local function createBufferBind(mode, keymap, action, desc)
						vim.keymap.set(mode, keymap, action, { buffer = ev.buf, desc = desc })
					end

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					createBufferBind('n', 'gD', vim.lsp.buf.declaration, "Goto declaration")
					createBufferBind('n', 'gd', vim.lsp.buf.definition, "Goto definition")
					createBufferBind('n', 'K', vim.lsp.buf.hover, "Code hover")
					createBufferBind('n', '<leader>cr', vim.lsp.buf.rename, "Rename")
					createBufferBind('n', 'gr', vim.lsp.buf.references, "Goto references")
					createBufferBind('n', 'gi', vim.lsp.buf.implementation, "Goto implementation")
					createBufferBind('n', '<leader>D', vim.lsp.buf.type_definition, "Type definition")
					createBufferBind('n', '<leader>ca', vim.lsp.buf.code_action, "Code action")
					createBufferBind('n', '<leader>f', function()
						vim.lsp.buf.format { async = true }
					end, "Format")
				end,
			})
		end
	}
}
