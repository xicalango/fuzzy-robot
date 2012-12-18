<?php

@include("data_adapter.php");

$partei_id = $_GET["parteiid"];

$da = new DataAdapter();
$da->evalQueryToJSON( "select * from get_top_10($1)", [ $partei_id] );

?>
