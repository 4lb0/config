if !$TERM_PROGRAM =~ "Apple_Terminal"
  set termguicolors
endif

call plug#begin('~/.vim/plugged')

" Visual plugins
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'

" IDE
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'dense-analysis/ale'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'editorconfig/editorconfig-vim'
Plug 'vim-test/vim-test'

" Type related
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'maxmellon/vim-jsx-pretty'
Plug 'nelsyeung/twig.vim', { 'for': 'twig' }
Plug 'cespare/vim-toml', { 'for': 'toml', 'branch': 'main' }
Plug 'jfecher/vale.vim', { 'for': 'vale' }
Plug 'bakpakin/janet.vim', { 'for': 'janet' }
Plug 'lluchs/vim-wren', { 'for': 'wren' }
Plug 'deoplete-plugins/deoplete-clang'

" Initialize plugin system
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Lightline
set showtabline=2
set noshowmode

function! CocCurrentFunction()
    return get(b:, 'coc_current_function', '')
endfunction

let g:lightline = {
\   'colorscheme': 'darcula',
\   'active': {
\    'left': [ [ 'mode', 'paste' ], [ 'cocstatus', 'currentfunction', 'readonly', 'filename', 'modified' ] ]
\   },
\   'tabline': {
\    'left': [ ['buffers'] ],
\    'right': [ ['close'] ]
\   },
\   'component_function': {
\    'cocstatus': 'coc#status',
\    'currentfunction': 'CocCurrentFunction'
\   },
\   'component_expand': {
\    'buffers': 'lightline#bufferline#buffers'
\   },
\   'component_type': {
\     'buffers': 'tabsel'
\   }
\ }

if !has('gui_running')
    set t_Co=256
endif
syntax enable

packadd! dracula_pro
syntax enable
let g:dracula_colorterm = 0
colorscheme dracula_pro

" CoC
set cmdheight=2
set updatetime=300
set shortmess+=c
set signcolumn=number

" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')
" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)
" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')
" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Mappings for CoCList
" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Show commands
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => IDE configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=utf-8
set shell=/bin/zsh
set relativenumber " show relative numbers line
set showmatch " highlight matching [{()}]
set lazyredraw " Speed up the macro, lazy redraw http://www.matthewoakley.co.uk/how-to-speed-up-your-macros-in-vim/
set omnifunc=syntaxcomplete#Complete " Enable omnicompletion
let php_htmlInStrings = 1
set title " Improve terminal title
set list listchars=tab:\ \ ,nbsp:␣,trail:•,extends:⟩,precedes:⟨ " Highlight trailing white space
set clipboard=unnamedplus " share clipboard with OS

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Search
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set ignorecase " Ignore case when searching
set smartcase " When searching try to be smart about cases
set hlsearch " Highlight search results
set incsearch " Makes search act like search in modern browsers

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set the files we don't want to search
set wildignore=*.o,*~,*.pyc,*cache/*,*log/*,.git/*,.svn/*,*/vendor/*,*/node_modules/*,*.png,*.jpg,*.gif,*.pdf
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile
set wildmenu  " visual autocomplete for command menu

autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd BufNewFile,BufRead *.phtml set filetype=php
autocmd BufNewFile,BufRead *.ts, *.tsx set filetype=typescript
autocmd BufNewFile,BufRead *.php,*.java,*.c setlocal shiftwidth=4 tabstop=4
autocmd BufNewFile,BufRead *.hwt set filetype=hwt
autocmd BufNewFile,BufRead *.blt set filetype=bialet

autocmd BufNewFile *pages/*.md 0r ~/.vim/skeletons/blog-post.md

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set expandtab " Use spaces instead of tabs
set smarttab " Be smart when using tabs ;)
set shiftwidth=2 " 1 tab == 4 spaces
set tabstop=2
" Linebreak on 500 characters
set lbr
set tw=500
set autoindent
set smartindent
set wrap "Wrap lines
set nofoldenable " Prevent folding

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Custom mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ","
" Move pastetoggle to F3 because guake uses F2
set pastetoggle=<F3>
" Toggle relative numbers line
nnoremap <silent> m :set relativenumber!<CR>
" Git
nnoremap gs :Git status<CR>
nnoremap gb :Git blame<CR>
" Tests
nnoremap <silent> <leader>t :TestSuite<CR>
" Fzf
nnoremap <silent> <leader>g :GFiles<CR>
nnoremap <silent> <leader>f :Files<CR>
nnoremap <silent> <leader>b :Buffers<CR>
nnoremap <silent> <leader>l :Lines<CR>
nnoremap <silent> <leader>S :Ag! <C-R><C-W><CR>
" Buffers
nnoremap <silent> <leader>n :enew<CR>
nnoremap <silent> <tab> :bnext<CR>
nnoremap <silent> <s-tab> :bprevious<CR>
" close buffer and go to previous one if exists
nnoremap <silent> q :
\ if len(getbufinfo({'buflisted':1})) > 1  <BAR>
\   bprevious <BAR>
\   bdelete # <BAR>
\ else <BAR>
\   bdelete <BAR>
\ endif <CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => JS Standard https://standardjs.com/#vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_linters = {
\  'javascript': ['prettier', 'standard'],
\  'html': ['prettier', 'tidy'],
\  'typescript': ['prettier', 'tslint'],
\  'c': ['clang'],
\  'python': ['pylint'],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\  'javascript': ['prettier', 'standard'],
\  'html': ['prettier', 'tidy'],
\  'typescript': ['prettier', 'tslint'],
\  'c': ['clang'],
\  'rust': ['rustfmt'],
\}
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 0

let g:ale_typescript_tslint_use_global = 0

nnoremap <silent> ff :ALEFix<CR>
