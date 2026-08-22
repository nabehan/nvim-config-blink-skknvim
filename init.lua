-- ~/.config/nvim/init.lua  lazy.nvim 版
-- ===================================================================
local vim = vim

-- <Leader> を Space キーに設定
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- ===================================================================
-- lazy.nvim 自動インストール
-- ===================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then -- 2026-06-20 Sat 02:14:47
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ===================================================================
-- プラグイン読み込み（lua/plugins/*.lua を自動スキャン）
-- ===================================================================
require("lazy").setup("plugins", {
  ui = { border = "single" },
  checker = { enabled = false },
  change_detection = { notify = false },
  rocks = { enabled = false }, -- ← これを追加
})

-- ===================================================================
-- Migemo 検索
-- ===================================================================
vim.keymap.set("n", "S", "<cmd>FuzzyMotion<CR>")
vim.cmd("let g:fuzzy_motion_matchers = ['kensaku', 'fzf']")

-- ===================================================================
-- 各種外部設定ファイルの読み込み
-- ===================================================================
require("my.utils.skkeleton")
-- 補完 (blink.cmp) は lua/plugins/06-lsp.lua の config() から
-- require("my.cmp.blink") として読み込まれる
require("my.telescope.config")
require("my.markdown.table") -- MarkdownTableBlock / MyTableFormat
require("my.markdown.list") -- Bulletize / Numberize / Checkbox / Quote 等

-- ===================================================================
-- 基本 options
-- ===================================================================
vim.opt.confirm = true
vim.opt.autoread = true
vim.opt.hidden = true
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.schedule(function()
  vim.opt.clipboard:append({ "unnamedplus" })
end)

vim.o.encoding = "utf-8"
vim.opt.fileencodings = { "ucs-boms", "utf-8", "euc-jp", "cp932", "iso-2022-jp" }
vim.opt.formatoptions:append({ "mMj" })
vim.opt.matchpairs:append({ "（:）,「:」,『:』,《:》,〈:〉,｛:｝,［:］,【:】,＜:＞" })
vim.opt.spell = true
vim.opt.spelllang = { "en_us", "cjk" }

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.ambiwidth = "single"

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakat = " 　,.、。;:"
vim.opt.breakindent = true
vim.opt.colorcolumn = "80"

vim.opt.list = true
vim.opt.listchars = { tab = ">-", trail = "~", nbsp = "+" }
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"

vim.opt.display:append({ "lastline" })
vim.opt.scrolloff = 9
vim.opt.virtualedit = "onemore,block"
vim.opt.whichwrap = "b,s,h,l,<,>,[,],~"

vim.opt.expandtab = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- ===================================================================
-- カスタム Functions
-- ===================================================================
require("my.utils.stable")
require("my.utils.clean_blank_lines")
require("my.utils.ranger")

-- ===================================================================
-- Auto Command
-- ===================================================================
require("my.autocommand")

-- ===================================================================
-- Keymap
-- ===================================================================
require("my.keymap")
require("my.markdown.keymap")
require("my.cmp.keymap")
require("my.telescope.keymap")

-- ===================================================================
-- Color scheme
-- ===================================================================
vim.cmd([[colorscheme kanagawa]])

vim.cmd([[highlight ZenkakuSpace  guibg=#3c3836 guifg=#fb4934 gui=underline]])
vim.cmd([[highlight TrailingSpace guibg=#3c3836 guifg=#fabd2f gui=bold,reverse]])
