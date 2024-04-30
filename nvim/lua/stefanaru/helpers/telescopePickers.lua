-- Declare the module
local telescopePickers = {}

-- Store Utilities we'll use frequently
local utils = require("telescope.utils")
local telescopeMakeEntryModule = require("telescope.make_entry")
local plenaryStrings = require("plenary.strings")
local devIcons = require("nvim-web-devicons")
local telescopeEntryDisplayModule = require("telescope.pickers.entry_display")
local Path = require("plenary.path")
local conf = require("telescope.config").values
-- Obtain Filename icon width
-- --------------------------
-- INSIGHT: This width applies to all icons that represent a file type
local fileTypeIconWidth = plenaryStrings.strdisplaywidth(devIcons.get_icon("fname", { default = true }))

---- Helper functions ----

-- Gets the File Path and its Tail (the file name) as a Tuple
function telescopePickers.getPathAndTail(fileName)
	-- Get the Tail
	local bufferNameTail = utils.path_tail(fileName)

	-- Now remove the tail from the Full Path
	local pathWithoutTail = require("plenary.strings").truncate(fileName, #fileName - #bufferNameTail, "")

	-- Apply truncation and other pertaining modifications to the path according to Telescope path rules
	local pathToDisplay = utils.transform_path({
		path_display = { "truncate" },
	}, pathWithoutTail)

	-- Return as Tuple
	return bufferNameTail, pathToDisplay
end

function telescopePickers.get_path_and_tail(filename)
	local utils = require("telescope.utils")
	local bufname_tail = utils.path_tail(filename)
	local path_without_tail = require("plenary.strings").truncate(filename, #filename - #bufname_tail, "")
	local path_to_display = utils.transform_path({
		path_display = { "truncate" },
	}, path_without_tail)

	return bufname_tail, path_to_display
end
---- Picker functions ----

-- Generates a Find File picker but beautified
-- -------------------------------------------
-- This is a wrapping function used to modify the appearance of pickers that provide a Find File
-- functionality, mainly because the default one doesn't look good. It does this by changing the 'display()'
-- function that Telescope uses to display each entry in the Picker.
--
-- Adapted from: https://github.com/nvim-telescope/telescope.nvim/issues/2014#issuecomment-1541423345.
--
-- @param (table) pickerAndOptions - A table with the following format:
--                                   {
--                                      picker = '<pickerName>',
--                                      (optional) options = { ... }
--                                   }
function telescopePickers.prettyFilesPicker(pickerAndOptions)
	-- Parameter integrity check
	if type(pickerAndOptions) ~= "table" or pickerAndOptions.picker == nil then
		print(
			"Incorrect argument format. Correct format is: { picker = 'desiredPicker', (optional) options = { ... } }"
		)

		-- Avoid further computation
		return
	end

	-- Ensure 'options' integrity
	options = pickerAndOptions.options or {}

	-- Use Telescope's existing function to obtain a default 'entry_maker' function
	-- ----------------------------------------------------------------------------
	-- INSIGHT: Because calling this function effectively returns an 'entry_maker' function that is ready to
	--          handle entry creation, we can later call it to obtain the final entry table, which will
	--          ultimately be used by Telescope to display the entry by executing its 'display' key function.
	--          This reduces our work by only having to replace the 'display' function in said table instead
	--          of having to manipulate the rest of the data too.
	--
	--  Set CWD options for git_files
	if pickerAndOptions.picker == "git_files" then
		telescopePickers.set_opts_cwd(options)
	end

	local originalEntryMaker = telescopeMakeEntryModule.gen_from_file(options)

	-- INSIGHT: 'entry_maker' is the hardcoded name of the option Telescope reads to obtain the function that
	--          will generate each entry.
	-- INSIGHT: The paramenter 'line' is the actual data to be displayed by the picker, however, its form is
	--          raw (type 'any) and must be transformed into an entry table.
	options.entry_maker = function(line)
		-- https://github.com/nvim-telescope/telescope.nvim/issues/2014
		local originalEntryTable = originalEntryMaker(line)
		local displayer = telescopeEntryDisplayModule.create({
			separator = " ",
			items = {
				{ width = fileTypeIconWidth },
				{ width = nil },
				{ remaining = true },
			},
		})
		originalEntryTable.display = function(et)
			local icon, iconhl = utils.get_devicons(et.value)
			local fileName = et.value:match("([^/]+)$")
			return displayer({
				{ icon, iconhl },
				fileName .. " ",
				{ et.value, "TelescopeResultsComment" },
			})
		end
		return originalEntryTable
	end

	-- Finally, check which file picker was requested and open it with its associated options
	if pickerAndOptions.picker == "find_files" then
		require("telescope.builtin").find_files(options)
	elseif pickerAndOptions.picker == "git_files" then
		options.show_untracked = true
		require("telescope.builtin").git_files(options)
	elseif pickerAndOptions.picker == "oldfiles" then
		require("telescope.builtin").oldfiles(options)
	elseif pickerAndOptions.picker == "" then
		print("Picker was not specified")
	else
		print("Picker is not supported by Pretty Find Files")
	end
end

local current_path_toplevel = function()
	local gitdir = vim.fn.finddir(".git", vim.fn.expand("%:p") .. ";")
	if gitdir == "" then
		return nil
	end
	return Path:new(gitdir):parent():absolute()
end

local try_worktrees = function(opts)
	local worktrees = conf.git_worktrees

	if vim.tbl_islist(worktrees) then
		for _, wt in ipairs(worktrees) do
			if vim.startswith(opts.cwd, wt.toplevel) then
				opts.toplevel = wt.toplevel
				opts.gitdir = wt.gitdir
				if opts.use_git_root then
					opts.cwd = wt.toplevel
				end
				return
			end
		end
	end

	error(opts.cwd .. " is not a git directory")
end

-- Needed for git_files to work
function telescopePickers.set_opts_cwd(opts)
	opts.use_git_root = vim.F.if_nil(opts.use_git_root, true)
	if opts.cwd then
		opts.cwd = utils.path_expand(opts.cwd)
	elseif opts.use_file_path then
		opts.cwd = current_path_toplevel()
		if not opts.cwd then
			opts.cwd = vim.fn.expand("%:p:h")
			try_worktrees(opts)
			return
		end
	else
		opts.cwd = vim.loop.cwd()
	end

	local toplevel, ret = utils.get_os_command_output({ "git", "rev-parse", "--show-toplevel" }, opts.cwd)

	if ret ~= 0 then
		local in_worktree = utils.get_os_command_output({ "git", "rev-parse", "--is-inside-work-tree" }, opts.cwd)
		local in_bare = utils.get_os_command_output({ "git", "rev-parse", "--is-bare-repository" }, opts.cwd)

		if in_worktree[1] ~= "true" and in_bare[1] ~= "true" then
			try_worktrees(opts)
		elseif in_worktree[1] ~= "true" and in_bare[1] == "true" then
			opts.is_bare = true
		end
	else
		if opts.use_git_root then
			opts.cwd = toplevel[1]
		end
	end
end
-- Generates a Grep Search picker but beautified
-- ----------------------------------------------
-- This is a wrapping function used to modify the appearance of pickers that provide Grep Search
-- functionality, mainly because the default one doesn't look good. It does this by changing the 'display()'
-- function that Telescope uses to display each entry in the Picker.
--
-- @param (table) pickerAndOptions - A table with the following format:
--                                   {
--                                      picker = '<pickerName>',
--                                      (optional) options = { ... }
--                                   }
function telescopePickers.prettyGrepPicker(pickerAndOptions)
	-- Parameter integrity check
	if type(pickerAndOptions) ~= "table" or pickerAndOptions.picker == nil then
		print(
			"Incorrect argument format. Correct format is: { picker = 'desiredPicker', (optional) options = { ... } }"
		)

		-- Avoid further computation
		return
	end

	-- Ensure 'options' integrity
	options = pickerAndOptions.options or {}

	-- Use Telescope's existing function to obtain a default 'entry_maker' function
	-- ----------------------------------------------------------------------------
	-- INSIGHT: Because calling this function effectively returns an 'entry_maker' function that is ready to
	--          handle entry creation, we can later call it to obtain the final entry table, which will
	--          ultimately be used by Telescope to display the entry by executing its 'display' key function.
	--          This reduces our work by only having to replace the 'display' function in said table instead
	--          of having to manipulate the rest of the data too.
	local originalEntryMaker = telescopeMakeEntryModule.gen_from_vimgrep(options)

	-- INSIGHT: 'entry_maker' is the hardcoded name of the option Telescope reads to obtain the function that
	--          will generate each entry.
	-- INSIGHT: The paramenter 'line' is the actual data to be displayed by the picker, however, its form is
	--          raw (type 'any) and must be transformed into an entry table.
	options.entry_maker = function(line)
		-- Generate the Original Entry table
		local originalEntryTable = originalEntryMaker(line)

		-- INSIGHT: An "entry display" is an abstract concept that defines the "container" within which data
		--          will be displayed inside the picker, this means that we must define options that define
		--          its dimensions, like, for example, its width.
		local displayer = telescopeEntryDisplayModule.create({
			separator = " ", -- Telescope will use this separator between each entry item
			items = {
				{ width = fileTypeIconWidth },
				{ width = nil },
				{ width = nil }, -- Maximum path size, keep it short
				{ remaining = true },
			},
		})

		-- LIFECYCLE: At this point the "displayer" has been created by the create() method, which has in turn
		--            returned a function. This means that we can now call said function by using the
		--            'displayer' variable and pass it actual entry values so that it will, in turn, output
		--            the entry for display.
		--
		-- INSIGHT: We now have to replace the 'display' key in the original entry table to modify the way it
		--          is displayed.
		-- INSIGHT: The 'entry' is the same Original Entry Table but is is passed to the 'display()' function
		--          later on the program execution, most likely when the actual display is made, which could
		--          be deferred to allow lazy loading.
		--
		-- HELP: Read the 'make_entry.lua' file for more info on how all of this works
		originalEntryTable.display = function(entry)
			---- Get File columns data ----
			-------------------------------

			-- Get the Tail and the Path to display
			local tail, pathToDisplay = telescopePickers.getPathAndTail(entry.filename)

			-- Get the Icon with its corresponding Highlight information
			local icon, iconHighlight = utils.get_devicons(tail)

			---- Format Text for display ----
			---------------------------------

			-- Add coordinates if required by 'options'
			local coordinates = ""

			if not options.disable_coordinates then
				if entry.lnum then
					if entry.col then
						coordinates = string.format(" -> %s:%s", entry.lnum, entry.col)
					else
						coordinates = string.format(" -> %s", entry.lnum)
					end
				end
			end

			-- Append coordinates to tail
			tail = tail .. coordinates

			-- Add an extra space to the tail so that it looks nicely separated from the path
			local tailForDisplay = tail .. " "

			-- Encode text if necessary
			local text = options.file_encoding and vim.iconv(entry.text, options.file_encoding, "utf8") or entry.text

			-- INSIGHT: This return value should be a tuple of 2, where the first value is the actual value
			--          and the second one is the highlight information, this will be done by the displayer
			--          internally and return in the correct format.
			return displayer({
				{ icon, iconHighlight },
				tailForDisplay,
				{ pathToDisplay, "TelescopeResultsComment" },
				text,
			})
		end

		return originalEntryTable
	end

	-- Finally, check which file picker was requested and open it with its associated options
	if pickerAndOptions.picker == "live_grep" then
		require("telescope.builtin").live_grep(options)
	elseif pickerAndOptions.picker == "grep_string" then
		require("telescope.builtin").grep_string(options)
	elseif pickerAndOptions.picker == "" then
		print("Picker was not specified")
	else
		print("Picker is not supported by Pretty Grep Picker")
	end
end

-- Return the module for use
return telescopePickers
