local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "win32yank", -- Use win32yank for clipboard operations
    copy = {
      ["+"] = "win32yank.exe -i --crlf", -- Command to copy to the system clipboard
      ["*"] = "win32yank.exe -i --crlf", -- Command to copy to the primary clipboard
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf", -- Command to paste from the system clipboard
      ["*"] = "win32yank.exe -o --lf", -- Command to paste from the primary clipboard
    },
    cache_enabled = false, -- Disable clipboard caching
  }
end
-- if vim.fn.has("wsl") == 1 then
--   vim.g.clipboard = {
--     name = "win32yank",
--     copy = {
--       ["+"] = "/home/gabri/.local/bin/win32yank -i --crlf", -- Ruta absoluta al enlace
--       ["*"] = "/home/gabri/.local/bin/win32yank -i --crlf",
--     },
--     paste = {
--       ["+"] = "/home/gabri/.local/bin/win32yank -o --lf",
--       ["*"] = "/home/gabri/.local/bin/win32yank -o --lf",
--     },
--     cache_enabled = false,
--   }
-- end
--
require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- vim.opt.largefile = false
local big_file_nuke_group = vim.api.nvim_create_augroup("big-file-nuke", { clear = true })
local huge_file = ""
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*",
  group = big_file_nuke_group,
  callback = function()
    local relevant_file = vim.fn.expand("<afile>")
    local ok, stats = pcall(vim.uv.fs_stat, vim.fn.expand(relevant_file))
    if not ok then
      return
    end
    local ok, linecount = pcall(vim.fn.system, "< " .. vim.fn.expand(relevant_file) .. "head -1000 | wc -l")
    if not ok then
      linecount = "1000"
    end
    local just_big = (stats.size > 1024 * 1024 * 2)
    local big_however = (stats.size > 1024 * 1024 * 0.5)
    local just_a_few_lines = tonumber(linecount:match("%d+")) < 3
    if just_big or (big_however and just_a_few_lines) then
      vim.notify("File: " .. relevant_file .. " is greater than 2MB.  Shutting off file detection ")
      huge_file = relevant_file
      vim.cmd.filetype("off")
      vim.cmd.setlocal("noswapfile")
      vim.cmd.setlocal("undolevels=0")
      vim.cmd.setlocal("bufhidden=unload")
    end
  end,
})
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  group = big_file_nuke_group,
  callback = function()
    local relevant_file = vim.fn.expand("<afile>")
    if relevant_file == huge_file then
      vim.cmd.filetype("on")
    end
  end,
})
