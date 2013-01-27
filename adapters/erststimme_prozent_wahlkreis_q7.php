<?php

@include("data_adapter.php");

$wahlkreis_id = $_GET["wahlkreisid"];

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * FROM adapter.prozent_erststimmen_by_wahlkreis_q7($1) ORDER BY prozent DESC", [$wahlkreis_id] );

?>
