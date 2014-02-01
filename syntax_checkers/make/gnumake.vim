"============================================================================
"File:        gnumake.vim
"Description: Syntax checking plugin for makefiles.
"Maintainer:  Steven Myint
"
"============================================================================

if exists("g:loaded_syntastic_make_gnumake_checker")
    finish
endif
let g:loaded_syntastic_make_gnumake_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_make_gnumake_IsAvailable() dict
    return executable('gtimeout') &&
        \ system('make --version') =~# '^GNU Make ' &&
        \ v:shell_error == 0
endfunction

function! SyntaxCheckers_make_gnumake_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'args_after': '--silent --just-print',
        \ 'args_before': '20 make',
        \ 'fname_before': '--file'})

    let errorformat = '%f:%l: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'returns': [0, 2, 124]})
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'make',
    \ 'exec': 'gtimeout',
    \ 'name': 'gnumake'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
