return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup {
      ensure_installed = { "lua", "vim", "vimdoc", "tsx", "html", "css", "typescript", "javascript", "go", "rust", "python" },

      highlight = {
        enable = true,
        use_languagetree = true,
      },
      indent = { enable = true },
    }
  end,
}
