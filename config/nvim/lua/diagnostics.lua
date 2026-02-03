local signs = {
  Error = "",
  Warn = "",
  Hint = "",
  Info = "",
}

local severity_icons = {
  [vim.diagnostic.severity.ERROR] = signs.Error,
  [vim.diagnostic.severity.WARN] = signs.Warn,
  [vim.diagnostic.severity.HINT] = signs.Hint,
  [vim.diagnostic.severity.INFO] = signs.Info,
}

vim.diagnostic.config({
  virtual_text = {
    prefix = function(diagnostic)
      return severity_icons[diagnostic.severity] or "●"
    end,
    spacing = 2,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = signs.Error,
      [vim.diagnostic.severity.WARN] = signs.Warn,
      [vim.diagnostic.severity.HINT] = signs.Hint,
      [vim.diagnostic.severity.INFO] = signs.Info,
    },
  },
  underline = true,
  update_in_insert = false,
})
