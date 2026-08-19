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

  { "vim-skk/skkeleton" },
  { "delphinus/skkeleton_indicator.nvim" },

  -- 補完ソースとしての skkeleton は blink.compat 経由の cmp-skkeleton ではなく
  -- lua/my/cmp/skkeleton_source.lua のネイティブ blink.cmp ソースを使う
  -- （06-lsp.lua の blink.cmp 設定を参照。追加のプラグインは不要）。
}
