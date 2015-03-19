if exists("g:loaded_syntastic_javascript_json_tool_checker")
    finish
endif
let g:loaded_syntastic_javascript_json_tool_checker = 1

let s:save_cpo = &cpo
set cpo&vim

let s:checker = expand('<sfile>:p:h') . syntastic#util#Slash() .
    \ 'json_tool.py'

function! SyntaxCheckers_javascript_json_tool_IsAvailable() dict
    return executable(self.getExec()) &&
        \ syntastic#util#versionIsAtLeast(
            \ self.getVersion(self.getExecEscaped() . ' -V'), [2, 4])
endfunction

function! SyntaxCheckers_javascript_json_tool_GetLocList() dict
    let makeprg = self.makeprgBuild({'exe': [self.getExec(), s:checker]})

    return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat':
        \     '%f:%l:%c: %m',
        \ 'returns': [0, 1]})
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'javascript',
    \ 'exec': 'python',
    \ 'name': 'json_tool'})

let &cpo = s:save_cpo
unlet s:save_cpo
