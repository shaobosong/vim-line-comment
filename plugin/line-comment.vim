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

let s:line_comment_table = [
    \ ['vim',          '"'],
    \ ['c',            '//'],
    \ ['cpp',          '//'],
    \ ['cs',           '//'],
    \ ['go',           '//'],
    \ ['rust',         '//'],
    \ ['java',         '//'],
    \ ['javascript',   '//'],
    \ ['php',          '//'],
    \ ['swift',        '//'],
    \ ['kotlin',       '//'],
    \ ['typescript',   '//'],
    \ ['sh',           '#'],
    \ ['zsh',          '#'],
    \ ['fish',         '#'],
    \ ['gdb',          '#'],
    \ ['perl',         '#'],
    \ ['ruby',         '#'],
    \ ['make',         '#'],
    \ ['cmake',        '#'],
    \ ['python',       '#'],
    \ ['tmux',         '#'],
    \ ['meson',        '#'],
    \ ['ssh_config',   '#'],
    \ ['sshd_config',  '#'],
    \ ['systemd',      '#'],
    \ ['tcl',          '#'],
    \ ['ada',          '--'],
    \ ['lua',          '--'],
    \ ['haskell',      '--'],
    \ ['vhdl',         '--'],
    \ ['erlang',       '%'],
    \ ['prolog',       '%'],
\ ]

if exists('g:line_comment_extra_table')
    call extend(s:line_comment_table, g:line_comment_extra_table)
endif

function! s:LineComment(r0, r1, sign, extra_sign, align)
    let l:need_sign = v:false
    let l:indent = 999
    for l:lnr in range(line(a:r0), line(a:r1))
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
    for l:lnr in range(line(a:r0), line(a:r1))
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

function! s:SingleLineComment(sign)
    call s:LineComment(".", ".", a:sign, g:line_comment_extra_sign, g:line_comment_tabstop)
endfunction

function! s:MultiLineComment(sign)
    call s:LineComment("'<", "'>", a:sign, g:line_comment_extra_sign, g:line_comment_tabstop)
endfunction

augroup LineCommentAugroup
    autocmd!
    for [filetypes, commsigns] in s:line_comment_table
        execute 'autocmd FileType ' . filetypes . ' nnoremap <silent> ' . g:line_comment_map . ' :call <sid>SingleLineComment(''' . commsigns . ''')<CR>'
        execute 'autocmd FileType ' . filetypes . ' xnoremap <silent> ' . g:line_comment_map . ' :<C-U>call <sid>MultiLineComment(''' . commsigns . ''')<CR>'
    endfor
augroup END
