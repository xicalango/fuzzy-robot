<?php

@include("adapters/data_adapter.php");

$da = new DataAdapter();
$bundeslaender = $da->queryToArray("SELECT id, '-1' as parentid, name as text FROM land WHERE jahr='2009'");
var_dump($bundeslaender);

?>
<select size="1" onchange="setAjaxContent('stimmen_wahlkreis_diagramm.php?bundeslandid='+$(this).val());">
	<option value="">- Bundesland -</option>
	<?foreach($bundeslaender as $k => $v){?>
		<option value="<?=$v['id'];?>"><?=$v['text'];?></option>
	<?}?>
	<option value="12">Bremen</option>
</select>
<select size="1" onchange="setAjaxContent('stimmen_wahlkreis_diagramm.php?wahlkreisid='+$(this).val());">
	<option value="">- Wahlkreis -</option>
	<option value="1">Bayern</option>
	<option value="12">Bremen</option>
</select>


<?php
if(!empty($_GET['wahlkreisid'])){
?>
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

	function setup_chart(element, settings) {

		var dataAdapter = new $.jqx.dataAdapter(settings.source,
		{
			autoBind: true,
			async: false,
			downloadComplete: function () { },
			loadComplete: function () { },
			loadError: function () { }
		});

		var chart_settings = {
			title: settings.title, 
			description: settings.subtitle,
			showLegend: true,
			enableAnimations: true,
			padding: { left: 20, top: 5, right: 20, bottom: 5 },
			titlePadding: { left: 90, top: 0, right: 0, bottom: 10 },
			source: dataAdapter,
			categoryAxis:
			    {
				dataField: settings.categoryField,
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
					description: settings.desc
				    },
				    series: [
					    { dataField: settings.dataField, displayText: settings.text }
					]
				}
			]
		};
            	// setup the chart
 		$(element).jqxChart(chart_settings);

	}

        $(document).ready(function () {
            // prepare chart data
                        
            var source =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'partei_name'},
					 { name: 'stimmen', type: 'number'}
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
                        dataField: 'partei_name',
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
                                    { dataField: 'stimmen', displayText: 'Stimmen' }
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
					 { name: 'partei_name'},
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
                        dataField: 'partei_name',
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


	var source_d =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'partei_name'},
					 { name: 'prozent', type: 'number'}
				],
				url: 'adapters/erststimme_differenz_wahlkreis.php?wahlkreisid=<?=$_GET['wahlkreisid']?>'
			};

		   var dataAdapter_d = new $.jqx.dataAdapter(source_d,
			{
				autoBind: true,
				async: false,
				downloadComplete: function () { },
				loadComplete: function () { },
				loadError: function () { }
			});
            var settings_d = {
                title: "Erststimmen pro Partei im Wahlkreis <?=$_GET['wahlkreisid']?> (Differenz zum Vorjahr)",
                description: "Bundestagswahl 2009",
                showLegend: true,
                enableAnimations: true,
                padding: { left: 20, top: 5, right: 20, bottom: 5 },
                titlePadding: { left: 90, top: 0, right: 0, bottom: 10 },
                source: dataAdapter_d,
                categoryAxis:
                    {
                        dataField: 'partei_name',
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
				description: '% Pkt.'
                            },
                            series: [
                                    { dataField: 'prozent', displayText: '% Punkte' }
                                ]
                        }
                    ]
            };
            // setup the chart
            $('#jqxChartD').jqxChart(settings_d);

     // prepare chart data
                        
            var source_z =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'partei_name'},
					 { name: 'stimmen', type: 'number'}
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
                        dataField: 'partei_name',
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
                                    { dataField: 'stimmen', displayText: 'Stimmen' }
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
					 { name: 'partei_name'},
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
                        dataField: 'partei_name',
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

	var source_zd =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'partei_name'},
					 { name: 'prozent', type: 'number'}
				],
				url: 'adapters/zweitstimme_differenz_wahlkreis.php?wahlkreisid=<?=$_GET['wahlkreisid']?>'
			};

		   var dataAdapter_zd = new $.jqx.dataAdapter(source_zd,
			{
				autoBind: true,
				async: false,
				downloadComplete: function () { },
				loadComplete: function () { },
				loadError: function () { }
			});
            var settings_zd = {
                title: "Zweitstimmen pro Partei im Wahlkreis <?=$_GET['wahlkreisid']?> (Differenz zum Vorjahr)",
                description: "Bundestagswahl 2009",
                showLegend: true,
                enableAnimations: true,
                padding: { left: 20, top: 5, right: 20, bottom: 5 },
                titlePadding: { left: 90, top: 0, right: 0, bottom: 10 },
                source: dataAdapter_zd,
                categoryAxis:
                    {
                        dataField: 'partei_name',
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
				description: '% Pkt.'
                            },
                            series: [
                                    { dataField: 'prozent', displayText: '% Punkte' }
                                ]
                        }
                    ]
            };
            // setup the chart
            $('#jqxChartZD').jqxChart(settings_zd);


	$.get('adapters/wahlkreis_info.php?wahlkreisid=<?=$_GET["wahlkreisid"]?>', function(data) {

		
		var candidat = data.direktkandidat;

		$('#wahlkreis_text').html('<b>' + data.name + '</b>');
		$('#wahlbeteiligung_text').html('<b>' + data.beteiligung + ' %</b>');
		$('#kandidat_text').html('<b>' + candidat.vorname + ' ' + candidat.nachname + ' (' + candidat.partei + ')</b>');



	});

		
	$('#docking').jqxDocking({ theme: 'classic', orientation: 'horizontal' });
	$('#docking').jqxDocking('hideAllCloseButtons');
	$('#docking').jqxDocking('showAllCollapseButtons');
        });
    </script>

