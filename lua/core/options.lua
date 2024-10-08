-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- show both relative and absolute line number
vim.o.number = true
vim.wo.relativenumber = true

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- highlight current line number
vim.opt.cursorline = true
vim.o.cursorlineopt = "number"

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.wo.number = true -- Make line numbers default
vim.o.mouse = 'a'    -- Enable mouse mode

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

vim.opt.updatetime = 750 -- decrease updatetime
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- ufo (folding)
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- NOTE: You should make sure your terminal supports this
vim.opt.termguicolors = true
vim.opt.scrolloff = 8

-- vim-sleuth probably handles most problem of tab
vim.opt.tabstop = 2

vim.o.wildmode = "longest:full,full" -- make nvim do completions like in bash

-- luarocks
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
