<?php

@include("data_adapter.php");

$partei_id = $_GET["parteiid"];

$da = new DataAdapter();
$da->evalQueryToJSON( "select * from adapter.top_10($1)", [ $partei_id] );

?>
