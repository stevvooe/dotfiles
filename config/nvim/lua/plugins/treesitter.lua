return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local languages = {
      "bash",
      "c",
      "cpp",
      "go",
      "javascript",
      "lua",
      "python",
      "rust",
      "tsx",
      "typescript",
      "vim",
    }

    local ts = require("nvim-treesitter")
    local homebrew_bins = { "/opt/homebrew/bin", "/usr/local/bin" }

    for _, bin in ipairs(homebrew_bins) do
      if vim.fn.isdirectory(bin) == 1 and not vim.env.PATH:match(vim.pesc(bin)) then
        vim.env.PATH = bin .. ":" .. vim.env.PATH
      end
    end

    if type(ts.setup) == "function" then
      ts.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
    end

    if type(ts.install) == "function" then
      ts.install(languages)
    else
      require("nvim-treesitter.install").ensure_installed(languages)
    end

    vim.opt.foldlevelstart = 99
    vim.treesitter.language.register("bash", { "zsh" })

    local group = vim.api.nvim_create_augroup("treesitter-start", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = {
        "bash",
        "c",
        "cpp",
        "go",
        "javascript",
        "javascriptreact",
        "lua",
        "python",
        "rust",
        "typescript",
        "typescriptreact",
        "vim",
        "zsh",
      },
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)

        local win = vim.api.nvim_get_current_win()
        vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[win].foldmethod = "expr"
      end,
    })
  end,
}
