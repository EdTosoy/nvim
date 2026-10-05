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

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--no-checkout", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
	local checkout = vim.fn.system({ "git", "-C", lazypath, "checkout", "--detach", lazy_revision })
	if vim.v.shell_error ~= 0 then
		error("Error selecting Lazy revision:\n" .. checkout)
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
