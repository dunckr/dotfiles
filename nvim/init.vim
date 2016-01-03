  " ============================================================================
  " VIM-PLUG BLOCK {{{
" ============================================================================

silent! if plug#begin('~/.config/nvim/plugged')

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'junegunn/rainbow_parentheses.vim'

Plug 'shougo/deoplete.nvim'
Plug 'mattn/emmet-vim'
Plug 'Chiel92/vim-autoformat'
Plug 'mtscout6/vim-cjsx'
Plug 'terryma/vim-multiple-cursors'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/syntastic', { 'on': 'SyntasticCheck' }

" 'elzr/vim-json'
" 'groenewege/vim-less'
" 'pangloss/vim-javascript'
" 'briancollins/vim-jst'
" 'kchmck/vim-coffee-script'

call plug#end()
endif

" }}}
" ============================================================================
" BASIC SETTINGS {{{
" ============================================================================

set ff=unix

" color scheme
syntax enable

" line numbers
set relativenumber

" search
set smartcase 
set ignorecase 

" use vim, not vi api
set nocompatible

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
" autocmd BufWritePre * :%s/\s\+$//e<Paste> 

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

" }}}
" ============================================================================
" PLUGINS {{{
" ============================================================================

" ----------------------------------------------------------------------------
" syntastic
" ----------------------------------------------------------------------------"

let g:syntastic_coffee_coffeelint_args = "--csv --file ~/.coffeelint.json"
let g:syntastic_ruby_checkers = ['rubocop']"

" ----------------------------------------------------------------------------
" deoplete 
" ----------------------------------------------------------------------------"
let g:deoplete#enable_at_startup = 1
