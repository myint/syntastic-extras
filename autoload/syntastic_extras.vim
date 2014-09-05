" For disabling ZZ if there are syntax errors.
function! syntastic_extras#quit_hook()
    write
    SyntasticCheck
    if exists('b:syntastic_loclist') &&
            \ !empty(b:syntastic_loclist) &&
            \ b:syntastic_loclist.isEmpty()
        quit
    else
        Errors
    endif
endfun
