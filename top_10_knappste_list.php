<!DOCTYPE html>
<html lang="de">
<head>
   <title id='Description'>Tabellarische Übersicht über die 10 knappsten Sieger einer Partei</title>
    <link rel="stylesheet" href="lib/jqwidgets/styles/jqx.base.css" type="text/css" />
    <script type="text/javascript" src="lib/scripts/jquery-1.7.2.min.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxcore.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxbuttons.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxdata.js"></script>    
	<script type="text/javascript" src="lib/jqwidgets/jqxscrollbar.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxmenu.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxgrid.js"></script>
	<script type="text/javascript" src="lib/jqwidgets/jqxgrid.sort.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxgrid.selection.js"></script>
	<script type="text/javascript">
        $(document).ready(function () {
            // prepare the data
            
			
			<?php
			$partei_id = $_GET["parteiid"];	
			$url = 'adapters/top_10_knappste.php?parteiid=' . $partei_id;
			?>
			
			
		var source =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'vorname'},
					 { name: 'nachname'},
					 { name: 'partei_name'},
					 { name: 'differenz', type:'int'},
					 { name: 'wahlkreis'}
					 
				],
				url: <?php echo '\'' . $url . '\''; ?>
			};


var dataAdapter = new $.jqx.dataAdapter(source);		
			
			
            $("#jqxgrid").jqxGrid(
            {
                source: dataAdapter,
				sortable: true,
                columns: [
                  { text: 'Vorname', datafield: 'vorname', width: 100 },
                  { text: 'Nachname', datafield: 'nachname', width: 100 },
				  { text: 'Partei', datafield: 'partei_name', width: 50 },
				  { text: 'Wahlkreis', datafield: 'wahlkreis', width: 120},
				   { text: 'Differenz', datafield: 'differenz', width: 100 }
                ]
            });
        });
		
				
		$("#jqxgrid").bind('bindingcomplete', function()
		{
		$("#jqxgrid").jqxGrid('sortby', 'differenz', 'asc');
		});
		
		
		
    </script>
</head>
<body class='default'>
    <div id='jqxWidget' style="font-size: 13px; font-family: Verdana; float: left;">
        <div id="jqxgrid"></div>
    </div>
</body>
</html>