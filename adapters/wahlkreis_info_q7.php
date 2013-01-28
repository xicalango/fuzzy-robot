<?php

@include("data_adapter.php");

$wahlkreis_id = $_GET["wahlkreisid"];

$da = new DataAdapter();
$info = $da->queryToArray( "SELECT * FROM adapter.wahlbeteiligung_q7 WHERE wahlkreis_id = $1", [$wahlkreis_id] );
$direktkandidat = $da->queryToArray( "SELECT * FROM adapter.gewaehlter_direktkandidat_by_wahlkreis_q7($1)", [$wahlkreis_id] );

$info[0]["direktkandidat"] = $direktkandidat[0];

$da->setJSONHeader();
echo json_encode( $info[0] );

?>

