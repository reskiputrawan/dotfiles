" Basic Settings
set nocompatible              " Use Vim settings, rather than Vi settings
syntax enable                 " Enable syntax highlighting
set encoding=utf-8           " Set encoding
set number                   " Show line numbers
set relativenumber           " Show relative line numbers
set ruler                    " Show cursor position
set showcmd                  " Display incomplete commands
set wildmenu                " Display command line's tab complete options as menu
set wildmode=longest,list,full

" Indentation
set autoindent              " Auto-indent new lines
set smartindent             " Enable smart-indent
set smarttab                " Enable smart-tabs
set shiftwidth=4            " Number of auto-indent spaces
set softtabstop=4          " Number of spaces per Tab
set tabstop=4              " Number of visual spaces per TAB
set expandtab               " Tabs are spaces

" Search
set incsearch              " Search as characters are entered
set hlsearch               " Highlight matches
set ignorecase            " Ignore case in searches by default
set smartcase             " But make it case sensitive if uppercase is entered

" System clipboard
set clipboard=unnamed     " Use system clipboard

" UI Configuration
set showmatch             " Highlight matching [{()}]
set cursorline            " Highlight current line
set laststatus=2         " Always show status line
set noshowmode           " Don't show mode in command line (shown in status line)
set showcmd              " Show command in bottom bar
set wildmenu             " Visual autocomplete for command menu
set splitbelow          " Horizontal split below current window
set splitright          " Vertical split right of current window

" File Management
set nobackup             " No backup files
set nowritebackup        " No backup files while editing
set noswapfile          " No swap files
set hidden              " Buffer becomes hidden when abandoned

" Performance
set lazyredraw          " Don't redraw while executing macros
set updatetime=300      " Faster completion
set timeoutlen=500      " By default timeoutlen is 1000 ms

" Key mappings
let mapleader = " "      " Map leader key to space

" Quick save
nnoremap <leader>w :w<CR>

" Quick quit
nnoremap <leader>q :q<CR>

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Tab navigation
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap <leader>th :tabprev<CR>
nnoremap <leader>tl :tabnext<CR>

" Remove search highlighting
nnoremap <leader><space> :nohlsearch<CR>

" Better indentation
vnoremap < <gv
vnoremap > >gv

" Move lines up and down
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Autocommands
augroup vimrc
    autocmd!
    " Return to last edit position when opening files
    autocmd BufReadPost *
         \ if line("'\"") > 0 && line("'\"") <= line("$") |
         \   exe "normal! g`\"" |
         \ endif

    " Auto-reload vimrc on save
    autocmd BufWritePost .vimrc source $MYVIMRC
    
    " Strip trailing whitespace on save
    autocmd BufWritePre * :%s/\s\+$//e
augroup END

" File type specific settings
filetype plugin indent on   " Enable file type detection and do language-dependent indenting

" Different tab/space stops for different file types
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType ruby setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType javascript setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType css setlocal ts=2 sts=2 sw=2 expandtab

" Color scheme
set background=dark
" You can uncomment and set your preferred colorscheme
" colorscheme desert