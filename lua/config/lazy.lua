local data = vim.fn.stdpath("data")
local snapshot = vim.fn.stdpath("config") .. "/lazy-lock.json"
local lockfile = data .. "/lazy-lock.json"
local lazy_revision = vim.json.decode(table.concat(vim.fn.readfile(snapshot), "\n"))["lazy.nvim"].commit

-- Home Manager deploys a read-only snapshot; Lazy writes its own operational lock.
if not vim.uv.fs_stat(lockfile) then
	vim.fn.mkdir(data, "p")
	assert(vim.uv.fs_copyfile(snapshot, lockfile, 1)) -- COPYFILE_EXCL: never overwrite
	assert(vim.uv.fs_chmod(lockfile, 384)) -- 0600, even when the snapshot is read-only
end

local lazy_parent = data .. "/lazy"
local lazypath = lazy_parent .. "/lazy.nvim"
local function lazy_installed()
	local module = vim.uv.fs_stat(lazypath .. "/lua/lazy/init.lua")
	return module and module.type == "file"
end

if not lazy_installed() then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.mkdir(lazy_parent, "p")
	local staging = assert(vim.uv.fs_mkdtemp(lazypath .. ".XXXXXX"))
	local ok, failure = pcall(function()
		local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--no-checkout", lazyrepo, staging })
		if vim.v.shell_error ~= 0 then
			error("Error cloning lazy.nvim:\n" .. out)
		end
		local checkout = vim.fn.system({ "git", "-C", staging, "checkout", "--detach", lazy_revision })
		if vim.v.shell_error ~= 0 then
			error("Error selecting Lazy revision:\n" .. checkout)
		end
		assert(vim.fn.filereadable(staging .. "/lua/lazy/init.lua") == 1, "Lazy checkout is missing its module")
		if not lazy_installed() then
			if vim.uv.fs_lstat(lazypath) then
				assert(vim.fn.delete(lazypath, "rf") == 0, "Could not remove incomplete Lazy installation")
			end
			local installed, rename_error = vim.uv.fs_rename(staging, lazypath)
			assert(installed or lazy_installed(), rename_error)
		end
	end)
	vim.fn.delete(staging, "rf")
	if not ok then
		error(failure)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{ "folke/lazy.nvim", commit = lazy_revision },
	{ import = "plugins" },
}, {
	lockfile = lockfile,
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
