" For disabling ZZ if there are syntax errors.
function! syntastic_extras#quit_hook()
    if &modified
        write
    endif

    SyntasticCheck
    if !exists('b:syntastic_loclist') ||
            \ empty(b:syntastic_loclist) ||
            \ b:syntastic_loclist.isEmpty()
        quit
    else
        Errors
    endif
endfun
