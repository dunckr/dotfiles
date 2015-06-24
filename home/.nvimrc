let g:python_host_prog='/usr/local/bin/python'

" PLUG#BEGIN (plugin manager begin) {{
" ==================================================================================================================================
call plug#begin('~/.nvim/plugged')

" VIM-GITGUTTER (show git diff in gutter)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/airblade/vim-gitgutter'
  function! SetGitGutter()
    let g:gitgutter_sign_column_always=0         " disable gutter when gitgutter disabled
    let g:gitgutter_enabled=1                    " enable at start
    let g:gitgutter_max_signs=1000               " max signs
    let g:gitgutter_sign_added="\u271a"          " heavy greek cross
    let g:gitgutter_sign_modified="\u279c"       " heavy rounded-tip rightwards arrow
    let g:gitgutter_sign_removed="\u2718"        " heavy ballot X
    let g:gitgutter_sign_modified_removed="►"    " medium right facing triangle
    let g:gitgutter_signs=1                      " enable signs by default
    let g:gitgutter_highlight_lines=0            " enable line highlights
    " toggle gitgutter
    nnoremap <Leader>gg :GitGutterToggle<CR>
  endfunction
" ----------------------------------------------------------------------------------------------------------------------------------

" AG (silver_sercher, super fast, replacepment for ack)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/rking/ag.vim'
" ----------------------------------------------------------------------------------------------------------------------------------

" TABULAR (provides filtering and alignment)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/godlygeek/tabular'
" ----------------------------------------------------------------------------------------------------------------------------------

" VIM-MULTPLE-CURSORS (multiple cursor support like sublime text)
" ----------------------------------------------------------------------------------------------------------------------------------
" NOTE VISUAL MODE:
"   1. ctrl-n will select the word(s) and place you in VISUAL mode
"   3. 'h','j','k' and 'l' will allow you to change the selection block
"   4. 'c' or 's' will delete the selected word(s) and enter INSERT mode
" NOTE NORMAL MODE:
"   1. use 'v' to enter normal mode
"   2. 'i' will insert at the cursor(s) current location
"   3. 'I' will move the cursor to the beginning of the line for insertion
"   4. 'a' will move the cursor to the end of the word for insertion
"   4. 'A' will move the cursor to the end of the line for insertion
Plug 'https://github.com/terryma/vim-multiple-cursors'
  function! SetMultipleCursors()
    " turn off defaults as they may conflict with CtrlP
    let g:multi_cursor_use_default_mapping=0
    let g:multi_cursor_next_key='<C-n>'
    let g:multi_cursor_prev_key='<C-m>'
    let g:multi_cursor_skip_key='<C-x>'
    let g:multi_cursor_quit_key='<Esc>'
  endfunction
" ----------------------------------------------------------------------------------------------------------------------------------

" SUPERTAB (awesome tab completion)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/ervandew/supertab'
  function! SetSuperTab()
    "@see - https://github.com/ervandew/supertab/issues/99
    let g:SuperTabDefaultCompletionType="context"
    let g:SuperTabContextDefaultCompletionType="<c-p>"
    let g:SuperTabCompletionContexts=['s:ContextText', 's:ContextDiscover']
    let g:SuperTabContextDiscoverDiscovery=["&omnifunc:<c-x><c-o>"]
    autocmd FileType *
        \ if &omnifunc != '' |
        \   call SuperTabChain(&omnifunc, "<c-p>") |
        \   call SuperTabSetDefaultCompletionType("<c-x><c-u>") |
        \ endif
  endfunction
" ----------------------------------------------------------------------------------------------------------------------------------

" DASH (load dash api support, must have dash installed, OSX only)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/rizzatti/dash.vim'
" ----------------------------------------------------------------------------------------------------------------------------------

" DELIMITMATE (autocompletion for parens, brackets, etc.)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/Raimondi/delimitMate'
" ----------------------------------------------------------------------------------------------------------------------------------

" SYNTASTIC (compilation syntax checker)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/scrooloose/syntastic'
  function! SetSyntastic()
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
    let g:syntastic_always_populate_loc_list=1
    let g:syntastic_auto_loc_list=1
    let g:syntastic_check_on_open=1
    let g:syntastic_check_on_wq=0
  endfunction
" ----------------------------------------------------------------------------------------------------------------------------------

" VIM-COLORS-SOLARIZED (best colorscheme around)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/chriskempson/base16-vim'

" ----------------------------------------------------------------------------------------------------------------------------------

" LIGHTLINE (best statusline for vim hands down!)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/itchyny/lightline.vim'
  function! SetLightline()
  endfunction
" ----------------------------------------------------------------------------------------------------------------------------------

" INDENTLINE (indents as thin vertical lines)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/Yggdroot/indentLine'
  function! SetIndentline()
    let g:indentLine_char='┋'
    let g:indentLine_leadingSpaceChar="."
    let g:indentLine_leadingSpaceEnabled=1
  endfunction
" ----------------------------------------------------------------------------------------------------------------------------------

" RAINBOW_PARENTHESIS (nested colored parenthesis)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/junegunn/rainbow_parentheses.vim'
  function! SetRainbowParen()
    nnoremap <Leader>r :RainbowParentheses!!<CR>
    let g:rainbow#max_level=16
    let g:rainbow#pairs=[['(', ')'], ['[', ']'], ['{','}']]
  endfunction
" ----------------------------------------------------------------------------------------------------------------------------------

" NERDTREE (explorer style navigation)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/scrooloose/nerdtree'
  function! SetNerdTree()
    nnoremap <c-e> :NERDTreeToggle<cr>
    nnoremap <Leader>t :NERDTreeToggle<CR>
    let g:NERDTreeShowHidden=1
    map <C-k><C-b> :NERDTreeToggle<CR>:NERDTreeMirror<CR>
  endfunction
" ----------------------------------------------------------------------------------------------------------------------------------

" CTRLP (fuzzy finder for files, buffers, mru, outline, etc.)
" ----------------------------------------------------------------------------------------------------------------------------------
Plug 'https://github.com/ctrlpvim/ctrlp.vim'
  function! SetCtrlP()
    let g:ctrlp_user_command='ag %s -l -g ""'    " use ag with (-l = files-with-matches, -g = pattern)
    let g:ctrlp_use_caching=0                    " disable cache, ag is more than fast enough
    " bottom = position window at bottom
    " order:ttb = order results from top to bottom
    " min:1 = minimum window size of 1
    " max:20 = maximum window size of 20
    " results:100 = maximum result list of 100 items
    let g:ctrlp_match_window='bottom,order:ttb,min:1,max:20,results:100'
  endfunction
" ----------------------------------------------------------------------------------------------------------------------------------

" DEFAULTS {{
" ==================================================================================================================================
" default mapping for keys

call SetCtrlP()         " init CtrlP
call SetGitGutter()     " init GitGutter
call SetNerdTree()      " init NerdTree
" ==================================================================================================================================
" }}

" COLORS {{
" ==================================================================================================================================
syntax enable
set background=dark     " important for dark schemes
color base16-eighties
" ----------------------------------------------------------------------------------------------------------------------------------

" KEYBINDS {{
" hardmode=1
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>
" ----------------------------------------------------------------------------------------------------------------------------------

" PLUG#END (plugin manager end)
call plug#end()
