-- ~/.config/nvim/lua/my/keymap.lua
local vim = vim

-- Escの2回押しでハイライト消去
vim.keymap.set("n", "<Esc><Esc>", "<cmd>nohlsearch<CR><ESC>", { noremap = true })

-- カーソル位置の強調を <leader>c でトグルする
vim.keymap.set("n", "<leader>c", "<cmd>setlocal cursorline! cursorcolumn!<CR><ESC>", { noremap = true })

-- 折り返しの切り替えショートカット
vim.keymap.set("n", "<leader>w", "<cmd>set wrap!<CR>", { desc = "Toggle wrap" })

-- 日本語編集対応のキーマップ
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "<DOWN>", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })
vim.keymap.set("n", "<UP>", "gk", { noremap = true })

-- vim-smartword の単語移動
vim.keymap.set("n", "w", "<Plug>(smartword-w)", { noremap = false })
vim.keymap.set("n", "b", "<Plug>(smartword-b)", { noremap = false })
vim.keymap.set("n", "e", "<Plug>(smartword-e)", { noremap = false })
vim.keymap.set("n", "ge", "<Plug>(smartword-ge)", { noremap = false })

-- yanky: yank の履歴拡張
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { noremap = false })
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { noremap = false })
vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)", { noremap = false })
vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)", { noremap = false })
vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)", { noremap = false })
vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)", { noremap = false })
-- kensaku-search : Migemo検索
vim.keymap.set("c", "<CR>", "<Plug>(kensaku-search-replace)<CR>", { noremap = false })

-- toggleterm で簡単にターミナルを呼び出す
vim.keymap.set("n", "<leader>tf", ":ToggleTerm direction=float<CR>")
vim.keymap.set("n", "<leader>tv", ":ToggleTerm direction=vertical<CR>")
vim.keymap.set("n", "<leader>th", ":ToggleTerm direction=horizontal<CR>")

-- ウィンドウの全画面化
vim.keymap.set("n", "<Leader>z", function()
  vim.cmd("wincmd _")
  vim.cmd("wincmd |")
end, { desc = "ウィンドウを全画面に広げる" })

-- jk で素早くノーマルモードに戻る
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })

-- nvim-hlslens: 検索マッチ位置を scrollbar に反映
local hlslens_ok, hlslens = pcall(require, "hlslens")
if hlslens_ok then
  local opts = { noremap = true, silent = true }

  vim.keymap.set("n", "n", "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>", opts)
  vim.keymap.set("n", "N", "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>", opts)
  vim.keymap.set("n", "*", "<Cmd>execute('normal! *')<CR><Cmd>lua require('hlslens').start()<CR>", opts)
  vim.keymap.set("n", "#", "<Cmd>execute('normal! #')<CR><Cmd>lua require('hlslens').start()<CR>", opts)
  vim.keymap.set("n", "g*", "<Cmd>execute('normal! g*')<CR><Cmd>lua require('hlslens').start()<CR>", opts)
  vim.keymap.set("n", "g#", "<Cmd>execute('normal! g#')<CR><Cmd>lua require('hlslens').start()<CR>", opts)
end
