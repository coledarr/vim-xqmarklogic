" xquery.vim - <Leader>B or <C-CR> run buffer against marklogic as an xquery
" Maintainer:   Darren Cole <http://github.com/coledarr/vim-xqmarklogic>
" Version:      1.1.1
" TODO: Add support for: GetLatestVimScripts: ### ### :AutoInstall: xqmarklogic
" TODO: see *glvs-plugins* might not work, but should at least try
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
" Assumes xml responses, for now tries to break up lines and re-indent For
" large responses this can be slow
"
" TODO output something more useful when curl return errors or status
" TODO should probably use <Plug>...


if exists('b:loaded_xqmarklogic')
    finish
endif
let b:loaded_xqmarklogic=1

" Settings, init, & Commands to change them 
function! s:initSettings() "{{{
    " Buffer settings {{{
    if !exists('g:xqmarklogic_defaultUser')
        let g:xqmarklogic_defaultUser='admin'
    endif
    let b:xqmarklogic_user=g:xqmarklogic_defaultUser
    " only set b:xqmarklogic_password if there is a default password
    " then prompt for it if needed later
    if exists('g:xqmarklogic_defaultPassword')
        let b:xqmarklogic_password=g:xqmarklogic_defaultPassword
    endif
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
        let g:xqmarklogic_defaultDb='Documents'
    endif
    let b:xqmarklogic_db=g:xqmarklogic_defaultDb
    if !exists('g:xqmarklogic_defaultMaxLinesIndent')
        let g:xqmarklogic_defaultMaxLinesIndent='400'
    endif
    let b:xqmarklogic_maxLinesIndent=g:xqmarklogic_defaultMaxLinesIndent
    " }}}

    " Buffer options {{{
    if !exists('g:xqmarklogic_defaultShowCurlCmd')
        let g:xqmarklogic_defaultShowCurlCmd=0
    endif
    let b:xqmarklogic_showCurlCmd=g:xqmarklogic_defaultShowCurlCmd
    if !exists('g:xqmarklogic_defaultshowDuration')
        let g:xqmarklogic_defaultShowDuration=1
    endif
    let b:xqmarklogic_showDuration=g:xqmarklogic_defaultShowDuration
    if !exists('g:xqmarklogic_defaultshowDb')
        let g:xqmarklogic_defaultShowDb=1
    endif
    let b:xqmarklogic_showDb=g:xqmarklogic_defaultShowDb

    if !exists('g:xqmarklogic_defaultNoOutCleanup')
        let g:xqmarklogic_defaultNoOutCleanup=0
    endif
    let b:xqmarklogic_noOutCleanup=g:xqmarklogic_defaultNoOutCleanup
    " }}}

    " global settings
    if !exists('g:xqmarklogic_noMappings')
        let g:xqmarklogic_noMappings=0
    endif
    if exists('g:mapleader')
        let l:leader = g:mapleader
    else
        let l:leader = '\'
    endif
    if !exists('g:xqmarklogic_ExploreDBKey')
        let g:xqmarklogic_ExploreDBKey = l:leader . 'E'
    endif
    if !exists('g:xqmarklogic_ExecQueryKey')
        let g:xqmarklogic_ExecQueryKey = l:leader . 'B'
    endif
    if !exists('g:xqmarklogic_MLExecQueryKey')
        let g:xqmarklogic_MLExecQueryKey = '<C-CR>'
    endif


endfunction
call s:initSettings()
" }}}

" set option & commands {{{
command -buffer -nargs=1 XQsetUser :execute s:setUser(<args>)
function! s:setUser(user)
    let b:xqmarklogic_user = a:user
endfunction

command -buffer XQsetPassword :execute s:setPassword()
function! s:setPassword()
    let b:xqmarklogic_password = inputsecret('MarkLogic ' . b:xqmarklogic_user . ' password:')
endfunction

command -buffer XQsetDefaultPassword :execute s:setDefaultPassword()
function! s:setDefaultPassword()
    let g:xqmarklogic_defaultPassword = inputsecret('MarkLogic ' . b:xqmarklogic_user . ' password:')
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

command -buffer -nargs=1 XQsetMaxLinesIndent :execute s:setMaxLinesIndent(<args>)
function! s:setMaxLinesIndent(lines)
    let b:xqmarklogic_maxLinesIndent=a:lines
