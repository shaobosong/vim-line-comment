" Line comment for any languages.
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
    call s:LineComment(".", ".", a:sign, ' ', &tabstop)
endfunction

function! s:MultiLineComment(sign)
    call s:LineComment("'<", "'>", a:sign, ' ', &tabstop)
endfunction

function! s:SingleLineComment(sign)
    call s:LineComment(".", ".", a:sign, ' ', &tabstop)
endfunction

function! s:MultiLineComment(sign)
    call s:LineComment("'<", "'>", a:sign, ' ', &tabstop)
endfunction

" Examples
" Typing ^_ by <C-v><C-/>
augroup LineCommentConfig
    autocmd!
    " C
    autocmd BufNewFile,BufRead,BufEnter *.c,*.h,*.c.inc,*.cpp,*.hpp setlocal filetype=c
    autocmd FileType c,cpp xnoremap <silent>  :<c-u>call <sid>MultiLineComment('//')<cr>
    autocmd FileType c,cpp nnoremap <silent>  :call <sid>SingleLineComment('//')<cr>
    " Vim
    autocmd BufNewFile,BufRead,BufEnter *.vim,*.vimrc setlocal filetype=vim
    autocmd FileType vim xnoremap <silent>  :<c-u>call <sid>MultiLineComment('"')<cr>
    autocmd FileType vim nnoremap <silent>  :call <sid>SingleLineComment('"')<cr>
    " Bash, Make, CMake, Python
    autocmd BufNewFile,BufRead,BufEnter *.sh setlocal filetype=sh
    autocmd BufNewFile,BufRead,BufEnter Makefile* setlocal filetype=make
    autocmd BufNewFile,BufRead,BufEnter *.py setlocal filetype=python
    autocmd BufNewFile,BufRead,BufEnter CMakeLists* setlocal filetype=cmake
    autocmd FileType gdb,make,cmake,sh,python xnoremap <silent>  :<c-u>call <sid>MultiLineComment('#')<cr>
    autocmd FileType gdb,make,cmake,sh,python nnoremap <silent>  :call <sid>SingleLineComment('#')<cr>
    " Lua
    autocmd BufNewFile,BufRead,BufEnter *.lua setlocal filetype=lua
    autocmd FileType lua xnoremap <silent>  :<c-u>call <sid>MultiLineComment('--')<cr>
    autocmd FileType lua nnoremap <silent>  :call <sid>SingleLineComment('--')<cr>
augroup END
