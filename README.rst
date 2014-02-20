================
syntastic-extras
================

Additional syntax checkers for the Vim plugin Syntastic_.

.. _Syntastic: https://github.com/scrooloose/syntastic

Checkers
========

- GNU Make:

.. code-block:: vim

    let g:syntastic_make_checkers = ['gnumake']

- Git commit language check:

.. code-block:: vim

    let g:syntastic_gitcommit_checkers = ['language_check']

- Subversion commit language check:

.. code-block:: vim

    let g:syntastic_svn_checkers = ['language_check']

Hooks
=====

- Block ``ZZ`` if there are syntax errors:

.. code-block:: vim

    nnoremap ZZ :call syntastic_extras#quit_hook()<cr>
