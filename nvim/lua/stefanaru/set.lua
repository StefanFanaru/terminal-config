vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.updatetime = 50
vim.opt.timeoutlen = 300

vim.g.mapleader = " "

-- Netrw settings
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.g.have_nerd_font = true
vim.opt.showmode = false

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.inccommand = "split"

if os.getenv("IS_BASH") == "true" then
	vim.opt.shellcmdflag = "-c"
	vim.opt.undodir = os.getenv("USERPROFILE") .. "/.vim/undodir"
	-- vim.opt.ssl = true
else
	vim.opt.undodir = os.getenv("")
end

vim.opt.smoothscroll = true
-- vim.opt.guicursor = {
--   "n-v:block",
--   "i-c-ci-ve:ver25",
--   "r-cr:hor20",
--   "o:hor50",
--   "i:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
--   "sm:block-blinkwait175-blinkoff150-blinkon175",
-- }
--