endfunction
" end of set option & commands }}}

" Toggle Options & Commands {{{
command -buffer XQtoggleShowCurlCmd :execute s:toggleShowCurlCmd()
function! s:toggleShowCurlCmd()
    if (b:xqmarklogic_showCurlCmd)
        let b:xqmarklogic_showCurlCmd=0
    else
        let b:xqmarklogic_showCurlCmd=1
    endif
endfunction
command -buffer XQtoggleShowDuration :execute s:toggleShowDuration()
function! s:toggleShowDuration()
    if (b:xqmarklogic_showDuration)
        let b:xqmarklogic_showDuration=0
    else
        let b:xqmarklogic_showDuration=1
    endif
endfunction
command -buffer XQtoggleShowDb :execute s:toggleShowDb()
function! s:toggleShowDb()
    if (b:xqmarklogic_showDb)
        let b:xqmarklogic_showDb=0
    else
        let b:xqmarklogic_showDb=1
    endif
endfunction
command -buffer XQtoggleOutCleanup :execute s:toggleOutCleanup()
function! s:toggleOutCleanup()
    if (b:xqmarklogic_noOutCleanup)
        let b:xqmarklogic_noOutCleanup=0
    else
        let b:xqmarklogic_noOutCleanup=1
    endif
endfunction
" end of toggle commands }}}

" Display settings {{{
command -buffer XQdisplaySettings :execute s:DisplaySettings()
function! s:DisplaySettings()
    echo ' --- settings --- '
    echo 'b:xqmarklogic_host	= ' . b:xqmarklogic_host
    echo 'b:xqmarklogic_uri	= ' . b:xqmarklogic_uri
    echo 'b:xqmarklogic_port	= ' . b:xqmarklogic_port
    echo 'b:xqmarklogic_user	= ' . b:xqmarklogic_user
    echo 'b:xqmarklogic_password	= ' . b:xqmarklogic_password
    echo 'b:xqmarklogic_script	= ' . b:xqmarklogic_script
    echo 'b:xqmarklogic_db	= ' . b:xqmarklogic_db
    echo 'b:xqmarklogic_maxLinesIndent = ' . b:xqmarklogic_maxLinesIndent
    echo ' --- options --- '
    echo 'b:xqmarklogic_noOutCleanup	= ' . b:xqmarklogic_noOutCleanup
    echo 'b:xqmarklogic_showDuration	= ' . b:xqmarklogic_showDuration
    echo 'b:xqmarklogic_showDb		= ' . b:xqmarklogic_showDb
    echo 'b:xqmarklogic_showCurlCmd	= ' . b:xqmarklogic_showCurlCmd
    echo ' --- global ---'
    echo 'g:xqmarklogic_noMappings	= ' . g:xqmarklogic_noMappings
    echo 'g:xqmarklogic_ExploreDBKey	= ' . g:xqmarklogic_ExploreDBKey
    echo 'g:xqmarklogic_ExecQueryKey	= ' . g:xqmarklogic_ExecQueryKey
    echo 'g:xqmarklogic_MLExecQueryKey	= ' . g:xqmarklogic_MLExecQueryKey
endfunction "}}}

" List the documents in database
let s:thisfile = expand('<sfile>')

" Mappings, commands, and functions {{{
if (!g:xqmarklogic_noMappings)
    if g:xqmarklogic_ExploreDBKey != ''
        exec 'map <buffer> ' . g:xqmarklogic_ExploreDBKey . ' :XQexploreDb<cr>'
    endif
endif
command -buffer XQexploreDb :execute s:ExploreDatabase()
function! s:ExploreDatabase()
    call s:QueryGenericMarkLogic('@'.fnameescape(fnamemodify(s:thisfile, ':p:h'). '/exploreDb.xqy'), 0)
endfunction

" Running the Buffer as a Query
if (!g:xqmarklogic_noMappings)
    if g:xqmarklogic_ExecQueryKey != ''
        exec 'map <buffer> ' . g:xqmarklogic_ExecQueryKey . ' :XQmlquery<cr>'
    endif
    if g:xqmarklogic_MLExecQueryKey != ''
        exec 'map <buffer> ' . g:xqmarklogic_MLExecQueryKey . ' :XQmlquery<cr>'
    endif
