<?

@include("data_adapter.php");

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * FROM adapter.sitzverteilung_pro_partei_name" );

?>
