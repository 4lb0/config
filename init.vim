if !$TERM_PROGRAM =~ "Apple_Terminal"
  set termguicolors
endif

call plug#begin('~/.vim/plugged')

" Visual plugins
Plug 'itchyny/lightline.vim'
Plug 'pearofducks/vim-quack-lightline'
Plug 'Mofiqul/dracula.nvim'

" IDE
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'dense-analysis/ale'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'editorconfig/editorconfig-vim'

" Type related
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'nelsyeung/twig.vim', { 'for': 'twig' }
Plug 'cespare/vim-toml', { 'for': 'toml', 'branch': 'main' }
Plug 'jfecher/vale.vim', { 'for': 'vale' }
Plug 'bakpakin/janet.vim', { 'for': 'janet' }

" Initialize plugin system
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins configuration 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Lightline
set laststatus=2
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
" Fzf
nnoremap <leader>t :GFiles<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>l :Lines<CR>
nnoremap <leader>S :Ag! <C-R><C-W><CR>
nnoremap <leader>h :History<CR>

" TODO mappings, yes this maybe be a function later
let g:light_todo_list_pending = "✘"
let g:light_todo_list_done = "✔"

nnoremap <silent> tt :.s/^\([✘✔*-] \)\?/\=submatch(0)=="✘ "?"✔ ":"✘ "/g<bar>let @/=""<cr>
vnoremap <silent> tt :s/\_^\([✘✔*-] \)\?/\=submatch(1)=="✘ "? "✔ ":"✘ "/g<bar>let @/=""<cr>
" Add td as todo done
" Add tp as todo pending 
" No add todo on empty string
" 2tt<arrow> motion keys - https://vi.stackexchange.com/questions/5495/mapping-with-motion

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => JS Standard https://standardjs.com/#vim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_linters = {'javascript': ['prettier', 'standard'], 'html': ['prettier', 'tidy'], 'typescript': ['prettier', 'tslint']}
let g:ale_fixers = {'javascript': ['prettier', 'standard'], 'html': ['prettier', 'tidy'], 'typescript': ['prettier', 'tslint']}
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 0

let g:ale_typescript_tslint_use_global = 0

nnoremap <silent> ff :ALEFix<CR>
