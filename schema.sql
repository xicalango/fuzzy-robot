--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.7
-- Dumped by pg_dump version 9.1.6
-- Started on 2013-01-09 12:21:05 CET

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 14 (class 2615 OID 59260)
-- Name: adapter; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA adapter;


--
-- TOC entry 11 (class 2615 OID 41761)
-- Name: alt; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA alt;


--
-- TOC entry 8 (class 2615 OID 16693)
-- Name: raw2005; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA raw2005;


--
-- TOC entry 7 (class 2615 OID 16387)
-- Name: raw2009; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA raw2009;


--
-- TOC entry 10 (class 2615 OID 41680)
-- Name: stimmen2005; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA stimmen2005;


--
-- TOC entry 9 (class 2615 OID 24942)
-- Name: stimmen2009; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA stimmen2009;


--
-- TOC entry 270 (class 3079 OID 11645)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2429 (class 0 OID 0)
-- Dependencies: 270
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = adapter, pg_catalog;

--
-- TOC entry 783 (class 1247 OID 59345)
-- Dependencies: 14 260
-- Name: type_direktkandidat_gewinner; Type: TYPE; Schema: adapter; Owner: -
--

CREATE TYPE type_direktkandidat_gewinner AS (
	vorname text,
	nachname text,
	partei text
);


--
-- TOC entry 888 (class 1247 OID 59426)
-- Dependencies: 14 269
-- Name: type_sitzverteilung_prozent_parteiname; Type: TYPE; Schema: adapter; Owner: -
--

CREATE TYPE type_sitzverteilung_prozent_parteiname AS (
	partei_name character varying,
	prozent numeric
);


--
-- TOC entry 780 (class 1247 OID 59423)
-- Dependencies: 14 268
-- Name: type_sitzverteilung_sitze_parteiname; Type: TYPE; Schema: adapter; Owner: -
--

CREATE TYPE type_sitzverteilung_sitze_parteiname AS (
	partei_name character varying,
	stimmen bigint
);


SET search_path = public, pg_catalog;

--
-- TOC entry 903 (class 1247 OID 59250)
-- Dependencies: 5
-- Name: gewinner_typ; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE gewinner_typ AS ENUM (
    'Direktkandidat',
    'Landeskandidat'
);


--
-- TOC entry 879 (class 1247 OID 59359)
-- Dependencies: 5 261
-- Name: type_direktkandidat_diff; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE type_direktkandidat_diff AS (
	vorname character varying,
	nachname character varying,
	wahlkreis character varying,
	partei_name character varying,
	differenz bigint
);


--
-- TOC entry 767 (class 1247 OID 59228)
-- Dependencies: 5 248
-- Name: type_land_stimmen; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE type_land_stimmen AS (
	land_id integer,
	stimmen bigint
);


--
-- TOC entry 900 (class 1247 OID 59237)
-- Dependencies: 5 250
-- Name: type_partei_land_stimmen; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE type_partei_land_stimmen AS (
	partei_id integer,
	land_id integer,
	sitze bigint
);


SET search_path = adapter, pg_catalog;

--
-- TOC entry 317 (class 1255 OID 59427)
-- Dependencies: 14 780
-- Name: absolute_erststimmen_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION absolute_erststimmen_by_wahlkreis(integer) RETURNS SETOF type_sitzverteilung_sitze_parteiname
    LANGUAGE sql
    AS $_$
SELECT p.name, sum(ea.stimmen)::bigint from partei p, erststimmen_aggregation ea, direktkandidat dk where p.id = dk.partei_id and ea.direktkandidat_id = dk.id and ea.wahlkreis_id = $1 group by p.id, p.name;
$_$;


--
-- TOC entry 319 (class 1255 OID 59428)
-- Dependencies: 14 780
-- Name: absolute_zweitstimmen_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION absolute_zweitstimmen_by_wahlkreis(integer) RETURNS SETOF type_sitzverteilung_sitze_parteiname
    LANGUAGE sql
    AS $_$
SELECT p.name, sum(za.stimmen)::bigint from partei p, zweitstimmen_aggregation za where p.id = za.partei_id and za.wahlkreis_id = $1 group by p.id, p.name;
$_$;


--
-- TOC entry 321 (class 1255 OID 59429)
-- Dependencies: 14 888
-- Name: differenz_erststimmen_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION differenz_erststimmen_by_wahlkreis(integer) RETURNS SETOF type_sitzverteilung_prozent_parteiname
    LANGUAGE sql
    AS $_$
with stimmen as (
	SELECT d.partei_id, sum(ea.stimmen) stimmen, sum(ea.stimmen_vorperiode) stimmen_vorperiode
	FROM erststimmen_aggregation ea, direktkandidat d
	WHERE ea.direktkandidat_id = d.id
	AND ea.wahlkreis_id = $1
	GROUP BY d.partei_id
), gesamtstimmen as (
	select sum(stimmen) sum_stimmen, sum(stimmen_vorperiode) sum_stimmen_vorperiode	
	from erststimmen_aggregation ea 
	where ea.wahlkreis_id = $1 
	and ea.direktkandidat_id is not null
)
SELECT p.name,((100*s.stimmen::numeric/gs.sum_stimmen::numeric) -  (100*s.stimmen_vorperiode::numeric/gs.sum_stimmen_vorperiode::numeric))::numeric(3,1) differenz
FROM stimmen s, gesamtstimmen gs, partei p
WHERE s.partei_id = p.id
ORDER BY s.stimmen DESC;

$_$;


--
-- TOC entry 322 (class 1255 OID 59430)
-- Dependencies: 14 888
-- Name: differenz_zweitstimmen_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION differenz_zweitstimmen_by_wahlkreis(integer) RETURNS SETOF type_sitzverteilung_prozent_parteiname
    LANGUAGE sql
    AS $_$
with stimmen as (
	SELECT za.partei_id, sum(za.stimmen) stimmen, sum(za.stimmen_vorperiode) stimmen_vorperiode
	FROM zweitstimmen_aggregation za
	WHERE za.wahlkreis_id = $1
	GROUP BY za.partei_id
), gesamtstimmen as (
	select sum(stimmen) sum_stimmen, sum(stimmen_vorperiode) sum_stimmen_vorperiode	
	from zweitstimmen_aggregation za 
	where za.wahlkreis_id = $1 
	and za.partei_id is not null
)
SELECT p.name,((100*s.stimmen::numeric/gs.sum_stimmen::numeric) -  (100*s.stimmen_vorperiode::numeric/gs.sum_stimmen_vorperiode::numeric))::numeric(3,1) differenz
FROM stimmen s, gesamtstimmen gs, partei p
WHERE s.partei_id = p.id
ORDER BY s.stimmen DESC;

$_$;


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 169 (class 1259 OID 16396)
-- Dependencies: 5
-- Name: direktkandidat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE direktkandidat (
    id integer NOT NULL,
    vorname character varying(50),
    nachname character varying(50),
    wahlkreis_id integer,
    partei_id integer
);


SET search_path = adapter, pg_catalog;

--
-- TOC entry 315 (class 1255 OID 59398)
-- Dependencies: 711 14
-- Name: gewaehlte_direktkandidaten_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION gewaehlte_direktkandidaten_by_wahlkreis(integer) RETURNS SETOF public.direktkandidat
    LANGUAGE sql
    AS $_$
SELECT dk.* FROM direktkandidat dk, wahl_gewinner wg WHERE dk.id = wg.kandidat_id AND dk.wahlkreis_id = $1 AND wg.typ = 'Direktkandidat' AND dk.id = wg.kandidat_id;
$_$;


--
-- TOC entry 307 (class 1255 OID 59346)
-- Dependencies: 14 783
-- Name: gewaehlter_direktkandidat_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION gewaehlter_direktkandidat_by_wahlkreis(integer) RETURNS SETOF type_direktkandidat_gewinner
    LANGUAGE sql
    AS $_$
SELECT dk.vorname, dk.nachname, p.name 
FROM direktkandidat dk, wahl_gewinner wg, partei p
WHERE dk.id = wg.kandidat_id 
AND dk.wahlkreis_id = $1 
AND wg.typ = 'Direktkandidat' 
AND dk.id = wg.kandidat_id
AND p.id = dk.partei_id;
$_$;


--
-- TOC entry 324 (class 1255 OID 59431)
-- Dependencies: 888 14
-- Name: prozent_erststimmen_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION prozent_erststimmen_by_wahlkreis(integer) RETURNS SETOF type_sitzverteilung_prozent_parteiname
    LANGUAGE sql
    AS $_$
with gesamtstimmen as (
select sum(stimmen) from erststimmen_aggregation ea where ea.wahlkreis_id = $1 and ea.direktkandidat_id is not null
)
select p.name, 100 * sum(ea.stimmen) / sum(gs.sum) as prozent from erststimmen_aggregation ea, gesamtstimmen gs, partei p, direktkandidat dk
where dk.partei_id = p.id and dk.id = ea.direktkandidat_id and ea.wahlkreis_id = $1 group by p.name;
$_$;


--
-- TOC entry 326 (class 1255 OID 59432)
-- Dependencies: 888 14
-- Name: prozent_zweitstimmen_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION prozent_zweitstimmen_by_wahlkreis(integer) RETURNS SETOF type_sitzverteilung_prozent_parteiname
    LANGUAGE sql
    AS $_$
with gesamtstimmen as (
select sum(stimmen) from zweitstimmen_aggregation a where a.wahlkreis_id = $1 and a.partei_id is not Null
)
select p.name, 100 * sum(za.stimmen) / sum(gs.sum) as prozent from zweitstimmen_aggregation za, gesamtstimmen gs, partei p
where p.id = za.partei_id and za.wahlkreis_id = $1 group by p.name;
$_$;


