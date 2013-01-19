<?php

@include("data_adapter.php");

$da = new DataAdapter();
$da->evalQueryToJSON( "select * from adapter.ueberhangmandate" );

?>
