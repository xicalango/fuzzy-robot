<?

@include("connect.php");

class DataAdapter
{
	var $dbConnection;

	function DataAdapter( $host, $db, $username, $password )
	{
		$dbConnString = "host=".$db_login_data["host"]." dbname=".$db_login_data["db"]." user=".$db_login_data["user"]." password=".$db_login_data["password"];

		$this->dbConnection = pg_pconnect($dbConnString);
	}


	function close()
	{
		pg_close($this->dbConnection);
	}

	function query( $query )
	{
		if( !$result = pg_query( $this->dbConnection, pg_escape_string ( $this->dbConnection, $query ) )
		{
			die "Error during Query: " . pg_error();
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

}

?>
