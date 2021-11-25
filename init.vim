set termguicolors

call plug#begin('~/.vim/plugged')

" Visual plugins
Plug 'itchyny/lightline.vim'
Plug 'pearofducks/vim-quack-lightline'
Plug 'overcache/NeoSolarized'

" IDE
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'zivyangll/git-blame.vim'
Plug 'dense-analysis/ale'
Plug 'tpope/vim-commentary'
Plug 'skanehira/docker-compose.vim'
Plug 'tpope/vim-fugitive'
Plug 'leafgarland/typescript-vim'

" Type related
Plug 'nelsyeung/twig.vim', { 'for': 'twig' }
Plug 'junegunn/goyo.vim', { 'for': 'markdown' }

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => IDE configuration 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
autocmd BufNewFile,BufRead *.js,*.html,*.css,*.scss,*.sh,*.json setlocal shiftwidth=2 tabstop=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set expandtab " Use spaces instead of tabs
set smarttab " Be smart when using tabs ;)
set shiftwidth=4 " 1 tab == 4 spaces
set tabstop=4
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
" Git Blame
nnoremap <leader>gb :<C-u>call gitblame#echo()<CR>
" Fzf
nnoremap <leader>t :GFiles<CR>
nnoremap <leader>f :Files<CR>
nnoremap <leader>C :Colors<CR>
nnoremap <C-Space> :Buffers<CR>
nnoremap <leader>l :Lines<CR>
nnoremap <leader>ag :Ag! <C-R><C-W><CR>
nnoremap <leader>m :History<CR>
nnoremap <silent> <leader>w :Welcome<CR>
nnoremap <silent> <leader>g :Goyo<CR>

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
let g:ale_linters = {'javascript': ['standard']}
let g:ale_fixers = {'javascript': ['standard']}
let g:ale_lint_on_save = 1
let g:ale_fix_on_save = 0
