" vim-xqmarklogic.vim - man <Leader>B run against marklogic
" Maintainer:   Darren Cole <http://github.com/coledarr/vim-xqmarklogic>
" Version:      0.5.1
" TODO: GetLatestVimScripts: ### ### :AutoInstall: vim-xqmarklogic
" TODO: see *glvs-plugins*
" 
" Inspired partly by: http://superiorautomaticdictionary.com/vim-nirvana-interactive-xquery-with-marklogic
" Assumes xq is setup
" ==== xq.xqy ====
"       xquery version "1.0-ml";
"       
"       let
"           $db := xdmp:get-request-field("db", "Documents"),
"           $xquery := xdmp:get-request-body("text")
"       return
"           try {
"               xdmp:eval($xquery, (), <options xmlns="xdmp:eval"><database>{xdmp:database($db)}</database></options>)
"           }
"           catch($e) {
"               $e
"           }
" ==== end xq.xqy ====
" This script is will execute whatever it is sent with xdmp:eval, so it can do
" pretty anything to the database
"
" Assumes xml responses, for now tries to break up lines and re-indent (TODO better
" would be to fix the xquery output) For large responses this can be slow
"
" TODO Cleanup for release
" TODO Prompt for password if unset
" TODO Consider a different script instead of xq.xqy.  Use XCC, RestFUL
" interface (MarkLogic6 and later), or even just package up the xq.xqy
" TODO add a real help doc
" TODO only load for xquery files, and better initialization
" TODO output something useful when curl returns an error

if exists('g:loaded_vimxqmarklogic')
    finish
endif
let g:loaded_vimxqmarklogic=1

" Options
let s:showCurlCmd=0
let s:showDuration=1

" initialize Default Settings {{{
function! s:initDefaultSettings()
    if !exists('g:vimxqmarklogic_defaultUser')
        let g:vimxqmarklogic_defaultUser='admin'
    endif
    let b:vimxqmarklogic_user=g:vimxqmarklogic_defaultUser

    " TODO Want error if no global password set
    if !exists('g:vimxqmarklogic_defaultPassword')
        let g:vimxqmarklogic_defaultPassword=''
        let b:vimxqmarklogic_password=''
        unlet b:vimxqmarklogic_password
    endif
    let b:vimxqmarklogic_password=g:vimxqmarklogic_defaultPassword

    if !exists('g:vimxqmarklogic_defaultURI')
        let g:vimxqmarklogic_defaultURI='http://'
    endif
    let b:vimxqmarklogic_uri=g:vimxqmarklogic_defaultURI

    if !exists('g:vimxqmarklogic_defaultHost')
        let g:vimxqmarklogic_defaultHost='localhost'
    endif
    let b:vimxqmarklogic_host=g:vimxqmarklogic_defaultHost

    if !exists('g:vimxqmarklogic_defaultPort')
        let g:vimxqmarklogic_defaultPort='8002'
    endif
    let b:vimxqmarklogic_port=g:vimxqmarklogic_defaultPort

    if !exists('g:vimxqmarklogic_defaultXq')
        let g:vimxqmarklogic_defaultXq='/xq.xqy'
    endif
    let b:vimxqmarklogic_xq=g:vimxqmarklogic_defaultXq

    if !exists('g:vimxqmarklogic_defaultDb')
        let g:vimxqmarklogic_defaultDb="Documents"
    endif
    let b:vimxqmarklogic_db=g:vimxqmarklogic_defaultDb

    let b:vimxqmarklogic_initialized=1
endfunction
" end of default Settings }}}

" Toggle Options
command XQtoggleShowCurlCmd :execute s:toggleShowCurlCmd()
function! s:toggleShowCurlCmd()
    if (s:showCurlCmd)
        let s:showCurlCmd=0
    else
        let s:showCurlCmd=1
    endif
endfunction
command XQtoggleShowDuration :execute s:toggleShowDuration()
function! s:toggleShowDuration()
    if (s:showDuration)
        let s:showDuration=0
    else
        let s:showDuration=1
    endif
endfunction

" Settings
command -nargs=1 XQsetDatabase :execute s:setDatabase(<args>)

function! s:setDatabase(db)
    let b:vimxqmarklogic_db = a:db
endfunction

" Display settings
command XQdisplaySettings :execute s:DisplaySettings()
function! s:DisplaySettings()
    echo 'b:vimxqmarklogic_user	= ' . b:vimxqmarklogic_user
    echo 'b:vimxqmarklogic_password	= ' . b:vimxqmarklogic_password
    echo 'b:vimxqmarklogic_uri	= ' . b:vimxqmarklogic_uri
    echo 'b:vimxqmarklogic_host	= ' . b:vimxqmarklogic_host
    echo 'b:vimxqmarklogic_port	= ' . b:vimxqmarklogic_port
    echo 'b:vimxqmarklogic_xq	= ' . b:vimxqmarklogic_xq
    echo 'b:vimxqmarklogic_db	= ' . b:vimxqmarklogic_db
endfunction

" Running the Query
map <Leader>B :XQmlquery<cr>

command XQmlquery :execute s:QueryMarkLogic(expand("%"))

" Used for preview window
function! s:QueryMarkLogic(fname)
    let info        = ''

    if !exists('b:vimxqmarklogic_initialized')
        call s:initDefaultSettings()
    endif

    " setup local settings
    let l:user      = b:vimxqmarklogic_user
    let l:password  = b:vimxqmarklogic_password
    let l:uri       = b:vimxqmarklogic_uri
    let l:host      = b:vimxqmarklogic_host
    let l:port      = b:vimxqmarklogic_port
    let l:xq        = b:vimxqmarklogic_xq
    let l:db        = b:vimxqmarklogic_db

    " Could use preview window
    "let s:out = tempname()
    "pedit s:out
    "wincmd P
    
    " Use a 'nofile' window
    "botright new
    belowright new

    let info .= ' db="' . l:db . '"'

    setlocal buftype=nofile
    setlocal filetype=xml
    let curlCmd='curl --digest --user ' . l:user . ':' . l:password . ' -s -X PUT -d@"' . a:fname . '" ' . l:uri . l:host . ':' . l:port  . l:xq . '?db='.l:db

    if (s:showCurlCmd)
        call append(0, '<!-- ' . curlCmd . '  -->')
    endif

    let start=reltime()
    execute 'r! ' . curlCmd

    if (s:showDuration)
        let end=reltimestr(reltime(start))
        let info .= ' query_duration="' . end . '"'
    endif
    call append(0, '<!-- ' . info .'" -->')

    
    silent! :%s/></></g
    normal gg=G 
endfunction

" vim:foldmarker=marker foldlevel=5:
