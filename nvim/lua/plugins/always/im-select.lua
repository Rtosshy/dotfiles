return {
	"keaising/im-select.nvim",
	config = function()
		require("im_select").setup({
			default_command = "macism",
			set_previous_events = {},
		})
	end,
}
