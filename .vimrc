
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vundle 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible              " be iMproved, required
filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'wincent/command-t'
Plugin 'tpope/vim-fugitive'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'shawncplus/phpcomplete.vim'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'itchyny/lightline.vim'

call vundle#end()            " required
filetype plugin indent on    " required

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins configuration 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Lightline
set laststatus=2
if !has('gui_running')
    set t_Co=256
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => IDE configuration 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set shell=/bin/zsh 
set relativenumber " show relative numbers line
set showmatch " highlight matching [{()}]
set lazyredraw " Speed up the macro, lazy redraw http://www.matthewoakley.co.uk/how-to-speed-up-your-macros-in-vim/
set omnifunc=syntaxcomplete#Complete " Enable omnicompletion

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
set wildignore=*.o,*~,*.pyc,*cache/*,*log/*,.svn/*,vendor/*,.git/*,*.png,*.jpg,*.gif
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile
set wildmenu  " visual autocomplete for command menu

autocmd BufNewFile,BufRead *.json set filetype=javascript
autocmd BufNewFile,BufRead *.md set filetype=markdown
autocmd BufNewFile,BufRead *.twig set filetype=html
autocmd BufNewFile,BufRead *.phtml set filetype=php

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
set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Custom mappings 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ","
" Move pastetoggle to F3 because guake uses F2
set pastetoggle=<F3>
" Toggle relative numbers line
nmap <silent> m :set relativenumber!<CR>

