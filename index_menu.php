<!DOCTYPE html>
<html lang="de" dir="ltr">
<head>
<title>Ergebnisse</title>
<!-- testfuck -->
<meta charset="utf-8" />
<script type="text/javascript" src="lib/scripts/jquery-1.7.2.min.js"></script>
<script type="text/javascript">
	function setAjaxContent(url){
		$.ajax({
			url: url,
			type: 'get',
			success: function(data){
				$('#ajaxcontent').html(data);
			}
		});
	}
	$(document).ready(function(){
		 $('#menu a').click(function(){
			if($(this).attr('href') == '#') return false;
			setAjaxContent($(this).attr('href')); 
			$('#menu li').removeClass('active');
			$(this).parent().addClass('active').parent().closest('li').addClass('active');
			return false;
		});
	});
</script>
<style type="text/css">
body {
	font-family:Verdana;
	font-size:12px;
	color:#333;
}

.cl {
	clear:both;
}

ul#menu {
	list-style:none;
	display:block;
	margin:0;
	padding:0;
	background:#eee;
	border-radius:5px;
	border:1px #aaa solid;
	position:relative;
	z-index:9999;
}

ul#menu li {
	list-style:none;
	display:inline-block;
	margin:0;
	position:relative;
}

ul#menu li a {
	display:block;
	padding:10px 20px;
	color:#666;
	text-decoration:none;
}

ul#menu li:hover > a,
ul#menu li.active > a {
	background:#ccc;
	color:#333;
}

ul#menu li ul {
	position:absolute;
	left:0;
	top:100%;
	display:none;
	list-style:none;
	padding:0;
	margin:0;
	border:1px #aaa solid;
	/*width:200%;*/
	background:#fff; /*rgba(255, 255, 255, 0.8);*/
	box-shadow:0 1px 3px rgba(0,0,0, 0.2);
}

ul#menu li ul li {
	display:block;
	white-space:nowrap;
	margin:0;
}

ul#menu li:hover ul {
	display:block;
}

#ajaxcontent {
	margin:20px 0;
}
select {
	padding:5px;
	border:1px #ccc solid;
	font-family:Verdana;
	border-radius:5px;
}


</style>
</head>
<body>

	<ul id="menu">
		<li><a href="home.php">Start</a></li>
		<li><a href="sitzverteilung_diagramm.php">Sitzverteilung</a></li>
		<li><a href="mitglieder_bundestag_list.php">Mitglieder des Bundestags</a></li>
		<li><a href="ueberhangmandate_list.php">Überhangmandate</a></li>
		<li><a href="#">Wahlkreisergebnisse</a>
			<ul>
				<li><a href="stimmen_wahlkreis_diagramm.php">Wahlkreisübersicht</a></li>
				<li><a href="wahlkreissieger_erststimme_list.php">Wahlkreissieger Erststimme</a></li>
				<li><a href="wahlkreissieger_zweitstimme_list.php">Wahlkreissieger Zweitstimme</a></li>
				<li><a href="stimmen_wahlkreis_diagramm_q7.php">Aggr. Wahlkreisübersicht</a></li>
			</ul>
		</li>
		<li><a href="top_10_knappste_list.php">Knappste Sieger</a></li>
	</ul>
	<div id="ajaxcontent">
		<?php
		@include('home.php');
		?>
	</div>
	
	
	
</body>
</html>
