<?php

@include("data_adapter.php");

$wahlkreis_id = $_GET["wahlkreisid"];

$da = new DataAdapter();
$info = $da->queryToArray( "SELECT * FROM adapter.wahlbeteiligung WHERE wahlkreis_id = $1", [$wahlkreis_id] );
$direktkandidat = $da->queryToArray( "SELECT * FROM get_gewaehlte_direktkandidaten_by_wahlkreis($1)", [$wahlkreis_id] );

$info[0]["direktkandidat"] = $direktkandidat[0];

$da->setJSONHeader();
echo json_encode( $info[0] );

?>

