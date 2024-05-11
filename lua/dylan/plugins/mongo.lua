return {
	dir = '~/.config/nvim/lua/plugins/mongodb/',
	build = "luarocks install lua-mongo",
	event = "VeryLazy",
	config = function()
		local mongo = require("mongodb")
		mongo.setup()

		vim.keymap.set("n", "<leader>mc", mongo.OpenCollections, { desc = "Show Mongo collections" })
		vim.keymap.set("n", "<leader>md", mongo.SetDefaultDatabase, { desc = "Change Mongo database" })
		vim.keymap.set("n", "<leader>ms", mongo.ChangeConnection, { desc = "Change Mongo Server" })
	end
}
