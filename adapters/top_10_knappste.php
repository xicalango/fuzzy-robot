<?php

@include("data_adapter.php");

$partei_id = $_GET["parteiid"];

$da = new DataAdapter();
$da->evalQueryToJSON( "(
SELECT ks.vorname, ks.nachname, p.name as partei from get_10_knappste_sieger($1) ks, partei p 
where p.id = ks.partei_id
union 
SELECT ks.vorname, ks.nachname, p.name from get_10_knappste_verlierer($1) ks, partei p 
where p.id = ks.partei_id)", [ partei_id] );

?>
