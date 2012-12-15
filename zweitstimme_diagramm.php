<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="de">
<head>
    <title id='Description'>Stimmenanteile Zweitstimme</title>
	<?php include("header.php");?>
	<script type="text/javascript">
        $(document).ready(function () {
            // prepare chart data
            
            
            var source =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'name'},
					 { name: 'prozent', type: 'number'}
				],
				url: 'adapters/zweitstimme_diag_daten.php'
			};

		   var dataAdapter = new $.jqx.dataAdapter(source,
			{
				autoBind: true,
				async: false,
				downloadComplete: function () { },
				loadComplete: function () { },
				loadError: function () { }
			});
            
            
            var sampleData = [
            {"name":"CDU","prozent":27.3},
            {"name":"SPD","prozent":23.0},
            {"name":"FDP","prozent":14.6},
            {"name":"DIE LINKE","prozent":11.9},
            {"name":"GR\u00dcNE","prozent":10.7},
            {"name":"CSU","prozent":6.5},
            {"name":"Andere","prozent":6.0}];
            // prepare jqxChart settings
            var settings = {
                title: "Stimmenanteile Zweitstimme",
                description: "Bundestagswahl 2009",
                showLegend: true,
                enableAnimations: true,
                padding: { left: 20, top: 5, right: 20, bottom: 5 },
                titlePadding: { left: 90, top: 0, right: 0, bottom: 10 },
                source: dataAdapter,
                categoryAxis:
                    {
                        dataField: 'name',
                        showGridLines: true
                    },
                colorScheme: 'scheme05',
                seriesGroups:
                    [
                        {
                            type: 'column',
                            columnsGapPercent: 100,
                            valueAxis:
                            {
                                unitInterval: 10,
                                maxValue: 30,
                                displayValueAxis: true,
                                description: '%'
                            },
                            series: [
                                    { dataField: 'prozent', displayText: ' ' }
                                ]
                        }
                    ]
            };
            // setup the chart
            $('#jqxChart').jqxChart(settings);
        });
    </script>
</head>
<?php include("menu.html");?>
<body class='default'>
    <div id='jqxChart' style="width:680px; height:400px; position: relative; left: 0px; top: 0px;">
    </div>
</body>
</html>


