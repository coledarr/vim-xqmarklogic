" vim-xqmarklogic.vim - man <Leader>B run against marklogic
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
" This script is will execute whatever it is sent with xdmp:eval, so it can do
" pretty anything to the database
"
" Assumes xml responses, for not tries to break up lines and re-indent (TODO better
" would be to fix the xquery output) For large responses this can be slow
"
" TODO The user and password are encoded in this file, and should be changed
" (prompt for password and cache for later calls) Or at least allow setting
" the values
" TODO Consider a different script instead of xq.xqy.  Use XCC, RestFUL
" interface (MarkLogic6 and later), or even just package up the xq.xqy
" TODO xq.xqy hardcodes database, but it would be better to be configurable
" (db http header can be set to override hardcoded default).  Best would be
" configured on a per buffer basis and maybe a default set in .vimrc
" TODO add a real help doc
" 
" Maintainer:   Darren Cole <http://github.com/coledarr/vim-xqmarklogic>
" Version:      0.3


" Options
let s:curlCmd=0
let s:showDuration=1

" Toggle Options
command -buffer XQtoggleCurlCmdAppend :execute s:toggleCurlCmdAppend()
function! s:toggleCurlCmdAppend()
    if (s:curlCmd)
        let s:curlCmd=0
    else
        let s:curlCmd=1
    endif
endfunction
command -buffer XQToggleShowDuration :execute s:toggleShowDuration()
function! s:toggleShowDuration()
    if (s:showDuration)
        let s:showDuration=0
    else
        let s:showDuration=1
    endif
endfunction

" Running the Query
map <Leader>B :XQmlquery<cr>

command -buffer XQmlquery :execute s:QueryMarkLogic(expand("%"))

let s:host = "localhost"
let s:uri = "http://"
let s:port = "8002"
let s:user = "admin"
let s:password = "password"
let s:xq = "/xq.xqy"

" Used for preview window
"let s:out = tempname()
function! s:QueryMarkLogic(fname)
    " Use preview window
    "pedit s:out
    "wincmd P
 
    " Use a 'nofile' window
    botright new
    setlocal buftype=nofile
    setlocal filetype=xml

    if (s:curlCmd)
        call append(0, '<!--  curl --digest --user ' . s:user . ':XXXXXX -s -X PUT -d@"' . a:fname . '" ' . s:uri . s:host . ':' . s:port  . s:xq  . '  -->')
    endif

    let start=reltime()
    execute 'r! curl --digest --user ' . s:user . ':' . s:password . ' -s -X PUT -d@"' . a:fname . '" ' . s:uri . s:host . ':' . s:port  . s:xq
    "execut 'r! curl --digest --user admin:password -s -X PUT -d@"' . a:fname . '" http://localhost:8002/xq.xqy'
    if (s:showDuration)
        let end=reltimestr(reltime(start))
        call append(0, '<!-- query_duration="' . end .'" -->')
    endif

    
    silent! :%s/></></g
    normal gg=G 
endfunction
