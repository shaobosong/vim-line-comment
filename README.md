# vim-line-comment
Line comment for vim

## Plug Install
```vim
Plug 'shaobosong/vim-line-comment'
```

## Plug Global Variables Notes
- `g:line_comment_map`: Shortcut key mapping in normal and visual mode. (Default: `'<C-_>'`)
- `g:line_comment_extra_sign`: Single filled sign between comment sign and effective expression. (Default: `' '`)
- `g:line_comment_tabstop`: Indent. (Default: `&tabstop`)
- `g:line_comment_extra_table`: User custom table including filetypes and comment signs.

## Plug Usages
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
