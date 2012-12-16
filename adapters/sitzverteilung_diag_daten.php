<?

@include("data_adapter.php");

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * FROM sitzverteilung_diagramm" );

?>
