local fileMap = {
	["%.component%.ts$"] = ".component.html",
	["%.component%.html$"] = ".component.ts",
	["%.component%.scss$"] = ".component.html",
	["%.module%.ts$"] = ".component.ts",
	["%.service%.ts$"] = ".controller.ts",
	["%.controller%.ts$"] = ".service.ts"
}

local function findMatchingFile()
	local current_file = vim.fn.expand("%")

	for pattern, replacement in pairs(fileMap) do
		local new_file = current_file:gsub(pattern, replacement)

		if new_file ~= current_file then
			return new_file
		end
	end

	return nil
end

function OpenMatchingFile()
	local new_file = findMatchingFile()

	if new_file then
		if vim.fn.filereadable(new_file) == 1 then
			vim.cmd("edit " .. new_file)
		else
			print("Swap file does not exist")
		end
	else
		print("No swap file found.")
	end
end

vim.api.nvim_set_keymap('n', '<leader>s<CR>', ':lua OpenMatchingFile()<CR>',
	{ noremap = true, silent = true, desc = "Swap Matching File" })
