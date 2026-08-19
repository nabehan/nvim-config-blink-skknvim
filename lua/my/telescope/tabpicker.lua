-- ~/.config/nvim/lua/my/telescope/tabpicker.lua
local vim = vim
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {}

local function get_tab_buffers(tab)
  local wins = vim.api.nvim_tabpage_list_wins(tab)
  local bufs = {}
  local seen = {}
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    if not seen[buf] then
      table.insert(bufs, buf)
      seen[buf] = true
    end
  end
  return bufs
end

M.select_tab = function()
  local tabs = vim.api.nvim_list_tabpages()
  local entries = {}

  for _, tab in ipairs(tabs) do
    local bufs = get_tab_buffers(tab)
    local names = {}
    for i, buf in ipairs(bufs) do
      local name = vim.api.nvim_buf_get_name(buf)
      name = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]"
      if i <= 3 then
        table.insert(names, name)
      end
    end
    local extra = #bufs > 3 and string.format(" (+%d more)", #bufs - 3) or ""
    local display = string.format("Tab %d: %s%s",
      vim.api.nvim_tabpage_get_number(tab),
      table.concat(names, ", "),
      extra
    )
    table.insert(entries, {
      display = display,
      ordinal = display,
      tab = tab,
      preview_buf = bufs[1] -- 最初のバッファでプレビューする
    })
  end

  pickers.new({}, {
    prompt_title = "Select Tab",
    finder = finders.new_table {
      results = entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.ordinal,
        }
      end,
    },

  previewer = previewers.new_buffer_previewer {
    define_preview = function(self, entry)
      local buf = entry.value.preview_buf
      if buf and vim.api.nvim_buf_is_valid(buf) then
        -- -- filetype をコピーしてハイライト有効化
        -- local ft = vim.api.nvim_buf_get_option(buf, "filetype")
        -- vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", ft)
        -- filetype をコピーしてハイライト有効化 2026-06-20 Sat 02:07:45
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        vim.api.nvim_set_option_value("filetype", ft, { buf = self.state.bufnr })

        -- バッファ内容をコピー（行単位）
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
      else
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "[Invalid Buffer]" })
      end
    end,
  },

    sorter = conf.generic_sorter({}),
    attach_mappings = function(_, map)
      local function on_select(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if selection and selection.value and selection.value.tab then
          vim.cmd("tabnext " .. vim.api.nvim_tabpage_get_number(selection.value.tab))
        end
      end
      map("i", "<CR>", on_select)
      map("n", "<CR>", on_select)
      return true
    end,
  }):find()
end

return M
