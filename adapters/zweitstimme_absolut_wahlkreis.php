<?php

@include("data_adapter.php");

$wahlkreis_id = $_GET["wahlkreisid"];

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * FROM get_absolute_zweitstimmen_by_wahlkreis($1) ORDER BY stimmen DESC", [$wahlkreis_id] );

?>
