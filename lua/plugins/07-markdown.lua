-- lua/plugins/07-markdown.lua
return {
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && yarn install",
    ft = "markdown",
  },

  { "godlygeek/tabular" },

  {
    "preservim/vim-markdown",
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal = 0
      vim.g.vim_markdown_math = 1
      vim.g.vim_markdown_toc_autofit = 1
      vim.g.markdown_recommended_style = 0
      vim.g.vim_markdown_auto_insert_bullets = 0
    end,
  },

  { "mzlogin/vim-markdown-toc" },

  {
    "Kicamon/markdown-table-mode.nvim",
    config = function()
      require("markdown-table-mode").setup({
        filetype = { "markdown", "text", "scratch" },
        options = {
          insert = true,
          insert_leave = true,
          pad_separator_line = false,
          align_style = "default",
        },
      })
    end,
  },

  {
    "bullets-vim/bullets.vim",
    config = function()
      vim.g.bullets_enabled_file_types = {
        "markdown",
        "text",
        "gitcommit",
        "scratch",
        "typst",
      }
      vim.g.bullets_outline_levels = {
        "num",
        "num",
        "num",
        "num",
        "num",
        "num",
        "num",
        "std+",
      }
    end,
  },

  {
    "kaarmu/typst.vim",
    ft = "typst",
    config = function()
      vim.g.typst_pdf_viewer = "zathura"

      -- local typst_group = vim.api.nvim_create_augroup("TypstAutoWatch", { clear = true })
      --
      -- vim.api.nvim_create_autocmd("FileType", {
      --   group = typst_group,
      --   pattern = "typst",
      --   callback = function()
      --    vim.cmd("silent! TypstWatch")
      --   end,
      -- })
    end,
  },

  {
    "chomosuke/typst-preview.nvim",
    version = "1.*",
    ft = "typst",
    config = function()
      local typst_group = vim.api.nvim_create_augroup("TypstAutoWatch", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = typst_group,
        pattern = "typst",
        callback = function()
          vim.cmd("silent! TypstPreview")
        end,
      })
    end,
  },

  {
    "lervag/vimtex",
    init = function()
      vim.g["tex_flavor"] = "latex"
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_view_general_viewer = "zathura"
      -- vim.g.vimtex_view_general_options = "--synctex-forward @line:@col:@tex --reuse-instance @pdf"
      vim.g.vimtex_view_general_options = '-x "nvr +%{line} %{input}" --synctex-forward @line:0:@tex @pdf'
    end,
  },

  {
    "jakewvincent/texmagic.nvim",
    config = function()
      require("texmagic").setup({})
    end,
  },
}
