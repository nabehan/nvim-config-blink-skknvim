-- ~/.config/nvim/lua/my/markdown/table.lua
local vim = vim
-- ===========================================================================
-- 共通ユーティリティ関数: 空行で囲まれた範囲を返す
-- ===========================================================================
local function get_block_range_by_blank_lines()
  local cursor_line = vim.fn.line(".")
  local total_lines = vim.fn.line("$")
  local start_line = cursor_line
  while start_line > 1 and vim.fn.getline(start_line - 1):match("^%s*$") == nil do
    start_line = start_line - 1
  end
  local end_line = cursor_line
  while end_line < total_lines and vim.fn.getline(end_line + 1):match("^%s*$") == nil do
    end_line = end_line + 1
  end
  return start_line, end_line
end
-- ===========================================================================
-- カーソル行を含む空行で囲まれた範囲を対象に
-- 特定のセパレーター記号を指定して Markdown テーブルに変換
-- ===========================================================================
local function ConvertDelimitedBlockToMarkdownTable()
  local bufnr = vim.api.nvim_get_current_buf()   -- 明示的に取得
  -- 適用範囲を設定する
  local start_line, end_line = get_block_range_by_blank_lines()
  local lines_to_process = vim.fn.getline(start_line, end_line)
  -- セパレーター選択肢（表示名・キー・パターン）
  local choices = {
    { label = "(s)pace",       key = "s", pattern = "%s+" },     -- Lua regex: 1回以上の空白
    { label = "(t)ab",         key = "t", pattern = "\t+" },     -- Lua regex: 1回以上のタブ
    { label = "',' comma",     key = ",", pattern = "," },
    { label = "';' semicolon", key = ";", pattern = ";" },
    { label = "':' colon",     key = ":", pattern = ":" },
    { label = "'|' pipe",      key = "|", pattern = "%|" },     -- Lua regex: | は特殊文字なのでエスケープ
    { label = "'&' ampersand", key = "&", pattern = "&" },
    { label = "'#' hash",      key = "#", pattern = "#" },
  }
  -- セパレーター選択 UI を表示
  vim.ui.select(choices, {
    prompt = "セパレーターを選んでください",
    format_item = function(item) return item.label end,
  }, function(choice)
    if not choice then
      vim.notify("キャンセルされました", vim.log.levels.WARN)
      return
    end
    -- セパレーターの設定と変数の初期化
    local sep_lua_pattern = choice.pattern
    local all_rows_cols = {}
    local max_cols = 0
    -- 行をセルへ分割
    for _, line_content in ipairs(lines_to_process) do
      -- vim.split を使用して行を分割。
      -- trimempty = false にして空のセルも保持する（例: "a,,b" -> {"a", "", "b"}）
      local cols_in_line = vim.split(line_content, sep_lua_pattern, { trimempty = false })
      local trimmed_cols = {}
      for _, col_text in ipairs(cols_in_line) do
        table.insert(trimmed_cols, vim.trim(col_text))         -- 各セルをトリム
      end
      table.insert(all_rows_cols, trimmed_cols)
      if #trimmed_cols > max_cols then
        max_cols = #trimmed_cols
      end
    end
    -- テーブル行に変換
    local table_output_lines = {}
    for i, row_data in ipairs(all_rows_cols) do
      local table_row_str = "|"
      for j = 1, max_cols do
        table_row_str = table_row_str .. " " .. (row_data[j] or "") .. " |"         -- 不足セルは空に
      end
      table.insert(table_output_lines, table_row_str)
      -- ヘッダ直後に罫線追加
      if i == 1 then       -- ヘッダー行の場合、セパレーター行を追加
        local header_sep_str = "|"
        for _ = 1, max_cols do
          header_sep_str = header_sep_str .. " --- |"
        end
        table.insert(table_output_lines, 2, header_sep_str)         -- 2番目に挿入
      end
    end
    -- 置換実行
    vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, table_output_lines)
    -- markdown-table-mode が有効なら整形
    if vim.fn.exists(':TableFormat') == 2 then
      vim.cmd("TableFormat")
        -- 行頭の空白を除去
        for lnum = start_line, start_line + #table_output_lines - 1 do
          local line = vim.fn.getline(lnum)
          local cleaned = line:gsub("^%s+", "")
          vim.fn.setline(lnum, cleaned)
        end
    else
      vim.cmd("redraw!")       -- メッセージ行を強制的に更新
      vim.notify("<Esc>:Mtm<CR> 'Markdown table mode ON' ⇒ A|<Esc> で自動整形")
    end
  end)
end

-- ユーザーコマンドとして登録
vim.api.nvim_create_user_command(
  "MarkdownTableBlock",
  ConvertDelimitedBlockToMarkdownTable,
  { desc = "ブロックをMarkdown Tableに変換" }
)

-- ===========================================================================
-- TabelFormat の改造 行頭の空白を削除する
-- ===========================================================================
vim.api.nvim_create_user_command("MyTableFormat", function()
  -- 適用範囲を設定する
  local start_line, end_line = get_block_range_by_blank_lines()
  -- 対象範囲を '<,'> に設定して TableFormat 実行
  vim.cmd(string.format("%d,%dTableFormat", start_line, end_line))
  -- 行頭の空白を除去（| で始まる行のみ対象）
  for lnum = start_line, end_line do
    local line = vim.fn.getline(lnum)
    if line:match("^%s*|") then
      local trimmed = line:gsub("^%s*", "")  -- 行頭空白を削除
      vim.fn.setline(lnum, trimmed)
    end
  end
end, {
  desc = "TableFormat (空行で囲まれた範囲) + 行頭空白削除",
})
