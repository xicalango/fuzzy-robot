    <?php

@include("adapters/data_adapter.php");

$da = new DataAdapter();
$bundeslaender = $da->queryToArray("SELECT id, '-1' as parentid, name as text FROM land WHERE jahr='2009'");

$bundesland_id = !empty($_GET['bundeslandid']) ? (int)$_GET['bundeslandid'] : 0;
$partei_id = !empty($_GET['parteiid']) ? (int)$_GET['parteiid'] : 0;

?>
<select size="1" onchange="setAjaxContent('<?=__FILE__;?>?bundeslandid='+$(this).val());">
	<option value="">- Bundesland -</option>
	<?foreach($bundeslaender as $k => $v){?>
		<option value="<?=$v['id'];?>"<?php if($bundesland_id == $v['id']) echo ' selected="selected"';?>><?=$v['text'];?></option>
	<?}?>
</select>
<?if(!empty($bundesland_id)){

	$da = new DataAdapter();
	$parteien = $da->queryToArray( "select p.id, p.name as text from partei p, landesliste ll, land l 
									where p.id = ll.partei_id and 
									ll.land_id = l.idand l.id = ".$bundesland_id );

	?>
	<select size="1" onchange="setAjaxContent('<?=__FILE__;?>?bundeslandid=<?=$bundesland_id;?>&parteiid='+$(this).val());">
		<option value="">- Partei -</option>
		<?foreach($parteien as $k => $v){?>
			<option value="<?=$v['id'];?>"<?php if($partei_id == $v['id']) echo ' selected="selected"';?>><?=$v['text'];?></option>
		<?}?>
	</select>
<?}?>
<div>&nbsp;</div>

<?php
if(!empty($_GET['parteiid'])){
?>
	
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
            
								
			
		var source =
			{
				 datatype: "json",
				 datafields: [
					 { name: 'partei_name'},
					 { name: 'land_name'},
					 { name: 'anzahl'}
				],
				url: 'adapters/ueberhangmandate.php'
			};


var dataAdapter = new $.jqx.dataAdapter(source);		
			
			
            $("#jqxgrid").jqxGrid(
            {
                source: dataAdapter,
                columns: [
                  { text: 'Partei', datafield: 'partei_name', width: 100 },
		  { text: 'Land', datafield: 'land_name', width: 100 },
		  { text: 'Anzahl', datafield: 'anzahl', width: 100 }
				    
                ]
            });
        });
    </script>

    <div id='jqxWidget' style="font-size: 13px; font-family: Verdana; float: left;">
        <div id="jqxgrid"></div>
    </div>

<?php
}
?>
