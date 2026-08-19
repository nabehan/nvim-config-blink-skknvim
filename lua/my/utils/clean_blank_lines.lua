-- ~/.config/nvim/lua/my/utils/clean_blank_lines.lua
local function clean_blank_lines()
  local function is_blank(line)
    -- 半角・全角空白・タブのみの行を空行とみなす
    return line:match("^[%s　]*$") ~= nil
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local res = {}

  for i, line in ipairs(lines) do
    if is_blank(line) then
      local prev = res[#res]
      local next_line = lines[i + 1]

      -- 単独空行（前後が非空）を削除
      if prev ~= nil and not is_blank(prev)
        and next_line ~= nil and not is_blank(next_line) then
        -- skip
      else
        -- 連続空行は1行にまとめる
        if #res == 0 or not is_blank(res[#res]) then
        --  if #res == 0 and not is_blank(res[#res]) then
          table.insert(res, "")
        end
      end
    else
      table.insert(res, line)
    end
  end

  -- 最終行の空行を削除
  while #res > 0 and is_blank(res[#res]) do
    table.remove(res)
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, res)
end

-- キーマップ
vim.keymap.set("n", "<leader>cl", clean_blank_lines)
