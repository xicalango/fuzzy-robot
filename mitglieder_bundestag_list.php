
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
            
			
		var source =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'vorname'},
					 { name: 'nachname'},
					 { name: 'partei_name'}
				],
				url: 'adapters/mitglieder_bundestag_list_daten.php'
			};


var dataAdapter = new $.jqx.dataAdapter(source);		
			
			
            $("#jqxgrid").jqxGrid(
            {
                source: dataAdapter,
				sortable: true,
                columns: [
                  { text: 'Vorname', datafield: 'vorname', width: 120 },
                  { text: 'Nachname', datafield: 'nachname', width: 200 },
                  { text: 'Partei', datafield: 'partei_name', width: 100 }
                ]
            });
        });
		$("#jqxgrid").bind('bindingcomplete', function()
		{
		$("#jqxgrid").jqxGrid('sortby', 'nachname', 'asc');
		});
    </script>

    <div id='jqxWidget' style="font-size: 13px; font-family: Verdana; float: left;">
        <div id="jqxgrid"></div>
    </div>
