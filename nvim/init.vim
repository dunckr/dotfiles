" ============================================================================
" VIM-PLUG BLOCK {{{
" ============================================================================

silent! if plug#begin('~/.config/nvim/plugged')

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'shougo/deoplete.nvim'
Plug 'mattn/emmet-vim'
Plug 'Chiel92/vim-autoformat'
Plug 'mtscout6/vim-cjsx'
Plug 'terryma/vim-multiple-cursors'
Plug 'scrooloose/nerdcommenter'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'spf13/vim-colors'

" Lang
Plug 'Shougo/neocomplcache'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
Plug 'honza/vim-snippets'
Plug 'amirh/HTML-AutoCloseTag'
Plug 'hail2u/vim-css3-syntax'
Plug 'gorodinskiy/vim-coloresque'
Plug 'tpope/vim-haml'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-markdown'
Plug 'elzr/vim-json'
Plug 'pangloss/vim-javascript'
Plug 'briancollins/vim-jst'
Plug 'kchmck/vim-coffee-script'
Plug 'junegunn/rainbow_parentheses.vim'
Plug 'benekastah/neomake'

call plug#end()
endif

" }}}
" ============================================================================
" BASIC SETTINGS {{{
" ============================================================================

set ff=unix

" color scheme
syntax enable
colorscheme default
set background=dark
colorscheme molokai

" mouse
set mouse=

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

set tabstop=2
set shiftwidth=2
set expandtab

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

" remove whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" }}}
" ============================================================================
" MAPPINGS {{{
" ============================================================================

" ----------------------------------------------------------------------------
" Basic mappings
" ----------------------------------------------------------------------------

let mapleader = ','

map <C-e> :NERDTreeToggle<CR>>

noremap H :call WrapRelativeMotion("^")<CR>
noremap L :call WrapRelativeMotion("$")<CR>

imap <expr> <Tab> CleverTab()

nnoremap <silent><C-p> :CtrlSpace O<CR>

" }}}
" ============================================================================
" FUNCTIONS & COMMANDS {{{
" ============================================================================

function! WrapRelativeMotion(key, ...)
  let vis_sel=""
  if a:0
    let vis_sel="gv"
  endif
  if &wrap
    execute "normal!" vis_sel . "g" . a:key
  else
    execute "normal!" vis_sel . a:key
  endif
endfunction

function! CleverTab()
  if pumvisible()
    return "\<C-n>"
  endif
  let substr = strpart(getline('.'), 0, col('.') - 1)
  let substr = matchstr(substr, '[^ \t]*$')
  if strlen(substr) == 0
    " nothing to match on empty string
    return "\<Tab>"
  else
    " existing text matching
    if neosnippet#expandable_or_jumpable()
      return "\<Plug>(neosnippet_expand_or_jump)"
    else
      return neocomplete#start_manual_complete()
    endif
  endif
endfunction

" }}}
" ============================================================================
" PLUGINS {{{
" ============================================================================

" ----------------------------------------------------------------------------
" deoplete
" ----------------------------------------------------------------------------"
let g:deoplete#enable_at_startup = 1

" ----------------------------------------------------------------------------
" NERDTree
" ----------------------------------------------------------------------------"
let NERDTreeShowBookmarks=1
let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
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
" ctrlp
" ----------------------------------------------------------------------------"
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](.git|.hg|.svn|node_modules|vendor|bower_components|temp|tmp)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }

" ----------------------------------------------------------------------------
" ctrlp
" ----------------------------------------------------------------------------"
autocmd FileType javascript,coffee,json RainbowParentheses

" ----------------------------------------------------------------------------
" neomake
" ----------------------------------------------------------------------------"
let g:neomake_javascript_enabled_makers = ['jshint']
let g:neomake_coffeescript_enabled_makers = ['coffeelint']
autocmd! BufWritePost * Neomake
