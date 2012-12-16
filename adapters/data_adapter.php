<?

class DataAdapter
{

	private static $db_login_data = array(
	    "host" => "link",
	    "user" => "btw2009",
	    "password" => "btw2009",
	    "db" => "btw2009"
	);


	var $dbConnection;

	function DataAdapter( )
	{
		$dbConnString = "host=".self::$db_login_data["host"]." dbname=".self::$db_login_data["db"]." user=".self::$db_login_data["user"]." password=".self::$db_login_data["password"];

		$this->dbConnection = pg_pconnect($dbConnString) or die("bla");
	}


	function close()
	{
		pg_close($this->dbConnection);
	}

	function query( $query )
	{
		if( !$result = pg_query( $this->dbConnection, pg_escape_string ( $this->dbConnection, $query ) ) )
		{
			die("Error during Query: " . pg_error());
		}

		return $result;
	}
	
	function queryToArray( $query )
	{
		$result = array();
		$qresult = $this->query( $query );

		while($arr = pg_fetch_assoc($qresult)) {
			array_push($result, $arr);
		}
		
		return $result;
	}
	
	function queryToJSON( $query )
	{
		$result = $this->queryToArray( $query );
		
		return json_encode($result);
	}

	function evalQueryToJSON( $query )
	{
		$json = $this->queryToJSON( $query );

		header('Content-type: application/json');
		echo $json;
	}
}

?>
