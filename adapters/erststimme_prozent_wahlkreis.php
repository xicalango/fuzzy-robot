<?php

@include("data_adapter.php");

$wahlkreis_id = $_GET["wahlkreisid"];

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * FROM get_prozent_erststimmen_by_wahlkreis($1)", [$wahlkreis_id] );

?>