<div>
	<div id='docking'>
	<div style='width:15%'>
		<div id='infos_window' style='height:15%'>
			<div>Infos &uuml;ber Wahlkreis #<?=$_GET["wahlkreisid"]?></div>
			<div>
				<div id='wahlkreis'>
					Wahlkreis:
					<div id='wahlkreis_text' style='display:block'></div>
				</div>
				<div id='wahlbeteiligung'>
					Wahlbeteiligung: 
					<div id='wahlbeteiligung_text' style='display:inline' ></div>
				</div>

				<div id='kandidat'>
					Gew&auml;hlter Direktkandidat:
					<div id='kandidat_text' style='display:block' ></div>
				</div>
			</div>
		</div>
	</div>
	<div style='width:42.5%'>

		<div id='jqxChart_window'>
			<div>Erststimmen</div>
			<div>

				<div id='jqxChart' style="width:680px; height:400px; position: relative; left: 0px; top: 0px; display:inline-block;">
				</div>
			</div>
		</div>

		<div id='jqxChartP_window'>
			<div>Erststimmen (prozent)</div>
			<div>
				<div id='jqxChartP' style="width:680px; height:400px; position: relative; left: 0px; top: 0px; display:inline-block;">
				</div>
			</div>
		</div>
	
		<div id='jqxChartD_window'>
			<div>Erststimmen (Differenz zum Vorjahr)</div>
			<div>
				<div id='jqxChartD' style="width:680px; height:400px; position: relative; left: 0px; top: 0px; display:inline-block;">
				</div>
			</div>
		</div>

	</div>
	<div style='width:42.5%'>

		<div id='jqxChartZ_window'>
			<div>Zweitstimmen</div>
			<div>
				<div id='jqxChartZ' style="width:680px; height:400px; position: relative; left: 0px; top: 0px; display:inline-block;">
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

		<div id='jqxChartZD_window'>
			<div>Zweitstimmen (Differenz zum Vorjahr)</div>
			<div>
				<div id='jqxChartZD' style="width:680px; height:400px; position: relative; left: 0px; top: 0px; display:inline-block;">
				</div>
			</div>
		</div>


	</div>
	</div>
</div>

<?php
}
?>

