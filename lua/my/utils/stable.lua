-- ~/.config/nvim/lua/my/utils/stable.lua
local vim = vim
-- -------------------------------------------------------------------
-- TAB区切りで列揃えを行う関数
-- -------------------------------------------------------------------
local function align_tab_columns()
  vim.cmd([[%!column -s $'\t' -t]])   -- TAB区切りで整列
end
-- AlignTabColumns として登録:normal mode file全体を処理
vim.api.nvim_create_user_command("AlignTabColumns", align_tab_columns, {})
vim.keymap.set('n', '<leader>at', ':AlignTabColumns<CR><ESC>',
  { noremap = true, desc = "TAB区切りでfile全体を整形" }
)
-- -------------------------------------------------------------------
-- 連続したスペースを単一の区切りとして列揃えを行う関数
-- -------------------------------------------------------------------
local function align_space_columns()
  vim.cmd([[%!column -t]])
end
-- AlignSpaceColums として登録:normal mode file全体を処理
vim.api.nvim_create_user_command("AlignSpaceColumns", align_space_columns, {})
vim.keymap.set('n', '<leader>as', ':AlignSpaceColumns<CR><ESC>',
  { noremap = true, desc = "Space区切りでfile全体を整形" }
)
