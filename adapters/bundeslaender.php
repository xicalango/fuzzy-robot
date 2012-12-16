<?

@include("data_adapter.php");

$da = new DataAdapter();
$da->evalQueryToJSON("SELECT id, '-1' as parentid, name as text FROM land WHERE jahr='2009'");

?>
