" Like Syntastic's normal checker, but only checks files if there is a
" '.syntastic_c_config' file existing in the directory or an ancestor
" directory.

if exists('g:loaded_syntastic_c_check_checker')
    finish
endif
let g:loaded_syntastic_c_check_checker = 1

if !exists('g:syntastic_c_compiler_options')
    let g:syntastic_c_compiler_options = '-std=gnu99'
endif

if !exists('g:syntastic_c_config_file')
    let g:syntastic_c_config_file = '.syntastic_c_config'
endif

let s:save_cpo = &cpo
set cpo&vim

let s:checker = expand('<sfile>:p:h') . syntastic#util#Slash() . 'check.py'

function! SyntaxCheckers_cfg_cfg_IsAvailable() dict
    return executable(self.getExec()) &&
        \ syntastic#util#versionIsAtLeast(
            \ syntastic#util#getVersion(self.getExecEscaped() . ' -V'), [2, 4])
endfunction

function! SyntaxCheckers_c_check_GetLocList() dict
    if !exists('g:syntastic_c_compiler')
        let g:syntastic_c_compiler = executable('gcc') ? 'gcc' : 'clang'
    endif

    let makeprg = self.makeprgBuild({
        \ 'args_before': s:checker,
        \ 'args_after':
            \ g:syntastic_c_config_file . ' ' .
            \ g:syntastic_c_compiler . ' ' .
            \ g:syntastic_c_compiler_options})

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat':
        \     '%-G%f:%s:,' .
        \     '%f:%l:%c: %trror: %m,' .
        \     '%f:%l:%c: %tarning: %m,' .
        \     '%f:%l:%c: %m,'.
        \     '%f:%l: %trror: %m,'.
        \     '%f:%l: %tarning: %m,'.
        \     '%f:%l: %m'})
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'c',
    \ 'name': 'check',
    \ 'exec': 'python'})

let &cpo = s:save_cpo
unlet s:save_cpo
