-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

-- tab/indent
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.breakindent = true

-- search
opt.incsearch = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.ignorecase = true
opt.smartcase = true
-- Preview substitutions live, as you type!
opt.inccommand = "split"

-- visual
opt.number = true
opt.relativenumber = true
opt.termguicolors = true
opt.signcolumn = "yes"
-- Show which line your cursor is on
opt.cursorline = true
-- Don't show the mode, since it's already in the status line
opt.showmode = false

-- etc
opt.encoding = "UTF-8"
opt.cmdheight = 1
-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10
-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = "a"
-- Save undo history
opt.undofile = true
-- Decrease update time
opt.updatetime = 250
-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300
-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true
