-- ============================================================
-- Personal Neovim Config
-- Based on kickstart.nvim
-- NixOS | Real Programmers Dvorak | One Dark Pro
-- ============================================================
-- Leader key — space is easiest to reach
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- You have JetBrainsMono Nerd Font installed
vim.g.have_nerd_font = true
-- ============================================================
-- OPTIONS
-- ============================================================
vim.o.number = true
vim.o.relativenumber = true -- relative numbers help with jump motions (5j, 3k)
vim.o.mouse = 'a'
vim.o.showmode = false -- mode shown in statusline already
vim.o.breakindent = true
vim.o.undofile = true -- persistent undo across sessions
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.tabstop = 2 -- 2 spaces for TS/Angular/Nix convention
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.wrap = true -- matches VSCode editor.wordWrap = "on"
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
-- Sync clipboard with system (wl-clipboard on Wayland)
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
-- ============================================================
-- KEYMAPS
-- ============================================================
-- Clear search highlights
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Save / write (like <leader>, in VSCode — save + format on write via conform)
vim.keymap.set('n', '<leader>,', '<cmd>w<CR>', { desc = '[W]rite file' })

-- Close buffer (like <leader>; in VSCode — closeActiveEditor)
vim.keymap.set('n', '<leader>;', '<cmd>bd<CR>', { desc = 'Close buffer' })

-- Close other buffers (like <leader>y in VSCode — closeOtherEditors)
vim.keymap.set('n', '<leader>y', '<cmd>%bd|e#|bd#<CR>', { desc = 'Close other buffers' })

-- Buffer navigation (like Tab/S-Tab in VSCode)
vim.keymap.set('n', '<Tab>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>', '<cmd>bprev<CR>', { desc = 'Prev buffer' })

-- Splits (like <leader>o and <leader>k in VSCode)
vim.keymap.set('n', '<leader>o', '<cmd>vsplit<CR>', { desc = 'Split vertical' })
vim.keymap.set('n', '<leader>k', '<cmd>split<CR>', { desc = 'Split horizontal' })

