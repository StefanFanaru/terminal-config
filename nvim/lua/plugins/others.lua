return {
	{ "tpope/vim-sleuth", event = { "BufReadPost", "BufNewFile" } },
	{ "tpope/vim-unimpaired", event = { "BufReadPost", "BufNewFile" } },
	{ "tpope/vim-surround", event = { "BufReadPost", "BufNewFile" } },
	{ "lewis6991/gitsigns.nvim", event = { "BufReadPost", "BufNewFile" } },
	{ "dstein64/vim-startuptime", event = { "BufReadPost", "BufNewFile" } },

	{
		"ThePrimeagen/vim-be-good",
		cmd = "VimBeGood",
	},
	{
		"b0o/SchemaStore.nvim",
		lazy = true,
		version = false, -- last release is way too old
	},
}
