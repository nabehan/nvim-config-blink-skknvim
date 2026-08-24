-- skk.nvim / nvim-autopairs 診断用の一時スクリプト
--
-- 使い方:
--   1. nvim-skk（NVIM_APPNAME=nvim-blink-skknvim）を起動
--   2. :lua dofile(vim.fn.expand("~/onkey_debug.lua"))
--      （あらかじめこのファイルをホームディレクトリ等に置いておく）
--   3. ひらがな入力モードで "uu" と打ち、続けて " を1回打鍵する
--      （"うう_う のような不具合を再現する操作）
--   4. :lua print(table.concat(_G.__skk_debug_log, "\n"))
--      でログを表示するか、
--      :lua vim.fn.writefile(_G.__skk_debug_log, "/tmp/skk_onkey_debug.log")
--      でファイルに書き出す
--   5. ログの内容を共有してください
--
-- このスクリプトは vim.on_key() に「もう一つの」観測用リスナーを
-- 追加で登録するだけで、skk.nvim 自体の動作には一切影響しません
-- （skk.nvim側のリスナーとは独立に、同じキーストリームを横から
-- 観測するだけです）。終了したい場合は Neovim を再起動してください。

_G.__skk_debug_log = {}

local function hex(s)
  local out = {}
  for i = 1, #s do
    table.insert(out, string.format("%02x", s:byte(i)))
  end
  return table.concat(out, ",")
end

vim.on_key(function(key, typed)
  local mode = vim.api.nvim_get_mode().mode
  local line = table.concat({
    os.clock(),
    "mode=" .. mode,
    "key=[" .. hex(key) .. "]",
    "typed=[" .. hex(typed or "") .. "]",
  }, " ")
  table.insert(_G.__skk_debug_log, line)
  -- ログが無限に伸びないよう上限を設ける
  if #_G.__skk_debug_log > 500 then
    table.remove(_G.__skk_debug_log, 1)
  end
end)

print(
  "skk.nvim on_key デバッグロガーを登録しました。再現後 :lua print(table.concat(_G.__skk_debug_log, '\\n')) を実行してください。"
)
