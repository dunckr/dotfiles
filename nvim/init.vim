" Plugins
" ============================================================================

silent! if plug#begin('~/.config/nvim/plugged')

Plug 'Raimondi/delimitMate'
Plug 'christoomey/vim-tmux-navigator'
Plug 'dunckr/molokai'
Plug 'dunckr/vim-base16-unikitty-light'
Plug 'dyng/ctrlsf.vim'
Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'ervandew/supertab'
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-hugefile'
Plug 'mhinz/vim-signify'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'rizzatti/dash.vim', { 'on': 'Dash' }
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-surround'

" Lang
Plug 'SirVer/ultisnips'
Plug 'dunckr/vim-ultisnips'
Plug 'heavenshell/vim-jsdoc'
Plug 'mattn/emmet-vim'
Plug 'sbdchd/neoformat'
Plug 'shougo/deoplete.nvim'
Plug 'tpope/vim-endwise'
Plug 'w0rp/ale'

" JS
Plug 'carlitux/deoplete-ternjs', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'dunckr/js_alternate.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'mxw/vim-jsx', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'] }

" Coffee
Plug 'kchmck/vim-coffee-script', { 'for': ['coffee', 'coffeescript', 'coffeescript.cjsx'] }
Plug 'mtscout6/vim-cjsx', { 'for': ['coffee', 'coffeescript', 'coffeescript.cjsx'] }

" TS
Plug 'leafgarland/typescript-vim', { 'for': ['typescript', 'ts'] }
Plug 'mhartington/nvim-typescript', { 'for': ['typescript', 'ts'] }

" Ruby
Plug 'tpope/vim-rails', { 'for': 'ruby' }
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
Plug 'uplus/deoplete-solargraph', { 'for': 'ruby', 'do': 'gem install solargraph -v 0.18.0; pip install solargraph-utils.py --user; yard gems; yard config --gem-install-yri' }

" Other
Plug 'ap/vim-css-color', { 'for': ['css', 'scss', 'sass', 'less'] }
Plug 'elzr/vim-json', { 'for': ['json'] }
Plug 'hail2u/vim-css3-syntax', { 'for': ['css'] }
Plug 'junegunn/vader.vim', { 'for': ['vim'], 'on': 'Vader' }
Plug 'tpope/vim-markdown', { 'for': ['md'] }

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

au BufNewFile,BufRead Jenkinsfile setf groovy

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

augroup filetype_vim
	autocmd!
	autocmd FileType vim setlocal foldmethod=marker
augroup END

"
" ============================================================================
" Scripts
" ============================================================================

function! BackgroundSwitch()
	if &background == "light"
		set background=dark
		colorscheme molokai
	else
		set background=light
		colorscheme base16-unikitty-light
	endif
endfunction

nnoremap <leader>l :call BackgroundSwitch()<cr>

"
" ============================================================================
" Plugins
" ============================================================================

" ----------------------------------------------------------------------------
" tmux
" ----------------------------------------------------------------------------

nnoremap <silent> <BS> :TmuxNavigateLeft<cr>

" ----------------------------------------------------------------------------
" jsx
" ----------------------------------------------------------------------------"
"
let g:jsx_ext_required=0

" ----------------------------------------------------------------------------
" deoplete
" ----------------------------------------------------------------------------"

let g:deoplete#enable_at_startup=1
let g:deoplete#enable_ignore_case = 1
let g:deoplete#enable_smart_case = 1
let g:deoplete#auto_complete_start_length = 2

let g:deoplete#omni#functions = {}
let g:deoplete#omni#functions.javascript = [
  \ 'tern#Complete',
\]
set completeopt=longest,menuone,preview
let g:deoplete#sources = {}
let g:deoplete#sources['javascript.jsx'] = ['ternjs', 'file', 'ultisnips']
let g:tern#command = ['tern']
let g:tern#arguments = ['--persistent']
let g:tern_show_argument_hints = 'on_hold'
let g:tern_show_signature_in_pum = 1

let g:deoplete#sources#omni#input_patterns = {}
let g:deoplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\w*\|\h\w*::'
let g:deoplete#sources['ruby'] = ['solargraph', 'file']

let g:SuperTabDefaultCompletionType = "<C-n>"
let g:SuperTabClosePreviewOnPopupClose = 1

let g:UltiSnipsExpandTrigger="<C-j>"
let g:UltiSnipsJumpForwardTrigger="<C-j>"
let g:UltiSnipsJumpBackwardTrigger="<C-k>"

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"

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
" ale
" ----------------------------------------------------------------------------"
if filereadable(".eslintrc")
  let g:ale_linters = { 'javascript': [ 'eslint' ] }
endif

if filereadable(".eslintrc.js")
  let g:ale_linters = { 'javascript': [ 'eslint' ] }
endif

if filereadable(".eslintrc.yml")
  let g:ale_linters = { 'javascript': [ 'eslint' ] }
endif

if filereadable(".eslintrc.json")
  let g:ale_linters = { 'javascript': [ 'eslint' ] }
endif

let g:ale_set_quickfix = 0
let g:ale_lint_on_save = 1
let g:ale_lint_on_text_changed = 0

" ----------------------------------------------------------------------------
" easymotion
" ----------------------------------------------------------------------------"

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

map <Leader>a :Neoformat<cr>
autocmd FileType ruby nnoremap <Leader>p :Neoformat<cr>

let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_enabled_json = ['jsbeautify']

" ----------------------------------------------------------------------------
" format
" ----------------------------------------------------------------------------"

autocmd FileType javascript.jsx,css,json nnoremap <leader>p :silent %!prettier --stdin --trailing-comma es5 --tab-width 2 --use-tabs --single-quote --print-width 120<CR>

" ----------------------------------------------------------------------------
" js_alternate
" ----------------------------------------------------------------------------"

let g:js_alternate#extension_types = ['js', 'jsx', 're']
autocmd FileType javascript.jsx nnoremap <leader>t :call js_alternate#run()<cr>

" ----------------------------------------------------------------------------
" ctrlsf
" ----------------------------------------------------------------------------"

nmap <C-F> <Plug>CtrlSFPrompt

" ----------------------------------------------------------------------------
" dash
" ----------------------------------------------------------------------------"

let g:dash_activate = 0
nmap <silent> <leader>d <Plug>DashSearch

" ----------------------------------------------------------------------------
" jsdoc
" ----------------------------------------------------------------------------"

let g:jsdoc_allow_input_prompt = 1
let g:jsdoc_input_description = 1
let g:jsdoc_enable_es6 = 1
let g:jsdoc_underscore_private = 1

autocmd FileType javascript.jsx nnoremap <leader>y :JsDoc<cr>

" ----------------------------------------------------------------------------
" emmet
" ----------------------------------------------------------------------------"
let g:user_emmet_settings = {
\  'javascript.jsx' : {
\      'extends' : 'jsx',
\  },
\}
