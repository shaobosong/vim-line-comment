" Line comment for any languages.
if exists('g:loaded_line_comment')
    finish
endif
let g:loaded_line_comment = 1

if !exists('g:line_comment_map')
    let g:line_comment_map = '<C-_>'
endif

if !exists('g:line_comment_extra_sign')
    let g:line_comment_extra_sign = ' '
endif

if !exists('g:line_comment_tabstop')
    let g:line_comment_tabstop = &tabstop
endif

let s:line_comment_table = {
            \ 'vim':        '"',
            \ 'c':          '//',
            \ 'cpp':        '//',
            \ 'cs':         '//',
            \ 'go':         '//',
            \ 'rust':       '//',
            \ 'java':       '//',
            \ 'javascript': '//',
            \ 'php':        '//',
            \ 'swift':      '//',
            \ 'kotlin':     '//',
            \ 'typescript': '//',
            \ 'sh':         '#',
            \ 'zsh':        '#',
            \ 'fish':       '#',
            \ 'gdb':        '#',
            \ 'perl':       '#',
            \ 'ruby':       '#',
            \ 'make':       '#',
            \ 'cmake':      '#',
            \ 'python':     '#',
            \ 'tmux':       '#',
            \ 'meson':      '#',
            \ 'sshconfig':  '#',
            \ 'sshdconfig': '#',
            \ 'systemd':    '#',
            \ 'tcl':        '#',
            \ 'ada':        '--',
            \ 'lua':        '--',
            \ 'haskell':    '--',
            \ 'vhdl':       '--',
            \ 'erlang':     '%',
            \ 'prolog':     '%',
            \ }

if exists('g:line_comment_extra_table')
    call extend(s:line_comment_table, g:line_comment_extra_table, "force")
endif

function! s:LineComment(r0, r1, sign, extra_sign, align)
    let l:need_sign = v:false
    let l:indent = 999
    for l:lnr in range(a:r0, a:r1)
        let l:line = getline(l:lnr)
        if len(l:line) == 0
            continue
        endif
        let l:need_sign = l:need_sign || match(l:line, '^[\t* *]*' . a:sign, 0) < 0
        let l:indent =  min([indent(l:lnr), l:indent])
    endfor
    " Round indent down to nearest multiple. Requires that align be a power of 2.
    let l:indent = and(l:indent, -a:align)
    " Prepend or remove signs.
    for l:lnr in range(a:r0, a:r1)
        let l:line = getline(l:lnr)
        if len(l:line) == 0
            continue
        endif
        " Prepend a sign.
        if l:need_sign
            " Find a good position for sign, even if '\t' exists in a line.
            for l:i in range(0, len(l:line))
                let l:prev = strpart(l:line, 0, l:i)
                call setline(l:lnr, l:prev)
                if indent(l:lnr) < l:indent
                    continue
                endif
                let l:next = strpart(l:line, l:i)
                let l:newline = l:prev . a:sign . a:extra_sign . l:next
                call setline(l:lnr, l:newline)
                break
            endfor
        " Remove a sign.
        else
            let l:sign_match = match(l:line, a:sign, 0)
            let l:prev = strpart(l:line, 0, l:sign_match)
            let l:next = strpart(l:line, l:sign_match + len(a:sign))
            if match(l:next, a:extra_sign, 0) == 0
                let l:next = strpart(l:next, len(a:extra_sign))
            endif
            let l:newline = l:prev . l:next
            call setline(l:lnr, l:newline)
        endif
    endfor
endfunction

function! s:LineCommentToggle(line1, line2)
    let l:sign = get(s:line_comment_table, &filetype, '#')
    call s:LineComment(a:line1, a:line2, l:sign, g:line_comment_extra_sign, g:line_comment_tabstop)
endfunction

command! -nargs=0 -range LineCommentToggle call s:LineCommentToggle(<line1>,<line2>)

nnoremap <silent> <Plug>LineCommentToggle :LineCommentToggle<CR>
xnoremap <silent> <Plug>LineCommentToggle :LineCommentToggle<CR>

execute 'nnoremap <silent> ' . g:line_comment_map . ' <Plug>LineCommentToggle'
execute 'xnoremap <silent> ' . g:line_comment_map . ' <Plug>LineCommentToggle'

" vim: set sw=4 ts=4 sts=4 et ft=vim:
