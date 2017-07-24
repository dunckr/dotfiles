" ============================================================================
"
"        ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
"        ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
"        ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
"        ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
"     ██╗██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
"     ╚═╝╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
"
" ============================================================================
" Plugins {{{
" ============================================================================

silent! if plug#begin('~/.config/nvim/plugged')

Plug 'Raimondi/delimitMate'
Plug 'christoomey/vim-tmux-navigator'
Plug 'dunckr/molokai'
Plug 'dunckr/vim-base16-unikitty-light'
Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'ervandew/supertab'
Plug 'junegunn/fzf.vim'
Plug 'mhinz/vim-hugefile'
Plug 'mhinz/vim-signify'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'shougo/deoplete.nvim'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-surround'

" Lang
Plug 'Shougo/neocomplcache'
Plug 'SirVer/ultisnips'
Plug 'benekastah/neomake'
Plug 'dunckr/vim-snippets'
Plug 'mattn/emmet-vim'
Plug 'sbdchd/neoformat'
Plug 'tpope/vim-endwise'

" JS
Plug 'carlitux/deoplete-ternjs', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'dunckr/js_alternate.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'mxw/vim-jsx', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'] }

" elm
Plug 'ElmCast/elm-vim', { 'for': ['elm'] }
Plug 'pbogut/deoplete-elm', { 'for': ['elm'] }

" Coffee
Plug 'kchmck/vim-coffee-script', { 'for': ['coffeescript', 'coffeescript.cjsx'] }
Plug 'mtscout6/vim-cjsx', { 'for': ['coffeescript', 'coffeescript.cjsx'] }

" Ruby
Plug 'tpope/vim-rails', { 'for': ['ruby'] }
Plug 'vim-ruby/vim-ruby', { 'for': ['ruby'] }

" Elixir
Plug 'elixir-lang/vim-elixir' , { 'for': ['elixir'] }
Plug 'slashmili/alchemist.vim', { 'for': ['elixir'] }

" Go
Plug 'fatih/vim-go', { 'for': ['go'] }
Plug 'zchee/deoplete-go', { 'for': ['go'], 'do': 'make'}

" Other
Plug 'ap/vim-css-color', { 'for': ['css', 'scss', 'sass', 'less'] }
Plug 'elzr/vim-json', { 'for': ['json'] }
Plug 'hail2u/vim-css3-syntax', { 'for': ['css'] }
Plug 'junegunn/vader.vim', { 'for': ['vim'], 'on': 'Vader' }
Plug 'tpope/vim-markdown', { 'for': ['md'] }
call plug#end()
endif

" }}}
" ============================================================================
" Basic {{{
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

" }}}
" ============================================================================
" Mappings {{{
" ============================================================================

" ----------------------------------------------------------------------------
" Basic
" ----------------------------------------------------------------------------

let mapleader = ','

map <Leader>a :Neoformat<cr>
map <Leader>w <ESC>:w<cr>
map <C-e> :NERDTreeToggle<CR>>
noremap H ^
noremap L $
map <Leader>t :set expandtab<cr>

map <Leader>z :so $MYVIMRC<cr>

augroup filetype_vim
	autocmd!
	autocmd FileType vim setlocal foldmethod=marker
augroup END

" }}}
" ============================================================================
" Scripts {{{
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

" }}}
" ============================================================================
" Plugins {{{
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
let g:deoplete#omni#functions = {}
let g:deoplete#omni#functions.javascript = [
  \ 'tern#Complete',
  \ 'jspc#omni'
\]
set completeopt=longest,menuone,preview
let g:deoplete#sources = {}
let g:deoplete#sources['javascript.jsx'] = ['ternjs', 'ultisnips', 'file']
let g:tern#command = ['tern']
let g:tern#arguments = ['--persistent']

let g:SuperTabDefaultCompletionType = "<c-n>"
let g:SuperTabClosePreviewOnPopupClose = 1

let g:UltiSnipsExpandTrigger="<C-k>"

inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

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

" ----------------------------------------------------------------------------
" neomake
" ----------------------------------------------------------------------------"

let g:neomake_coffeescript_enabled_makers = ['coffeelint']
let g:neomake_python_enabledmarkers= ['python', 'flake8', 'pylint', 'pyflakes']

let g:neomake_javascript_enabled_makers = ['eslint']

let s:eslint_path = system('PATH=$(npm bin):$PATH && which eslint')
let g:neomake_javascript_eslint_exe = substitute(s:eslint_path, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')

let config_names = [
  \'.eslintrc.js',
  \'.eslintrc.yaml',
  \'.eslintrc.yml',
  \'.eslintrc.json',
  \'.eslintrc',
  \'eslint.js',
  \'~/.eslint.js'
\]
let config = filter(config_names, 'findfile(v:val, ".;") !=# ""')
if len(config) == 1
	let g:neomake_javascript_eslint_args = ['-f', 'compact', '--no-eslintrc', '--config', config[0]]
endif

let g:neomake_elixir_enabled_makers = ['credo', 'dogma']

autocmd! BufWritePost * Neomake

nmap <Leader><Space>o :lopen<CR>      " open location window
nmap <Leader><Space>c :lclose<CR>     " close location window
nmap <Leader><Space>, :ll<CR>         " go to current error/warning
nmap <Leader><Space>n :lnext<CR>      " next error/warning
nmap <Leader><Space>p :lprev<CR>      " previous error/warning
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

let g:neoformat_enabled_javascript = ['jsbeautify', 'esformatter']

" ----------------------------------------------------------------------------
" format
" ----------------------------------------------------------------------------"

autocmd FileType javascript.jsx nnoremap <leader>p :silent %!prettier --stdin --trailing-comma es5 --tab-width 2 --use-tabs --single-quote<CR>

" ----------------------------------------------------------------------------
" js_alternate
" ----------------------------------------------------------------------------"

autocmd FileType javascript.jsx,coffee nnoremap <leader>t :call js_alternate#run()<cr>

" ----------------------------------------------------------------------------
" go
" ----------------------------------------------------------------------------"

let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_term_mode = "split"


function! s:go_run_or_test()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
		call go#cmd#Run(0)
  endif
endfunction

autocmd FileType go nmap <leader>t :GoAlternate<CR>
autocmd FileType go nmap <leader>r :<C-u>call <SID>go_run_or_test()<CR>

" ----------------------------------------------------------------------------
" elm
" ----------------------------------------------------------------------------"

let g:elm_format_autosave = 1

" }}}
