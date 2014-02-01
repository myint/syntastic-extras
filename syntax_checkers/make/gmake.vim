"============================================================================
"File:        gmake.vim
"Description: Syntax checking plugin for makefiles.
"Maintainer:  Steven Myint
"
"============================================================================

if exists("g:loaded_syntastic_make_gmake_checker")
    finish
endif
let g:loaded_syntastic_make_gmake_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_make_gmake_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'args_after': '--silent --just-print',
        \ 'fname_before': '--file' })

    let errorformat = '%f:%l: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'returns': [0, 2] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'make',
    \ 'name': 'gmake'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
