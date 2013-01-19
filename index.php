<!DOCTYPE html>
<html lang="de" dir="ltr">
<head>
<title>Ergebnisse</title>
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

ul#menu li:hover > a {
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
	border:1px #ccc solid;
	/*width:200%;*/
	background:#fff; /*rgba(255, 255, 255, 0.8);*/
}

ul#menu li ul li {
	display:block;
	white-space:nowrap;
}

ul#menu li:hover ul {
	display:block;
}


</style>
</head>
<body>

	<ul id="menu">
		<li><a href="#">Sitzverteilung</a></li>
		<li><a href="#">Mitglieder des Bundestags</a></li>
		<li><a href="#">Wahlkreisergebnisse</a>
			<ul>
				<li><a href="stimmen_wahlkreis_diagramm.php?wahlkreisid=" onclick="setAjaxContent($(this).attr('href')); return false;">Wahlkreisübersicht</a></li>
				<li><a href="#">Wahlkreissieger</a></li>
				<li><a href="#">Aggr. Wahlkreisübersicht</a></li>
				<li><a href="#">Aggr. Wahlkreissieger</a></li>
			</ul>
		</li>
		<li><a href="#" target="">Überhangmandate</a></li>
		<li><a href="#">Knappste Sieger</a></li>
	</ul>

	<div id="ajaxcontent"></div>
	
	
	
</body>
</html>