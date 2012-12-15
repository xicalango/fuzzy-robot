<?

$conn = pg_connect("host=link port=5432 dbname=btw2009 user=btw2009 password=btw2009") or die("Connection error...");

$qresult = pg_query( $conn, "SELECT id, '-1' as partentid, name as text FROM land WHERE jahr='2009'") or die("Query error...");


$result = array();

while($arr = pg_fetch_assoc($qresult)) {
	array_push($result, $arr);
}



header('Content-type: application/json');
echo json_encode($result);

?>
