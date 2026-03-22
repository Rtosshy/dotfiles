return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false, -- neo-tree will lazily load itself
    ---@module 'neo-tree'
    ---@type neotree.Config
    keys = {
        { "<leader>e", "<cmd>Neotree action=focus source=filesystem position=left toggle<CR>", desc = "" },
    },
    opts = {
        -- options go here
        close_if_last_window = true,
        window = {
            mappings = {
                ["l"] = "open",
                ["h"] = "close_node",
            },
        },
    },
}
