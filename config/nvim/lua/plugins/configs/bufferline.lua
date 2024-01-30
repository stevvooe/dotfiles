
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
