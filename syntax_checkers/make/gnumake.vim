"============================================================================
"File:        gnumake.vim
"Description: Syntax checking plugin for makefiles.
"============================================================================

if exists("g:loaded_syntastic_make_gnumake_checker")
    finish
endif
let g:loaded_syntastic_make_gnumake_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_make_gnumake_IsAvailable() dict
    return executable('timeout') &&
        \ system('make --version') =~# '^GNU Make ' &&
        \ v:shell_error == 0
endfunction

function! SyntaxCheckers_make_gnumake_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'args_after': '--silent --just-print',
        \ 'args_before': '3 make',
        \ 'fname_before': '--file'})

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat':
        \     '%f:%l: %tarning: %m,' .
        \     '%f:%l: %m',
        \ 'returns': [0, 2, 124]})
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'make',
    \ 'exec': 'timeout',
    \ 'name': 'gnumake'})

let &cpo = s:save_cpo
unlet s:save_cpo
