if exists("g:loaded_syntastic_gitcommit_proselint_checker")
    finish
endif
let g:loaded_syntastic_gitcommit_proselint_checker = 1

let s:save_cpo = &cpo
set cpo&vim

let s:wrapper =
    \ expand('<sfile>:p:h') . syntastic#util#Slash() . 'proselint_wrapper.py'

function! SyntaxCheckers_gitcommit_proselint_IsAvailable() dict
    return executable(self.getExec()) &&
        \ syntastic#util#versionIsAtLeast(
            \ self.getVersion(self.getExecEscaped() . ' -V'), [2, 4])
endfunction

function! SyntaxCheckers_gitcommit_proselint_GetLocList() dict
    let makeprg = self.makeprgBuild({
        \ 'args_before': s:wrapper})

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
    \ 'exec': 'python'})

let &cpo = s:save_cpo
unlet s:save_cpo
