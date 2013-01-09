<?

@include("data_adapter.php");

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * FROM adapter.ergebnisse_zweitstimme_diagramm_name" );

?>
