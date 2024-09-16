function AddToCSpellWordlist(opts, shouldLint)
	-- default to true
	shouldLint = shouldLint == nil or shouldLint

	local cspell_file = vim.fs.dirname(vim.fs.find({ "cspell.json" }, { upwards = true })[1]) .. "/cspell.json"

	local existing_words = vim.fn.json_decode(vim.fn.readfile(cspell_file))

	-- Check if cspell.json exists
	if vim.fn.filereadable(cspell_file) == 1 then
		existing_words = vim.fn.json_decode(vim.fn.readfile(cspell_file))
	else
		-- Create cspell.json if it doesn't exist
		local newFile = io.open(cspell_file, "w")
		if newFile then
			newFile:write('{ "words": [] }')
			newFile:close()
			print("Created cspell.json file.")
		else
			print("Error creating cspell.json file.")
			return
		end
	end

	local new_word = opts.args

	if vim.fn.index(existing_words.words, new_word) == -1 then
		table.insert(existing_words.words, new_word)
		vim.fn.writefile({ vim.fn.json_encode(existing_words) }, cspell_file)
		print('Added word "' .. new_word .. '" to cspell.json wordlist.')
	else
		print('Word "' .. new_word .. '" already exists in the wordlist.')
	end

	if shouldLint then
		local lint = require("lint")
		lint.try_lint()
	end
end

function AddAllCSpellWarningsToList()
	local current_buffer_path = vim.fn.expand('%:p')
	local command_output = vim.fn.systemlist('cspell ' ..
		current_buffer_path .. ' --words-only --no-summary --no-progress')

	for _, line in ipairs(command_output) do
		AddToCSpellWordlist({ args = line }, false)
	end

	local lint = require("lint")
	lint.try_lint()
end

return {
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")

			local cspell = lint.linters.cspell
			if vim.fs.find({ ".git" }, { upwards = true })[1] then
				cspell.args = {
					'--root=' .. vim.fs.dirname(vim.fs.find({ ".git" }, { upwards = true })[1])
				}
			end

			lint.linters_by_ft = {
				javascript = { "eslint_d", "cspell" },
				typescript = { "eslint_d", "cspell" },
				javascriptreact = { "eslint_d", "cspell" },
				typescriptreact = { "eslint_d", "cspell" },
				html = { "cspell" },
				css = { "cspell" },
				scss = { "cspell" },
				lua = { "cspell" }
			}

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

			vim.api.nvim_create_user_command("SpellAdd", AddToCSpellWordlist, { nargs = 1 })
			vim.api.nvim_set_keymap("n", "<leader>sa", [[:lua AddAllCSpellWarningsToList()<CR>]],
				{ noremap = true, silent = true, desc = "Wordlist all cspell warnings" })

			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})
		end
	}
}
