-- ~/.config/nvim/lua/my/telescope/keymap.lua
-- telescope keybind
-- ===================================================================
local vim = vim
local builtin = require('telescope.builtin')
vim.keymap.set("n", "<leader>f.", "<cmd>Telescope resume<CR>", { desc = "Resume last Telescope" })
vim.keymap.set("n", "<leader>fp", "<cmd>Telescope yank_history<CR>", { desc = "Paste from yank history" })
vim.keymap.set("n", "<leader>fn", "<cmd>Telescope file_browser<CR>", { desc = "File Browser" })
vim.keymap.set("n", "<leader>fu", "<cmd>Telescope undo<CR>", { desc = "View Undo Tree" })
vim.keymap.set("n", "<leader>fa", "<cmd>Telescope live_grep_args live_grep_args<CR>", { desc = "Live grep with args" })
vim.keymap.set("n", "<leader>fb", "<cmd>GrepOpenBuffers<CR>" , { desc = "Grep open files only" })
vim.keymap.set("v", "<leader>fb", "<cmd>GrepOpenBuffersSelection<CR>", { desc = "Grep selection in open buffers" })
vim.keymap.set("v", "<leader>fg", "<cmd>LiveGrepVisualSelectionFast<CR>", { desc = "Live grep visual selection (fast)" })
vim.keymap.set("v", "<leader>fG", "<cmd>LiveGrepVisualSelectionFull<CR>", { desc = "Live grep visual selection (full)" })
vim.keymap.set("n", "<leader>ft", "<cmd>TelescopeSelectTab<CR>", { desc = "TAB Select" })
vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fc", builtin.current_buffer_fuzzy_find, { desc = "Current buffer fuzzy" })
vim.keymap.set("n", "<leader>fw", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fe", builtin.symbols, { desc = "external symbols" })
-- -------------------------------------------------------------------
-- find_files 隠しファイルや .gitignore 無視も含めた全探索
-- -------------------------------------------------------------------
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files (fast)" })
vim.keymap.set("n", "<leader>fF", function()
  builtin.find_files({
    hidden = true,
    no_ignore = true,
    follow = true,
    find_command = {
      "fd", "--type", "f", "--hidden", "--follow", "--no-ignore", "--exclude", ".git"
    }
  })
end, { desc = "Find all files (full scan)" })
-- -------------------------------------------------------------------
-- live_grep 隠しファイルや .gitignore 無視も含めた全探索
-- -------------------------------------------------------------------
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep (project)" })
vim.keymap.set("n", "<leader>fG", function()
  builtin.live_grep({
    additional_args = function()
      return { "--hidden", "--follow", "--no-ignore" }
    end
  })
end, { desc = "Live grep (full scan)" })
-- -------------------------------------------------------------------
-- grep_string カーソル下の単語でgrep
-- -------------------------------------------------------------------
vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>fS", function()
  builtin.grep_string({
    additional_args = function()
      return { "--hidden", "--follow", "--no-ignore" }
    end
  })
end, { desc = "Grep word under cursor (full scan)" })

