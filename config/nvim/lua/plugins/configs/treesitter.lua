require("nvim-treesitter.configs").setup {
  ensure_installed = { "lua", "vim", "vimdoc", "tsx", "html", "css", "typescript", "javascript", "go", "rust" },

  highlight = {
    enable = true,
    use_languagetree = true,
  },
  indent = { enable = true },
}
