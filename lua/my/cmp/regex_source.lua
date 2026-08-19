-- ~/.config/nvim/lua/my/cmp/regex_source.lua
-- blink.cmp ネイティブソース: Vim/Neovim の正規表現補完を提供（検索・置換用）
-- (旧 nvim-cmp 版からの書き換え。:h blink.cmp source boilerplate 準拠)

---@module 'blink.cmp'
---@class blink.cmp.Source
local source = {}

-- 補完候補一覧（正規表現キーワードを網羅的に）
local regex_keywords = {
  -- 基本記号
  ".", "*", "+", "?", "\\|", "\\(", "\\)",

  -- 拡張表現
  "\\v", "\\m", "\\M", "\\V",

  -- 位置指定
  "^", "$", "\\zs", "\\ze",

  -- 文字クラス
  "\\d", "\\D", "\\s", "\\S", "\\w", "\\W", "[a-z]", "[^a-z]",

  -- 数量指定子
  "\\{n}", "\\{n,}", "\\{,m}", "\\{n,m}",

  -- 特殊エスケープ
  "\\n", "\\t", "\\r", "\\e", "\\b",

  -- グループ参照
  "\\1", "\\2", "\\3", "\\4", "\\5", "\\6", "\\7", "\\8", "\\9",
}

local descriptions = {
  ["."] = "任意の1文字にマッチ",
  ["*"] = "直前の文字の0回以上の繰り返し",
  ["+"] = "直前の文字の1回以上の繰り返し",
  ["?"] = "直前の文字の0または1回の繰り返し",
  ["\\|"] = "OR: 左右いずれかにマッチ",
  ["\\("] = "グループの開始",
  ["\\)"] = "グループの終了",
  ["\\v"] = "very magic: 特殊文字を簡略化",
  ["\\m"] = "magic: デフォルトモード",
  ["\\M"] = "nomagic: 特殊文字を減らす",
  ["\\V"] = "very nomagic: 全てリテラル扱い",
  ["^"] = "行頭にマッチ",
  ["$"] = "行末にマッチ",
  ["\\zs"] = "ここからマッチ対象開始",
  ["\\ze"] = "ここでマッチ対象終了",
  ["\\d"] = "数字 [0-9]",
  ["\\D"] = "非数字",
  ["\\s"] = "空白文字 (スペース、タブなど)",
  ["\\S"] = "非空白文字",
  ["\\w"] = "単語構成文字（英数字＋_）",
  ["\\W"] = "非単語文字",
  ["[a-z]"] = "小文字a〜zのいずれか",
  ["[^a-z]"] = "小文字a〜z以外の文字",
  ["\\{n}"] = "n回の繰り返し",
  ["\\{n,}"] = "n回以上の繰り返し",
  ["\\{,m}"] = "m回以下の繰り返し",
  ["\\{n,m}"] = "n〜m回の繰り返し",
  ["\\n"] = "改行",
  ["\\t"] = "タブ文字",
  ["\\r"] = "キャリッジリターン",
  ["\\e"] = "エスケープ文字",
  ["\\b"] = "バックスペース",
  ["\\1"] = "第1キャプチャグループを参照",
  ["\\2"] = "第2キャプチャグループを参照",
  ["\\3"] = "第3キャプチャグループを参照",
  ["\\4"] = "第4キャプチャグループを参照",
  ["\\5"] = "第5キャプチャグループを参照",
  ["\\6"] = "第6キャプチャグループを参照",
  ["\\7"] = "第7キャプチャグループを参照",
  ["\\8"] = "第8キャプチャグループを参照",
  ["\\9"] = "第9キャプチャグループを参照",
}

function source.new(opts)
  local self = setmetatable({}, { __index = source })
  self.opts = opts or {}
  return self
end

-- '\', '(', '[', '^', '$' の直後でも補完候補を出す
function source:get_trigger_characters()
  return { "\\", "(", "[", "^", "$" }
end

function source:get_completions(_, callback)
  local items = {}
  for _, kw in ipairs(regex_keywords) do
    table.insert(items, {
      label = kw,
      insertText = kw,
      kind = require("blink.cmp.types").CompletionItemKind.Keyword,
      documentation = {
        kind = "plaintext",
        value = descriptions[kw] or "",
      },
    })
  end

  callback({
    items = items,
    is_incomplete_backward = false,
    is_incomplete_forward = false,
  })

  return function() end
end

return source
