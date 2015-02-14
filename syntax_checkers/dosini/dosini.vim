if exists("g:loaded_syntastic_dosini_dosini_checker")
    finish
endif
let g:loaded_syntastic_dosini_dosini_checker = 1

runtime! syntax_checkers/cfg/cfg.vim

call g:SyntasticRegistry.CreateAndRegisterChecker({
    \ 'filetype': 'dosini',
    \ 'exec': 'python',
    \ 'name': 'dosini',
    \ 'redirect': 'cfg/cfg'})
