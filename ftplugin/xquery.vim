" xquery.vim - man <Leader>B run against marklogic
" Maintainer:   Darren Cole <http://github.com/coledarr/xqmarklogic>
" Version:      0.7.0
" TODO: GetLatestVimScripts: ### ### :AutoInstall: xqmarklogic
" TODO: see *glvs-plugins*
" 
" Inspired partly by: http://superiorautomaticdictionary.com/vim-nirvana-interactive-xquery-with-marklogic
"
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
" The above script will execute whatever it is sent with xdmp:eval, so it can do
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


if exists('b:loaded_xqmarklogic')
    finish
endif
let b:loaded_xqmarklogic=1

" Options
let s:showCurlCmd=0
let s:showDuration=1

" Toggle Options
command -buffer XQtoggleShowCurlCmd :execute s:toggleShowCurlCmd()
function! s:toggleShowCurlCmd()
    if (s:showCurlCmd)
        let s:showCurlCmd=0
    else
        let s:showCurlCmd=1
    endif
endfunction
command -buffer XQtoggleShowDuration :execute s:toggleShowDuration()
function! s:toggleShowDuration()
    if (s:showDuration)
        let s:showDuration=0
    else
        let s:showDuration=1
    endif
endfunction

" Settings, init, & Commands to change them
function! s:initSettings()
    if !exists('g:xqmarklogic_defaultUser')
        let g:xqmarklogic_defaultUser='admin'
    endif
    let b:xqmarklogic_user=g:xqmarklogic_defaultUser
    " TODO Want error if no global password set
    if !exists('g:xqmarklogic_defaultPassword')
        let g:xqmarklogic_defaultPassword=''
        let b:xqmarklogic_password=''
        unlet b:xqmarklogic_password
    endif
    let b:xqmarklogic_password=g:xqmarklogic_defaultPassword
    if !exists('g:xqmarklogic_defaultURI')
        let g:xqmarklogic_defaultURI='http://'
    endif
    let b:xqmarklogic_uri=g:xqmarklogic_defaultURI
    if !exists('g:xqmarklogic_defaultHost')
        let g:xqmarklogic_defaultHost='localhost'
    endif
    let b:xqmarklogic_host=g:xqmarklogic_defaultHost
    if !exists('g:xqmarklogic_defaultPort')
        let g:xqmarklogic_defaultPort='8002'
    endif
    let b:xqmarklogic_port=g:xqmarklogic_defaultPort
    if !exists('g:xqmarklogic_defaultScript')
        let g:xqmarklogic_defaultScript='/xq.xqy'
    endif
    let b:xqmarklogic_script=g:xqmarklogic_defaultScript
    if !exists('g:xqmarklogic_defaultDb')
        let g:xqmarklogic_defaultDb="Documents"
    endif
    let b:xqmarklogic_db=g:xqmarklogic_defaultDb
    command -buffer -nargs=1 XQsetUser :execute s:setUser(<args>)
endfunction
call s:initSettings()

function! s:setUser(user)
    let b:xqmarklogic_user = a:user
endfunction

command -buffer -nargs=1 XQsetPassword :execute s:setPort(<args>)
function! s:setPassword(password)
    let b:xqmarklogic_password = a:password
endfunction

command -buffer -nargs=1 XQsetURI :execute s:setURI(<args>)
function! s:setURI(uri)
    let b:xqmarklogic_uri = a:uri
endfunction

command -buffer -nargs=1 XQsetHost :execute s:setHost(<args>)
function! s:setHost(host)
    let b:xqmarklogic_host = a:host
endfunction

command -buffer -nargs=1 XQsetPort :execute s:setPort(<args>)
function! s:setPort(port)
    let b:xqmarklogic_port = a:port
endfunction

command -buffer -nargs=1 XQsetScript :execute s:setScript(<args>)
function! s:setScript(script)
    let b:xqmarklogic_script = a:script
endfunction

command -buffer -nargs=1 XQsetDatabase :execute s:setDatabase(<args>)
function! s:setDatabase(db)
    let b:xqmarklogic_db = a:db
endfunction

" Display settings
command -buffer XQdisplaySettings :execute s:DisplaySettings()
function! s:DisplaySettings()
    echo 'b:xqmarklogic_user	= ' . b:xqmarklogic_user
    echo 'b:xqmarklogic_password	= ' . b:xqmarklogic_password
    echo 'b:xqmarklogic_uri	= ' . b:xqmarklogic_uri
    echo 'b:xqmarklogic_host	= ' . b:xqmarklogic_host
    echo 'b:xqmarklogic_port	= ' . b:xqmarklogic_port
    echo 'b:xqmarklogic_script	= ' . b:xqmarklogic_script
    echo 'b:xqmarklogic_db	= ' . b:xqmarklogic_db
endfunction

" Running the Query
map <Leader>B :XQmlquery<cr>
command -buffer XQmlquery :execute s:QueryMarkLogic(expand("%"))
function! s:QueryMarkLogic(fname)
    let info        = ''

    " setup local settings
    let l:user      = b:xqmarklogic_user
    let l:password  = b:xqmarklogic_password
    let l:uri       = b:xqmarklogic_uri
    let l:host      = b:xqmarklogic_host
    let l:port      = b:xqmarklogic_port
    let l:script        = b:xqmarklogic_script
    let l:db        = b:xqmarklogic_db

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
    let curlCmd='curl --digest --user ' . l:user . ':' . l:password . ' -s -X PUT -d@"' . a:fname . '" ' . l:uri . l:host . ':' . l:port  . l:script . '?db='.l:db

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

    " cleanup output
    silent! :%s/></></g
    normal gg=G 
endfunction

" vim: foldmethod=marker foldlevel=5:
