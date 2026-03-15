return {
	"rebelot/kanagawa.nvim",
	lazy = false,
	priority = 1000,
	opts = function()
		return {
			transparent = true,
		}
	end,
	config = function(_, opts)
        require("kanagawa").setup(opts)
        vim.cmd.colorscheme("kanagawa")
    end,
}