-- Diagnostics navigation (like ]e [e in VSCode)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Window navigation — hjkl pane focus (matches VSCode ctrl+hjkl)
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- ============================================================
-- AUTOCOMMANDS
-- ============================================================
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- ============================================================
-- PLUGIN MANAGER (lazy.nvim)
-- ============================================================
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================
-- PLUGINS
-- ============================================================
require('lazy').setup({

  -- Detect indentation automatically
  { 'NMAC427/guess-indent.nvim', opts = {} },

  -- --------------------------------------------------------
  -- GIT
  -- --------------------------------------------------------
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      -- Hunk navigation + staging (like GitLens hunk actions)
      on_attach = function(bufnr)
        local gs = require 'gitsigns'
        local map = function(mode, l, r, desc) vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc }) end
        map('n', ']h', gs.next_hunk, 'Next git [H]unk')
        map('n', '[h', gs.prev_hunk, 'Prev git [H]unk')
        map('n', '<leader>hs', gs.stage_hunk, '[H]unk [S]tage')
        map('n', '<leader>hr', gs.reset_hunk, '[H]unk [R]eset')
        map('n', '<leader>hp', gs.preview_hunk, '[H]unk [P]review')
        map('n', '<leader>hb', gs.blame_line, '[H]unk [B]lame line')
        map('n', '<leader>hd', gs.diffthis, '[H]unk [D]iff')
      end,
    },
  },

  -- --------------------------------------------------------
  -- WHICH-KEY — show pending keybinds while learning
  -- --------------------------------------------------------
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
      },
    },
  },

  -- --------------------------------------------------------
  -- TELESCOPE — fuzzy finder
  -- <leader>sf  find files    (VSCode: <leader>uu quickOpen)
  -- <leader>sg  live grep     (VSCode: <leader>ui findInFiles)
  -- --------------------------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'

      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files' })
      vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })

      -- LSP-aware Telescope binds (buffer-local on LspAttach)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
        callback = function(event)
          local buf = event.buf
          vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
          vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
          vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
          vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
          vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
          vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
        end,
      })

      vim.keymap.set(
        'n',
        '<leader>/',
        function()
          builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        { desc = '[/] Fuzzily search in current buffer' }
      )

      vim.keymap.set(
        'n',
        '<leader>s/',
        function() builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' } end,
        { desc = '[S]earch [/] in Open Files' }
      )

      vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  -- --------------------------------------------------------
  -- HARPOON 2 — file marking, core to your workflow
  -- Mirrors VSCode vscode-harpoon keybinds exactly:
  --   <leader>a  → add file
  --   <leader>d  → show menu
  --   <leader>1-5 → jump to slot
  -- --------------------------------------------------------
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end, { desc = 'Harpoon [A]dd file' })
      vim.keymap.set('n', '<leader>d', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'Harpoon [D]isplay menu' })

      vim.keymap.set('n', '<leader>+', function() harpoon:list():select(1) end, { desc = 'Harpoon file 1' })
      vim.keymap.set('n', '<leader>[', function() harpoon:list():select(2) end, { desc = 'Harpoon file 2' })
      vim.keymap.set('n', '<leader>{', function() harpoon:list():select(3) end, { desc = 'Harpoon file 3' })
      vim.keymap.set('n', '<leader>(', function() harpoon:list():select(4) end, { desc = 'Harpoon file 4' })
      vim.keymap.set('n', '<leader>)', function() harpoon:list():select(5) end, { desc = 'Harpoon file 5' })
    end,
  },

  -- --------------------------------------------------------
  -- LSP — no Mason, binaries managed by Nix
  -- Ensure these are in your home.nix packages:
  --   typescript-language-server   → ts_ls
  --   angular-language-server      → angularls
  --   vscode-langservers-extracted → html, cssls, eslint
  --   nil                          → nil_ls
  --   lua-language-server          → lua_ls
  --   prettierd, stylua            → formatters
  -- --------------------------------------------------------
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'j-hui/fidget.nvim', opts = {} }, -- LSP status spinner in corner
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, 'Code [A]ction', { 'n', 'x' })
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          -- Hover docs (VSCode: shift+t → showHover)
          map('K', vim.lsp.buf.hover, 'Hover docs')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local hl = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = hl,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = hl,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(ev)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = ev.buf }
              end,
            })
          end

          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      local servers = {
        ts_ls = {},
        angularls = {},
        html = {},
        cssls = {},
        eslint = {},
        nil_ls = {},
        lua_ls = {
          on_init = function(client)
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
            end
            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
              runtime = { version = 'LuaJIT' },
              workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file('', true),
              },
            })
          end,
          settings = { Lua = {} },
        },
      }
      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
    end,
  },

  -- --------------------------------------------------------
  -- FORMATTING — prettierd for TS/Angular, stylua for Lua
  -- formatOnSave mirrors VSCode editor.formatOnSave = true
  -- --------------------------------------------------------
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then return nil end
        return { timeout_ms = 500, lsp_format = 'fallback' }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        html = { 'prettierd' },
        css = { 'prettierd' },
        json = { 'prettierd' },
        jsonc = { 'prettierd' },
        markdown = { 'prettierd' },
        yaml = { 'prettierd' },
      },
    },
  },

  -- --------------------------------------------------------
  -- COMPLETION — blink.cmp (modern, faster than nvim-cmp)
  -- --------------------------------------------------------
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        opts = {},
      },
    },
    opts = {
      keymap = { preset = 'default' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 300 },
      },
      sources = { default = { 'lsp', 'path', 'snippets' } },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },

  -- --------------------------------------------------------
  -- COLORSCHEME — One Dark Pro Night Flat
  -- Matches your VSCode "One Dark Pro Night Flat" theme
  -- oneDarkPro.bold = true, oneDarkPro.vivid = true
  -- --------------------------------------------------------
  {
    'olimorris/onedarkpro.nvim',
    priority = 1000,
    config = function()
      require('onedarkpro').setup {
        colors = {
          bg = '#1e1e1e',
          bg_float = '#1e1e1e',
        },
        styles = {
          comments = 'italic', -- matches VSCode italic font scope rules
          keywords = 'italic',
          functions = 'NONE',
          variables = 'NONE',
        },
        options = {
          bold = true,
          italic = true,
        },
      }
      vim.cmd.colorscheme 'onedark_dark'
    end,
  },

  -- --------------------------------------------------------
  -- TODO COMMENTS — highlights TODO, FIXME, NOTE, HACK etc
  -- Matches VSCode todohighlight + todo-tree behavior
  -- --------------------------------------------------------
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      signs = false,
      keywords = {
        NOTE = { icon = '󰋽 ', color = 'hint' }, -- matches your VSCode NOTE lightblue style
      },
    },
  },

  -- --------------------------------------------------------
  -- MINI.NVIM — editing primitives + file explorer + statusline
  -- --------------------------------------------------------
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Extended text objects — va), cin, etc.
      require('mini.ai').setup { n_lines = 500 }

      -- Surround — sa (add), sd (delete), sr (replace)
      require('mini.surround').setup()

      -- Auto pairs — {, (, [, ", ' etc.
      -- Matches VSCode auto-close-tag behavior
      require('mini.pairs').setup()

      -- File explorer
      -- <leader>. open at current file (like VSCode <leader>. sidebar toggle)
      -- <leader>e open at cwd
      require('mini.files').setup {
        windows = { preview = true, width_preview = 50 },
        options = { use_as_default_explorer = true },
      }
      vim.keymap.set('n', '<leader>.', function()
        local mf = require 'mini.files'
        if not mf.close() then mf.open(vim.api.nvim_buf_get_name(0)) end
      end, { desc = 'File explorer (current file)' })
      vim.keymap.set('n', '<leader>e', function()
        local mf = require 'mini.files'
        if not mf.close() then mf.open() end
      end, { desc = 'File explorer (cwd)' })

      -- Statusline with mode colors
      -- Colors mirror your VSCode nvim-ui-modes customization exactly:
      --   normal  → #3C3C3C  (your statusBar.background default)
      --   insert  → #4B6E6E
      --   visual  → #094771
      --   replace → #6E4B4B
      --   command → #2D2D2D
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      local function set_mode_highlights()
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeNormal', { bg = '#3C3C3C', fg = '#CCCCCC', bold = true })
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeInsert', { bg = '#4B6E6E', fg = '#CCCCCC', bold = true })
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeVisual', { bg = '#094771', fg = '#CCCCCC', bold = true })
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeReplace', { bg = '#6E4B4B', fg = '#CCCCCC', bold = true })
        vim.api.nvim_set_hl(0, 'MiniStatuslineModeCommand', { bg = '#2D2D2D', fg = '#CCCCCC', bold = true })
      end
      set_mode_highlights()
      -- Re-apply after colorscheme reloads
      vim.api.nvim_create_autocmd('ColorScheme', { callback = set_mode_highlights })

      -- Custom active statusline — mode label uses color-per-mode
      local mode_map = {
        ['n'] = { label = 'NORMAL', hl = 'MiniStatuslineModeNormal' },
        ['i'] = { label = 'INSERT', hl = 'MiniStatuslineModeInsert' },
        ['v'] = { label = 'VISUAL', hl = 'MiniStatuslineModeVisual' },
        ['V'] = { label = 'V-LINE', hl = 'MiniStatuslineModeVisual' },
        ['\22'] = { label = 'V-BLOCK', hl = 'MiniStatuslineModeVisual' },
        ['R'] = { label = 'REPLACE', hl = 'MiniStatuslineModeReplace' },
        ['c'] = { label = 'COMMAND', hl = 'MiniStatuslineModeCommand' },
        ['t'] = { label = 'TERMINAL', hl = 'MiniStatuslineModeInsert' },
      }

      MiniStatusline.config.content.active = function()
        local m = mode_map[vim.fn.mode()] or { label = vim.fn.mode(), hl = 'MiniStatuslineModeNormal' }
        local git = MiniStatusline.section_git { trunc_width = 75 }
        local diag = MiniStatusline.section_diagnostics { trunc_width = 75 }
        local file = MiniStatusline.section_filename { trunc_width = 140 }
        local loc = '%2l:%-2v'

        return MiniStatusline.combine_groups {
          { hl = m.hl, strings = { m.label } },
          { hl = 'MiniStatuslineDevinfo', strings = { git } },
          '%<',
          { hl = 'MiniStatuslineFilename', strings = { file } },
          '%=',
          { hl = 'MiniStatuslineDevinfo', strings = { diag } },
          { hl = m.hl, strings = { loc } },
        }
      end
    end,
  },

  -- --------------------------------------------------------
  -- TREESITTER — syntax highlighting and smart indentation
  -- Added angular + jsonc + yaml parsers for your stack
  -- --------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    branch = 'main',
    config = function()
      local parsers = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        -- your stack
        'typescript',
        'javascript',
        'tsx',
        'angular',
        'css',
        'json',
        'jsonc',
        'yaml',
        'nix',
      }
      require('nvim-treesitter').install(parsers)
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, filetype = args.buf, args.match
          local language = vim.treesitter.language.get_lang(filetype)
          if not language then return end
          if not vim.treesitter.language.add(language) then return end
          vim.treesitter.start(buf, language)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
-- vim: ts=2 sts=2 sw=2 et
