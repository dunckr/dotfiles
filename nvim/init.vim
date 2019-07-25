" Plugins
" ============================================================================

silent! if plug#begin('~/.config/nvim/plugged')

Plug 'Raimondi/delimitMate'
Plug 'christoomey/vim-tmux-navigator'
Plug 'dunckr/molokai'
Plug 'dyng/ctrlsf.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'ervandew/supertab'
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-hugefile'
Plug 'mhinz/vim-signify'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'terryma/vim-multiple-cursors'

Plug 'tpope/vim-endwise'

call plug#end()
endif

"
" ============================================================================
" Basic
" ============================================================================

set ff=unix

" color scheme
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors
syntax enable
set background=light
colorscheme molokai

" mouse
set mouse=a
set cb=unnamed

set clipboard+=unnamedplus

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

set foldmethod=marker foldlevel=0

autocmd Filetype gitcommit setlocal spell textwidth=72

" ============================================================================
" Mappings
" ============================================================================

" ----------------------------------------------------------------------------
" Basic
" ----------------------------------------------------------------------------

let mapleader = ','

map <Leader>w <ESC>:w<cr>
map <C-e> :NERDTreeToggle<CR>>
noremap H ^
noremap L $
map <Leader>t :set expandtab<cr>

map <Leader>r :so $MYVIMRC<cr>

"
" ============================================================================
" Plugins
" ============================================================================

" ----------------------------------------------------------------------------
" tmux
" ----------------------------------------------------------------------------

nnoremap <silent> <BS> :TmuxNavigateLeft<cr>

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
" indent-guides
" ----------------------------------------------------------------------------"

let g:indent_guides_auto_colors = 0
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 1

" ----------------------------------------------------------------------------
" fzf
" ----------------------------------------------------------------------------"

set rtp+=/usr/local/opt/fzf
nnoremap <silent><C-p> :GFiles<cr>
nnoremap <silent><C-t> :Tags<cr>

" ----------------------------------------------------------------------------
" commenter
" ----------------------------------------------------------------------------"

let g:NERDDefaultAlign = 'left'
let g:NERDCompactSexyComs = 1
let g:NERDSpaceDelims = 1

" ----------------------------------------------------------------------------
" format
" ----------------------------------------------------------------------------"

autocmd FileType javascript.jsx,typescript,css,json nnoremap <leader>p :silent %!prettier --stdin --trailing-comma es5 --tab-width 2 --use-tabs --single-quote --print-width 120 --parser typescript<CR>

" ----------------------------------------------------------------------------
" js_alternate
" ----------------------------------------------------------------------------"

let g:js_alternate#extension_types = ['js', 'jsx', 're', 'ts', 'tsx']
autocmd FileType javascript.jsx nnoremap <leader>t :call js_alternate#run()<cr>

" ----------------------------------------------------------------------------
" ctrlsf
" ----------------------------------------------------------------------------"

nmap <C-F> <Plug>CtrlSFPrompt
