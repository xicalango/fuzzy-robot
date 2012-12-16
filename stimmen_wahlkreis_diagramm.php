<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="de">
<head>
<title id='Description'>Stimmenanteile Zweitstimme</title>
    <link rel="stylesheet" href="lib/jqwidgets/styles/jqx.base.css" type="text/css" />
    <script type="text/javascript" src="lib/scripts/jquery-1.7.2.min.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxcore.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxdocking.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxwindow.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxchart.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxdata.js"></script>   
    <script type="text/javascript" src="lib/jqwidgets/jqxpanel.js"></script>
    <script type="text/javascript" src="lib/jqwidgets/jqxsplitter.js"></script>
	<script type="text/javascript">
        $(document).ready(function () {
            // prepare chart data
                        
            var source =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'partei_id'},
					 { name: 'sitze', type: 'number'}
				],
				url: 'adapters/erststimme_absolut_wahlkreis.php?wahlkreisid=<?=$_GET['wahlkreisid']?>'
			};

		   var dataAdapter = new $.jqx.dataAdapter(source,
			{
				autoBind: true,
				async: false,
				downloadComplete: function () { },
				loadComplete: function () { },
				loadError: function () { }
			});
                        
           
            // prepare jqxChart settings
            var settings = {
                title: "Erststimmen pro Partei im Wahlkreis <?=$_GET['wahlkreisid']?>",
                description: "Bundestagswahl 2009",
                showLegend: true,
                enableAnimations: true,
                padding: { left: 20, top: 5, right: 20, bottom: 5 },
                titlePadding: { left: 90, top: 0, right: 0, bottom: 10 },
                source: dataAdapter,
                categoryAxis:
                    {
                        dataField: 'partei_id',
                        showGridLines: true
                    },
                colorScheme: 'scheme05',
                seriesGroups:
                    [
                        {
                            type: 'column',
                            columnsGapPercent: 100,
			    showLabels: true,
                            valueAxis:
                            {
                                unitInterval: 5000,
                                displayValueAxis: true
                            },
                            series: [
                                    { dataField: 'sitze', displayText: 'Stimmen' }
                                ]
                        }
                    ]
            };

        // setup the chart
        $('#jqxChart').jqxChart(settings);

	var source_p =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'partei_id'},
					 { name: 'prozent', type: 'number'}
				],
				url: 'adapters/erststimme_prozent_wahlkreis.php?wahlkreisid=<?=$_GET['wahlkreisid']?>'
			};

		   var dataAdapter_p = new $.jqx.dataAdapter(source_p,
			{
				autoBind: true,
				async: false,
				downloadComplete: function () { },
				loadComplete: function () { },
				loadError: function () { }
			});
            var settings_p = {
                title: "Erststimmen pro Partei im Wahlkreis <?=$_GET['wahlkreisid']?> (prozentual)",
                description: "Bundestagswahl 2009",
                showLegend: true,
                enableAnimations: true,
                padding: { left: 20, top: 5, right: 20, bottom: 5 },
                titlePadding: { left: 90, top: 0, right: 0, bottom: 10 },
                source: dataAdapter_p,
                categoryAxis:
                    {
                        dataField: 'partei_id',
                        showGridLines: true
                    },
                colorScheme: 'scheme05',
                seriesGroups:
                    [
                        {
                            type: 'column',
                            columnsGapPercent: 100,
			    showLabels: true,
                            valueAxis:
                            {
                                unitInterval: 10,
                                displayValueAxis: true,
				description: '%'
                            },
                            series: [
                                    { dataField: 'prozent', displayText: '% Stimmenanteil' }
                                ]
                        }
                    ]
            };
            // setup the chart
            $('#jqxChartP').jqxChart(settings_p);


            // prepare chart data
                        
            var source_z =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'partei_id'},
					 { name: 'sitze', type: 'number'}
				],
				url: 'adapters/zweitstimme_absolut_wahlkreis.php?wahlkreisid=<?=$_GET['wahlkreisid']?>'
			};

		   var dataAdapter_z = new $.jqx.dataAdapter(source_z,
			{
				autoBind: true,
				async: false,
				downloadComplete: function () { },
				loadComplete: function () { },
				loadError: function () { }
			});
                        
           
            // prepare jqxChart settings
            var settings_z = {
                title: "Zweitstimmen pro Partei im Wahlkreis <?=$_GET['wahlkreisid']?>",
                description: "Bundestagswahl 2009",
                showLegend: true,
                enableAnimations: true,
                padding: { left: 20, top: 5, right: 20, bottom: 5 },
                titlePadding: { left: 90, top: 0, right: 0, bottom: 10 },
                source: dataAdapter_z,
                categoryAxis:
                    {
                        dataField: 'partei_id',
                        showGridLines: true
                    },
                colorScheme: 'scheme05',
                seriesGroups:
                    [
                        {
                            type: 'column',
                            columnsGapPercent: 100,
			    showLabels: true,
                            valueAxis:
                            {
                                unitInterval: 5000,
                                displayValueAxis: true
                            },
                            series: [
                                    { dataField: 'sitze', displayText: 'Stimmen' }
                                ]
                        }
                    ]
            };

        // setup the chart
        $('#jqxChartZ').jqxChart(settings_z);

	var source_zp =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'partei_id'},
					 { name: 'prozent', type: 'number'}
				],
				url: 'adapters/zweitstimme_prozent_wahlkreis.php?wahlkreisid=<?=$_GET['wahlkreisid']?>'
			};

		   var dataAdapter_zp = new $.jqx.dataAdapter(source_zp,
			{
				autoBind: true,
				async: false,
				downloadComplete: function () { },
				loadComplete: function () { },
				loadError: function () { }
			});
            var settings_zp = {
                title: "Zweitstimmen pro Partei im Wahlkreis <?=$_GET['wahlkreisid']?> (prozentual)",
                description: "Bundestagswahl 2009",
                showLegend: true,
                enableAnimations: true,
                padding: { left: 20, top: 5, right: 20, bottom: 5 },
                titlePadding: { left: 90, top: 0, right: 0, bottom: 10 },
                source: dataAdapter_zp,
                categoryAxis:
                    {
                        dataField: 'partei_id',
                        showGridLines: true
                    },
                colorScheme: 'scheme05',
                seriesGroups:
                    [
                        {
                            type: 'column',
                            columnsGapPercent: 100,
			    showLabels: true,
                            valueAxis:
                            {
                                unitInterval: 10,
                                displayValueAxis: true,
				description: '%'
                            },
                            series: [
                                    { dataField: 'prozent', displayText: '% Stimmenanteil' }
                                ]
                        }
                    ]
            };
            // setup the chart
            $('#jqxChartZP').jqxChart(settings_zp);


	$.get('adapters/gewaehlte_direktkandidaten_wahlkreis.php?wahlkreisid=<?=$_GET["wahlkreisid"]?>', function(data) {
	
		var candidat = data[0];

		$('#kandidat_text').html('<b>' + candidat.vorname + ' ' + candidat.nachname + '</b>');

	});

		
	$('#docking').jqxDocking({ theme: 'classic', orientation: 'horizontal', });
        });
    </script>
