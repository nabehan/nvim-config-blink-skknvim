--  ~/.config/nvim/lua/my/markdown/list.lua
-- ===========================================================================
-- Markdown 箇条書き整形用ユーザーコマンド定義集
-- - bullets.vim との併用前提（:RenumberList など）
-- ===========================================================================
-- 共通関数: チェックボックス・番号・記号を除去して本文を抽出
-- bullets.vim チェックボックス、番号付きリスト、記号に対応
-- -------------------------------------------------------------------
local vim = vim
local function sanitize_line_body(line)
    local shiftwidth = vim.opt.shiftwidth:get()
    -- インデントと本文に分割
    local indent, body = line:match("^(%s*)(.*)$")
    -- 引用の処理: 先頭から ">" を数える
    local quote_prefix = body:match("^(>+)")
    if quote_prefix then
      local quote_level = #quote_prefix
      if quote_level == 1 then
        -- "> " を除去
        body = body:gsub("^> ?", "")
      else
        -- shiftwidth × (level - 1) のスペースを indent に追加
        indent = indent .. string.rep(" ", shiftwidth * (quote_level - 1))
        body = body:gsub("^>+ ?", "")
      end
    end
    -- チェックボックス・箇条書き・番号付きリストを除去
    body = body
        :gsub("^%s*[-*+]?%s*%[[ xXoO%.]%]%s*", "")   -- bullets.vimのチェックボックス
        :gsub("^[%-%+%*]%s*", "")                    -- 箇条書き（- + *）
        :gsub("^%d+%.%s*", "")                       -- 番号付きリスト（1. など）
    return indent, body
  end
  -- -------------------------------------------------------------------
  -- 箇条書き：選択したリスト記号で変換する
  -- もとのインデントはネストに反映される
  -- -------------------------------------------------------------------
  -- 共通関数：ユーザーにカスタム記号を入力させる関数
  local function ask_for_custom_symbol(callback)
    -- 入力プロンプトを表示
    vim.ui.input({ prompt = "Enter a custom bullet symbol: " }, function(symbol)
      -- 入力された記号が1文字かチェック
      if symbol and #symbol == 1 then
        callback(symbol)  -- コールバックで入力された記号を渡す
      else
        print("Invalid input. Please enter a single character.")  -- 無効な入力の場合は警告
      end
    end)
  end
  -- -------------------------------------------------------------------
  -- 共通関数：リスト記号の選択と入力
  local function choose_bullet_symbol(callback)
    -- 選択肢を定義、説明文（desc）も含める
    local symbols = {
      { label = "-", pattern = "-", desc = "Bullet Point in typst" },  -- `-` 記号
      { label = "+", pattern = "+", desc = "Numbered Point in typst" },  -- `+` 記号
      { label = "*", pattern = "*", desc = "Only Markdown" },  -- `*` 記号
      { label = "C", pattern = "OtherSymbol", desc = "Custom Symbol" }  -- カスタム記号の入力
    }
    -- `vim.ui.select` を使ってリスト記号を選択させる
    vim.ui.select(symbols, {
      prompt = 'Choose Bullet Symbol',   -- プロンプトメッセージ
      format_item = function(item)       -- アイテムの表示をカスタマイズ
      return string.format("[%s] %s", item.label, item.desc or "")
      end
    }, function(choice)
      -- ユーザーが選択をキャンセルした場合
      if not choice then
        vim.notify("No symbol chosen, operation canceled.", vim.log.levels.WARN)
        return
      end
      -- "Other symbol" が選ばれた場合はカスタム記号の入力を求める
      if choice.pattern == "OtherSymbol" then
        ask_for_custom_symbol(function(custom_symbol)
          callback(custom_symbol)   -- 入力された記号をコールバックで返す
        end)
      else
        callback(choice.pattern)  -- 選ばれた記号をコールバックで返す
      end
    end)
  end
  -- -------------------------------------------------------------------
  -- 共通関数：選択範囲について箇条書き処理を繰り返す
  local function apply_to_range_lines(opts, transform_fn)
    local start_row = opts.line1 - 1  -- 選択範囲の開始行
    local end_row = opts.line2        -- 選択範囲の終了行
    -- 選択範囲の行を取得
    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
    for i, line in ipairs(lines) do
      lines[i] = transform_fn(line, i)
    end
    vim.api.nvim_buf_set_lines(0, start_row, end_row, false, lines)
  end
  -- -------------------------------------------------------------------
  -- カーソル行を選択したリスト記号で箇条書きに変換するコマンド
  vim.api.nvim_create_user_command("BulletizeLine", function()
    -- リスト記号を選択させて、カーソル行を変換
    choose_bullet_symbol(function(symbol)
      local row = vim.api.nvim_win_get_cursor(0)[1]  -- 現在のカーソル位置（行）
      local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]  -- カーソル行のテキスト
      local indent, body = sanitize_line_body(line)  -- 行のインデント部分と本文を分ける
      local new_line = indent .. symbol .. " " .. body  -- 新しい行を作成
      vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })  -- 行を更新
    end)
  end, { desc = "カーソル行を選んだ記号で箇条書きに変換" })
  -- -------------------------------------------------------------------
  -- 選択範囲の各行を選択したリスト記号で箇条書きに変換するコマンド
  vim.api.nvim_create_user_command("BulletizeRange", function(opts)
    -- リスト記号を選択させて、選択範囲を変換
    choose_bullet_symbol(function(symbol)
      apply_to_range_lines(opts, function(line)
        local indent, body = sanitize_line_body(line)
        return indent .. symbol .. " " .. body
      end)
    end)
  end, {
    range = true,  -- 選択範囲を指定するオプション
    desc = "選択範囲を選んだ記号で箇条書きに変換"
  })
  -- -------------------------------------------------------------------
  -- Normal-mode: カーソル行を "- " 箇条書きに変換
  vim.api.nvim_create_user_command("BulletizeLineInstant", function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    local indent, body = sanitize_line_body(line)
    local new_line = indent .. "- " .. body
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
  end, { desc = "カーソル行を - 箇条書きに変換" })
  -- -------------------------------------------------------------------
  -- Visual-mode: 選択範囲の各行を "- " 箇条書きに変換
  vim.api.nvim_create_user_command("BulletizeRangeInstant", function(opts)
    apply_to_range_lines(opts, function(line)
      local indent, body = sanitize_line_body(line)
      return indent .. "- " .. body
    end)
  end, { range = true, desc = "選択範囲を - 箇条書きに変換" })
  -- -------------------------------------------------------------------
  -- Normal-mode: カーソル行を "1. " 番号付きリストに変換
  -- bullets.vim の RenumberList を使って連番化
  -- -------------------------------------------------------------------
  vim.api.nvim_create_user_command("NumberizeLine", function()
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1   -- 0-indexed
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    local indent, body = sanitize_line_body(line)
    local new_line = indent .. "1. " .. body
    vim.api.nvim_buf_set_lines(0, row, row + 1, false, { new_line })
    -- bullets.vim の :RenumberList で連番調整（非同期実行）
    vim.schedule(function()
      vim.cmd("silent! RenumberList")
    end)
  end, { desc = "カーソル行を番号付きリストに変換" })
  -- -------------------------------------------------------------------
  -- Visual-mode: 選択範囲の行を i. 番号付きリストに変換
  -- bullets.vim の RenumberList により全体を整形
  -- -------------------------------------------------------------------
  vim.api.nvim_create_user_command("NumberizeRange", function(opts)
    apply_to_range_lines(opts, function(line, i)
      local indent, body = sanitize_line_body(line)
      return indent .. i .. ". " .. body
    end)
    -- bullets.vim の :RenumberList を使って連番調整
    vim.schedule(function()
      vim.cmd("silent! RenumberList")
    end)
  end, {
    range = true,
    desc = "選択範囲を番号付きリストに変換"
  })
  -- -------------------------------------------------------------------
  -- markdown:normal-mode;チェックボックストグル/変更 bullets.vim と連携
  -- カーソル行がチェックボックスならトグル、それ以外は"+ [ ] "に変換
  -- -------------------------------------------------------------------
  vim.api.nvim_create_user_command("CheckboxLine", function()
    -- 現在行を取得
    local line = vim.api.nvim_get_current_line()
    -- すでにチェックボックスがある場合は bullets.vim でトグル
    if line:match("^%s*[-+*]%s+%[[ oOxX%.]%]") then
      vim.cmd("ToggleCheckbox")
      return
    end
    -- インデント + チェックボックス + 本文を構成
    local indent, body = sanitize_line_body(line)
    local new_line = indent .. "+ [ ] " .. body
    -- 行を更新
    vim.api.nvim_set_current_line(new_line)
  end, { desc = "行をチェックリストに変換(既存はトグル)" })
  -- -------------------------------------------------------------------
  -- markdown:visual-mode;チェックボック変更
  -- チェックボックスならスキップ、それ以外は"+ [ ] "に変換
  -- -------------------------------------------------------------------
  vim.api.nvim_create_user_command("CheckboxRange", function(opts)
    apply_to_range_lines(opts, function(line)
      if line:match("^%s*[-+*]%s+%[[ ooxx%.]%]") then
        return line   -- チェックボックスが既にある行はスキップ
      else
        local indent, body = sanitize_line_body(line)
        return indent .. "+ [ ] " .. body
      end
    end)
  end, {
    range = true,
    desc = "選択範囲をチェックリストに変換（既存は維持）",
  })
  -- -------------------------------------------------------------------
  -- Normar mode:カーソル行を引用にする(既存の階層を深める)
  -- -------------------------------------------------------------------
  local function quote_line()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    -- 行頭のインデントと本文に分割
    local indent, body = line:match("^(%s*)(.*)$")
    -- すでに > がある場合 → さらに > を追加
    if body:match("^>") then
      vim.fn.setline(row, indent .. ">" .. body)
    else
      -- vim.fn.setline(row, indent .. "> " .. body)
      vim.fn.setline(row, "> " .. indent .. body)
    end
  end
  vim.api.nvim_create_user_command("QuoteLine", quote_line,
    { desc = "現在行のMarkdown引用を増段" })
  -- -------------------------------------------------------------------
  -- Normal mode: カーソル行のMarkdown引用を1段解除
  -- -------------------------------------------------------------------
  local function unquote_line()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local line = vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1]
    -- インデントと本文に分離
    local indent, body = line:match("^(%s*)(.*)$")
    -- 引用解除処理
    if body:match("^>+") then
      -- ">>>" のように複数段ある場合 → 1つ削除
      body = body:gsub("^>%s?", "", 1)
      vim.fn.setline(row, indent .. body)
    end
  end
  vim.api.nvim_create_user_command("UnquoteLine", unquote_line,
    { desc = "現在行のMarkdown引用を減段" })
  -- -------------------------------------------------------------------
  -- Visual mode: 選択範囲を引用にする(既存の階層を深める)
  -- -------------------------------------------------------------------
  vim.api.nvim_create_user_command("QuoteRange", function(opts)
    local start_row = opts.line1 - 1
    local end_row = opts.line2
    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
    for i, line in ipairs(lines) do
      local indent, body = line:match("^(%s*)(.*)$")
      if body:match("^>") then
        lines[i] = indent .. ">" .. body
      else
        lines[i] = "> " .. indent .. body
      end
    end
    vim.api.nvim_buf_set_lines(0, start_row, end_row, false, lines)
  end, {
    range = true,
    desc = "選択範囲のMarkdown引用を増段"
  })
  -- -------------------------------------------------------------------
  -- Visual mode: 選択範囲のMarkdown引用を1段解除
  -- -------------------------------------------------------------------
  vim.api.nvim_create_user_command("UnquoteRange", function(opts)
    local start_row = opts.line1 - 1
    local end_row = opts.line2
    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row, false)
    for i, line in ipairs(lines) do
      local indent, body = line:match("^(%s*)(.*)$")
      if body:match("^>+") then
        body = body:gsub("^>%s?", "", 1)
        lines[i] = indent .. body
      end
    end
    vim.api.nvim_buf_set_lines(0, start_row, end_row, false, lines)
  end, {
    range = true,
    desc = "選択範囲のMarkdown引用を1つ減段"
  })

