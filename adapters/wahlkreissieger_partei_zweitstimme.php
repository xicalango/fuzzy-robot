<?php

@include("data_adapter.php");

$wahlkreis_id = $_GET["wahlkreisid"];

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * FROM wahlkreissieger_partei_zweitstimme($1)", [$wahlkreis_id] );

?>