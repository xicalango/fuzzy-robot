<!DOCTYPE html>
<html lang="en">
<head>
    <title id='Description'>This example shows how to create a Grid from Array data.</title>
    <link rel="stylesheet" href="../../jqwidgets/styles/jqx.base.css" type="text/css" />
    <script type="text/javascript" src="../../scripts/jquery-1.6.2.min.js"></script>
    <script type="text/javascript" src="../../jqwidgets/jqxcore.js"></script>
    <script type="text/javascript" src="../../jqwidgets/jqxdata.js"></script>
    <script type="text/javascript" src="../../jqwidgets/jqxbuttons.js"></script>
    <script type="text/javascript" src="../../jqwidgets/jqxscrollbar.js"></script>
    <script type="text/javascript" src="../../jqwidgets/jqxmenu.js"></script>
    <script type="text/javascript" src="../../jqwidgets/jqxgrid.js"></script>
    <script type="text/javascript" src="../../jqwidgets/jqxgrid.selection.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            // prepare the data
            
			
			
			
			


var source =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'vorname'},
					 { name: 'nachname'},
					 { name: 'partei'}
				],
				url: 'adapters/mitglieder_bundestag_list_daten.php'
			};


var dataAdapter = new $.jqx.dataAdapter(source);		
			
			
            $("#jqxgrid").jqxGrid(
            {
                source: dataAdapter,
                columns: [
                  { text: 'Vorname', datafield: 'vorname', width: 100 },
                  { text: 'Nachname', datafield: 'nachname', width: 100 },
                  { text: 'Partei', datafield: 'partei', width: 180 }
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