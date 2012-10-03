xquery version "1.0-ml";

let
    $db := xdmp:get-request-field("db", "Documents"),
    $xquery := xdmp:get-request-body("text")
return
    try {
        xdmp:eval($xquery, (), <options xmlns="xdmp:eval"><database>{xdmp:database($db)}</database></options>)
    }
    catch($e) {
        $e
    }
