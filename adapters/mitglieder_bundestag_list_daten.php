<?

@include("data_adapter.php");

$da = new DataAdapter();
$da->evalQueryToJSON( "SELECT * from mitglieder_bundestag" );

?>
