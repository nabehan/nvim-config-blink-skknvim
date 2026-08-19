-- ~/.config/nvim/lua/my/utils/ranger.lua
-- toggleterm 経由で ranger を起動してファイル選択する
-- kitty + Wayland 環境では :! コマンドが動作しないため toggleterm を使用

local function ranger_chooser()
  local temp = vim.fn.tempname()

  local ok, Terminal = pcall(function()
    return require("toggleterm.terminal").Terminal
  end)

  if not ok then
    vim.notify("toggleterm が見つかりません", vim.log.levels.ERROR)
    return
  end

  local ranger = Terminal:new({
    cmd           = "ranger --choosefiles=" .. vim.fn.shellescape(temp),
    direction     = "float",
    close_on_exit = true,
    float_opts    = {
      border   = "single",
      winblend = 0,  -- ranger は透過なしの方が見やすい
    },
    on_exit = function()
      vim.schedule(function()
        if vim.fn.filereadable(temp) == 0 then return end
        local names = vim.fn.readfile(temp)
        if #names == 0 then return end
        vim.cmd("edit " .. vim.fn.fnameescape(names[1]))
        for i = 2, #names do
          vim.cmd("argadd " .. vim.fn.fnameescape(names[i]))
        end
      end)
    end,
  })

  ranger:toggle()
end

vim.api.nvim_create_user_command("RangerChooser", ranger_chooser, {})
vim.keymap.set("n", "<leader>r", "<cmd>RangerChooser<CR>", { noremap = true, silent = true })
