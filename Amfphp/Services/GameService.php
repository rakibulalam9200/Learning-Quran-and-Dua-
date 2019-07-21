<?php 

/**
 * 
 */
class GameService
{
	private $conn;
	
	function __construct()
	{
		$this->conn=mysqli_connect("localhost","root","","quran_dua");
		// Check connection
		if ($this->conn->connect_error) {
		    return "Connection failed: " . $conn->connect_error;
		} 
		return "Connected successfully";
	}
	
	public function generateHighscore($value)
	{
		
		$query="INSERT INTO scoredata(score) VALUES('$value[0]')";
		$result=$this->conn->query($query);
		if ($result) {
			return true;
		}else
		{
			return false;
		}
	}
	public function showHighscore()
	{
		$query="SELECT MAX(score) AS maximum FROM  scoredata LIMIT 1";
		$result=$this->conn->query($query);
		if ($result) {
			$rows= array();
			if ($result->num_rows > 0) {
				while ($row = $result->fetch_assoc()) {
					$rows[]=$row;
				}
			}else
			{
				$rows[0]['id']=0;
				$rows[0]['score']='';
			}
			return $rows;
		}else
		{
			return false;
		}
	}
	
	

}


 ?>