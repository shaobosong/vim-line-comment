# vim-line-comment
Line comment for vim

## Install
- vim-plug
```vim
Plug 'shaobosong/vim-line-comment'
```

## Global Variables
- `g:line_comment_map`: Shortcut key mapping in normal and visual mode. (Default: `'<C-_>'`, i.e. `Ctrl+/`)
- `g:line_comment_extra_sign`: Extra sign will be filled multiply between comment signs and effective expression. (Default: `' '`)
- `g:line_comment_tabstop`: Find a good position placed comment signs. (Default: `&tabstop`)
- `g:line_comment_extra_table`: Extra table including different filetypes and comment signs.

## Usage
### Configuration in vimrc
```vim
let g:line_comment_map = '<C-_>'
let g:line_comment_extra_sign = ' '
let g:line_comment_tabstop = &tabstop
let g:line_comment_extra_table = {
    \ 'vb':     "'",
    \ 'awk':    '#',
    \ 'sed':    '#',
    \ 'conf':   '#',
    \ }
augroup LineCommentAugroup
    autocmd BufNewFile,BufRead,BufEnter *.c.inc setlocal filetype=c
augroup END
```
### Command-line mode in vim
```vim
:LineCommentToggle
:1,10LineCommentToggle
:'<,'>LineCommentToggle
```

## Todo
- Support `xml` language
- Support block comments
