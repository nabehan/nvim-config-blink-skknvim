-- ~/.config/nvim/lua/my/cmp/keymap.lua
local vim = vim

-- -------------------------------------------------------------------
-- blink.cmp をトグルする
-- lua/my/cmp/blink.lua 側の enabled() が vim.g.my_blink_enabled を
-- 参照しているので、ここではそのフラグを反転させるだけでよい
-- -------------------------------------------------------------------
local function ToggleBlink()
  vim.g.my_blink_enabled = not vim.g.my_blink_enabled
  vim.notify("blink.cmp " .. (vim.g.my_blink_enabled and "enabled" or "disabled"))
end

-- ノーマルモード
vim.keymap.set("n", "<C-q>", ToggleBlink, { desc = "Toggle blink.cmp" })

-- インサートモード
vim.keymap.set("i", "<C-q>", ToggleBlink, { desc = "Toggle blink.cmp" })