--
-- TOC entry 316 (class 1255 OID 59408)
-- Dependencies: 930 14 879
-- Name: top_10(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION top_10(integer) RETURNS SETOF public.type_direktkandidat_diff
    LANGUAGE plpgsql
    AS $_$


BEGIN

PERFORM * FROM hat_direktmandat WHERE id = $1;



IF FOUND THEN
return query select * from get_10_knappste_sieger($1);
ELSE
return query select * from get_10_knappste_verlierer($1);
END IF;
END


$_$;


SET search_path = alt, pg_catalog;

--
-- TOC entry 305 (class 1255 OID 59195)
-- Dependencies: 11 930
-- Name: sitze_partei_bundesland(integer); Type: FUNCTION; Schema: alt; Owner: -
--

CREATE FUNCTION sitze_partei_bundesland(jahr integer) RETURNS SETOF record
    LANGUAGE plpgsql ROWS 500
    AS $_$
DECLARE

	r record;

BEGIN

	FOR r IN SELECT * FROM get_laender_by_jahr($1) LOOP
		RETURN QUERY SELECT r.id as land_id, s.* FROM sitze_partei_ein_land( r.id ) s;
	END LOOP;
END;
$_$;


--
-- TOC entry 262 (class 1259 OID 59363)
-- Dependencies: 2343 11
-- Name: type_sitzverteilung; Type: VIEW; Schema: alt; Owner: -
--

CREATE VIEW type_sitzverteilung AS
    SELECT NULL::integer AS partei_id, NULL::bigint AS sitze;


--
-- TOC entry 323 (class 1255 OID 59367)
-- Dependencies: 921 11
-- Name: sitze_partei_ein_land(integer); Type: FUNCTION; Schema: alt; Owner: -
--

CREATE FUNCTION sitze_partei_ein_land(land_id integer) RETURNS SETOF type_sitzverteilung
    LANGUAGE sql
    AS $_$
WITH 
--Wählt alle gültigen parteien (>5%, mehr als 2 direktkandidaten) aus
parteien_dabei as (
	SELECT pspl.* FROM partei_stimmen_pro_land pspl, parteien_einzug pe
	WHERE pspl.partei_id = pe.partei_id
),
scherper_gewicht as (
SELECT ps.partei_id, stimmen::numeric/f.faktor as gewicht
FROM parteien_dabei ps, scherperfaktoren f
WHERE ps.land_id = $1
ORDER BY gewicht DESC
LIMIT (SELECT COUNT(*) FROM wahlkreis w WHERE w.land_id = $1)*2
)
SELECT partei_id, count(partei_id) as sitze
FROM scherper_gewicht
GROUP BY partei_id;
$_$;


--
-- TOC entry 325 (class 1255 OID 59368)
-- Dependencies: 11 921
-- Name: sitze_partei_ein_land_(integer); Type: FUNCTION; Schema: alt; Owner: -
--

CREATE FUNCTION sitze_partei_ein_land_(land_id integer) RETURNS SETOF type_sitzverteilung
    LANGUAGE sql ROWS 10
    AS $_$

--Wählt direktkandidaten aus, die auch auf landesliste sind, und schon als direktkandidat gewonnen haben
WITH 
--Wählt alle gültigen parteien (>5%, mehr als 2 direktkandidaten) aus
 parteien_dabei as (
	SELECT pspl.* FROM partei_stimmen_pro_land pspl, parteien_einzug pe
	WHERE pspl.partei_id = pe.partei_id
), 
scherper_gewicht as (

SELECT ps.partei_id, stimmen::numeric/f.faktor as gewicht
FROM parteien_dabei ps, scherperfaktoren f
WHERE ps.land_id = $1
ORDER BY gewicht DESC
LIMIT (SELECT COUNT(*) FROM wahlkreis w WHERE w.land_id = $1)*2
)
SELECT partei_id, count(partei_id) as sitze
FROM scherper_gewicht
GROUP BY partei_id;

$_$;


--
-- TOC entry 327 (class 1255 OID 59369)
-- Dependencies: 930 11 921
-- Name: sitze_partei_ein_land__(integer); Type: FUNCTION; Schema: alt; Owner: -
--

CREATE FUNCTION sitze_partei_ein_land__(p_land_id integer) RETURNS SETOF type_sitzverteilung
    LANGUAGE plpgsql ROWS 10
    AS $$
DECLARE
	gewinner RECORD;
	sl RECORD;

	c INTEGER;
BEGIN
	DROP TABLE IF EXISTS scherper_land;

	CREATE TEMPORARY TABLE scherper_land AS SELECT * FROM scherper_land(p_land_id) sl( partei_id  integer, gewicht numeric );

	FOR gewinner IN SELECT partei_id, COUNT(partei_id) 
		FROM wahl_gewinner
		WHERE land_id = p_land_id
		GROUP BY partei_id LOOP

		FOR c in 1..gewinner.count LOOP
			DELETE FROM scherper_land WHERE 
				partei_id = gewinner.partei_id 
				AND gewicht = (SELECT max(gewicht) FROM scherper_land WHERE partei_id = gewinner.partei_id);
				--LIMIT 1;
		END LOOP;
		
	END LOOP;

	RETURN QUERY SELECT partei_id, count(partei_id) as sitze FROM
		(SELECT partei_id FROM 
			scherper_land
			ORDER BY gewicht DESC
			LIMIT (SELECT COUNT(*) FROM wahlkreis w WHERE w.land_id = p_land_id)*2
		) auswertung
		GROUP BY partei_id;
END;
$$;


SET search_path = public, pg_catalog;

--
-- TOC entry 297 (class 1255 OID 25113)
-- Dependencies: 5 930
-- Name: create_uebrige_direktkandidaten(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_uebrige_direktkandidaten(p_jahr integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
	rec record;
BEGIN

	FOR rec IN SELECT * FROM wahlkreis WHERE land_id IN (SELECT id FROM land WHERE jahr = p_jahr) LOOP
		INSERT INTO direktkandidat (vorname, nachname , wahlkreis_id, partei_id)
			VALUES ( 'Übrige', 'Übrige', rec.id, get_partei_id_by_name('Übrige') );
	END LOOP;

END;
$$;


--
-- TOC entry 318 (class 1255 OID 59360)
-- Dependencies: 879 5
-- Name: get_10_knappste_sieger(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_10_knappste_sieger(integer) RETURNS SETOF type_direktkandidat_diff
    LANGUAGE sql
    AS $_$

select vorname, nachname, wahlkreis, partei_name, diff from(

-- Pateien, die Direktkandidatenmandat gewonnen haben
select dk.vorname, dk.nachname, wk.name as wahlkreis, p.name as partei_name, dd.diff 
from direktkandidat dk, direktkandidat_differenz_auf_zweiten dd, partei p, wahlkreis wk 
where dk.partei_id = p.id and dd.kandidat_id = dk.id 
and dk.partei_id = $1 and diff>0 and wk.id = dk.wahlkreis_id


order by diff
limit 10
) a;


$_$;


--
-- TOC entry 320 (class 1255 OID 59361)
-- Dependencies: 5 879
-- Name: get_10_knappste_verlierer(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_10_knappste_verlierer(integer) RETURNS SETOF type_direktkandidat_diff
    LANGUAGE sql
    AS $_$

select vorname, nachname, wahlkreis, partei_name, diff from(

-- Pateien, die Direktkandidatenmandat gewonnen haben
select dk.vorname, dk.nachname, wk.name as wahlkreis, p.name as partei_name, dd.diff 
from direktkandidat dk, direktkandidat_differenz_auf_ersten dd, partei p, wahlkreis wk 
where dk.partei_id = p.id and dd.kandidat_id = dk.id and dk.partei_id = $1 and diff<0 and dk.wahlkreis_id = wk.id


order by diff desc
limit 10
) a;


$_$;


--
-- TOC entry 284 (class 1255 OID 16388)
-- Dependencies: 5
-- Name: get_bundesland_id_by_name(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_bundesland_id_by_name(bundesland_name character varying, jahr integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT l.id FROM public."land" l WHERE l.name = $1 AND l.jahr = $2 LIMIT 1;$_$;


--
-- TOC entry 303 (class 1255 OID 24952)
-- Dependencies: 711 5
-- Name: get_direktkandidat_by_wahlkreis_partei_jahr(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_direktkandidat_by_wahlkreis_partei_jahr(character varying, character varying, integer) RETURNS direktkandidat
    LANGUAGE sql
    AS $_$
SELECT * 
	FROM "direktkandidat" 
	WHERE wahlkreis_id = (SELECT id FROM get_wahlkreis_by_jahr_and_name($3, $1))
	AND partei_id = get_partei_id_by_name($2)
$_$;


--
-- TOC entry 308 (class 1255 OID 24980)
-- Dependencies: 5
-- Name: get_direktkandidat_id_by_wahlkreis_partei_jahr(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_direktkandidat_id_by_wahlkreis_partei_jahr(character varying, character varying, integer) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT id 
	FROM "direktkandidat" 
	WHERE wahlkreis_id = (SELECT id FROM get_wahlkreis_by_jahr_and_name($3, $1))
	AND partei_id = get_partei_id_by_name($2)
$_$;


--
-- TOC entry 174 (class 1259 OID 16409)
-- Dependencies: 5
-- Name: land; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE land (
    id integer NOT NULL,
    name character varying(30),
    jahr integer
);


--
-- TOC entry 295 (class 1255 OID 16717)
-- Dependencies: 646 5
-- Name: get_laender_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_laender_by_jahr(integer) RETURNS SETOF land
    LANGUAGE sql
    AS $_$
SELECT * FROM "land" WHERE jahr = $1;$_$;


--
-- TOC entry 178 (class 1259 OID 16419)
-- Dependencies: 5
-- Name: landesliste; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE landesliste (
    id integer NOT NULL,
    listenplatz integer,
    land_id integer,
    partei_id integer
);


--
-- TOC entry 329 (class 1255 OID 16668)
-- Dependencies: 5 653
-- Name: get_landesliste_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_landesliste_by_jahr(integer) RETURNS SETOF landesliste
    LANGUAGE sql
    AS $_$SELECT * FROM "landesliste" WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1);$_$;


--
-- TOC entry 302 (class 1255 OID 25137)
-- Dependencies: 5
-- Name: get_landesliste_id_by_wahlkreis_partei_jahr(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_landesliste_id_by_wahlkreis_partei_jahr(character varying, character varying, integer) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT id 
	FROM landesliste 
	WHERE land_id = (SELECT land_id FROM get_wahlkreis_by_jahr_and_name($3, $1))
	AND partei_id = get_partei_id_by_name($2)
$_$;


--
-- TOC entry 287 (class 1255 OID 16389)
-- Dependencies: 5
-- Name: get_partei_id_by_name(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_partei_id_by_name(partei_name character varying) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT p.id FROM public."partei" p WHERE p.name = $1 LIMIT 1;$_$;


--
-- TOC entry 182 (class 1259 OID 16434)
-- Dependencies: 5
-- Name: wahlkreis; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wahlkreis (
    id integer NOT NULL,
    name character varying(100),
    land_id integer,
    nummer integer,
    wahlberechtigte integer
);


--
-- TOC entry 285 (class 1255 OID 16642)
-- Dependencies: 5 661
-- Name: get_wahlkreis_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_wahlkreis_by_jahr(integer) RETURNS SETOF wahlkreis
    LANGUAGE sql
    AS $_$
SELECT * FROM "wahlkreis" WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1);$_$;


--
-- TOC entry 301 (class 1255 OID 24950)
-- Dependencies: 5 661
-- Name: get_wahlkreis_by_jahr_and_name(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_wahlkreis_by_jahr_and_name(integer, character varying) RETURNS wahlkreis
    LANGUAGE sql
    AS $_$
SELECT * 
	FROM "wahlkreis" 
	WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1)
	AND "name" = $2;
$_$;


--
-- TOC entry 311 (class 1255 OID 25000)
-- Dependencies: 5
-- Name: get_wahlkreis_id_by_jahr_and_name(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_wahlkreis_id_by_jahr_and_name(integer, character varying) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT id 
	FROM "wahlkreis" 
	WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1)
	AND "name" = $2;
$_$;


--
-- TOC entry 309 (class 1255 OID 42662)
-- Dependencies: 5 711
-- Name: gewaehlte_direktkandidaten(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gewaehlte_direktkandidaten(integer) RETURNS SETOF direktkandidat
    LANGUAGE sql
    AS $_$
SELECT dk.* FROM direktkandidat dk, wahl_gewinner_rischtisch wg WHERE dk.id = wg.kandidat_id AND dk.wahlkreis_id = $1 AND wg.typ = 'Direktkandidat' AND dk.id = wg.kandidat_id;
$_$;


--
-- TOC entry 298 (class 1255 OID 16722)
-- Dependencies: 5
-- Name: initialize_db(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION initialize_db() RETURNS void
    LANGUAGE sql
    AS $$

--reset db to zero
SELECT reset_db();

INSERT INTO partei ("name") VALUES ('Übrige');

--2009
INSERT INTO "jahr" VALUES (2009);
SELECT raw2009.import_bundeslaender();
SELECT raw2009.import_parteien();
SELECT raw2009.import_wahlkreise();
SELECT raw2009.import_landeslisten();
SELECT raw2009.import_landeskandidaten();
SELECT raw2009.import_direktkandidaten();

SELECT create_uebrige_direktkandidaten(2009);

--2005
INSERT INTO "jahr" VALUES (2005);
--SELECT raw2005.import_bundeslaender();
--SELECT raw2005.import_parteien();
--SELECT raw2005.import_wahlkreise();

$$;


--
-- TOC entry 223 (class 1259 OID 41663)
-- Dependencies: 5
-- Name: erststimmen_aggregation; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE erststimmen_aggregation (
    direktkandidat_id integer NOT NULL,
    wahlkreis_id integer NOT NULL,
    stimmen bigint,
    stimmen_vorperiode bigint
);


--
-- TOC entry 220 (class 1259 OID 33451)
-- Dependencies: 2311 5
-- Name: direktkandidat_gewinner; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidat_gewinner AS
    WITH max_stimmen_per_wahlkreis AS (SELECT ea2.wahlkreis_id, max(ea2.stimmen) AS max_stimmen FROM erststimmen_aggregation ea2 GROUP BY ea2.wahlkreis_id) SELECT ea.wahlkreis_id, ea.direktkandidat_id, (ea.stimmen)::integer AS stimmen FROM erststimmen_aggregation ea, max_stimmen_per_wahlkreis mspw WHERE ((ea.wahlkreis_id = mspw.wahlkreis_id) AND (ea.stimmen = mspw.max_stimmen));


--
-- TOC entry 176 (class 1259 OID 16414)
-- Dependencies: 5
-- Name: landeskandidat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE landeskandidat (
    id integer NOT NULL,
    vorname character varying(50),
    nachname character varying(50),
    listenrang integer,
    landesliste_id integer
);


--
-- TOC entry 255 (class 1259 OID 59282)
-- Dependencies: 2338 5
-- Name: landeskandidat_ohne_direktmandat; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW landeskandidat_ohne_direktmandat AS
    SELECT l.id, l.vorname, l.nachname, l.listenrang, l.landesliste_id FROM landeskandidat l, landesliste ll WHERE ((l.landesliste_id = ll.id) AND (NOT (EXISTS (SELECT dg.wahlkreis_id, dg.direktkandidat_id, dg.stimmen, d.id, d.vorname, d.nachname, d.wahlkreis_id, d.partei_id FROM direktkandidat_gewinner dg, direktkandidat d WHERE ((((dg.direktkandidat_id = d.id) AND ((l.vorname)::text = (d.vorname)::text)) AND ((l.nachname)::text = (d.nachname)::text)) AND (ll.partei_id = d.partei_id))))));


--
-- TOC entry 314 (class 1255 OID 59299)
-- Dependencies: 5 930 909
-- Name: landeskandidat_ohne_direktmandat_bereinigt(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION landeskandidat_ohne_direktmandat_bereinigt() RETURNS SETOF landeskandidat_ohne_direktmandat
    LANGUAGE plpgsql
    AS $$
DECLARE
	i integer = 1;
	old_ll integer = 1;
	lkr record; --landeskandidat record
BEGIN

	FOR lkr IN SELECT * FROM landeskandidat_ohne_direktmandat ORDER BY landesliste_id, listenrang ASC LOOP
		IF old_ll <> lkr.landesliste_id THEN
			i = 1;
		END IF;

		old_ll = lkr.landesliste_id;


		RETURN QUERY SELECT lkr.id, lkr.vorname, lkr.nachname, i, lkr.landesliste_id;

		i = i + 1;
	END LOOP;

END;
$$;


--
-- TOC entry 296 (class 1255 OID 16583)
-- Dependencies: 5 930
-- Name: reset_db(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION reset_db() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
	rec record;
BEGIN

RAISE EXCEPTION 'Bist du dir sicher, dass du das tun willst?';

EXECUTE 'DELETE FROM "erststimme"';
EXECUTE 'DELETE FROM "zweitstimme"';

EXECUTE 'DELETE FROM "direktkandidat"';
EXECUTE 'DELETE FROM "landeskandidat"';
EXECUTE 'DELETE FROM "landesliste"';

EXECUTE 'DELETE FROM "wahlkreis"';
EXECUTE 'DELETE FROM "land"';
EXECUTE 'DELETE FROM "jahr"';

EXECUTE 'DELETE FROM "partei"';

FOR rec IN SELECT * FROM information_schema.sequences WHERE sequence_catalog = 'btw2009' AND sequence_schema = 'public' LOOP
	EXECUTE 'ALTER SEQUENCE "' || rec.sequence_name || '" RESTART 1';
END LOOP;


END;
$$;


--
-- TOC entry 300 (class 1255 OID 25198)
-- Dependencies: 5 930
-- Name: scherper_faktoren(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION scherper_faktoren() RETURNS SETOF numeric
    LANGUAGE plpgsql
    AS $$
BEGIN

	FOR i IN 0..597 LOOP -- insges 598 zeilen
		RETURN NEXT i+0.5;
	END LOOP;



END;


$$;


--
-- TOC entry 304 (class 1255 OID 41812)
-- Dependencies: 5
-- Name: scherper_land(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION scherper_land(land_id integer) RETURNS SETOF record
    LANGUAGE sql
    AS $_$

WITH 
--Wählt alle gültigen parteien (>5%, mehr als 2 direktkandidaten) aus
parteien_dabei as (
	SELECT pspl.* FROM partei_stimmen_pro_land pspl, parteien_einzug pe
	WHERE pspl.partei_id = pe.partei_id
),
scherper_gewicht as (
SELECT ps.partei_id, stimmen::numeric/f.faktor as gewicht
FROM parteien_dabei ps, scherperfaktoren f
WHERE ps.land_id = $1
ORDER BY gewicht DESC
--LIMIT (SELECT COUNT(*) FROM wahlkreis w WHERE w.land_id = 16)*2
)
SELECT * FROM scherper_gewicht
$_$;


--
-- TOC entry 313 (class 1255 OID 59239)
-- Dependencies: 5 900 930
-- Name: sitze_alle_parteien_bundesland(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sitze_alle_parteien_bundesland() RETURNS SETOF type_partei_land_stimmen
    LANGUAGE plpgsql
    AS $$
DECLARE
	p_id INTEGER;
BEGIN

	FOR p_id in SELECT partei_id FROM parteien_einzug LOOP

		RETURN QUERY SELECT * FROM sitze_partei_bundesland(p_id);
		
	END LOOP;

END;


$$;


--
-- TOC entry 312 (class 1255 OID 59238)
-- Dependencies: 900 5
-- Name: sitze_partei_bundesland(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sitze_partei_bundesland(partei_id integer) RETURNS SETOF type_partei_land_stimmen
    LANGUAGE sql
    AS $_$

WITH scherper_gewichte AS (
SELECT land_id, s.stimmen / f.faktor as gewicht FROM stimmen_land_eine_partei($1) s, scherperfaktoren f
ORDER BY gewicht DESC
LIMIT (SELECT sitze FROM sitzverteilung_ohne_ueberhangmandate WHERE partei_id = $1)
)
SELECT $1, land_id, count(land_id) as sitze FROM scherper_gewichte GROUP BY land_id;

$_$;


--
-- TOC entry 310 (class 1255 OID 59234)
-- Dependencies: 5 767
-- Name: stimmen_land_eine_partei(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION stimmen_land_eine_partei(partei_id integer) RETURNS SETOF type_land_stimmen
    LANGUAGE sql ROWS 500
    AS $_$
SELECT land_id, stimmen FROM partei_land_stimmen_einzug WHERE partei_id = $1;
$_$;


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 283 (class 1255 OID 16716)
-- Dependencies: 8
-- Name: import_bundeslaender(); Type: FUNCTION; Schema: raw2005; Owner: -
--

CREATE FUNCTION import_bundeslaender() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO "Land" ("name", "jahr") SELECT DISTINCT "Land", 2005 FROM raw2005.wahlkreise;
$$;


--
-- TOC entry 282 (class 1255 OID 16719)
-- Dependencies: 8
-- Name: import_parteien(); Type: FUNCTION; Schema: raw2005; Owner: -
--

CREATE FUNCTION import_parteien() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO "Partei" ("name") SELECT * FROM
(
	SELECT DISTINCT trim("Partei") FROM raw2005.wahlbewerber WHERE "Partei" IS NOT NULL AND trim("Partei") NOT IN
		(SELECT "name" FROM "Partei")
) p;
$$;


--
-- TOC entry 290 (class 1255 OID 16865)
-- Dependencies: 8 930
-- Name: import_wahlkreise(); Type: FUNCTION; Schema: raw2005; Owner: -
--

CREATE FUNCTION import_wahlkreise() RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
	rec record;

	newid integer;
BEGIN

	EXECUTE 'DROP TABLE IF EXISTS raw2005.mapid_wahlkreise';
	EXECUTE 'CREATE TABLE raw2005.mapid_wahlkreise ( id_old INTEGER PRIMARY KEY, id_new INTEGER );';

	DELETE FROM "Wahlkreis" WHERE land_id IN (SELECT id FROM "Land" WHERE jahr=2005); --Alte 2005er einträge löschen

	FOR rec IN SELECT 
			"Nummer" wknr, 
			"Name" n , 
			get_bundesland_id_by_name("Land", 2005) blnr
		FROM raw2005.wahlkreise 
	LOOP

		INSERT INTO "Wahlkreis" ("name", "land_id") 
			VALUES ( rec.n, rec.blnr ) 
			RETURNING "id" INTO newid;

		INSERT INTO raw2005."mapid_wahlkreise"  ( "id_old", "id_new" )
			VALUES  ( rec.wknr, newid );


		
	END LOOP;

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2005.map_wahlkreis(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2005.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';
	 
END;
$_$;


--
-- TOC entry 299 (class 1255 OID 16900)
-- Dependencies: 8
-- Name: map_wahlkreis(integer); Type: FUNCTION; Schema: raw2005; Owner: -
--

CREATE FUNCTION map_wahlkreis(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2005.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;$_$;


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 291 (class 1255 OID 16720)
-- Dependencies: 7
-- Name: import_bundeslaender(); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION import_bundeslaender() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO "land" ("name", "jahr") SELECT DISTINCT "Bundesland", 2009 FROM raw2009.landeslisten;
$$;


--
-- TOC entry 292 (class 1255 OID 16391)
-- Dependencies: 930 7
-- Name: import_direktkandidaten(); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION import_direktkandidaten() RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
	rec record;

	newid integer;
BEGIN

	EXECUTE 'DROP TABLE IF EXISTS raw2009.mapid_direktkandidaten';
	EXECUTE 'CREATE TABLE raw2009.mapid_direktkandidaten ( id_old INTEGER PRIMARY KEY, id_new INTEGER );';

	DELETE FROM "direktkandidat" WHERE wahlkreis_id IN (SELECT id FROM get_wahlkreis_by_jahr(2009)); --Alte 2009er wahlkreise löschen

	FOR rec IN SELECT 
			"Kandidatennummer",
			"Vorname",
			"Nachname", 
			"Wahlkreis",
			"partei_id"
		FROM raw2009."wahlbewerber_direktkandidat"
	LOOP

		INSERT INTO "direktkandidat" ("vorname", "nachname", "wahlkreis_id", "partei_id") 
			VALUES ( rec."Vorname", rec."Nachname", raw2009.map_wahlkreis( rec."Wahlkreis" ), rec.partei_id )
			RETURNING "id" INTO newid;

		INSERT INTO raw2009."mapid_direktkandidaten"  ( "id_old", "id_new" )
			VALUES  ( rec."Kandidatennummer", newid );

	END LOOP;

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_direktkandidat(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_direktkandidaten WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';

END;

$_$;


--
-- TOC entry 328 (class 1255 OID 16392)
-- Dependencies: 930 7
-- Name: import_landeskandidaten(); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION import_landeskandidaten() RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
	rec record;

	newid integer;
BEGIN

	EXECUTE 'DROP TABLE IF EXISTS raw2009.mapid_landeskandidaten';
	EXECUTE 'CREATE TABLE raw2009.mapid_landeskandidaten ( id_old INTEGER PRIMARY KEY, id_new INTEGER );';

	DELETE FROM "landeskandidat" WHERE landesliste_id IN (SELECT id FROM get_landesliste_by_jahr(2009)); --Alte 2009er einträge löschen

	FOR rec IN SELECT 
			"Kandidatennummer",
			"VornameTitel",
			"Nachname", 
			"Position",
			"Landesliste"
		FROM raw2009."wahlbewerber_landesliste"
	LOOP

		INSERT INTO "landeskandidat" ("vorname", "nachname", "listenrang", "landesliste_id") 
			VALUES ( rec."VornameTitel", rec."Nachname", rec."Position", raw2009.map_landesliste(rec."Landesliste") )
			RETURNING "id" INTO newid;

		INSERT INTO raw2009."mapid_landeskandidaten"  ( "id_old", "id_new" )
			VALUES  ( rec."Kandidatennummer", newid );
		
	END LOOP;

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_landeskandidat(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_landeskandidaten WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';

END;

$_$;


--
-- TOC entry 289 (class 1255 OID 16635)
-- Dependencies: 930 7
-- Name: import_landeslisten(); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION import_landeslisten() RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
	rec record;

	newid integer;
BEGIN

	EXECUTE 'DROP TABLE IF EXISTS raw2009.mapid_landeslisten';
	EXECUTE 'CREATE TABLE raw2009.mapid_landeslisten ( id_old INTEGER PRIMARY KEY, id_new INTEGER );';

	DELETE FROM "landesliste" WHERE land_id IN (SELECT id FROM "land" WHERE jahr=2009); --Alte 2009er landesliste löschen

	FOR rec IN SELECT 
			"Listennummer" listen_nr,
			get_bundesland_id_by_name("Bundesland", 2009) land_id,
			get_partei_id_by_name("Partei") partei_id
		FROM raw2009."landeslisten"
	LOOP

		INSERT INTO "landesliste" ("listenplatz", "land_id", "partei_id") 
			VALUES ( rec.listen_nr, rec.land_id, rec.partei_id ) 
			RETURNING "id" INTO newid;

		INSERT INTO raw2009."mapid_landeslisten"  ( "id_old", "id_new" )
			VALUES  ( rec.listen_nr, newid );
		
	END LOOP;

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_landesliste(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_landeslisten WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';
	
END;
$_$;


--
-- TOC entry 286 (class 1255 OID 16394)
-- Dependencies: 7
-- Name: import_parteien(); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION import_parteien() RETURNS void
    LANGUAGE sql
    AS $$
--DELETE FROM "Partei";
INSERT INTO "partei" ("name") SELECT * FROM
(
	SELECT DISTINCT trim("Partei") partei FROM raw2009.landeslisten
	UNION
	SELECT DISTINCT trim("Partei") partei FROM raw2009.wahlbewerber WHERE "Partei" IS NOT NULL
) p
WHERE p.partei NOT IN (SELECT "name" FROM "partei");
$$;


--
-- TOC entry 306 (class 1255 OID 59089)
-- Dependencies: 930 7
-- Name: import_wahlberechtigte(); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION import_wahlberechtigte() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	r RECORD;
BEGIN

	FOR r IN SELECT * FROM raw2009.wahlkreise LOOP
		UPDATE wahlkreis SET wahlberechtigte = r."Wahlberechtigte" WHERE nummer = r."WahlkreisNr" AND land_id BETWEEN 1 AND 16; --unschön:hard constraints
		UPDATE wahlkreis SET wahlberechtigte = r."Vorperiode" WHERE nummer = r."WahlkreisNr" AND land_id BETWEEN 17 AND 32;
	END LOOP;
	
END;
$$;


--
-- TOC entry 293 (class 1255 OID 16589)
-- Dependencies: 7 930
-- Name: import_wahlkreise(); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION import_wahlkreise() RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
	rec record;

	newid integer;
BEGIN

	EXECUTE 'DROP TABLE IF EXISTS raw2009.mapid_wahlkreise';
	EXECUTE 'CREATE TABLE raw2009.mapid_wahlkreise ( id_old INTEGER PRIMARY KEY, id_new INTEGER );';

	DELETE FROM "wahlkreis" WHERE land_id IN (SELECT id FROM "land" WHERE jahr=2009); --Alte 2009er wahlkreise löschen

	FOR rec IN SELECT 
			"WahlkreisNr" wknr, 
			"Name" n , 
			get_bundesland_id_by_name("Land", 2009) blnr,
			"Wahlberechtigte" ber
		FROM raw2009.wahlkreise 
		WHERE "WahlkreisNr" < 900 --WahlkreisNr >=900 sind "Insgesamt Werte"
	LOOP

		INSERT INTO "wahlkreis" ("name", "land_id") 
			VALUES ( rec.n, rec.blnr ) 
			RETURNING "id" INTO newid;

		INSERT INTO raw2009."mapid_wahlkreise"  ( "id_old", "id_new" )
			VALUES  ( rec.wknr, newid );
		
	END LOOP;

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_wahlkreis(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';
	 
END;
$_$;


--
-- TOC entry 331 (class 1255 OID 16662)
-- Dependencies: 7
-- Name: map_direktkandidat(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_direktkandidat(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_direktkandidaten WHERE id_old = $1 LIMIT 1;$_$;


--
-- TOC entry 330 (class 1255 OID 16689)
-- Dependencies: 7
-- Name: map_landeskandidat(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_landeskandidat(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_landeskandidaten WHERE id_old = $1 LIMIT 1;$_$;


--
-- TOC entry 294 (class 1255 OID 16645)
-- Dependencies: 7
-- Name: map_landesliste(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_landesliste(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_landeslisten WHERE id_old = $1 LIMIT 1;$_$;


--
-- TOC entry 288 (class 1255 OID 16646)
-- Dependencies: 7
-- Name: map_wahlkreis(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_wahlkreis(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;$_$;


SET search_path = public, pg_catalog;

--
-- TOC entry 222 (class 1259 OID 33477)
-- Dependencies: 5
-- Name: zweitstimmen_aggregation; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zweitstimmen_aggregation (
    partei_id integer NOT NULL,
    wahlkreis_id integer NOT NULL,
    stimmen bigint,
    stimmen_vorperiode bigint
);


--
-- TOC entry 221 (class 1259 OID 33459)
-- Dependencies: 2312 5
-- Name: zweitstimmen_prozent; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW zweitstimmen_prozent AS
    WITH zweitstimmen_pro_partei AS (SELECT zweitstimmen_aggregation.partei_id, sum(zweitstimmen_aggregation.stimmen) AS stimmen FROM zweitstimmen_aggregation zweitstimmen_aggregation GROUP BY zweitstimmen_aggregation.partei_id), zweitstimmen_gesamt AS (SELECT sum(zweitstimmen_aggregation.stimmen) AS gesamtstimmen FROM zweitstimmen_aggregation zweitstimmen_aggregation WHERE (zweitstimmen_aggregation.partei_id IS NOT NULL)) SELECT zspp.partei_id, (((100)::numeric * zspp.stimmen) / ges.gesamtstimmen) AS prozent FROM zweitstimmen_pro_partei zspp, zweitstimmen_gesamt ges ORDER BY (((100)::numeric * zspp.stimmen) / ges.gesamtstimmen) DESC;


--
-- TOC entry 239 (class 1259 OID 41752)
-- Dependencies: 2326 5
-- Name: ergebnisse_zweitstimme_diagramm; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW ergebnisse_zweitstimme_diagramm AS
    (SELECT zweitstimmen_prozent.partei_id, (zweitstimmen_prozent.prozent)::numeric(3,1) AS prozent FROM zweitstimmen_prozent WHERE (zweitstimmen_prozent.partei_id IS NOT NULL) LIMIT 6) UNION ALL (WITH rest AS (SELECT zweitstimmen_prozent.prozent FROM zweitstimmen_prozent WHERE (zweitstimmen_prozent.partei_id IS NOT NULL) OFFSET 6) SELECT NULL::integer AS partei_id, (sum(rest.prozent))::numeric(3,1) AS prozent FROM rest);


--
-- TOC entry 180 (class 1259 OID 16424)
-- Dependencies: 5
-- Name: partei; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE partei (
    name character varying(150),
    id integer NOT NULL
);


SET search_path = adapter, pg_catalog;

--
-- TOC entry 267 (class 1259 OID 59417)
-- Dependencies: 2348 14
-- Name: ergebnisse_zweitstimme_diagramm_name; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW ergebnisse_zweitstimme_diagramm_name AS
    SELECT p.name, zsd.prozent FROM public.ergebnisse_zweitstimme_diagramm zsd, public.partei p WHERE (p.id = zsd.partei_id) UNION ALL SELECT 'Andere'::character varying AS name, ergebnisse_zweitstimme_diagramm.prozent FROM public.ergebnisse_zweitstimme_diagramm WHERE (ergebnisse_zweitstimme_diagramm.partei_id IS NULL);


SET search_path = public, pg_catalog;

--
-- TOC entry 251 (class 1259 OID 59240)
-- Dependencies: 2334 5
-- Name: direktkandidat_gewinner_land_partei; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidat_gewinner_land_partei AS
    SELECT dg.direktkandidat_id AS kandidat_id, l.id AS land_id, p.id AS partei_id FROM direktkandidat_gewinner dg, direktkandidat d, land l, partei p, wahlkreis wk WHERE ((((dg.direktkandidat_id = d.id) AND (d.partei_id = p.id)) AND (dg.wahlkreis_id = wk.id)) AND (wk.land_id = l.id));


--
-- TOC entry 252 (class 1259 OID 59244)
-- Dependencies: 2335 5
-- Name: wahl_gewinner_aux; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW wahl_gewinner_aux AS
    WITH direktkandidaten_anzahl AS (SELECT direktkandidat_gewinner_land_partei.land_id, direktkandidat_gewinner_land_partei.partei_id, count(*) AS direkt_sitze FROM direktkandidat_gewinner_land_partei GROUP BY direktkandidat_gewinner_land_partei.land_id, direktkandidat_gewinner_land_partei.partei_id), aux AS (SELECT spb.partei_id, spb.land_id, COALESCE(w.direkt_sitze, (0)::bigint) AS direkt_sitze, spb.sitze AS zweit_sitze FROM (sitze_alle_parteien_bundesland() spb(partei_id, land_id, sitze) LEFT JOIN direktkandidaten_anzahl w ON (((spb.land_id = w.land_id) AND (spb.partei_id = w.partei_id))))) SELECT aux.partei_id, aux.land_id, aux.direkt_sitze, aux.zweit_sitze, (aux.direkt_sitze - aux.zweit_sitze) AS diff FROM aux;


--
-- TOC entry 2430 (class 0 OID 0)
-- Dependencies: 252
-- Name: VIEW wahl_gewinner_aux; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW wahl_gewinner_aux IS 'Stellt pro Partei und Land die Anzahl der gewonnenen Direktmandate, sowie die Anzahl der Sitze laut Zweitstimme dar.
Außerdem wird die Differenz dieser Werte angegeben. Darauß lässt sich die Anzahl der Überhangmandate (Wert positiv), oder die Anzahl der Kandidaten, die von der Landesliste nachrutschen müssen (Wert negativ) bestimmen.';


--
-- TOC entry 253 (class 1259 OID 59255)
-- Dependencies: 2336 5 903
-- Name: wahl_gewinner; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW wahl_gewinner AS
    SELECT direktkandidat_gewinner_land_partei.kandidat_id, 'Direktkandidat'::gewinner_typ AS typ, direktkandidat_gewinner_land_partei.land_id, direktkandidat_gewinner_land_partei.partei_id FROM direktkandidat_gewinner_land_partei UNION ALL SELECT k.id AS kandidat_id, 'Landeskandidat'::gewinner_typ AS typ, l.land_id, l.partei_id FROM landeskandidat_ohne_direktmandat_bereinigt() k(id, vorname, nachname, listenrang, landesliste_id), landesliste l, wahl_gewinner_aux wga WHERE (((((k.landesliste_id = l.id) AND (l.land_id = wga.land_id)) AND (l.partei_id = wga.partei_id)) AND (wga.diff < 0)) AND (k.listenrang <= abs(wga.diff)));


--
-- TOC entry 2431 (class 0 OID 0)
-- Dependencies: 253
-- Name: VIEW wahl_gewinner; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW wahl_gewinner IS 'Listet die Gewinner der Wahl auf (mit Land und Partei). Dabei wird bei jedem Kandidaten dazugeschrieben ob es sich um einen Direktmandat oder ein Listenmandat handelt.';


SET search_path = adapter, pg_catalog;

--
-- TOC entry 263 (class 1259 OID 59399)
-- Dependencies: 2344 14
-- Name: mitglieder_bundestag; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW mitglieder_bundestag AS
    SELECT dk.vorname, dk.nachname, p.name AS partei_name FROM public.wahl_gewinner g, public.direktkandidat dk, public.partei p WHERE (((dk.id = g.kandidat_id) AND (g.typ = 'Direktkandidat'::public.gewinner_typ)) AND (dk.partei_id = p.id)) UNION ALL SELECT lk.vorname, lk.nachname, p.name AS partei_name FROM public.wahl_gewinner g, public.landeskandidat lk, public.landesliste ll, public.partei p WHERE ((((lk.id = g.kandidat_id) AND (g.typ = 'Landeskandidat'::public.gewinner_typ)) AND (lk.landesliste_id = ll.id)) AND (ll.partei_id = p.id)) ORDER BY 2;


--
-- TOC entry 264 (class 1259 OID 59404)
-- Dependencies: 2345 14
-- Name: sitzverteilung_pro_partei_name; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW sitzverteilung_pro_partei_name AS
    SELECT p.name AS partei_name, count(*) AS sitze FROM public.wahl_gewinner wg, public.partei p WHERE (p.id = wg.partei_id) GROUP BY wg.partei_id, p.name;


--
-- TOC entry 254 (class 1259 OID 59265)
-- Dependencies: 2337 14
-- Name: ueberhangmandate; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW ueberhangmandate AS
    SELECT p.name AS partei_name, l.name AS land_name, wa.diff AS anzahl FROM public.wahl_gewinner_aux wa, public.partei p, public.land l WHERE (((wa.diff > 0) AND (wa.partei_id = p.id)) AND (wa.land_id = l.id));


--
-- TOC entry 259 (class 1259 OID 59338)
-- Dependencies: 2342 14
-- Name: wahlbeteiligung; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW wahlbeteiligung AS
    WITH abgegebene_stimmen AS (SELECT erststimmen_aggregation.wahlkreis_id, sum(erststimmen_aggregation.stimmen) AS stimmen FROM public.erststimmen_aggregation GROUP BY erststimmen_aggregation.wahlkreis_id) SELECT wk.id AS wahlkreis_id, wk.name, wk.wahlberechtigte, abs.stimmen, (((abs.stimmen * (100)::numeric) / (wk.wahlberechtigte)::numeric))::numeric(4,2) AS beteiligung FROM public.wahlkreis wk, abgegebene_stimmen abs WHERE (abs.wahlkreis_id = wk.id);


--
-- TOC entry 265 (class 1259 OID 59409)
-- Dependencies: 2346 14
-- Name: wahlkreissieger_partei_erststimme; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW wahlkreissieger_partei_erststimme AS
    SELECT wk.name AS wahlkreis, p.name AS partei_name, dk.vorname, dk.nachname FROM public.wahlkreis wk, public.partei p, public.direktkandidat dk, public.wahl_gewinner wg WHERE (((((wg.typ)::text = 'Direktkandidat'::text) AND (wg.kandidat_id = dk.id)) AND (p.id = wg.partei_id)) AND (dk.wahlkreis_id = wk.id));


--
-- TOC entry 266 (class 1259 OID 59413)
-- Dependencies: 2347 14
-- Name: wahlkreissieger_partei_zweitstimme; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW wahlkreissieger_partei_zweitstimme AS
    SELECT wk.name AS wahlkreis, p.name AS partei_name FROM public.zweitstimmen_aggregation za1, public.zweitstimmen_aggregation za2, public.partei p, public.wahlkreis wk WHERE (((za1.wahlkreis_id = za2.wahlkreis_id) AND (za1.partei_id = p.id)) AND (za1.wahlkreis_id = wk.id)) GROUP BY za1.wahlkreis_id, p.name, za1.stimmen, wk.name HAVING (za1.stimmen = max(za2.stimmen));


SET search_path = alt, pg_catalog;

--
-- TOC entry 240 (class 1259 OID 41770)
-- Dependencies: 2327 11
-- Name: prozent_partei_zweitstimmen; Type: VIEW; Schema: alt; Owner: -
--

CREATE VIEW prozent_partei_zweitstimmen AS
    WITH stimmen_pro_partei AS (SELECT zweitstimmen_aggregation.partei_id, sum(zweitstimmen_aggregation.stimmen) AS stimmen FROM public.zweitstimmen_aggregation GROUP BY zweitstimmen_aggregation.partei_id), gesamtstimmen AS (SELECT sum(zweitstimmen_aggregation.stimmen) AS stimmen FROM public.zweitstimmen_aggregation) SELECT sp.partei_id, (sp.stimmen / gs.stimmen) AS prozent FROM stimmen_pro_partei sp, gesamtstimmen gs;


SET search_path = public, pg_catalog;

--
-- TOC entry 170 (class 1259 OID 16399)
-- Dependencies: 5 169
-- Name: Direktkandidat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Direktkandidat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2432 (class 0 OID 0)
-- Dependencies: 170
-- Name: Direktkandidat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Direktkandidat_id_seq" OWNED BY direktkandidat.id;


--
-- TOC entry 171 (class 1259 OID 16401)
-- Dependencies: 5
-- Name: erststimme; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE erststimme (
    id integer NOT NULL,
    wahlkreis_id integer,
    direktkandidat_id integer
);


--
-- TOC entry 172 (class 1259 OID 16404)
-- Dependencies: 5 171
-- Name: Erststimme_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Erststimme_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2433 (class 0 OID 0)
-- Dependencies: 172
-- Name: Erststimme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Erststimme_id_seq" OWNED BY erststimme.id;


--
-- TOC entry 175 (class 1259 OID 16412)
-- Dependencies: 174 5
-- Name: Land_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Land_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2434 (class 0 OID 0)
-- Dependencies: 175
-- Name: Land_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Land_id_seq" OWNED BY land.id;


--
-- TOC entry 177 (class 1259 OID 16417)
-- Dependencies: 176 5
-- Name: Landeskandidat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Landeskandidat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2435 (class 0 OID 0)
-- Dependencies: 177
-- Name: Landeskandidat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Landeskandidat_id_seq" OWNED BY landeskandidat.id;


--
-- TOC entry 179 (class 1259 OID 16422)
-- Dependencies: 5 178
-- Name: Landesliste_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Landesliste_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2436 (class 0 OID 0)
-- Dependencies: 179
-- Name: Landesliste_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Landesliste_id_seq" OWNED BY landesliste.id;


--
-- TOC entry 181 (class 1259 OID 16427)
-- Dependencies: 5 180
-- Name: Partei_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Partei_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2437 (class 0 OID 0)
-- Dependencies: 181
-- Name: Partei_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Partei_id_seq" OWNED BY partei.id;


--
-- TOC entry 183 (class 1259 OID 16437)
-- Dependencies: 182 5
-- Name: Wahlkreis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Wahlkreis_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2438 (class 0 OID 0)
-- Dependencies: 183
-- Name: Wahlkreis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Wahlkreis_id_seq" OWNED BY wahlkreis.id;


--
-- TOC entry 184 (class 1259 OID 16439)
-- Dependencies: 5
-- Name: zweitstimme; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zweitstimme (
    id integer NOT NULL,
    wahlkreis_id integer,
    landesliste_id integer
);


--
-- TOC entry 185 (class 1259 OID 16442)
-- Dependencies: 184 5
-- Name: Zweitstimme_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Zweitstimme_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2439 (class 0 OID 0)
-- Dependencies: 185
-- Name: Zweitstimme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Zweitstimme_id_seq" OWNED BY zweitstimme.id;


--
-- TOC entry 256 (class 1259 OID 59293)
-- Dependencies: 2339 5
-- Name: anzahl_direktmandat_auch_landeskandidat; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW anzahl_direktmandat_auch_landeskandidat AS
    SELECT d.partei_id, w.land_id, count(*) AS count FROM direktkandidat_gewinner dg, direktkandidat d, wahlkreis w WHERE (((dg.direktkandidat_id = d.id) AND (d.wahlkreis_id = w.id)) AND (EXISTS (SELECT l.id, l.vorname, l.nachname, l.listenrang, l.landesliste_id, ll.id, ll.listenplatz, ll.land_id, ll.partei_id FROM landeskandidat l, landesliste ll WHERE ((((l.landesliste_id = ll.id) AND ((l.vorname)::text = (d.vorname)::text)) AND ((l.nachname)::text = (d.nachname)::text)) AND (ll.partei_id = d.partei_id))))) GROUP BY d.partei_id, w.land_id;


--
-- TOC entry 244 (class 1259 OID 59094)
-- Dependencies: 2329 5
-- Name: direktkandidat_differenz_auf_ersten; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidat_differenz_auf_ersten AS
    SELECT p.id AS partei_id, dk.id AS kandidat_id, (ea1.stimmen - (SELECT ea.stimmen FROM erststimmen_aggregation ea, partei p, direktkandidat dk1 WHERE ((((dk1.wahlkreis_id = ea.wahlkreis_id) AND (dk1.partei_id = p.id)) AND (dk1.id = ea.direktkandidat_id)) AND (ea.wahlkreis_id = dk.wahlkreis_id)) ORDER BY ea.stimmen DESC LIMIT 1)) AS diff FROM partei p, direktkandidat dk, erststimmen_aggregation ea1 WHERE ((p.id = dk.partei_id) AND (dk.id = ea1.direktkandidat_id));


--
-- TOC entry 245 (class 1259 OID 59106)
-- Dependencies: 2330 5
-- Name: direktkandidat_differenz_auf_zweiten; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidat_differenz_auf_zweiten AS
    SELECT p.id AS partei_id, dk.id AS kandidat_id, (ea1.stimmen - (SELECT ea.stimmen FROM erststimmen_aggregation ea, partei p, direktkandidat dk1 WHERE (((dk1.partei_id = p.id) AND (dk1.id = ea.direktkandidat_id)) AND (ea.wahlkreis_id = dk.wahlkreis_id)) ORDER BY ea.stimmen DESC OFFSET 1 LIMIT 1)) AS diff FROM partei p, direktkandidat dk, erststimmen_aggregation ea1 WHERE ((p.id = dk.partei_id) AND (dk.id = ea1.direktkandidat_id));


--
-- TOC entry 236 (class 1259 OID 41732)
-- Dependencies: 2323 5
-- Name: direktkandidaten_pro_partei; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidaten_pro_partei AS
    SELECT d.partei_id, count(*) AS anzahl_direktkandidaten FROM direktkandidat_gewinner dg, direktkandidat d WHERE (dg.direktkandidat_id = d.id) GROUP BY d.partei_id;


--
-- TOC entry 242 (class 1259 OID 59077)
-- Dependencies: 5
-- Name: erststimme_q7; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE erststimme_q7 (
    id integer,
    wahlkreis_id integer,
    direktkandidat_id integer
);


--
-- TOC entry 246 (class 1259 OID 59112)
-- Dependencies: 2331 5
-- Name: erststimmen_agg_q7; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW erststimmen_agg_q7 AS
    SELECT erststimmen_aggregation.direktkandidat_id, erststimmen_aggregation.wahlkreis_id, erststimmen_aggregation.stimmen FROM erststimmen_aggregation WHERE ((erststimmen_aggregation.wahlkreis_id < 214) OR (erststimmen_aggregation.wahlkreis_id > 217)) UNION ALL SELECT erststimme_q7.direktkandidat_id, erststimme_q7.wahlkreis_id, count(*) AS stimmen FROM erststimme_q7 GROUP BY erststimme_q7.direktkandidat_id, erststimme_q7.wahlkreis_id;


SET search_path = stimmen2009, pg_catalog;

--
-- TOC entry 201 (class 1259 OID 24943)
-- Dependencies: 9
-- Name: ErststimmenEndgueltig; Type: TABLE; Schema: stimmen2009; Owner: -; Tablespace: 
--

CREATE TABLE "ErststimmenEndgueltig" (
    "Nr" integer,
    "GehoertZu" integer,
    "Partei" character varying(100),
    "Gebiet" character varying(100),
    "Stimmen" integer
);


--
-- TOC entry 205 (class 1259 OID 25025)
-- Dependencies: 2301 9
-- Name: direktkandidat_stimmen; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW direktkandidat_stimmen AS
    SELECT public.get_direktkandidat_id_by_wahlkreis_partei_jahr("ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Partei", 2009) AS kandidat_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen, public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text IN (SELECT partei.name FROM public.partei)) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 204 (class 1259 OID 25001)
-- Dependencies: 2300 9
-- Name: erststimme_ungueltige; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW erststimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 215 (class 1259 OID 25180)
-- Dependencies: 2307 9
-- Name: erststimme_insges; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW erststimme_insges AS
    SELECT direktkandidat_stimmen.kandidat_id, direktkandidat_stimmen.stimmen, direktkandidat_stimmen.wahlkreis_id FROM direktkandidat_stimmen UNION ALL SELECT NULL::integer AS kandidat_id, erststimme_ungueltige.stimmen, erststimme_ungueltige.wahlkreis_id FROM erststimme_ungueltige;


SET search_path = public, pg_catalog;

--
-- TOC entry 219 (class 1259 OID 33447)
-- Dependencies: 2310 5
-- Name: erststimmen_aggregation_ausKerg; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW "erststimmen_aggregation_ausKerg" AS
    SELECT erststimme_insges.kandidat_id AS direktkandidat_id, erststimme_insges.stimmen, erststimme_insges.wahlkreis_id FROM stimmen2009.erststimme_insges;


--
-- TOC entry 257 (class 1259 OID 59301)
-- Dependencies: 2340 5
-- Name: hat_direktmandat; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW hat_direktmandat AS
    SELECT DISTINCT p.id FROM partei p, wahl_gewinner wg WHERE ((p.id = wg.partei_id) AND (wg.typ = 'Direktkandidat'::gewinner_typ));


--
-- TOC entry 173 (class 1259 OID 16406)
-- Dependencies: 5
-- Name: jahr; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jahr (
    jahr integer NOT NULL
);


--
-- TOC entry 237 (class 1259 OID 41736)
-- Dependencies: 2324 5
-- Name: parteien_einzug; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW parteien_einzug AS
    SELECT zweitstimmen_prozent.partei_id FROM zweitstimmen_prozent WHERE (zweitstimmen_prozent.prozent > (5)::numeric) UNION SELECT direktkandidaten_pro_partei.partei_id FROM direktkandidaten_pro_partei WHERE (direktkandidaten_pro_partei.anzahl_direktkandidaten > 2);


--
-- TOC entry 249 (class 1259 OID 59230)
-- Dependencies: 2333 5
-- Name: partei_land_stimmen_einzug; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW partei_land_stimmen_einzug AS
    SELECT za.partei_id, w.land_id, (sum(za.stimmen))::bigint AS stimmen FROM zweitstimmen_aggregation za, wahlkreis w WHERE ((za.wahlkreis_id = w.id) AND (za.partei_id IN (SELECT parteien_einzug.partei_id FROM parteien_einzug))) GROUP BY za.partei_id, w.land_id;


--
-- TOC entry 241 (class 1259 OID 41778)
-- Dependencies: 2328 5
-- Name: partei_stimmen_pro_land; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW partei_stimmen_pro_land AS
    SELECT za.partei_id, w.land_id, sum(za.stimmen) AS stimmen FROM zweitstimmen_aggregation za, wahlkreis w WHERE (za.wahlkreis_id = w.id) GROUP BY za.partei_id, w.land_id;


--
-- TOC entry 217 (class 1259 OID 25211)
-- Dependencies: 5
-- Name: scherperfaktoren; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scherperfaktoren (
    faktor numeric NOT NULL
);


--
-- TOC entry 224 (class 1259 OID 41672)
-- Dependencies: 2313 5
-- Name: scherper_auswertung_bund; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW scherper_auswertung_bund AS
    WITH stimmen_partei AS (SELECT pe.partei_id, sum(za.stimmen) AS stimmen FROM zweitstimmen_aggregation za, parteien_einzug pe WHERE (za.partei_id = pe.partei_id) GROUP BY pe.partei_id) SELECT sp.partei_id, (sp.stimmen / f.faktor) AS gewicht FROM stimmen_partei sp, scherperfaktoren f ORDER BY (sp.stimmen / f.faktor) DESC;


--
-- TOC entry 238 (class 1259 OID 41744)
-- Dependencies: 2325 5
-- Name: sitzverteilung_ohne_ueberhangmandate; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW sitzverteilung_ohne_ueberhangmandate AS
    WITH leute AS (SELECT scherper_auswertung_bund.partei_id, scherper_auswertung_bund.gewicht FROM scherper_auswertung_bund LIMIT 598) SELECT leute.partei_id, count(leute.partei_id) AS sitze FROM leute GROUP BY leute.partei_id;


--
-- TOC entry 258 (class 1259 OID 59318)
-- Dependencies: 2341 5
-- Name: wahlbeteiligung; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW wahlbeteiligung AS
    WITH abgegebene_stimmen AS (SELECT e.wahlkreis_id, sum(e.stimmen) AS stimmen FROM erststimmen_aggregation e GROUP BY e.wahlkreis_id) SELECT w.id AS wahlkreis_id, (((100)::numeric * a.stimmen) / (w.wahlberechtigte)::numeric) AS beteiligung FROM wahlkreis w, abgegebene_stimmen a WHERE (w.id = a.wahlkreis_id);


--
-- TOC entry 243 (class 1259 OID 59080)
-- Dependencies: 5
-- Name: zweitstimme_q7; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zweitstimme_q7 (
    id integer,
    wahlkreis_id integer,
    landesliste_id integer
);


SET search_path = stimmen2009, pg_catalog;

--
-- TOC entry 203 (class 1259 OID 24989)
-- Dependencies: 9
-- Name: ZweitstimmenEndgueltig; Type: TABLE; Schema: stimmen2009; Owner: -; Tablespace: 
--

CREATE TABLE "ZweitstimmenEndgueltig" (
    "Nr" integer,
    "GehoertZu" integer,
    "Partei" character varying(100),
    "Gebiet" character varying(100),
    "Stimmen" integer
);


--
-- TOC entry 210 (class 1259 OID 25150)
-- Dependencies: 2306 9
-- Name: landesliste_stimmen; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW landesliste_stimmen AS
    SELECT public.get_landesliste_id_by_wahlkreis_partei_jahr(ee."Gebiet", ee."Partei", 2009) AS landesliste_id, ee."Stimmen" AS stimmen, public.get_wahlkreis_id_by_jahr_and_name(2009, ee."Gebiet") AS wahlkreis_id FROM "ZweitstimmenEndgueltig" ee WHERE (((((ee."Partei")::text IN (SELECT partei.name FROM public.partei)) AND (ee."GehoertZu" IS NOT NULL)) AND ((ee."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND (ee."Stimmen" IS NOT NULL));


--
-- TOC entry 207 (class 1259 OID 25138)
-- Dependencies: 2303 9
-- Name: zweitstimme_ungueltige; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW zweitstimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ZweitstimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ZweitstimmenEndgueltig"."Stimmen" AS stimmen FROM "ZweitstimmenEndgueltig" WHERE ((((("ZweitstimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ZweitstimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ZweitstimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ZweitstimmenEndgueltig"."Stimmen" IS NOT NULL));


SET search_path = public, pg_catalog;

--
-- TOC entry 218 (class 1259 OID 33439)
-- Dependencies: 2309 5
-- Name: zweitstimmen_aggregation_ausKerg; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW "zweitstimmen_aggregation_ausKerg" AS
    SELECT ll.partei_id, s.wahlkreis_id, s.stimmen FROM stimmen2009.landesliste_stimmen s, landesliste ll WHERE (s.landesliste_id = ll.id) UNION ALL SELECT NULL::integer AS partei_id, s.wahlkreis_id, s.stimmen FROM stimmen2009.zweitstimme_ungueltige s;


--
-- TOC entry 247 (class 1259 OID 59116)
-- Dependencies: 2332 5
-- Name: zweitstimmen_q7_agg; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW zweitstimmen_q7_agg AS
    SELECT zweitstimmen_aggregation.partei_id, zweitstimmen_aggregation.wahlkreis_id, zweitstimmen_aggregation.stimmen FROM zweitstimmen_aggregation WHERE ((zweitstimmen_aggregation.wahlkreis_id < 213) OR (zweitstimmen_aggregation.wahlkreis_id > 217)) UNION ALL (WITH zweitstimmenwahlkreisliste AS (SELECT z.landesliste_id, z.wahlkreis_id, count(z.*) AS stimmen FROM zweitstimme_q7 z, landesliste ll WHERE (z.landesliste_id = ll.id) GROUP BY z.landesliste_id, z.wahlkreis_id) SELECT p.id AS partei_id, zl.wahlkreis_id, zl.stimmen FROM partei p, zweitstimmenwahlkreisliste zl, landesliste ll2 WHERE ((ll2.id = zl.landesliste_id) AND (p.id = ll2.partei_id)));


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 196 (class 1259 OID 16866)
-- Dependencies: 8
-- Name: bundeslandkuerzel; Type: TABLE; Schema: raw2005; Owner: -; Tablespace: 
--

CREATE TABLE bundeslandkuerzel (
    name character varying(100),
    kuerzel_5 character varying(5),
    kuerzel_2 character varying(2) NOT NULL
);


--
-- TOC entry 198 (class 1259 OID 16895)
-- Dependencies: 8
-- Name: mapid_wahlkreise; Type: TABLE; Schema: raw2005; Owner: -; Tablespace: 
--

CREATE TABLE mapid_wahlkreise (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 193 (class 1259 OID 16697)
-- Dependencies: 8
-- Name: wahlbewerber; Type: TABLE; Schema: raw2005; Owner: -; Tablespace: 
--

CREATE TABLE wahlbewerber (
    "Vorname" character varying(100),
    "Name" character varying(100),
    "Partei" character varying(100),
    "Wahlkreis" integer,
    "Land" character varying(100),
    "Platz" integer,
    id integer NOT NULL
);


--
-- TOC entry 197 (class 1259 OID 16871)
-- Dependencies: 2296 8
-- Name: wahlbewerber_mit_land; Type: VIEW; Schema: raw2005; Owner: -
--

CREATE VIEW wahlbewerber_mit_land AS
    SELECT wb."Vorname", wb."Name", wb."Partei", wb."Wahlkreis", wb."Land", wb."Platz", wb.id, kz.name AS land_name FROM wahlbewerber wb, bundeslandkuerzel kz WHERE ((wb."Land")::text = (kz.kuerzel_2)::text);


--
-- TOC entry 199 (class 1259 OID 24910)
-- Dependencies: 2297 8
-- Name: wahlbewerber_direktkandidat; Type: VIEW; Schema: raw2005; Owner: -
--

CREATE VIEW wahlbewerber_direktkandidat AS
    SELECT w.id, w."Vorname", w."Name", w."Wahlkreis", public.get_partei_id_by_name(w."Partei") AS partei_id FROM wahlbewerber_mit_land w WHERE (w."Wahlkreis" IS NOT NULL);


--
-- TOC entry 194 (class 1259 OID 16701)
-- Dependencies: 8 193
-- Name: wahlbewerber_id_seq; Type: SEQUENCE; Schema: raw2005; Owner: -
--

CREATE SEQUENCE wahlbewerber_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2440 (class 0 OID 0)
-- Dependencies: 194
-- Name: wahlbewerber_id_seq; Type: SEQUENCE OWNED BY; Schema: raw2005; Owner: -
--

ALTER SEQUENCE wahlbewerber_id_seq OWNED BY wahlbewerber.id;


--
-- TOC entry 200 (class 1259 OID 24914)
-- Dependencies: 2298 8
-- Name: wahlbewerber_landesliste; Type: VIEW; Schema: raw2005; Owner: -
--

CREATE VIEW wahlbewerber_landesliste AS
    SELECT w.id, w."Vorname", w."Name", w."Wahlkreis", public.get_partei_id_by_name(w."Partei") AS partei_id FROM wahlbewerber_mit_land w WHERE (w."Wahlkreis" IS NULL);


--
-- TOC entry 195 (class 1259 OID 16709)
-- Dependencies: 8
-- Name: wahlkreise; Type: TABLE; Schema: raw2005; Owner: -; Tablespace: 
--

CREATE TABLE wahlkreise (
    "Nummer" integer NOT NULL,
    "Land" character varying(100),
    "Name" character varying(100)
);


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 186 (class 1259 OID 16444)
-- Dependencies: 7
-- Name: landeslisten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE landeslisten (
    "Listennummer" integer NOT NULL,
    "Bundesland" character varying(100),
    "Partei" character varying(100)
);


--
-- TOC entry 187 (class 1259 OID 16447)
-- Dependencies: 7
-- Name: listenplaetze; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE listenplaetze (
    "Landesliste" integer NOT NULL,
    "Kandidat" integer NOT NULL,
    "Position" integer
);


--
-- TOC entry 214 (class 1259 OID 25169)
-- Dependencies: 7
-- Name: mapid_direktkandidaten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_direktkandidaten (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 213 (class 1259 OID 25164)
-- Dependencies: 7
-- Name: mapid_landeskandidaten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_landeskandidaten (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 212 (class 1259 OID 25159)
-- Dependencies: 7
-- Name: mapid_landeslisten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_landeslisten (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 211 (class 1259 OID 25154)
-- Dependencies: 7
-- Name: mapid_wahlkreise; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_wahlkreise (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 188 (class 1259 OID 16450)
-- Dependencies: 7
-- Name: wahlbewerber; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE wahlbewerber (
    "Titel" character varying(100),
    "Vorname" character varying(100),
    "Nachname" character varying(100),
    "Partei" character varying(100),
    "Jahrgang" integer,
    "Kandidatennummer" integer NOT NULL
);


--
-- TOC entry 202 (class 1259 OID 24953)
-- Dependencies: 2299 7
-- Name: wahlbewerber_mit_titel; Type: VIEW; Schema: raw2009; Owner: -
--

CREATE VIEW wahlbewerber_mit_titel AS
    SELECT CASE WHEN (w."Titel" IS NULL) THEN (w."Vorname")::text ELSE (((w."Titel")::text || ' '::text) || (w."Vorname")::text) END AS "Vorname", w."Nachname", w."Partei", w."Jahrgang", w."Kandidatennummer" FROM wahlbewerber w;


--
-- TOC entry 189 (class 1259 OID 16453)
-- Dependencies: 7
-- Name: wahlbewerber_mit_wahlkreis; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE wahlbewerber_mit_wahlkreis (
    "Vorname" character varying(100),
    "Nachname" character varying(100),
    "Jahrgang" integer,
    "Partei" character varying(100),
    "Wahlkreis" integer
);


--
-- TOC entry 190 (class 1259 OID 16456)
-- Dependencies: 2294 7
-- Name: wahlbewerber_direktkandidat; Type: VIEW; Schema: raw2009; Owner: -
--

CREATE VIEW wahlbewerber_direktkandidat AS
    SELECT w."Kandidatennummer", ww."Vorname", ww."Nachname", ww."Wahlkreis", public.get_partei_id_by_name(ww."Partei") AS partei_id FROM wahlbewerber_mit_wahlkreis ww, wahlbewerber_mit_titel w WHERE (((((ww."Vorname")::text = w."Vorname") AND ((ww."Nachname")::text = (w."Nachname")::text)) AND (ww."Jahrgang" = w."Jahrgang")) AND ((public.get_partei_id_by_name(ww."Partei") IS NULL) OR ((ww."Partei")::text = (w."Partei")::text)));


--
-- TOC entry 191 (class 1259 OID 16460)
-- Dependencies: 2295 7
-- Name: wahlbewerber_landesliste; Type: VIEW; Schema: raw2009; Owner: -
--

CREATE VIEW wahlbewerber_landesliste AS
    SELECT CASE WHEN (w."Titel" IS NULL) THEN (w."Vorname")::text ELSE (((w."Titel")::text || ' '::text) || (w."Vorname")::text) END AS "VornameTitel", w."Nachname", w."Partei", w."Jahrgang", w."Kandidatennummer", lp."Landesliste", lp."Position" FROM wahlbewerber w, listenplaetze lp WHERE (w."Kandidatennummer" = lp."Kandidat");


--
-- TOC entry 192 (class 1259 OID 16464)
-- Dependencies: 7
-- Name: wahlkreise; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE wahlkreise (
    "Land" character varying(100),
    "WahlkreisNr" integer NOT NULL,
    "Name" character varying(200),
    "Wahlberechtigte" integer,
    "Vorperiode" integer
);


SET search_path = stimmen2005, pg_catalog;

--
-- TOC entry 225 (class 1259 OID 41681)
-- Dependencies: 10
-- Name: ErststimmenEndgueltig; Type: TABLE; Schema: stimmen2005; Owner: -; Tablespace: 
--

CREATE TABLE "ErststimmenEndgueltig" (
    "Nr" integer,
    "GehoertZu" integer,
    "Partei" character varying(100),
    "Gebiet" character varying(100),
    "Stimmen" integer
);


--
-- TOC entry 226 (class 1259 OID 41684)
-- Dependencies: 10
-- Name: ZweitstimmenEndgueltig; Type: TABLE; Schema: stimmen2005; Owner: -; Tablespace: 
--

CREATE TABLE "ZweitstimmenEndgueltig" (
    "Nr" integer,
    "GehoertZu" integer,
    "Partei" character varying(100),
    "Gebiet" character varying(100),
    "Stimmen" integer
);


--
-- TOC entry 227 (class 1259 OID 41687)
-- Dependencies: 2314 10
-- Name: direktkandidat_stimmen; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW direktkandidat_stimmen AS
    SELECT public.get_direktkandidat_id_by_wahlkreis_partei_jahr("ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Partei", 2009) AS kandidat_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen, public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text IN (SELECT partei.name FROM public.partei)) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id, nummer, wahlberechtigte)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 232 (class 1259 OID 41707)
-- Dependencies: 2319 10
-- Name: direktkandidat_uebrige; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW direktkandidat_uebrige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Übrige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id, nummer, wahlberechtigte)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 228 (class 1259 OID 41691)
-- Dependencies: 2315 10
-- Name: erststimme_ungueltige; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW erststimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id, nummer, wahlberechtigte)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 229 (class 1259 OID 41695)
-- Dependencies: 2316 10
-- Name: erststimme_insges; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW erststimme_insges AS
    SELECT direktkandidat_stimmen.kandidat_id, direktkandidat_stimmen.stimmen, direktkandidat_stimmen.wahlkreis_id FROM direktkandidat_stimmen UNION ALL SELECT NULL::integer AS kandidat_id, erststimme_ungueltige.stimmen, erststimme_ungueltige.wahlkreis_id FROM erststimme_ungueltige;


--
-- TOC entry 233 (class 1259 OID 41711)
-- Dependencies: 2320 10
-- Name: erststimmen_statistik; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW erststimmen_statistik AS
    SELECT "ErststimmenEndgueltig"."Nr", "ErststimmenEndgueltig"."GehoertZu", "ErststimmenEndgueltig"."Partei", "ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Stimmen" FROM "ErststimmenEndgueltig" WHERE ("ErststimmenEndgueltig"."GehoertZu" IS NULL);


--
-- TOC entry 230 (class 1259 OID 41699)
-- Dependencies: 2317 10
-- Name: landesliste_stimmen; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW landesliste_stimmen AS
    SELECT public.get_landesliste_id_by_wahlkreis_partei_jahr(ee."Gebiet", ee."Partei", 2009) AS landesliste_id, ee."Stimmen" AS stimmen, public.get_wahlkreis_id_by_jahr_and_name(2009, ee."Gebiet") AS wahlkreis_id FROM "ZweitstimmenEndgueltig" ee WHERE (((((ee."Partei")::text IN (SELECT partei.name FROM public.partei)) AND (ee."GehoertZu" IS NOT NULL)) AND ((ee."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id, nummer, wahlberechtigte)))) AND (ee."Stimmen" IS NOT NULL));


--
-- TOC entry 231 (class 1259 OID 41703)
-- Dependencies: 2318 10
-- Name: zweitstimme_ungueltige; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW zweitstimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ZweitstimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ZweitstimmenEndgueltig"."Stimmen" AS stimmen FROM "ZweitstimmenEndgueltig" WHERE ((((("ZweitstimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ZweitstimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ZweitstimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id, nummer, wahlberechtigte)))) AND ("ZweitstimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 234 (class 1259 OID 41715)
-- Dependencies: 2321 10
-- Name: zweitstimme_insges; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW zweitstimme_insges AS
    SELECT landesliste_stimmen.landesliste_id, landesliste_stimmen.stimmen, landesliste_stimmen.wahlkreis_id FROM landesliste_stimmen UNION ALL SELECT NULL::integer AS landesliste_id, zweitstimme_ungueltige.stimmen, zweitstimme_ungueltige.wahlkreis_id FROM zweitstimme_ungueltige;


--
-- TOC entry 235 (class 1259 OID 41719)
-- Dependencies: 2322 10
-- Name: zweitstimmen_statistik; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW zweitstimmen_statistik AS
    SELECT "ZweitstimmenEndgueltig"."Nr", "ZweitstimmenEndgueltig"."GehoertZu", "ZweitstimmenEndgueltig"."Partei", "ZweitstimmenEndgueltig"."Gebiet", "ZweitstimmenEndgueltig"."Stimmen" FROM "ZweitstimmenEndgueltig" WHERE ("ZweitstimmenEndgueltig"."GehoertZu" IS NULL);


SET search_path = stimmen2009, pg_catalog;

--
-- TOC entry 206 (class 1259 OID 25108)
-- Dependencies: 2302 9
-- Name: direktkandidat_uebrige; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW direktkandidat_uebrige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Übrige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 208 (class 1259 OID 25142)
-- Dependencies: 2304 9
-- Name: erststimmen_statistik; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW erststimmen_statistik AS
    SELECT "ErststimmenEndgueltig"."Nr", "ErststimmenEndgueltig"."GehoertZu", "ErststimmenEndgueltig"."Partei", "ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Stimmen" FROM "ErststimmenEndgueltig" WHERE ("ErststimmenEndgueltig"."GehoertZu" IS NULL);


--
-- TOC entry 216 (class 1259 OID 25184)
-- Dependencies: 2308 9
-- Name: zweitstimme_insges; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW zweitstimme_insges AS
    SELECT landesliste_stimmen.landesliste_id, landesliste_stimmen.stimmen, landesliste_stimmen.wahlkreis_id FROM landesliste_stimmen UNION ALL SELECT NULL::integer AS landesliste_id, zweitstimme_ungueltige.stimmen, zweitstimme_ungueltige.wahlkreis_id FROM zweitstimme_ungueltige;


--
-- TOC entry 209 (class 1259 OID 25146)
-- Dependencies: 2305 9
-- Name: zweitstimmen_statistik; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW zweitstimmen_statistik AS
    SELECT "ZweitstimmenEndgueltig"."Nr", "ZweitstimmenEndgueltig"."GehoertZu", "ZweitstimmenEndgueltig"."Partei", "ZweitstimmenEndgueltig"."Gebiet", "ZweitstimmenEndgueltig"."Stimmen" FROM "ZweitstimmenEndgueltig" WHERE ("ZweitstimmenEndgueltig"."GehoertZu" IS NULL);


SET search_path = public, pg_catalog;

--
-- TOC entry 2349 (class 2604 OID 16467)
-- Dependencies: 170 169
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY direktkandidat ALTER COLUMN id SET DEFAULT nextval('"Direktkandidat_id_seq"'::regclass);


--
-- TOC entry 2350 (class 2604 OID 16468)
-- Dependencies: 172 171
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimme ALTER COLUMN id SET DEFAULT nextval('"Erststimme_id_seq"'::regclass);


--
-- TOC entry 2351 (class 2604 OID 16469)
-- Dependencies: 175 174
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY land ALTER COLUMN id SET DEFAULT nextval('"Land_id_seq"'::regclass);


--
-- TOC entry 2352 (class 2604 OID 16470)
-- Dependencies: 177 176
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY landeskandidat ALTER COLUMN id SET DEFAULT nextval('"Landeskandidat_id_seq"'::regclass);


--
-- TOC entry 2353 (class 2604 OID 16471)
-- Dependencies: 179 178
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY landesliste ALTER COLUMN id SET DEFAULT nextval('"Landesliste_id_seq"'::regclass);


--
-- TOC entry 2354 (class 2604 OID 16472)
-- Dependencies: 181 180
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY partei ALTER COLUMN id SET DEFAULT nextval('"Partei_id_seq"'::regclass);


--
-- TOC entry 2355 (class 2604 OID 16474)
-- Dependencies: 183 182
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wahlkreis ALTER COLUMN id SET DEFAULT nextval('"Wahlkreis_id_seq"'::regclass);


--
-- TOC entry 2356 (class 2604 OID 16475)
-- Dependencies: 185 184
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme ALTER COLUMN id SET DEFAULT nextval('"Zweitstimme_id_seq"'::regclass);


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 2357 (class 2604 OID 16703)
-- Dependencies: 194 193
-- Name: id; Type: DEFAULT; Schema: raw2005; Owner: -
--

ALTER TABLE ONLY wahlbewerber ALTER COLUMN id SET DEFAULT nextval('wahlbewerber_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- TOC entry 2359 (class 2606 OID 16477)
-- Dependencies: 169 169 2424
-- Name: Direktkandidat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_pkey" PRIMARY KEY (id);


--
-- TOC entry 2361 (class 2606 OID 16479)
-- Dependencies: 171 171 2424
-- Name: Erststimme_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_pkey" PRIMARY KEY (id);


--
-- TOC entry 2365 (class 2606 OID 16481)
-- Dependencies: 173 173 2424
-- Name: Jahr_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jahr
    ADD CONSTRAINT "Jahr_pkey" PRIMARY KEY (jahr);


--
-- TOC entry 2367 (class 2606 OID 16483)
-- Dependencies: 174 174 2424
-- Name: Land_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY land
    ADD CONSTRAINT "Land_pkey" PRIMARY KEY (id);


--
-- TOC entry 2369 (class 2606 OID 16485)
-- Dependencies: 176 176 2424
-- Name: Landeskandidat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY landeskandidat
    ADD CONSTRAINT "Landeskandidat_pkey" PRIMARY KEY (id);


--
-- TOC entry 2371 (class 2606 OID 16487)
-- Dependencies: 178 178 2424
-- Name: Landesliste_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_pkey" PRIMARY KEY (id);


--
-- TOC entry 2373 (class 2606 OID 16631)
-- Dependencies: 180 180 2424
-- Name: Partei_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partei
    ADD CONSTRAINT "Partei_name_key" UNIQUE (name);


--
-- TOC entry 2375 (class 2606 OID 16489)
-- Dependencies: 180 180 2424
-- Name: Partei_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partei
    ADD CONSTRAINT "Partei_pkey" PRIMARY KEY (id);


--
-- TOC entry 2377 (class 2606 OID 16493)
-- Dependencies: 182 182 2424
-- Name: Wahlkreis_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlkreis
    ADD CONSTRAINT "Wahlkreis_pkey" PRIMARY KEY (id);


--
-- TOC entry 2379 (class 2606 OID 16495)
-- Dependencies: 184 184 2424
-- Name: Zweitstimme_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_pkey" PRIMARY KEY (id);


--
-- TOC entry 2409 (class 2606 OID 41667)
-- Dependencies: 223 223 223 2424
-- Name: erststimmen_aggregation_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY erststimmen_aggregation
    ADD CONSTRAINT erststimmen_aggregation_pkey PRIMARY KEY (direktkandidat_id, wahlkreis_id);


--
-- TOC entry 2405 (class 2606 OID 25218)
-- Dependencies: 217 217 2424
-- Name: scherperfaktoren_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scherperfaktoren
    ADD CONSTRAINT scherperfaktoren_pkey PRIMARY KEY (faktor);


--
-- TOC entry 2407 (class 2606 OID 33481)
-- Dependencies: 222 222 222 2424
-- Name: zweitstimmen_aggregation_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zweitstimmen_aggregation
    ADD CONSTRAINT zweitstimmen_aggregation_pkey PRIMARY KEY (partei_id, wahlkreis_id);


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 2391 (class 2606 OID 16713)
-- Dependencies: 195 195 2424
-- Name: Wahlkreise2005_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlkreise
    ADD CONSTRAINT "Wahlkreise2005_pkey" PRIMARY KEY ("Nummer");


--
-- TOC entry 2393 (class 2606 OID 16870)
-- Dependencies: 196 196 2424
-- Name: bundeslandkuerzel_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bundeslandkuerzel
    ADD CONSTRAINT bundeslandkuerzel_pkey PRIMARY KEY (kuerzel_2);


--
-- TOC entry 2395 (class 2606 OID 16899)
-- Dependencies: 198 198 2424
-- Name: mapid_wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_wahlkreise
    ADD CONSTRAINT mapid_wahlkreise_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2389 (class 2606 OID 16708)
-- Dependencies: 193 193 2424
-- Name: wahlbewerber_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlbewerber
    ADD CONSTRAINT wahlbewerber_pkey PRIMARY KEY (id);


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 2381 (class 2606 OID 16497)
-- Dependencies: 186 186 2424
-- Name: landeslisten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY landeslisten
    ADD CONSTRAINT landeslisten_pkey PRIMARY KEY ("Listennummer");


--
-- TOC entry 2383 (class 2606 OID 16499)
-- Dependencies: 187 187 187 2424
-- Name: listenplaetze_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT listenplaetze_pkey PRIMARY KEY ("Landesliste", "Kandidat");


--
-- TOC entry 2403 (class 2606 OID 25173)
-- Dependencies: 214 214 2424
-- Name: mapid_direktkandidaten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_direktkandidaten
    ADD CONSTRAINT mapid_direktkandidaten_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2401 (class 2606 OID 25168)
-- Dependencies: 213 213 2424
-- Name: mapid_landeskandidaten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_landeskandidaten
    ADD CONSTRAINT mapid_landeskandidaten_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2399 (class 2606 OID 25163)
-- Dependencies: 212 212 2424
-- Name: mapid_landeslisten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_landeslisten
    ADD CONSTRAINT mapid_landeslisten_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2397 (class 2606 OID 25158)
-- Dependencies: 211 211 2424
-- Name: mapid_wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_wahlkreise
    ADD CONSTRAINT mapid_wahlkreise_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2385 (class 2606 OID 16501)
-- Dependencies: 188 188 2424
-- Name: wahlbewerber_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlbewerber
    ADD CONSTRAINT wahlbewerber_pkey PRIMARY KEY ("Kandidatennummer");


--
-- TOC entry 2387 (class 2606 OID 16503)
-- Dependencies: 192 192 2424
-- Name: wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlkreise
    ADD CONSTRAINT wahlkreise_pkey PRIMARY KEY ("WahlkreisNr");


SET search_path = public, pg_catalog;

--
-- TOC entry 2362 (class 1259 OID 25179)
-- Dependencies: 171 2424
-- Name: erststimme_direktkandidat_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX erststimme_direktkandidat_id_idx ON erststimme USING btree (direktkandidat_id);


--
-- TOC entry 2363 (class 1259 OID 25178)
-- Dependencies: 171 2424
-- Name: erststimme_wahlkreis_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX erststimme_wahlkreis_id_idx ON erststimme USING btree (wahlkreis_id);


--
-- TOC entry 2410 (class 2606 OID 16504)
-- Dependencies: 169 180 2374 2424
-- Name: Direktkandidat_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES partei(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2411 (class 2606 OID 16509)
-- Dependencies: 169 182 2376 2424
-- Name: Direktkandidat_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2412 (class 2606 OID 25005)
-- Dependencies: 2358 169 171 2424
-- Name: Erststimme_direktkandidat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_direktkandidat_id_fkey" FOREIGN KEY (direktkandidat_id) REFERENCES direktkandidat(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2413 (class 2606 OID 25010)
-- Dependencies: 182 2376 171 2424
-- Name: Erststimme_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2414 (class 2606 OID 16524)
-- Dependencies: 173 2364 174 2424
-- Name: Land_jahr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY land
    ADD CONSTRAINT "Land_jahr_fkey" FOREIGN KEY (jahr) REFERENCES jahr(jahr) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2415 (class 2606 OID 16529)
-- Dependencies: 176 178 2370 2424
-- Name: Landeskandidat_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landeskandidat
    ADD CONSTRAINT "Landeskandidat_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES landesliste(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2416 (class 2606 OID 16534)
-- Dependencies: 178 2366 174 2424
-- Name: Landesliste_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_land_id_fkey" FOREIGN KEY (land_id) REFERENCES land(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2417 (class 2606 OID 16539)
-- Dependencies: 180 2374 178 2424
-- Name: Landesliste_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES partei(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2418 (class 2606 OID 59083)
-- Dependencies: 182 174 2366 2424
-- Name: Wahlkreis_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY wahlkreis
    ADD CONSTRAINT "Wahlkreis_land_id_fkey" FOREIGN KEY (land_id) REFERENCES land(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2419 (class 2606 OID 25015)
-- Dependencies: 178 2370 184 2424
-- Name: Zweitstimme_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES landesliste(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2420 (class 2606 OID 25020)
-- Dependencies: 184 2376 182 2424
-- Name: Zweitstimme_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 2421 (class 2606 OID 16564)
-- Dependencies: 187 188 2384 2424
-- Name: listenplaetze_Kandidat_fkey; Type: FK CONSTRAINT; Schema: raw2009; Owner: -
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT "listenplaetze_Kandidat_fkey" FOREIGN KEY ("Kandidat") REFERENCES wahlbewerber("Kandidatennummer");


--
-- TOC entry 2422 (class 2606 OID 16569)
-- Dependencies: 186 187 2380 2424
-- Name: listenplaetze_Landesliste_fkey; Type: FK CONSTRAINT; Schema: raw2009; Owner: -
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT "listenplaetze_Landesliste_fkey" FOREIGN KEY ("Landesliste") REFERENCES landeslisten("Listennummer");


-- Completed on 2013-01-09 12:21:06 CET

--
-- PostgreSQL database dump complete
--

