return {
	-- Mason: LSP installer
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},

	-- Mason-lspconfig: Bridge between Mason and lspconfig
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"ts_ls",
					"pyright",
					"gopls",
					"rust_analyzer",
					"html",
					"cssls",
					"jsonls",
					"yamlls",
					"bashls",
				},
				automatic_installation = true,
			})
		end,
	},

	-- LSP config using native Neovim 0.11+ API
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Ensure capabilities are available
			local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			if has_cmp then
				capabilities = cmp_nvim_lsp.default_capabilities()
			end

			-- Setup LSP keymaps on attach
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local opts = { buffer = bufnr, noremap = true, silent = true }
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
					vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
				end,
			})

			-- Diagnostic configuration
			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
			})

			-- Use native vim.lsp.config API (Neovim 0.11+)
			local default_config = {
				capabilities = capabilities,
			}

			-- Configure lua_ls with special settings
			vim.lsp.config("lua_ls", vim.tbl_extend("force", default_config, {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
					},
				},
			}))

			-- Configure other language servers
			local servers = {
				{ name = "ts_ls", cmd = { "typescript-language-server", "--stdio" }, filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" } },
				{ name = "pyright", cmd = { "pyright-langserver", "--stdio" }, filetypes = { "python" } },
				{ name = "rust_analyzer", cmd = { "rust-analyzer" }, filetypes = { "rust" } },
				{ name = "gopls", cmd = { "gopls" }, filetypes = { "go", "gomod", "gowork", "gotmpl" } },
				{ name = "html", cmd = { "vscode-html-language-server", "--stdio" }, filetypes = { "html" } },
				{ name = "cssls", cmd = { "vscode-css-language-server", "--stdio" }, filetypes = { "css", "scss", "less" } },
				{ name = "jsonls", cmd = { "vscode-json-language-server", "--stdio" }, filetypes = { "json", "jsonc" } },
				{ name = "yamlls", cmd = { "yaml-language-server", "--stdio" }, filetypes = { "yaml", "yaml.docker-compose" } },
				{ name = "bashls", cmd = { "bash-language-server", "start" }, filetypes = { "sh", "bash" } },
			}

			for _, server in ipairs(servers) do
				vim.lsp.config(server.name, vim.tbl_extend("force", default_config, {
					cmd = server.cmd,
					filetypes = server.filetypes,
				}))
			end

			-- Enable LSP servers for configured filetypes
			vim.lsp.enable({ "lua_ls", "ts_ls", "pyright", "rust_analyzer", "gopls", "html", "cssls", "jsonls", "yamlls", "bashls" })
		end,
	},

	-- LuaSnip: Snippet engine
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
	},

	-- nvim-cmp: Completion engine
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
			})
		end,
	},
}
