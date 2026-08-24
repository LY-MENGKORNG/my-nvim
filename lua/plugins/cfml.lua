-- CFML / ColdFusion support: filetype, LSP (cfmleditor-lsp), tree-sitter.
--
-- Prerequisites installed out-of-band:
--   * ~/.local/bin/cfmleditor-lsp            (github.com/cfmleditor/cfmleditor-lsp)
--   * ~/.local/share/nvim/site/parser/{cfml,cfscript,cfquery}.so
--   * ~/.config/nvim/queries/{cfml,cfscript,cfquery}/*.scm
--
-- Per-project tuning lives in a `.cfmleditor.json` at the project root
-- (beanPaths / mappings / componentResolvers drive goto-definition).

-- Neovim ships a builtin `cf` filetype for these extensions; override it so the
-- filetype, the tree-sitter parser and the LSP languageId all agree on "cfml".
vim.filetype.add({
  extension = {
    cfm = "cfml",
    cfml = "cfml",
    cfc = "cfml",
    cfs = "cfml",
  },
})

local lsp_bin = vim.fn.expand("~/.local/bin/cfmleditor-lsp")

vim.lsp.config("cfmleditor", {
  cmd = { lsp_bin },
  filetypes = { "cfml" },
  root_markers = { ".cfmleditor.json", "box.json", "Application.cfc", ".git" },
})

local group = vim.api.nvim_create_augroup("cfml_setup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "cfml",
  callback = function(ev)
    -- Tree-sitter highlighting + folds + indent. The cfml grammar injects
    -- cfscript (component bodies, <cfscript>) and cfquery (SQL in <cfquery>).
    if pcall(vim.treesitter.start, ev.buf, "cfml") then
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end

    vim.bo[ev.buf].commentstring = "<!--- %s --->"

    -- The server's formatter rewrites tag casing/indentation wholesale, which
    -- makes enormous diffs on legacy files. Keep it off format-on-save; use
    -- <leader>cF below to format deliberately.
    vim.b[ev.buf].autoformat = false
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= "cfmleditor" then
      return
    end
    vim.keymap.set("n", "<leader>cF", function()
      vim.lsp.buf.format({ async = true })
    end, { buffer = ev.buf, desc = "Format CFML (cfmleditor-lsp)" })
    vim.keymap.set("n", "<leader>cR", function()
      client:exec_cmd({ command = "cfmleditor.reindex", arguments = {} })
      vim.notify("cfmleditor-lsp: reindexing workspace", vim.log.levels.INFO)
    end, { buffer = ev.buf, desc = "Reindex CFML workspace" })
  end,
})

-- On 0.11+ this is self-contained: it registers a filetype hook that starts the
-- client for `cfml` buffers. nvim-lspconfig is not involved.
vim.lsp.enable("cfmleditor")

return {}
