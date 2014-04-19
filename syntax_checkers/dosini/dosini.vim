if exists("g:loaded_syntastic_dosini_dosini_checker")
    finish
endif
let g:loaded_syntastic_dosini_dosini_checker = 1

let s:save_cpo = &cpo
set cpo&vim

let s:checker = expand('<sfile>:p:h') . syntastic#util#Slash() . 'dosini.py'

function! SyntaxCheckers_dosini_dosini_IsAvailable() dict
    return executable(self.getExec()) &&
        \ syntastic#util#versionIsAtLeast(
            \ syntastic#util#getVersion(self.getExecEscaped() . ' -V'), [2, 4])
endfunction

function! SyntaxCheckers_dosini_dosini_GetLocList() dict
    let makeprg = self.makeprgBuild({'exe': [self.getExec(), s:checker]})

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat':
        \     '%f:%l: %m',
        \ 'returns': [0]})
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'dosini',
    \ 'exec': 'python',
    \ 'name': 'dosini'})

let &cpo = s:save_cpo
unlet s:save_cpo
