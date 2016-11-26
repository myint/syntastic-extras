if exists("g:loaded_syntastic_gitcommit_proselint_checker")
    finish
endif
let g:loaded_syntastic_gitcommit_proselint_checker = 1

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_gitcommit_proselint_GetLocList() dict
    let makeprg = self.makeprgBuild({})

    let errorformat =
        \ '%f:%l:%c: %m'

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'defaults': { 'type': 'W', 'subtype': 'Style' },
        \ 'returns': [0, 1] })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'gitcommit',
    \ 'name': 'proselint',
    \ 'exec': 'proselint'})

let &cpo = s:save_cpo
unlet s:save_cpo
