-- lua/plugins/09-notify-skk.lua
-- Noice / notify / SKK
return {
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("notify")
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
      })
    end,
  },

  -- SKK日本語入力（denops非依存、Lua実装）。
  -- setup() は lua/my/utils/skk.lua で行う（init.lua から blink.cmp の
  -- setup() 完了後に require される。詳細はそちらのコメント参照）。
  -- blink.cmp ネイティブソース（skk.blink_source）も本体に同梱のため、
  -- skkeleton_indicator.nvim・skkeleton_cmp_shim 相当の追加プラグイン/
  -- ブリッジコードは不要。
  { "nabehan/skk.nvim" },
}