</head>
<body class='default'>
<div>
	<div id='docking'>
	<div>
		<div id='infos_window'>
			<div>Infos</div>
			<div>
				<div id='wahlbeteiligung'>
					Wahlbeteiligung: 
					<div id='wahlbeteiligung_text' style='display:inline' ></div>
				</div>

				<div id='kandidat'>
					Gew&auml;hlter Direktkandidat:
					<div id='kandidat_text' style='display:inline' ></div>
				</div>
			</div>
		</div>

		<div id='jqxChart_window'>
			<div>Erststimmen</div>
			<div>

				<div id='jqxChart' style="width:680px; height:400px; position: relative; left: 0px; top: 0px; display:inline-block;">
				</div>
			</div>
		</div>

		<div id='jqxChartZ_window'>
			<div>Erststimmen (prozent)</div>
			<div>
				<div id='jqxChartZ' style="width:680px; height:400px; position: relative; left: 0px; top: 0px; display:inline-block;">
				</div>
			</div>
		</div>

	</div>
	<div>

		<div id='jqxChartP_window'>
			<div>Zweitstimmen</div>
			<div>
				<div id='jqxChartP' style="width:680px; height:400px; position: relative; left: 0px; top: 0px; display:inline-block;">
				</div>
			</div>
		</div>

		<div id='jqxChartZP_window'>
			<div>Zweitstimmen (prozent)</div>
			<div>
				<div id='jqxChartZP' style="width:680px; height:400px; position: relative; left: 0px; top: 0px; display:inline-block;" >
				</div>
			</div>
		</div>

	</div>
	</div>
</div>
</body>
</html>


