if exists("g:loaded_syntastic_cfg_cfg_checker")
    finish
endif
let g:loaded_syntastic_cfg_cfg_checker = 1

let s:save_cpo = &cpo
set cpo&vim

let s:checker = expand('<sfile>:p:h') . syntastic#util#Slash() . 'cfg.py'

function! SyntaxCheckers_cfg_cfg_IsAvailable() dict
    return executable(self.getExec()) &&
        \ syntastic#util#versionIsAtLeast(
            \ syntastic#util#getVersion(self.getExecEscaped() . ' -V'), [2, 4])
endfunction

function! SyntaxCheckers_cfg_cfg_GetLocList() dict
    let makeprg = self.makeprgBuild({'exe': [self.getExec(), s:checker]})

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat':
        \     '%f:%l: %m',
        \ 'returns': [0, 1]})
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'cfg',
    \ 'exec': 'python',
    \ 'name': 'cfg'})

let &cpo = s:save_cpo
unlet s:save_cpo
