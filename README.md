xqmarklogic
===========

Vim filetype plugin enables you to run xqueries files against a MarkLogic
server, it displays the results in a separate window.

* [See](http://www.vim.org/scripts/script.php?script_id=4255)
* [Source](github.com/coledarr/vim-xqmarklogic)

Requirements
------------

vim (obviously), MarkLogic (probably obvious), and curl (not so obvious)

Installation
------------

Can be broken into two steps.  Setup vim and to setup MarkLogic

For setting up vim I'd suggest either

* [pathogen.vim](http://www.vim.org/scripts/script.php?script_id=2332)
([pathogen.vim source](http://github.com/tpope/vim-pathogen))

or

* [vundle](http://www.vim.org/scripts/script.php?script_id=3458)
([vundle source](https://github.com/gmarik/vundle))

Both have good documentation and make it far easier to setup plugins.

For pathogen put the plugin in your bundle directory and in vim run

    :Helptags

For vundle add this line to your vimrc

    Bundle 'coledarr/vim-xqmarklogic'

To manually install:

1. copy vim-xqmarklogic/ftplugin/xquery.vim to ~/.vim/ftplugin (or ~\vimfiles\ftplugin)
1. copy vim-xqmarklogic/doc/xqmarklogic.txt to ~/.vim/ftplugin (or ~\vimfiles\ftplugin)
1. In vim run:

      :helptags

For more details and setting up MarkLogic run this in vim once you've done the above:

    :help xqmarklogic-install


It works well with [xqyeryvim](http://www.vim.org/scripts/script.php?script_id=3611)
