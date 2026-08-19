-- ~/.config/nvim/lua/my/cmp/luasnip_source.lua
-- blink.cmp ネイティブソース: LuaSnip のスニペットをトリガー文字列として
-- 補完候補に出す。
--
-- 【なぜ blink.cmp 組み込みの snippets(preset="luasnip") を使わないか】
-- 組み込みソース (lua/blink/cmp/sources/snippets/luasnip.lua) は確定時に
-- 自前で luasnip.snip_expand() を呼んで展開まで行うが、このファイルの
-- 冒頭には
--   "FIXME: Some annotations are based on an unmerged PR:
--    https://github.com/L3MON4D3/LuaSnip/pull/1396"
-- と明記されている、まだ本家にマージされていない LuaSnip の変更を前提に
-- した実験的な実装。実際にこれを使うと、日付を入力して二重目のノード
-- （曜日）へ <Tab> でジャンプしようとした際に LuaSnip 内部のセッション
-- 追跡が壊れ、"E565: Not allowed to change text or change window" が
-- 発生する不具合が確認された。
--
-- そこで、このソースは確定時に "トリガー文字列（例: "dw"）をただの
-- プレーンテキストとして挿入するだけ" にとどめ、実際のスニペット展開・
-- ジャンプは lua/my/cmp/blink.lua の <Tab> キーマップが
-- luasnip.expand_or_jump() を呼ぶことで行う。
-- これは旧 nvim-cmp + saadparwaiz1/cmp_luasnip の組み合わせと全く同じ、
-- 安定版の LuaSnip 公開 API だけに依存する枯れた方式。
--
-- execute() をあえて定義しない: blink.cmp は「ソースが execute を
-- 定義していなければ default_implementation（＝素の textEdit 適用）だけ
-- 行う」仕様なので、これだけで「プレーンテキスト挿入するだけ」を実現できる
-- (lua/blink/cmp/sources/lib/provider/init.lua の source:execute を参照)。

---@module 'blink.cmp'
---@class blink.cmp.Source
local source = {}
source.__index = source

function source.new()
  return setmetatable({}, source)
end

function source:enabled()
  return (pcall(require, "luasnip"))
end

function source:get_trigger_characters()
  return {}
end

function source:get_completions(_, callback)
  local ok, luasnip = pcall(require, "luasnip")
  if not ok then
    callback({ items = {}, is_incomplete_forward = false, is_incomplete_backward = false })
    return function() end
  end

  local kind_snippet = require("blink.cmp.types").CompletionItemKind.Snippet
  local items = {}
  local seen = {}

  for _, ft in ipairs(luasnip.get_snippet_filetypes()) do
    local snippets = luasnip.get_snippets(ft, { type = "snippets" }) or {}
    for _, snip in ipairs(snippets) do
      local trigger = snip.trigger
      if trigger and not seen[trigger] then
        seen[trigger] = true

        local description = nil
        if snip.dscr and snip.dscr[1] then
          description = table.concat(snip.dscr, " ")
        end

        table.insert(items, {
          label = trigger,
          insertText = trigger,
          kind = kind_snippet,
          labelDetails = description and { description = description } or nil,
        })
      end
    end
  end

  callback({
    items = items,
    is_incomplete_forward = false,
    is_incomplete_backward = false,
  })

  return function() end
end

return source
