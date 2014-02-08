" For disabling ZZ if there are syntax errors.
function! syntastic_extras#quit_hook()
    write
    if g:syntastic_mode_map.mode ==# 'passive'
        SyntasticCheck
    endif
    if exists('b:syntastic_loclist') &&
            \ !empty(b:syntastic_loclist) &&
            \ b:syntastic_loclist.isEmpty()
        quit
    else
        Errors
    endif
endfun
