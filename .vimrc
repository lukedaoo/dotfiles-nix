set clipboard=unnamedplus
set cmdheight=2
set mouse="a
set showmode
set splitbelow  
set splitright
set hlsearch   
set incsearch   
set ignorecase   
set number   
set relativenumber

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent

set scrolloff=8
set sidescrolloff=8
set colorcolumn=120

syntax on
set termguicolors
colorscheme GruberDarker


" === Leader key ===
let mapleader = " "

" === Basic Shortcuts ===
nnoremap <leader>q :exit<CR>
nnoremap <leader>h :nohlsearch<CR>
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>
nnoremap <C-a> ggVG
nnoremap <leader>\| :vsplit<CR>
nnoremap <leader>_ :split<CR>
nnoremap <leader>se <C-w>=
nnoremap <leader>sx :close<CR>
nnoremap <leader><leader> ciw

" === Clipboard Mappings (requires +clipboard support) ===
"
" Keymaps for system clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y

nnoremap <leader>p "+p
vnoremap <leader>p "+p

" Fallback if +clipboard not available
xnoremap p P

" === Visual Mode Movement ===
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
vnoremap w iw

" Easier line navigation
nnoremap H ^
nnoremap L g_
vnoremap H ^
vnoremap L g_
onoremap H ^
onoremap L g_

" Scroll with recenter
nnoremap J <C-D>zz
nnoremap K <C-U>zz
vnoremap J <C-D>zz
vnoremap K <C-U>zz
onoremap J <C-D>zz
onoremap K <C-U>zz

" Indent visually selected text
xnoremap < <gv
xnoremap > >gv

" Move selected lines
xnoremap K :move '<-2<CR>gv-gv
xnoremap J :move '>+1<CR>gv-gv

" === Window Navigation ===
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" === Resize splits ===
nnoremap <S-Up> :resize +2<CR>
nnoremap <S-Down> :resize -2<CR>
nnoremap <S-Left> :vertical resize -2<CR>
nnoremap <S-Right> :vertical resize +2<CR>

" === Tab management ===
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tq :tabclose<CR>
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>

" === Delete without yanking ===
nnoremap <leader>x "_x
vnoremap <leader>x "_x
vnoremap vd "_d
nnoremap vd "_dd

" === Escape from insert ===
inoremap jj <ESC>
inoremap jk <ESC>
inoremap kk <ESC>
inoremap AA <ESC>
inoremap VV <ESC>V

" === Save/Quit Command Abbreviations ===
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev WQ wq
cnoreabbrev Wq wq
cnoreabbrev Wqa wqa
cnoreabbrev w; w
cnoreabbrev ;w w

nnoremap <C-x> :wq<CR>

" === Disable accidental command history ===
nnoremap q: <Nop>
nnoremap q/ <Nop>
nnoremap q? <Nop>
nnoremap qq <Nop>
vnoremap Q <Nop>
nnoremap q <Nop>

" === Search with visual selection ===
vnoremap n :<C-u>let @/ = '\V' . escape(@", '/\')<CR>
