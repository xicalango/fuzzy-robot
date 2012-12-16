<?php

@include("data_adapter.php");

$partei_id = $_GET["parteiid"];

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * get_10_knappste_sieger($1) union Select * from get_10_knappste_verlierer($1)", [$partei_id] );

?>