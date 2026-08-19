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

-- -- ▼▼▼ デバッグ用：原因特定後に削除 ▼▼▼
-- local _orig_notify = vim.notify
-- vim.notify = function(msg, level, opts)
--   local trace = debug.traceback("", 2)
--   local f = io.open("/tmp/nvim_notify_trace.log", "a")
--   if f then
--     f:write("=== MSG: " .. tostring(msg) .. "\n")
--     f:write(trace .. "\n\n")
--     f:close()
--   end
--   _orig_notify(msg, level, opts)
-- end
-- -- ▲▲▲ デバッグ用ここまで ▲▲▲

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
-- vim.opt.fileencoding = "utf-8"
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
-- vim.cmd[[colorscheme cyberdream]]

vim.cmd([[highlight ZenkakuSpace  guibg=#3c3836 guifg=#fb4934 gui=underline]])
vim.cmd([[highlight TrailingSpace guibg=#3c3836 guifg=#fabd2f gui=bold,reverse]])

-- ===================================================================
-- skkeleton 変換候補ポップアップ専用ハイライト（オーカー＆濃青・目保護版）
-- ===================================================================
local function set_skkeleton_popup_hl()
  -- パレット定義
  local bg_ochre = "#112218" -- ベースのディープフォレストグリーン背景
  local fg_sand = "#e0f0e3" -- 目に優しいペーッルグリーン文字
  local sel_bg_blue = "#bc9c68" -- 選択中の明るめのライトオーカー背景
  local sel_fg_blue = "#171d26" -- 選択中の濃紺文字
  local border_blue = "#53739a" -- 落ち着いた枠線色

  -- Floatウィンドウ全体の共通背景（透過防止）
  vim.api.nvim_set_hl(0, "NormalFloat", { fg = fg_sand, bg = bg_ochre, force = true })
  -- Floatウィンドウの枠線
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = border_blue, bg = sel_fg_blue, force = true })
end

-- 即時反映
set_skkeleton_popup_hl()

-- カラースキーム変更時にも自動再適用
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = set_skkeleton_popup_hl,
})

-- パターン1：アース・オーカー ＋ 濃青（落ち着きと視認性のバランス）
-- 候補背景 (bg):       #332a1e（ダークオーカー）
-- 標準文字 (fg):       #d1c2a5（温かみのあるサンドベージュ）
-- 選択時背景 (sel_bg): #2d4259（ディープブルー）
-- 選択時文字 (sel_fg): #e2ebf3（ペールブルー）
--
-- パターン2：アンバー・モス ＋ 濃緑（長時間の執筆・コード入力に最適）
-- 候補背景 (bg):       #2e281e（アンバーオーカー）
-- 標準文字 (fg):       #c7bc9b（ウォームグレー）
-- 選択時背景 (sel_bg): #29402e（ディープフォレストグリーン）
-- 選択時文字 (sel_fg): #e0f0e3（ペールグリーン）
--
-- パターン3：ヴィンテージ・ペーパー（高コントラスト＆クラシック）
-- 候補背景 (bg):       #382d1d（リッチオーカー）
-- 標準文字 (fg):       #dccfa9（アンティークホワイト）
-- 選択時背景 (sel_bg): #bc9c68（明るめのライトオーカー）
-- 選択時文字 (sel_fg): #171d26（ダークインディゴ/濃）
--
-- パターン4：ウォーム・オーカー × 深藍（インディゴ墨）
-- 候補背景 (bg):       #a89269（明るいクラフトオーカー）
-- 標準文字 (fg):       #161f28（ディープインディgo / 濃藍墨）
-- 選択時背景 (sel_bg): #2f4858（ダークブルーグリーン）
-- 選択時文字 (sel_fg): #f0f5f9（ペールブルーホワイト
--
-- パターン5：ライト・サンド × 深緑（フォレストブラック）
-- 候補背景 (bg):       #b09f7a（サンドオーカー）
-- 標準文字 (fg):       #112218（ダークフォレスト / 濃緑墨）
-- 選択時背景 (sel_bg): #1f3a2b（ディープグリーン）
-- 選択時文字 (sel_fg): #e8f5e9（ペールグリーン）
--
-- パターン6：アンバー・イエロー × 墨色（チャコール）
-- 候補背景 (bg):       #ba9c5e（アンバーオーカー）
-- 標準文字 (fg):       #121212（チャコールブラック）
-- 選択時背景 (sel_bg): #33281a（ダークブラウン）
-- 選択時文字 (sel_fg): #f5e9d3（ウォームホワイト）
