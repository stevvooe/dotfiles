return {
  'akinsho/bufferline.nvim',
  version = "*",
  branch = "main",
  commit = "73540cb95f8d95aa1af3ed57713c6720c78af915",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require("bufferline").setup({
      options = {
        separator_style = "slant",
        --- count is an integer representing total count of errors
        --- level is a string "error" | "warning"
        --- this should return a string
        --- Don't get too fancy as this function will be executed a lot
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and " " or ""
          return " " .. icon .. count
        end,
        themable = true,
        offsets = {
          { filetype = "NvimTree", highlight = "NvimTreeNormal" },
        },
      }
    })
  end,
}
