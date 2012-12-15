<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<?php include("header.php");?>
</head>
<body>

	<div id='jqxDockPanel' style="background: none; border: none;">	
					
		<div dock='top'>
			<?php include("menu_bundesebene.html"); ?>		
		</div>
		<div dock='left'>
			<?php include("menu.html") ?>
		</div>
		<div id='Sitzverteilung_Sitzverteilung' dock='right'>
			Bundesebene
			<div id='pieChartBundesebene' style="width: 680px; height: 400px;"></div>
		</div>
	</div>
	
	
</body>
</html>
