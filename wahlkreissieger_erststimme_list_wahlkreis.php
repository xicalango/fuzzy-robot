<!DOCTYPE html>
<html lang="en">
<head>
   <title id='Description'>Tabellarische Übersicht über die Sitzverteilung im Bundestag</title>
    <link rel="stylesheet" href="lib/jqwidgets/styles/jqx.base.css" type="text/css" />
    <script type="text/javascript" src="lib/scripts/jquery-1.7.2.min.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxcore.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxbuttons.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxdata.js"></script>    
	<script type="text/javascript" src="lib/jqwidgets/jqxscrollbar.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxmenu.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxgrid.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxgrid.selection.js"></script>
	<script type="text/javascript">
        $(document).ready(function () {
            // prepare the data
            
			
			<?php
			$wahlkreis_id = $_GET["wahlkreisid"];	
			$url = 'adapters/wahlkreissieger_partei_erststimme.php?wahlkreisid=' . $wahlkreis_id;
			?>
			
			
		var source =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'wahlkreis'},
					 { name: 'partei'}
				],
				url: <?php echo $url; ?>
			};


var dataAdapter = new $.jqx.dataAdapter(source);		
			
			
            $("#jqxgrid").jqxGrid(
            {
                source: dataAdapter,
                columns: [
                  { text: 'Wahlkreis', datafield: 'wahlkreis', width: 100 },
                  { text: 'Partei', datafield: 'partei', width: 100 }
                ]
            });
        });
    </script>
</head>
<body class='default'>
    <div id='jqxWidget' style="font-size: 13px; font-family: Verdana; float: left;">
        <div id="jqxgrid"></div>
    </div>
</body>
</html>