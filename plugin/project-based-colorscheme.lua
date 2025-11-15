local M = {}

local default_config = {
	default_colorscheme = "catppuccin-mocha",
	config_files = {
		".nvimrc.lua",
		".nvim.lua",
		"nvim-config.lua",
		".vimrc.lua",
	},
	project_root_indicators = {
		".git",
		"package.json",
		"Cargo.toml",
		"go.mod",
		"pyproject.toml",
		"requirements.txt",
		"Makefile",
		"CMakeLists.txt",
		".project-root",
	},
	auto_setup = false, -- Automatically setup on plugin load (set to true in setup() if desired)
}

local config = default_config

local function find_project_root()
	local current_dir = vim.fn.getcwd()

	local function check_dir(dir)
		for _, indicator in ipairs(config.project_root_indicators) do
			if
				vim.fn.isdirectory(dir .. "/" .. indicator) == 1
				or vim.fn.filereadable(dir .. "/" .. indicator) == 1
			then
				return dir
			end
		end
		return nil
	end

	local dir = current_dir
	while dir ~= "/" do
		local root = check_dir(dir)
		if root then
			return root
		end
		dir = vim.fn.fnamemodify(dir, ":h")
	end
	return current_dir -- fallback to current dir
end

local function load_project_config(project_root)
	for _, config_file in ipairs(config.config_files) do
		local config_path = project_root .. "/" .. config_file
		if vim.fn.filereadable(config_path) == 1 then
			local success, project_config = pcall(function()
				local file = io.open(config_path, "r")
				if not file then
					return nil
				end
				local content = file:read("*a")
				file:close()
				-- Use loadstring for Lua 5.1 compatibility, or load for Lua 5.2+
				local chunk, err = loadstring(content)
				if not chunk then
					return nil
				end
				return chunk()
			end)

			if success and type(project_config) == "table" then
				return project_config
			end
		end
	end
	return nil
end

local function apply_colorscheme(colorscheme)
	if not colorscheme or colorscheme == "" then
		return false
	end

	local success, _ = pcall(vim.cmd.colorscheme, colorscheme)
	if success then
		vim.notify("Applied colorscheme: " .. colorscheme, vim.log.levels.INFO)
		return true
	else
		vim.notify("Failed to apply colorscheme: " .. colorscheme, vim.log.levels.WARN)
		return false
	end
end

-- Track last applied project root to avoid re-applying unnecessarily
local last_project_root = nil

function M.setup(user_config)
	if user_config then
		config = vim.tbl_deep_extend("force", default_config, user_config)
	end

	M.apply_project_colorscheme()

	vim.api.nvim_create_autocmd("DirChanged", {
		pattern = "*",
		callback = function()
			M.apply_project_colorscheme()
		end,
		desc = "Apply project colorscheme on directory change",
	})
end

function M.apply_project_colorscheme()
	local project_root = find_project_root()

	if project_root == last_project_root then
		return
	end

	last_project_root = project_root
	local project_config = load_project_config(project_root)

	if project_config and project_config.colorscheme then
		local success = apply_colorscheme(project_config.colorscheme)
		if not success then
			apply_colorscheme(config.default_colorscheme)
		end
	else
		apply_colorscheme(config.default_colorscheme)
	end
end

function M.create_project_config(colorscheme)
	local project_root = find_project_root()
	local config_path = project_root .. "/.nvimrc.lua"

	local config_content = string.format(
		[[-- Neovim project configuration
return {
  colorscheme = "%s"
}
]],
		colorscheme or "default"
	)

	local file = io.open(config_path, "w")
	if file then
		file:write(config_content)
		file:close()
		vim.notify("Created project config at: " .. config_path, vim.log.levels.INFO)
		return true
	else
		vim.notify("Failed to create project config at: " .. config_path, vim.log.levels.ERROR)
		return false
	end
end

vim.api.nvim_create_user_command("ProjectColorscheme", function(opts)
	local colorscheme = opts.args
	if colorscheme == "" then
		vim.notify("Usage: :ProjectColorscheme <colorscheme_name>", vim.log.levels.ERROR)
		return
	end

	-- Test if colorscheme exists
	local success = apply_colorscheme(colorscheme)
	if success then
		M.create_project_config(colorscheme)
	end
end, {
	nargs = 1,
	complete = function()
		-- Get available colorschemes
		return vim.fn.getcompletion("", "color")
	end,
})

vim.api.nvim_create_user_command("ProjectInfo", function()
	local project_root = find_project_root()
	local project_config = load_project_config(project_root)

	local info = { "Project root: " .. project_root }
	if project_config and project_config.colorscheme then
		table.insert(info, "Project colorscheme: " .. project_config.colorscheme)
	else
		table.insert(info, "No project colorscheme configured")
		table.insert(info, "Default colorscheme: " .. config.default_colorscheme)
	end

	vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
end, {})

-- Store module in global for access via require()
_G.project_based_colorscheme = M

return M

