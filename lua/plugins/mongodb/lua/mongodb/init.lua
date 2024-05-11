local mongo = require('mongo')

local connections = {
	{ 'local', 'mongodb://127.0.0.1:27017' },
	{ 'test',  'mongodb://127.0.0.1:51899/merch' },
};

-- Function to read the config file
local function readConfig(filename)
	local file = io.open(filename, "r")
	if not file then
		return
	end

	for line in io.lines(filename) do
		local dbName, connectionString = line:match("(%w+)=(.+)")
		if dbName and connectionString then
			table.insert(connections, { dbName, connectionString })
		else
			print("Error parsing line:", line)
		end
	end
end

-- Call the function with the filename
readConfig("db.config")

local connectionName = "local"
local client = mongo.Client('mongodb://127.0.0.1:27017')

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local defaultDatabase = client:getDatabase('release')

local augroup = vim.api.nvim_create_augroup('DYLAN_MONGO', {})
local bufnr = nil

local M = {}

local createBuffer = function()
	bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(bufnr, 'filetype', 'json')
	vim.api.nvim_buf_set_option(bufnr, 'buftype', 'acwrite')
	vim.api.nvim_buf_set_name(bufnr, 'results.json')
end

local openResultBuffer = function(id, collection, text)
	-- Format the text with jq
	local cmd = string.format("echo '%s' | jq '.'", text)
	local handle = io.popen(cmd)
	local formatted_text = handle:read("*a")
	handle:close()

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(formatted_text, '\n'))

	local width = 120 -- Set your preferred width
	local height = 40 -- Set your preferred height
	vim.api.nvim_open_win(bufnr, true, {
		width = width,
		height = height,
		relative = 'editor',
		row = math.floor((vim.api.nvim_get_option('lines') - height) / 2),
		col = math.floor((vim.api.nvim_get_option('columns') - width) / 2),
		style = 'minimal',
		border = 'single',
	})

	vim.api.nvim_win_set_cursor(0, { 1, 0 })

	vim.api.nvim_create_autocmd("BufWriteCmd", {
		group = augroup,
		buffer = bufnr,
		callback = function()
			local text = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			local results = collection:replaceOne(
				mongo.BSON { _id = id },
				mongo.BSON(table.concat(text, '\n'))
			)
			print("Write results: ", vim.inspect(results))
		end
	})

	vim.api.nvim_create_autocmd("BufModifiedSet", {
		group = augroup,
		buffer = bufnr,
		callback = function()
			vim.api.nvim_buf_set_option(bufnr, 'modified', false)
		end
	})
end

local databases = function(callback)
	local databases = client:getDatabaseNames()

	pickers.new(require("telescope.themes").get_dropdown({}), {
		prompt_title = "Databases",
		finder = finders.new_table {
			results = databases
		},
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if callback ~= nil then
					callback(selection[1])
				end
			end)
			return true
		end,
	}):find()
end

local connectionPicker = function(callback)
	pickers.new(require("telescope.themes").get_dropdown({}), {
		prompt_title = "Connections",
		finder = finders.new_table {
			results = connections,
			entry_maker = function(entry)
				return {
					value = entry[2],
					display = entry[1],
					ordinal = entry[1]
				}
			end,
		},
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if callback ~= nil then
					callback(selection.value, selection.display)
				end
			end)
			return true
		end,
	}):find()
end

local collections = function(callback)
	if (defaultDatabase == nil) then
		print("No database set")
		return
	end

	local collections = defaultDatabase:getCollectionNames()

	pickers.new(require("telescope.themes").get_dropdown({}), {
		prompt_title = "Collections " .. "(" .. connectionName .. ")",
		finder = finders.new_table {
			results = collections
		},
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				if callback ~= nil then
					callback(selection[1])
				end
			end)
			return true
		end,
	}):find()
end

local documents = function(collectionName)
	if (defaultDatabase == nil) then
		print("No database set")
		return
	end

	local collection = defaultDatabase:getCollection(collectionName)
	local cursor = collection:find({}, { limit = 100 })

	local data = {}

	for value in cursor:iterator() do
		table.insert(data, { tostring(vim.inspect(value)), tostring(value._id) })
	end

	pickers.new({}, {
		prompt_title = collectionName .. " Documents",
		finder = finders.new_table {
			results = data,
			entry_maker = function(entry)
				return {
					value = entry[1],
					display = entry[2],
					ordinal = entry[1]
				}
			end,
		},
		sorter = conf.generic_sorter({}),
		previewer = require("telescope.previewers").new_buffer_previewer({
			define_preview = function(self, entry, status)
				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, true, vim.split(entry.value, "\n") or {})
			end,
		}),
		attach_mappings = function(prompt_bufnr, _)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()

				local id = mongo.ObjectID(selection.display)
				local document = collection:findOne(mongo.BSON { _id = id })
				openResultBuffer(id, collection, tostring(document))
			end)
			return true
		end,
	}):find()
end

function M.setup(config)
	createBuffer()
end

function M.ChangeConnection()
	connectionPicker(function(connectionString, name)
		connectionName = name
		client = mongo.Client(connectionString)
		M.SetDefaultDatabase(
			M.OpenCollections
		);
	end)
end

function M.SetDefaultDatabase(callback)
	databases(function(dbName)
		defaultDatabase = client:getDatabase(dbName)
		if callback ~= nil then
			callback()
		end
	end)
end

function M.OpenCollections()
	if (defaultDatabase == nil) then
		M.SetDefaultDatabase(collections)
	else
		collections(documents)
	end
end

return M
