================
syntastic-extras
================

Additional syntax checkers for the Vim plugin Syntastic_.

.. _Syntastic: https://github.com/scrooloose/syntastic

Checkers
========

- ``cfg``/``dosini`` syntax checker:

.. code-block:: vim

    let g:syntastic_cfg_checkers = ['cfg']
    let g:syntastic_dosini_checkers = ['dosini']

- GNU Make:

.. code-block:: vim

    let g:syntastic_make_checkers = ['gnumake']

- Language check in ``gitcommit``/``svn`` (commit prompts):

.. code-block:: vim

    let g:syntastic_gitcommit_checkers = ['language_check']
    let g:syntastic_svn_checkers = ['language_check']

Hooks
=====

- Block ``ZZ`` if there are syntax errors:

.. code-block:: vim

    nnoremap ZZ :call syntastic_extras#quit_hook()<cr>
