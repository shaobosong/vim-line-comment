" Line comment for any languages.
if exists('g:loaded_line_comment')
    finish
endif
let g:loaded_line_comment = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:line_comment_map')
    let g:line_comment_map = '<C-_>'
endif

command! -nargs=0 -range LineCommentToggle call lc#LineCommentToggle(<line1>,<line2>)

nnoremap <silent> <Plug>LineCommentToggle :LineCommentToggle<CR>
xnoremap <silent> <Plug>LineCommentToggle :LineCommentToggle<CR>

execute 'nnoremap <silent> ' . g:line_comment_map . ' <Plug>LineCommentToggle'
execute 'xnoremap <silent> ' . g:line_comment_map . ' <Plug>LineCommentToggle'

let &cpo = s:save_cpo
" vim: set sw=4 ts=4 sts=4 et ft=vim:
