# vim-line-comment
Line comment for vim

## Install
```vim
Plug 'shaobosong/vim-line-comment'
```

## Global Variables
- `g:line_comment_map`: Shortcut key mapping in normal and visual mode. (Default: `'<C-_>'`)
- `g:line_comment_extra_sign`: Extra sign will be filled multiply between comment signs and effective expression. (Default: `' '`)
- `g:line_comment_tabstop`: Find a good position placed comment signs. (Default: `&tabstop`)
- `g:line_comment_extra_table`: Extra table including different filetypes and comment signs.

## Usage
```vim
let g:line_comment_map = '<C-_>'
let g:line_comment_extra_sign = ' '
let g:line_comment_tabstop = &tabstop
let g:line_comment_extra_table = [
    \ ['vb',  ''''''],
    \ ['awk', '#'],
    \ ['sed', '#'],
\ ]
augroup MyAugroup
    autocmd BufNewFile,BufRead,BufEnter *.c.inc setlocal filetype=c
augroup END
```

## Todo
- Support `xml` language
- Support block comments
