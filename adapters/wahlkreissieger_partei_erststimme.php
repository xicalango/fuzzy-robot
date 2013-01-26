<?php

@include("data_adapter.php");

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * FROM adapter.wahlkreissieger_partei_erststimme");

?>
