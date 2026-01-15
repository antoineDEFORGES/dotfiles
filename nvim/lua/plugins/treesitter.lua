-- Treesitter syntax highlighting
return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            ensure_installed = {
                "lua", "python", "go", "c", "bash",
                "javascript", "typescript", "tsx",
                "json", "yaml", "toml", "markdown",
                "html", "css", "dockerfile",
            },
        })
    end,
}
