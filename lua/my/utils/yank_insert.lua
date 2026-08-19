-- ~/.config/nvim/lua/my/utils/yank_insert.lua

local M = {}

function M.insert_yank()
  local telescope = require("telescope")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local function feedkeys(str, mode)
    local keys = vim.api.nvim_replace_termcodes(str, true, false, true)
    vim.api.nvim_feedkeys(keys, mode or "n", false)
  end

  telescope.extensions.yank_history.yank_history({
    attach_mappings = function(_, _)
      actions.select_default:replace(function(prompt_bufnr)
        local entry = action_state.get_selected_entry()

        vim.schedule(function()
          actions.close(prompt_bufnr)
          if not entry or not entry.content then
            return
          end

          local text = type(entry.content) == "table"
            and table.concat(entry.content, "\n")
            or tostring(entry.content)

          local mode = vim.fn.mode()

          if mode == "i" then
            feedkeys("<Esc>a" .. text, "n")
          elseif mode == "c" then
            -- 正しいコマンドラインタイプを保持して insert
            local cmd_type = vim.fn.getcmdtype()
            vim.api.nvim_feedkeys("", "c", false) -- clear
            feedkeys(cmd_type .. text, "c")
          elseif mode == "n" then
            local cursor = vim.api.nvim_win_get_cursor(0)
            feedkeys("i" .. text .. "<Esc>", "n")
            vim.api.nvim_win_set_cursor(0, cursor)
          elseif mode == "v" or mode == "V" or mode == "\22" then
            -- 選択範囲を削除して挿入（gvc = delete and insert mode）
            feedkeys("gvc" .. text .. "<Esc>", "n")
          end
        end)
      end)
      return true
    end,
  })
end

return M