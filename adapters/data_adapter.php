<?php

class DataAdapter
{

	private static $db_login_data = array(
	    "host" => "link",
	    "user" => "btw2009",
	    "password" => "btw2009",
	    "db" => "btw2009"
	);


	var $dbConnection;

	/** Creates a new DataAdapter with default credentials
	*
	*/
	function DataAdapter( )
	{
		$dbConnString = "host=".self::$db_login_data["host"]." dbname=".self::$db_login_data["db"]." user=".self::$db_login_data["user"]." password=".self::$db_login_data["password"];

		$this->dbConnection = pg_pconnect($dbConnString) or die("bla");
	}

	/** Closes a DataAdapter (not really needed)
	*
	*/
	function close()
	{
		pg_close($this->dbConnection);
	}

	/** Executes a query 
	* \return A postgres query result cursor 
	*/
	function query( $query, $params = array() )
	{
		if( !$result = pg_query_params( $this->dbConnection, $query, $params ) )
		{
			die("Error during Query: " . pg_last_error($this->dbConnection));
		}

		return $result;
	
	}
	
	/** Executes a query and pushes the results into an array
	*
	*/
	function queryToArray( $query, $params = array() )
	{
		$result = array();
		$qresult = $this->query( $query, $params );

		while($arr = pg_fetch_assoc($qresult)) {
			array_push($result, $arr);
		}
		
		return $result;
	}
	
	/** Executes a query and returns the result as json array
	*
	*/
	function queryToJSON( $query, $params  = array() )
	{
		$result = $this->queryToArray( $query, $params );
		
		return json_encode($result);
	}

	function setJSONHeader()
	{
		header('Content-type: application/json');
	}

	/** Executes a query, sets the header to json and prints the json result
	*
	*/
	function evalQueryToJSON( $query, $params  = array() )
	{
		$json = $this->queryToJSON( $query, $params );

		$this->setJSONHEader();
		echo $json;
	}
}

?>
