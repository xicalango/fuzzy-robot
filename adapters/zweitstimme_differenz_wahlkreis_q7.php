<?php

@include("data_adapter.php");

$wahlkreis_id = $_GET["wahlkreisid"];

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * FROM adapter.differenz_zweitstimmen_by_wahlkreis_q7($1)", [$wahlkreis_id] );

?>
