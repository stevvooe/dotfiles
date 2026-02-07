return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    { 'nvim-tree/nvim-web-devicons', opt = true },
  },
  config = function()
    require('lualine').setup({
      options = { theme = 'auto' },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 1,
          },
        },
      }
    })
  end,
}
