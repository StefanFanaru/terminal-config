local M = {}

-- We cache the results of "git rev-parse"
-- Process creation is expensive in Windows, so this reduces latency
local is_inside_work_tree = {}

M.project_files = function()
	local opts = {} -- define here if you want to define something

	local cwd = vim.fn.getcwd()
	print(cwd)
	vim.notify(cwd)
	if is_inside_work_tree[cwd] == nil then
		vim.fn.system({ "git", "rev-parse", "--is-inside-work-tree" })
		is_inside_work_tree[cwd] = vim.v.shell_error == 0
	end

	local customPickers = require("stefanaru.helpers.telescopePickers")
	if is_inside_work_tree[cwd] then
		customPickers.prettyFilesPicker({ picker = "git_files" })
	else
		customPickers.prettyFilesPicker({ picker = "find_files" })
	end
end

return M
