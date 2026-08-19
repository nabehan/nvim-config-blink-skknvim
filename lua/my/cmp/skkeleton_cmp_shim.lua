-- ~/.config/nvim/lua/my/cmp/skkeleton_cmp_shim.lua
--
-- 【背景】
-- vim-skk/skkeleton の autoload/skkeleton.vim にある s:complete_info() は、
-- 現在どの補完エンジンが表示されているかを次の順で判定している:
--
--   1. pum.vim (pum#visible())
--   2. nvim-cmp ("cmp") -- package.loaded["cmp"].visible() が true かどうか
--   3. それ以外は "native"（Vim組み込みの complete_info(['pum_visible'])）
--
-- blink.cmp は独自のフローティングウィンドウで補完メニューを描画するため、
-- Vim組み込みの pumvisible() は常に false になる。かつ nvim-cmp 自体を
-- アンインストールしているので package.loaded["cmp"] も存在しない。
-- 結果として skkeleton は常に "native" と誤判定し、eggLikeNewline による
-- <CR> 確定処理（denops/skkeleton/main.ts の handleCompleteKey）が
-- 一度も発火しない。これが「skkeleton・buffer・rg 等どのソースの候補を
-- 選んでも <CR> で確定できない」不具合の直接の原因だった。
--
-- 【対処】
-- blink.compat の impersonate_nvim_cmp が用意する「偽の cmp モジュール」
-- （blink.compat/lua/cmp/init.lua、register_source 等は実装済みだが
-- visible()/confirm() は無い）に、skkeleton が呼び出す2メソッドだけを
-- 追加で生やす。テーブルを丸ごと置き換えるのではなく既存テーブルに
-- フィールドを追加するだけなので、calc/emoji/spell/latex_symbols/rg の
-- ための blink.compat 本来の cmp シムとも衝突しない。

local M = {}

function M.setup()
  local ok, cmp_shim = pcall(require, "cmp")
  if not ok then
    -- blink.compat がまだロードされていない（通常は 06-lsp.lua で
    -- lazy=true を外しているので起こらないはずだが、念のため）
    vim.notify_once(
      "skkeleton_cmp_shim: require('cmp') に失敗しました。blink.compat が読み込まれているか確認してください。",
      vim.log.levels.WARN
    )
    return
  end

  cmp_shim.visible = function()
    local blink_ok, blink = pcall(require, "blink.cmp")
    return blink_ok and blink.is_menu_visible() == true
  end

  cmp_shim.get_active_entry = function()
    local list_ok, list = pcall(require, "blink.cmp.completion.list")
    if not list_ok then
      return nil
    end
    return list.get_selected_item()
  end

  -- skkeleton は <Cmd>lua require('cmp').confirm({select = true})<CR> を
  -- 直接実行するので、引数の中身に関わらず blink.cmp 側の accept を呼べばよい
  cmp_shim.confirm = function(_)
    local blink_ok, blink = pcall(require, "blink.cmp")
    if not blink_ok then
      return
    end
    if not blink.accept() then
      blink.accept({ force = true })
    end
  end
end

return M
