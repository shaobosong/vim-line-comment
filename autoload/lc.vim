let s:save_cpo = &cpo
set cpo&vim

if !exists('g:line_comment_extra_sign')
    let g:line_comment_extra_sign = ' '
endif

if !exists('g:line_comment_tabstop')
    let g:line_comment_tabstop = &tabstop
endif

let s:line_comment_table = {
            \ 'vim':        '"',
            \ 'xml':        {'left': '<!--', 'right': '-->'},
            \
            \ 'c':          '//',
            \ 'c3':         '//',
            \ 'cpp':        '//',
            \ 'cs':         '//',
            \ 'go':         '//',
            \ 'java':       '//',
            \ 'javascript': '//',
            \ 'kotlin':     '//',
            \ 'php':        '//',
            \ 'rust':       '//',
            \ 'swift':      '//',
            \ 'typescript': '//',
            \ 'zig':        '//',
            \
            \ 'awk':        '#',
            \ 'cmake':      '#',
            \ 'conf':       '#',
            \ 'fish':       '#',
            \ 'gdb':        '#',
            \ 'make':       '#',
            \ 'meson':      '#',
            \ 'perl':       '#',
            \ 'python':     '#',
            \ 'ruby':       '#',
            \ 'sed':        '#',
            \ 'sh':         '#',
            \ 'sshconfig':  '#',
            \ 'sshdconfig': '#',
            \ 'systemd':    '#',
            \ 'tcl':        '#',
            \ 'tmux':       '#',
            \ 'zsh':        '#',
            \
            \ 'ada':        '--',
            \ 'haskell':    '--',
            \ 'lua':        '--',
            \ 'vhdl':       '--',
            \
            \ 'erlang':     '%',
            \ 'prolog':     '%',
            \
            \ 'vb':         "'",
            \ }

if exists('g:line_comment_extra_table')
    call extend(s:line_comment_table, g:line_comment_extra_table, "force")
endif

function! s:GetCommentSpec(filetype)
    let l:comment = get(s:line_comment_table, a:filetype, '#')
    if type(l:comment) == v:t_dict
        return {
                    \ 'left': get(l:comment, 'left', '#'),
                    \ 'right': get(l:comment, 'right', ''),
                    \ }
    endif
    return {'left': l:comment, 'right': ''}
endfunction

function! s:FindInsertIndex(line, target_indent)
    for l:i in range(0, len(a:line))
        if strdisplaywidth(strpart(a:line, 0, l:i)) >= a:target_indent
            return l:i
        endif
    endfor
    return len(a:line)
endfunction

function! s:IsCommented(line, left, right)
    let l:start = match(a:line, '\S')
    if l:start < 0
        return v:false
    endif
    if strpart(a:line, l:start, len(a:left)) !=# a:left
        return v:false
    endif
    if empty(a:right)
        return v:true
    endif
    let l:trail = matchstr(a:line, '\s*$')
    let l:end = len(a:line) - len(l:trail)
    if l:end < l:start + len(a:left) + len(a:right)
        return v:false
    endif
    return strpart(a:line, l:end - len(a:right), len(a:right)) ==# a:right
endfunction

function! s:CommentLine(line, left, right, extra_sign, indent)
    let l:index = s:FindInsertIndex(a:line, a:indent)
    let l:prev = strpart(a:line, 0, l:index)
    let l:next = strpart(a:line, l:index)
    let l:trail = matchstr(l:next, '\s*$')
    let l:body = strpart(l:next, 0, len(l:next) - len(l:trail))
    let l:newline = l:prev . a:left
    if !empty(a:extra_sign)
        let l:newline .= a:extra_sign
    endif
    let l:newline .= l:body
    if !empty(a:right)
        if !empty(l:body) && !empty(a:extra_sign)
            let l:newline .= a:extra_sign
        endif
        let l:newline .= a:right
    endif
    return l:newline . l:trail
endfunction

function! s:UncommentLine(line, left, right, extra_sign)
    let l:start = match(a:line, '\S')
    let l:pos = l:start + len(a:left)
    if !empty(a:extra_sign) && strpart(a:line, l:pos, len(a:extra_sign)) ==# a:extra_sign
        let l:pos += len(a:extra_sign)
    endif
    let l:prev = strpart(a:line, 0, l:start)
    let l:next = strpart(a:line, l:pos)
    if empty(a:right)
        return l:prev . l:next
    endif

    let l:trail = matchstr(l:next, '\s*$')
    let l:body = strpart(l:next, 0, len(l:next) - len(l:trail))
    let l:end = len(l:body) - len(a:right)
    let l:body = strpart(l:body, 0, l:end)
    if !empty(a:extra_sign) && len(l:body) >= len(a:extra_sign)
                \ && strpart(l:body, len(l:body) - len(a:extra_sign), len(a:extra_sign)) ==# a:extra_sign
        let l:body = strpart(l:body, 0, len(l:body) - len(a:extra_sign))
    endif
    return l:prev . l:body . l:trail
endfunction

function! s:LineComment(r0, r1, left, right, extra_sign, align)
    let l:need_sign = v:false
    let l:indent = 999
    for l:lnr in range(a:r0, a:r1)
        let l:line = getline(l:lnr)
        if len(l:line) == 0
            continue
        endif
        let l:need_sign = l:need_sign || !s:IsCommented(l:line, a:left, a:right)
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
            call setline(l:lnr, s:CommentLine(l:line, a:left, a:right, a:extra_sign, l:indent))
        " Remove a sign.
        else
            call setline(l:lnr, s:UncommentLine(l:line, a:left, a:right, a:extra_sign))
        endif
    endfor
endfunction

function! lc#LineCommentToggle(line1, line2)
    let l:comment = s:GetCommentSpec(&filetype)
    call s:LineComment(a:line1, a:line2, l:comment.left, l:comment.right, g:line_comment_extra_sign, g:line_comment_tabstop)
endfunction

let &cpo = s:save_cpo
