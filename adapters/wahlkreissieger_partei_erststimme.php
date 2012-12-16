<?php

@include("data_adapter.php");

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * FROM wahlkreissieger_partei_erststimme");

?>