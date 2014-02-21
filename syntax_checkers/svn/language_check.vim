if exists("g:loaded_syntastic_svn_language_check_checker")
    finish
endif
let g:loaded_syntastic_svn_language_check_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_svn_language_check_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'args_after':
        \ '--disable=EN_QUOTES --disable=EN_UNPAIRED_BRACKETS ' .
        \ '--ignore-lines="^(--|.    |@@|==|-|\+|}|Index: )" ' .
        \ '--spell-check-off'})

    let errorformat =
        \ '%f:%l:%c: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'subtype': 'Style',
        \ 'returns': [0, 2] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'svn',
    \ 'name': 'language_check',
    \ 'exec': 'language-check'})

let &cpo = s:save_cpo
unlet s:save_cpo
