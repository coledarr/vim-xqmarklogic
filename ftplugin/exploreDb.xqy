xquery version "1.0-ml";

for $doc in fn:doc()
    let $uri := fn:document-uri($doc)
return
    <document db_uri="{$uri}">
        {if ($doc/name(/*) = "")
            (: Assume a binary document if root element name is "" :)
            then <binary-node>1</binary-node>
            else <root-element>{$doc/name(/*)}</root-element>}
            {if (fn:empty(xdmp:document-properties($uri)))
                (: if empty, no properties :)
                then <properties>false</properties>
                else <properties>true</properties>}
      <collections>{xdmp:document-get-collections($uri)}</collections>
    </document>
