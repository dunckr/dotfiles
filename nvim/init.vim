" VIM-PLUG BLOCK {{{
" ============================================================================
silent! if plug#begin('~/.config/nvim/plugged')

Plug 'Raimondi/delimitMate'
Plug 'christoomey/vim-tmux-navigator'
Plug 'dunckr/molokai'
Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'ervandew/supertab'
Plug 'junegunn/fzf.vim'
Plug 'ludovicchabant/vim-gutentags'
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
Plug 'mattn/emmet-vim'
Plug 'mhinz/vim-hugefile'
Plug 'mhinz/vim-signify'
Plug 'mhinz/vim-startify'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'shougo/deoplete.nvim'
Plug 'terryma/vim-multiple-cursors'
Plug 'tommcdo/vim-lion'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'

" Lang
Plug 'Chiel92/vim-autoformat'
Plug 'Shougo/neocomplcache'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
Plug 'SirVer/ultisnips'
Plug 'ap/vim-css-color'
Plug 'beloglazov/vim-online-thesaurus'
Plug 'benekastah/neomake'
Plug 'briancollins/vim-jst'
Plug 'carlitux/deoplete-ternjs', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'elixir-lang/vim-elixir'
Plug 'elzr/vim-json'
Plug 'fatih/vim-nginx'
Plug 'hail2u/vim-css3-syntax'
Plug 'hashivim/vim-terraform'
Plug 'heavenshell/vim-jsdoc'
Plug 'honza/dockerfile.vim'
Plug 'honza/vim-snippets'
Plug 'kchmck/vim-coffee-script'
Plug 'mattn/emmet-vim'
Plug 'moll/vim-node'
Plug 'mtscout6/vim-cjsx'
Plug 'mustache/vim-mustache-handlebars'
Plug 'mxw/vim-jsx'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'othree/jspc.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'pangloss/vim-javascript'
Plug 'rhysd/vim-grammarous'
Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'tpope/vim-cucumber'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-haml'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-rails'
Plug 'vim-ruby/vim-ruby'

call plug#end()
endif
" }}}
" ============================================================================
" BASIC SETTINGS {{{
" ============================================================================
set ff=unix

" color scheme
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors
syntax enable
set background=light
colorscheme molokai

" mouse
set mouse=
set cb=unnamed

" line numbers
set relativenumber

" search
set smartcase
set ignorecase

" use vim, not vi api
set nocompatible
set hidden

" no backup files
set nobackup

set autoindent
set noexpandtab
set nopaste

" no write backup
set nowritebackup

" no swap file
set noswapfile

" command history
set history=100

" always show cursor
set ruler

" show incomplete commands
set showcmd

" incremental searching
set incsearch

" highlight search
set hlsearch

" spell checking
set spell
set spell spelllang=en_us

" remove whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" ctags
set tags=./tags;/

" only syntax highlight first columns
set synmaxcol=120

set inccommand=nosplit

set cursorline
" set cursorcolumn

set completeopt-=preview

let g:loaded_python_provider = 1

" }}}
" ============================================================================
" MAPPINGS {{{
" ============================================================================

" ----------------------------------------------------------------------------
" Basic mappings
" ----------------------------------------------------------------------------
let mapleader = ','

map <Leader>a :Autoformat<cr>
map <Leader>w <ESC>:w<cr>
map <C-e> :NERDTreeToggle<CR>>
noremap H ^
noremap L $
map <Leader>t :set expandtab<cr>
" }}}
" ============================================================================
" SCRIPTS {{{
" ============================================================================
" ----------------------------------------------------------------------------
map <Leader>bg :let &background = ( &background == "dark"? "light" : "dark" )<CR>
" }}}
" ============================================================================
" PLUGINS {{{
" ============================================================================
" ----------------------------------------------------------------------------
" Tmux
" ----------------------------------------------------------------------------
nnoremap <silent> <BS> :TmuxNavigateLeft<cr>
" ----------------------------------------------------------------------------
" jsx
" ----------------------------------------------------------------------------"
let g:jsx_ext_required=0
" ----------------------------------------------------------------------------
" deoplete
" ----------------------------------------------------------------------------"
let g:deoplete#enable_at_startup=1
let g:deoplete#omni#functions = {}
let g:deoplete#omni#functions.javascript = [
  \ 'tern#Complete',
  \ 'jspc#omni'
\]
set completeopt=longest,menuone,preview
let g:deoplete#sources = {}
let g:deoplete#sources['javascript.jsx'] = ['file', 'ultisnips', 'ternjs']
let g:tern#command = ['tern']
let g:tern#arguments = ['--persistent']

let g:SuperTabDefaultCompletionType = "<c-n>"
let g:SuperTabClosePreviewOnPopupClose = 1

let g:UltiSnipsExpandTrigger="<C-j>"
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" " ----------------------------------------------------------------------------
" NERDTree
" ----------------------------------------------------------------------------"
let NERDTreeShowBookmarks=1
let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$', '\.tern-port$']
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=1
let NERDTreeMouseMode=2
let NERDTreeShowHidden=1
let NERDTreeKeepTreeInNewTab=1
let NERDTreeMapToggleHidden=1
" ----------------------------------------------------------------------------
" indent_guides
" ----------------------------------------------------------------------------"
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1
" ----------------------------------------------------------------------------
" fzf
" ----------------------------------------------------------------------------"
set rtp+=/usr/local/opt/fzf
nnoremap <silent><C-p> :GFiles<cr>
" ----------------------------------------------------------------------------
" neomake
" ----------------------------------------------------------------------------"
let g:neomake_coffeescript_enabled_makers = ['coffeelint']
let g:neomake_python_enabledmarkers= ['python', 'flake8', 'pylint', 'pyflakes']

let g:neomake_javascript_enabled_makers = ['eslint']

let s:eslint_path = system('PATH=$(npm bin):$PATH && which eslint')
let g:neomake_javascript_eslint_exe = substitute(s:eslint_path, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')

autocmd! BufWritePost * Neomake

nmap <Leader><Space>o :lopen<CR>      " open location window
nmap <Leader><Space>c :lclose<CR>     " close location window
nmap <Leader><Space>, :ll<CR>         " go to current error/warning
nmap <Leader><Space>n :lnext<CR>      " next error/warning
nmap <Leader><Space>p :lprev<CR>      " previous error/warning
" ----------------------------------------------------------------------------
" easymotion
" ----------------------------------------------------------------------------"
" <Leader>f{char} to move to {char}
map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>f <Plug>(easymotion-overwin-f)

" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)

" Move to line
map <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)
" ----------------------------------------------------------------------------
" commenter
" ----------------------------------------------------------------------------"
let g:NERDDefaultAlign = 'left'
let g:NERDCompactSexyComs = 1
let g:NERDSpaceDelims = 1
" ----------------------------------------------------------------------------
" format
" ----------------------------------------------------------------------------"
let g:formatdef_esformatter = '"esformatter"'
let g:formatters_cs = ['esformatter']

autocmd FileType javascript set formatprg=prettier\ --stdin\ --single-quote\ --trailing-comma\ --tab-width\ 4
