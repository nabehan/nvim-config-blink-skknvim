-- ~/.config/nvim/lua/my/markdown/keymap.lua
-- Markdown key Configure
-- ===================================================================
local vim = vim
-- Markdownプレビューを <leader>mp で開く
vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { noremap = true, silent = true })
-- markdownの目次生成 <leader>mg や更新 <leader>mu
vim.keymap.set('n', '<leader>mg', ':GenTocGFM<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>mu', ':UpdateToc<CR>', { noremap = true, silent = true })
-- ナンバー付きリストを再ナンバリング <leader>mr
vim.keymap.set('n', '<leader>mr', '<Plug>(bullets-renumber)', { noremap = false, silent = true })
vim.keymap.set('v', '<leader>mr', '<Plug>(bullets-renumber)', { noremap = false, silent = true })
-- 空行で挟まれたブロックを Markdown Table に変換 <leader>mt
vim.keymap.set('n', '<leader>mt', ':MarkdownTableBlock<CR>', { noremap = true, silent = true })
-- カーソル行とVisual選択行を箇条書きリストに変更 <leader>mb
vim.keymap.set('n', '<leader>mb', ':BulletizeLine<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>mB', ':BulletizeLineInstant<CR>', { noremap = true, silent = true })
vim.keymap.set('v', '<leader>mb', ':BulletizeRange<CR>', { noremap = true, silent = true })
vim.keymap.set('v', '<leader>mB', ':BulletizeRangeInstant<CR>', { noremap = true, silent = true })
-- カーソル行とVisual選択行を番号付きリストに変更 <leader>mn
vim.keymap.set('n', '<leader>mn', ':NumberizeLine<CR>', { noremap = true, silent = true })
vim.keymap.set('v', '<leader>mn', ':NumberizeRange<CR>', { noremap = true, silent = true })
-- カーソル行をチェックリストに変更(既存はトグル) <leader>mc
vim.keymap.set('n', '<leader>mc', ":CheckboxLine<CR>", { noremap = true, silent = true, })
-- Visual選択行をチェックリストに変更(既存は維持) <leader>mc
vim.keymap.set('v', '<leader>mc', ':CheckboxRange<CR>', { noremap = true, silent = true, })
-- カーソル行とVisual選択行を引用または引用の増段 <leader>m>
vim.keymap.set("n", "<leader>m>", ":QuoteLine<CR>", { noremap = true, silent = true, })
vim.keymap.set("v", "<leader>m>", ":QuoteRange<CR>", { noremap = true, silent = true })
-- カーソル行とVisual選択行の引用を減段または解除 <leader>m<
vim.keymap.set("n", "<leader>m<", ":UnquoteLine<CR>", { noremap = true, silent = true })
vim.keymap.set("v", "<leader>m<", ":UnquoteRange<CR>", { noremap = true, silent = true })
