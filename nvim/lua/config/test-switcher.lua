-- Jump between a source file and its test (the terminal-nvim equivalent of the
-- VSCode test-switcher extension bound to <leader>a).

local M = {}

local function exists(path)
	local stat = (vim.uv or vim.loop).fs_stat(path)
	return stat ~= nil and stat.type == "file"
end

-- Swap the first matching directory segment, e.g. src/foo.ts -> test/foo.ts
local function swap_dir(dir, from, to)
	local swapped, n = dir:gsub("/" .. from .. "/", "/" .. to .. "/", 1)
	if n == 0 then
		swapped, n = dir:gsub("/" .. from .. "$", "/" .. to, 1)
	end
	if n == 0 then
		return nil
	end
	return swapped
end

-- Every directory the counterpart might live in, given the file's directory.
local function dir_variants(dir, source_dirs, test_dirs, to_test)
	local dirs = { dir }
	local from = to_test and source_dirs or test_dirs
	local to = to_test and test_dirs or source_dirs
	for _, f in ipairs(from) do
		for _, t in ipairs(to) do
			local swapped = swap_dir(dir, f, t)
			if swapped then
				table.insert(dirs, swapped)
			end
		end
	end
	return dirs
end

local JS_EXTS = { "ts", "tsx", "js", "jsx", "mjs", "cjs" }
local JS_SUFFIXES = { "test", "spec" }
local JS_TEST_DIRS = { "__tests__", "test", "tests", "spec" }
local JS_SRC_DIRS = { "src", "lib", "app" }

local function js_candidates(dir, stem, ext)
	local out = {}
	local base, suffix = stem:match("^(.*)%.(%w+)$")
	local is_test = suffix == "test" or suffix == "spec"

	local exts = { ext }
	for _, e in ipairs(JS_EXTS) do
		if e ~= ext then
			table.insert(exts, e)
		end
	end

	if is_test then
		-- test -> source: drop the suffix, climb out of any __tests__ dir
		local dirs = dir_variants(dir, JS_SRC_DIRS, JS_TEST_DIRS, false)
		for _, d in ipairs(JS_TEST_DIRS) do
			if dir:match("/" .. d .. "$") then
				table.insert(dirs, (dir:gsub("/" .. d .. "$", "", 1)))
			end
		end
		for _, d in ipairs(dirs) do
			for _, e in ipairs(exts) do
				table.insert(out, d .. "/" .. base .. "." .. e)
			end
		end
	else
		-- source -> test: same dir first, then sibling/mirrored test dirs
		local dirs = dir_variants(dir, JS_SRC_DIRS, JS_TEST_DIRS, true)
		for _, d in ipairs(JS_TEST_DIRS) do
			table.insert(dirs, dir .. "/" .. d)
		end
		for _, d in ipairs(dirs) do
			for _, s in ipairs(JS_SUFFIXES) do
				for _, e in ipairs(exts) do
					table.insert(out, d .. "/" .. stem .. "." .. s .. "." .. e)
				end
			end
		end
	end

	return out
end

local RUBY_SRC_DIRS = { "app", "lib" }
local RUBY_TEST_DIRS = { "spec", "test" }

local function ruby_candidates(dir, stem)
	local out = {}
	local base = stem:match("^(.*)_spec$") or stem:match("^(.*)_test$")

	if base then
		for _, d in ipairs(dir_variants(dir, RUBY_SRC_DIRS, RUBY_TEST_DIRS, false)) do
			table.insert(out, d .. "/" .. base .. ".rb")
		end
		-- spec/models/foo_spec.rb -> app/models/foo.rb, when the root is the repo
		table.insert(out, (dir:gsub("^(.-)/spec/", "%1/app/", 1)) .. "/" .. base .. ".rb")
		table.insert(out, (dir:gsub("^(.-)/spec/", "%1/lib/", 1)) .. "/" .. base .. ".rb")
	else
		for _, d in ipairs(dir_variants(dir, RUBY_SRC_DIRS, RUBY_TEST_DIRS, true)) do
			table.insert(out, d .. "/" .. stem .. "_spec.rb")
			table.insert(out, d .. "/" .. stem .. "_test.rb")
		end
		table.insert(out, (dir:gsub("^(.-)/app/", "%1/spec/", 1)) .. "/" .. stem .. "_spec.rb")
		table.insert(out, (dir:gsub("^(.-)/lib/", "%1/spec/", 1)) .. "/" .. stem .. "_spec.rb")
	end

	return out
end

local function go_candidates(dir, stem)
	local base = stem:match("^(.*)_test$")
	if base then
		return { dir .. "/" .. base .. ".go" }
	end
	return { dir .. "/" .. stem .. "_test.go" }
end

local PY_TEST_DIRS = { "tests", "test" }
local PY_SRC_DIRS = { "src", "lib" }

local function py_candidates(dir, stem)
	local out = {}
	local base = stem:match("^test_(.*)$") or stem:match("^(.*)_test$")

	if base then
		local dirs = dir_variants(dir, PY_SRC_DIRS, PY_TEST_DIRS, false)
		for _, d in ipairs(PY_TEST_DIRS) do
			if dir:match("/" .. d .. "$") then
				table.insert(dirs, (dir:gsub("/" .. d .. "$", "", 1)))
			end
		end
		for _, d in ipairs(dirs) do
			table.insert(out, d .. "/" .. base .. ".py")
		end
	else
		local dirs = dir_variants(dir, PY_SRC_DIRS, PY_TEST_DIRS, true)
		for _, d in ipairs(PY_TEST_DIRS) do
			table.insert(dirs, dir .. "/" .. d)
		end
		for _, d in ipairs(dirs) do
			table.insert(out, d .. "/test_" .. stem .. ".py")
			table.insert(out, d .. "/" .. stem .. "_test.py")
		end
	end

	return out
end

-- Paths the counterpart of `path` could live at, best guess first.
function M.candidates(path)
	local dir = vim.fn.fnamemodify(path, ":h")
	local stem = vim.fn.fnamemodify(path, ":t:r")
	local ext = vim.fn.fnamemodify(path, ":e")

	if ext == "rb" then
		return ruby_candidates(dir, stem)
	elseif ext == "go" then
		return go_candidates(dir, stem)
	elseif ext == "py" then
		return py_candidates(dir, stem)
	elseif vim.tbl_contains(JS_EXTS, ext) then
		return js_candidates(dir, stem, ext)
	end

	return {}
end

-- Open the counterpart of the current buffer, or report that there isn't one.
function M.switch()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		vim.notify("test-switcher: buffer has no file", vim.log.levels.WARN)
		return
	end

	local seen = {}
	for _, candidate in ipairs(M.candidates(path)) do
		if not seen[candidate] then
			seen[candidate] = true
			if exists(candidate) then
				vim.cmd.edit(vim.fn.fnameescape(candidate))
				return
			end
		end
	end

	vim.notify("test-switcher: no counterpart for " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.WARN)
end

return M