endif
command -buffer XQmlquery :execute s:QueryMarkLogic(expand('%'))
function! s:QueryMarkLogic(fname)
    if &modified
        echoerr 'Buffer has been changed, using last saved version'
    endif
    call s:QueryGenericMarkLogic('@'.a:fname, 1)
endfunction
" }}}

" Runs the query using curl
" a:data - what to put after the -d" in the curl command
command -buffer XQmlqueryArgs :execute s:QueryGenericMarkLogic(<args>)
function! s:QueryGenericMarkLogic(data, bufferQuery)
    " setup local settings
    let l:user      = b:xqmarklogic_user
    let l:uri       = b:xqmarklogic_uri
    let l:host      = b:xqmarklogic_host
    let l:port      = b:xqmarklogic_port
    let l:script    = b:xqmarklogic_script
    let l:db        = b:xqmarklogic_db
    let l:maxLinesIndent = b:xqmarklogic_maxLinesIndent
    let l:noOutClean = b:xqmarklogic_noOutCleanup
    let l:showCurlCmd = b:xqmarklogic_showCurlCmd
    let l:showDuration = b:xqmarklogic_showDuration
    let l:showDb    = b:xqmarklogic_showDb
    let l:info=''

    " prompt for password if b:xqmarklogic_password and
    " g:xqmarklogic_defaultPassword are unset
    let l:password = ''
    if !exists('b:xqmarklogic_password')
        if !exists('g:xqmarklogic_defaultPassword')
            let l:password = inputsecret('MarkLogic ' . b:xqmarklogic_user . ' password:')
            " since default password was unset assume we should use the same
            " for all passwords
            " TODO decide if this is best.  Might be better not to do this,
            " and let XQsetDefaultPassword provide a solution instead
            "let g:xqmarklogic_defaultPassword = l:password
        else
            " since default exists use that password
            let l:password = g:xqmarklogic_defaultPassword
        endif
        " keep password for next time
        let b:xqmarklogic_password = l:password
    else
        let l:password  = b:xqmarklogic_password
    endif

    " Could use preview window
    "let s:out = tempname()
    "pedit s:out
    "wincmd P
    
    " Use a 'nofile' window
    "botright new
    belowright new
    setlocal buftype=nofile
    setlocal filetype=xml

    " Buffer Mappings for Result window
    if (a:bufferQuery)
        if g:xqmarklogic_ExploreDBKey != ''
            exec "map <buffer> " . g:xqmarklogic_ExploreDBKey . " <C-W><C-P>:XQexploreDb<cr>"
        endif
    else
        if g:xqmarklogic_ExploreDBKey != ''
            exec "map <buffer> " . g:xqmarklogic_ExploreDBKey . " :q<CR>:XQexploreDb<cr>"
        endif
    endif
    if g:xqmarklogic_ExecQueryKey != ''
        exec "map <buffer> " . g:xqmarklogic_ExecQueryKey . " :q<CR>:XQmlqueryArgs \"" . a:data . "\", 1<CR>"
    endif
    if g:xqmarklogic_MLExecQueryKey != ''
        exec "map <buffer> " . g:xqmarklogic_MLExecQueryKey . " :q<CR>:XQmlqueryArgs \"" . a:data . "\", 1<cr>"
    endif
    map <buffer> q :q<CR>

    if (l:showDb)
        let l:info .= ' db="' . l:db . '"'
    endif

    let curlCmd='curl --digest --user ' . l:user . ':' . l:password . ' -s -X PUT -d"' . a:data . '" ' . "'" . l:uri . l:host . ':' . l:port  . l:script . '?db='.l:db . "'"

    if (l:showCurlCmd)
        call append(0, '<!-- ' . curlCmd . '  -->')
    endif

    let start=reltime()
    execute 'r! ' . curlCmd

    if (l:showDuration)
        let end=reltimestr(reltime(start))
        let l:info .= ' query_duration="' . end . '"'
    endif
    if (l:info != '' )
        call append(0, '<!-- ' . l:info .' -->')
    endif

    " cleanup output
    if (!l:noOutClean)
        silent! :%s/></></g
        if line('$') < l:maxLinesIndent
            normal gg=G 
            setlocal foldlevel=10
        endif
    endif
endfunction

" vim: foldmethod=marker foldlevel=0:
