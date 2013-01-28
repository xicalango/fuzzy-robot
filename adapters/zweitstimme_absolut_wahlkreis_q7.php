<?php

@include("data_adapter.php");

$wahlkreis_id = $_GET["wahlkreisid"];

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * FROM adapter.absolute_zweitstimmen_by_wahlkreis_q7($1) ORDER BY stimmen DESC", [$wahlkreis_id] );

?>
