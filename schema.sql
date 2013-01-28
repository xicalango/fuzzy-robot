--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.7
-- Dumped by pg_dump version 9.2.1
-- Started on 2013-01-28 13:53:00

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
-- TOC entry 279 (class 3079 OID 11645)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2520 (class 0 OID 0)
-- Dependencies: 279
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 280 (class 3079 OID 59501)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 2521 (class 0 OID 0)
-- Dependencies: 280
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = adapter, pg_catalog;

--
-- TOC entry 825 (class 1247 OID 59345)
-- Name: type_direktkandidat_gewinner; Type: TYPE; Schema: adapter; Owner: -
--

CREATE TYPE type_direktkandidat_gewinner AS (
	vorname text,
	nachname text,
	partei text
);


--
-- TOC entry 930 (class 1247 OID 59426)
-- Name: type_sitzverteilung_prozent_parteiname; Type: TYPE; Schema: adapter; Owner: -
--

CREATE TYPE type_sitzverteilung_prozent_parteiname AS (
	partei_name character varying,
	prozent numeric
);


--
-- TOC entry 822 (class 1247 OID 59423)
-- Name: type_sitzverteilung_sitze_parteiname; Type: TYPE; Schema: adapter; Owner: -
--

CREATE TYPE type_sitzverteilung_sitze_parteiname AS (
	partei_name character varying,
	stimmen bigint
);


SET search_path = public, pg_catalog;

--
-- TOC entry 957 (class 1247 OID 59250)
-- Name: gewinner_typ; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE gewinner_typ AS ENUM (
    'Direktkandidat',
    'Landeskandidat'
);


--
-- TOC entry 921 (class 1247 OID 59359)
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
-- TOC entry 671 (class 1247 OID 59533)
-- Name: type_direktkandidat_differenz; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE type_direktkandidat_differenz AS (
	vorname character varying,
	nachname character varying,
	wahlkreis character varying,
	partei_name character varying,
	differenz bigint,
	partei_id bigint
);


--
-- TOC entry 809 (class 1247 OID 59228)
-- Name: type_land_stimmen; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE type_land_stimmen AS (
	land_id integer,
	stimmen bigint
);


--
-- TOC entry 954 (class 1247 OID 59237)
-- Name: type_partei_land_stimmen; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE type_partei_land_stimmen AS (
	partei_id integer,
	land_id integer,
	sitze bigint
);


SET search_path = adapter, pg_catalog;

--
-- TOC entry 348 (class 1255 OID 59427)
-- Name: absolute_erststimmen_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION absolute_erststimmen_by_wahlkreis(integer) RETURNS SETOF type_sitzverteilung_sitze_parteiname
    LANGUAGE sql
    AS $_$
SELECT p.name, sum(ea.stimmen)::bigint from partei p, erststimmen_aggregation ea, direktkandidat dk where p.id = dk.partei_id and ea.direktkandidat_id = dk.id and ea.wahlkreis_id = $1 group by p.id, p.name;
$_$;


--
-- TOC entry 337 (class 1255 OID 59477)
-- Name: absolute_erststimmen_by_wahlkreis_q7(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION absolute_erststimmen_by_wahlkreis_q7(integer) RETURNS SETOF type_sitzverteilung_sitze_parteiname
    LANGUAGE sql
    AS $_$
SELECT p.name, sum(ea.stimmen)::bigint from partei p, erststimmen_aggregation_q7 ea, direktkandidat dk where p.id = dk.partei_id and ea.direktkandidat_id = dk.id and ea.wahlkreis_id = $1 group by p.id, p.name;
$_$;


--
-- TOC entry 350 (class 1255 OID 59428)
-- Name: absolute_zweitstimmen_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION absolute_zweitstimmen_by_wahlkreis(integer) RETURNS SETOF type_sitzverteilung_sitze_parteiname
    LANGUAGE sql
    AS $_$
SELECT p.name, sum(za.stimmen)::bigint from partei p, zweitstimmen_aggregation za 
where p.id != 1 and --exclude übrige
p.id = za.partei_id and za.wahlkreis_id = $1 group by p.id, p.name;
$_$;


--
-- TOC entry 341 (class 1255 OID 59478)
-- Name: absolute_zweitstimmen_by_wahlkreis_q7(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION absolute_zweitstimmen_by_wahlkreis_q7(integer) RETURNS SETOF type_sitzverteilung_sitze_parteiname
    LANGUAGE sql
    AS $_$
SELECT p.name, sum(za.stimmen)::bigint from partei p, zweitstimmen_aggregation_q7 za 
where p.id != 1 --exclude Übrige
and p.id = za.partei_id and za.wahlkreis_id = $1 group by p.id, p.name;
$_$;


--
-- TOC entry 351 (class 1255 OID 59429)
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
-- TOC entry 343 (class 1255 OID 59479)
-- Name: differenz_erststimmen_by_wahlkreis_q7(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION differenz_erststimmen_by_wahlkreis_q7(integer) RETURNS SETOF type_sitzverteilung_prozent_parteiname
    LANGUAGE sql
    AS $_$
with stimmen as (
	SELECT d.partei_id, sum(ea.stimmen) stimmen, sum(ea.stimmen_vorperiode) stimmen_vorperiode
	FROM erststimmen_aggregation_q7 ea, direktkandidat d
	WHERE ea.direktkandidat_id = d.id
	AND ea.wahlkreis_id = $1
	GROUP BY d.partei_id
), gesamtstimmen as (
	select sum(stimmen) sum_stimmen, sum(stimmen_vorperiode) sum_stimmen_vorperiode	
	from erststimmen_aggregation_q7 ea 
	where ea.wahlkreis_id = $1 
	and ea.direktkandidat_id is not null
)
SELECT p.name,((100*s.stimmen::numeric/gs.sum_stimmen::numeric) -  (100*s.stimmen_vorperiode::numeric/gs.sum_stimmen_vorperiode::numeric))::numeric(3,1) differenz
FROM stimmen s, gesamtstimmen gs, partei p
WHERE s.partei_id = p.id
ORDER BY s.stimmen DESC;

$_$;


--
-- TOC entry 352 (class 1255 OID 59430)
-- Name: differenz_zweitstimmen_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION differenz_zweitstimmen_by_wahlkreis(integer) RETURNS SETOF type_sitzverteilung_prozent_parteiname
    LANGUAGE sql
    AS $_$
with stimmen as (
	SELECT za.partei_id, sum(za.stimmen) stimmen, sum(za.stimmen_vorperiode) stimmen_vorperiode
	FROM zweitstimmen_aggregation za
	WHERE za.wahlkreis_id = $1
	AND za.partei_id != 1 --Übrige ausschließen, da 2009er werte nicht vorliegen
	GROUP BY za.partei_id
), gesamtstimmen as (
	select sum(stimmen) sum_stimmen, sum(stimmen_vorperiode) sum_stimmen_vorperiode	
	from zweitstimmen_aggregation za 
	where za.wahlkreis_id = $1 
	and za.partei_id is not null
	-- Übrige einschließen, da notwendig für summe der stimmen der vorperiode
)
SELECT p.name,((100*s.stimmen::numeric/gs.sum_stimmen::numeric) -  (100*s.stimmen_vorperiode::numeric/gs.sum_stimmen_vorperiode::numeric))::numeric(3,1) differenz
FROM stimmen s, gesamtstimmen gs, partei p
WHERE s.partei_id = p.id
ORDER BY s.stimmen DESC;

$_$;


--
-- TOC entry 346 (class 1255 OID 59480)
-- Name: differenz_zweitstimmen_by_wahlkreis_q7(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION differenz_zweitstimmen_by_wahlkreis_q7(integer) RETURNS SETOF type_sitzverteilung_prozent_parteiname
    LANGUAGE sql
    AS $_$
with stimmen as (
	SELECT za.partei_id, sum(za.stimmen) stimmen, sum(za.stimmen_vorperiode) stimmen_vorperiode
	FROM zweitstimmen_aggregation_q7 za
	WHERE za.wahlkreis_id = $1
	AND za.partei_id != 0
	GROUP BY za.partei_id
), gesamtstimmen as (
	select sum(stimmen) sum_stimmen, sum(stimmen_vorperiode) sum_stimmen_vorperiode	
	from zweitstimmen_aggregation_q7 za 
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
-- TOC entry 345 (class 1255 OID 59398)
-- Name: gewaehlte_direktkandidaten_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION gewaehlte_direktkandidaten_by_wahlkreis(integer) RETURNS SETOF public.direktkandidat
    LANGUAGE sql
    AS $_$
SELECT dk.* FROM direktkandidat dk, wahl_gewinner wg WHERE dk.id = wg.kandidat_id AND dk.wahlkreis_id = $1 AND wg.typ = 'Direktkandidat' AND dk.id = wg.kandidat_id;
$_$;


--
-- TOC entry 336 (class 1255 OID 59346)
-- Name: gewaehlter_direktkandidat_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION gewaehlter_direktkandidat_by_wahlkreis(integer) RETURNS SETOF type_direktkandidat_gewinner
    LANGUAGE sql
    AS $_$
SELECT dk.vorname, dk.nachname, p.name 
FROM direktkandidat dk, direktkandidat_gewinner_land_partei dg, partei p
WHERE dk.id = dg.kandidat_id 
AND dk.wahlkreis_id = $1 
AND p.id = dk.partei_id;
$_$;


--
-- TOC entry 330 (class 1255 OID 59550)
-- Name: gewaehlter_direktkandidat_by_wahlkreis_q7(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION gewaehlter_direktkandidat_by_wahlkreis_q7(integer) RETURNS SETOF type_direktkandidat_gewinner
    LANGUAGE sql
    AS $_$
SELECT dk.vorname, dk.nachname, p.name 
FROM direktkandidat dk, direktkandidat_gewinner_land_partei_q7 dg, partei p
WHERE dk.id = dg.kandidat_id 
AND dk.wahlkreis_id = $1 
AND p.id = dk.partei_id;
$_$;


--
-- TOC entry 354 (class 1255 OID 59431)
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
-- TOC entry 347 (class 1255 OID 59481)
-- Name: prozent_erststimmen_by_wahlkreis_q7(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION prozent_erststimmen_by_wahlkreis_q7(integer) RETURNS SETOF type_sitzverteilung_prozent_parteiname
    LANGUAGE sql
    AS $_$
with gesamtstimmen as (
select sum(stimmen) from erststimmen_aggregation_q7 ea where ea.wahlkreis_id = $1 and ea.direktkandidat_id is not null
)
select p.name, 100 * sum(ea.stimmen) / sum(gs.sum) as prozent from erststimmen_aggregation_q7 ea, gesamtstimmen gs, partei p, direktkandidat dk
where dk.partei_id = p.id and dk.id = ea.direktkandidat_id and ea.wahlkreis_id = $1 group by p.name;
$_$;


--
-- TOC entry 356 (class 1255 OID 59432)
-- Name: prozent_zweitstimmen_by_wahlkreis(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION prozent_zweitstimmen_by_wahlkreis(integer) RETURNS SETOF type_sitzverteilung_prozent_parteiname
    LANGUAGE sql
    AS $_$
with gesamtstimmen as (
select sum(stimmen) from zweitstimmen_aggregation a where a.wahlkreis_id = $1 and a.partei_id is not Null
)
select p.name, 100 * sum(za.stimmen) / sum(gs.sum) as prozent from zweitstimmen_aggregation za, gesamtstimmen gs, partei p
where p.id = za.partei_id and za.partei_id != 1 and za.wahlkreis_id = $1 group by p.name;
$_$;


--
-- TOC entry 349 (class 1255 OID 59482)
-- Name: prozent_zweitstimmen_by_wahlkreis_q7(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION prozent_zweitstimmen_by_wahlkreis_q7(integer) RETURNS SETOF type_sitzverteilung_prozent_parteiname
    LANGUAGE sql
    AS $_$
with gesamtstimmen as (
select sum(stimmen) from zweitstimmen_aggregation_q7 a where a.wahlkreis_id = $1 and a.partei_id is not Null
)
select p.name, 100 * sum(za.stimmen) / sum(gs.sum) as prozent from zweitstimmen_aggregation_q7 za, gesamtstimmen gs, partei p
where p.id = za.partei_id and za.partei_id != 1 and za.wahlkreis_id = $1 group by p.name;
$_$;


--
-- TOC entry 340 (class 1255 OID 59540)
-- Name: top_10(integer); Type: FUNCTION; Schema: adapter; Owner: -
--

CREATE FUNCTION top_10(integer) RETURNS SETOF public.type_direktkandidat_differenz
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
-- TOC entry 316 (class 1255 OID 59195)
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
-- TOC entry 259 (class 1259 OID 59363)
-- Name: type_sitzverteilung; Type: VIEW; Schema: alt; Owner: -
--

CREATE VIEW type_sitzverteilung AS
    SELECT NULL::integer AS partei_id, NULL::bigint AS sitze;


--
-- TOC entry 353 (class 1255 OID 59367)
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
-- TOC entry 355 (class 1255 OID 59368)
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
-- TOC entry 357 (class 1255 OID 59369)
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
-- TOC entry 334 (class 1255 OID 59522)
-- Name: check_uuid(uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION check_uuid(id uuid, year integer) RETURNS boolean
    LANGUAGE sql
    AS $_$
SELECT v FROM (
(
SELECT 1 id, true v FROM berechtigten_uuid WHERE id = $1 AND jahr = $2 AND used = false
)
UNION ALL
(
SELECT 2 id, false v
)
) a
ORDER BY id
LIMIT 1;
$_$;


--
-- TOC entry 307 (class 1255 OID 25113)
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
-- TOC entry 329 (class 1255 OID 59537)
-- Name: get_10_knappste_sieger(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_10_knappste_sieger(integer) RETURNS SETOF type_direktkandidat_differenz
    LANGUAGE sql
    AS $_$

select vorname, nachname, wahlkreis, partei_name, diff, id from(

-- Pateien, die Direktkandidatenmandat gewonnen haben
select dk.vorname, dk.nachname, wk.name as wahlkreis, p.name as partei_name, dd.diff, p.id :: bigint
from direktkandidat dk, direktkandidat_differenz_auf_zweiten dd, partei p, wahlkreis wk 
where dk.partei_id = p.id and dd.kandidat_id = dk.id 
and dk.partei_id = $1 and diff>0 and wk.id = dk.wahlkreis_id


order by diff
limit 10
) a;


$_$;


--
-- TOC entry 333 (class 1255 OID 59539)
-- Name: get_10_knappste_verlierer(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_10_knappste_verlierer(integer) RETURNS SETOF type_direktkandidat_differenz
    LANGUAGE sql
    AS $_$

select vorname, nachname, wahlkreis, partei_name, diff, id from(

-- Pateien, die Direktkandidatenmandat gewonnen haben
select dk.vorname, dk.nachname, wk.name as wahlkreis, p.name as partei_name, dd.diff, p.id :: bigint
from direktkandidat dk, direktkandidat_differenz_auf_ersten dd, partei p, wahlkreis wk 
where dk.partei_id = p.id and dd.kandidat_id = dk.id and dk.partei_id = $1 and diff<0 and dk.wahlkreis_id = wk.id


order by diff desc
limit 10
) a;


$_$;


--
-- TOC entry 294 (class 1255 OID 16388)
-- Name: get_bundesland_id_by_name(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_bundesland_id_by_name(bundesland_name character varying, jahr integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT l.id FROM public."land" l WHERE l.name = $1 AND l.jahr = $2 LIMIT 1;$_$;


--
-- TOC entry 313 (class 1255 OID 24952)
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
-- TOC entry 331 (class 1255 OID 24980)
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
-- Name: land; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE land (
    id integer NOT NULL,
    name character varying(30),
    jahr integer
);


--
-- TOC entry 305 (class 1255 OID 16717)
-- Name: get_laender_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_laender_by_jahr(integer) RETURNS SETOF land
    LANGUAGE sql
    AS $_$
SELECT * FROM "land" WHERE jahr = $1;$_$;


--
-- TOC entry 178 (class 1259 OID 16419)
-- Name: landesliste; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE landesliste (
    id integer NOT NULL,
    listenplatz integer,
    land_id integer,
    partei_id integer
);


--
-- TOC entry 359 (class 1255 OID 16668)
-- Name: get_landesliste_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_landesliste_by_jahr(integer) RETURNS SETOF landesliste
    LANGUAGE sql
    AS $_$SELECT * FROM "landesliste" WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1);$_$;


--
-- TOC entry 312 (class 1255 OID 25137)
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
-- TOC entry 297 (class 1255 OID 16389)
-- Name: get_partei_id_by_name(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_partei_id_by_name(partei_name character varying) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT p.id FROM public."partei" p WHERE p.name = $1 LIMIT 1;$_$;


--
-- TOC entry 328 (class 1255 OID 59521)
-- Name: get_unused_uuid(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_unused_uuid(year integer) RETURNS uuid
    LANGUAGE sql
    AS $_$SELECT id as "uuid" FROM berechtigten_uuid WHERE used = 'f' AND jahr = $1 ORDER BY RANDOM() LIMIT 1$_$;


--
-- TOC entry 182 (class 1259 OID 16434)
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
-- TOC entry 295 (class 1255 OID 16642)
-- Name: get_wahlkreis_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_wahlkreis_by_jahr(integer) RETURNS SETOF wahlkreis
    LANGUAGE sql
    AS $_$
SELECT * FROM "wahlkreis" WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1);$_$;


--
-- TOC entry 311 (class 1255 OID 24950)
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
-- TOC entry 338 (class 1255 OID 25000)
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
-- TOC entry 332 (class 1255 OID 42662)
-- Name: gewaehlte_direktkandidaten(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gewaehlte_direktkandidaten(integer) RETURNS SETOF direktkandidat
    LANGUAGE sql
    AS $_$
SELECT dk.* FROM direktkandidat dk, wahl_gewinner_rischtisch wg WHERE dk.id = wg.kandidat_id AND dk.wahlkreis_id = $1 AND wg.typ = 'Direktkandidat' AND dk.id = wg.kandidat_id;
$_$;


--
-- TOC entry 308 (class 1255 OID 16722)
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
-- Name: erststimmen_aggregation; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE erststimmen_aggregation (
    direktkandidat_id integer,
    wahlkreis_id integer NOT NULL,
    stimmen bigint,
    stimmen_vorperiode bigint,
    id integer NOT NULL
);


--
-- TOC entry 220 (class 1259 OID 33451)
-- Name: direktkandidat_gewinner; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidat_gewinner AS
    WITH max_stimmen_per_wahlkreis AS (SELECT ea2.wahlkreis_id, max(ea2.stimmen) AS max_stimmen FROM erststimmen_aggregation ea2 GROUP BY ea2.wahlkreis_id) SELECT ea.wahlkreis_id, ea.direktkandidat_id, (ea.stimmen)::integer AS stimmen FROM erststimmen_aggregation ea, max_stimmen_per_wahlkreis mspw WHERE ((ea.wahlkreis_id = mspw.wahlkreis_id) AND (ea.stimmen = mspw.max_stimmen));


--
-- TOC entry 176 (class 1259 OID 16414)
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
-- TOC entry 252 (class 1259 OID 59282)
-- Name: landeskandidat_ohne_direktmandat; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW landeskandidat_ohne_direktmandat AS
    SELECT l.id, l.vorname, l.nachname, l.listenrang, l.landesliste_id FROM landeskandidat l, landesliste ll WHERE ((l.landesliste_id = ll.id) AND (NOT (EXISTS (SELECT dg.wahlkreis_id, dg.direktkandidat_id, dg.stimmen, d.id, d.vorname, d.nachname, d.wahlkreis_id, d.partei_id FROM direktkandidat_gewinner dg, direktkandidat d WHERE ((((dg.direktkandidat_id = d.id) AND ((l.vorname)::text = (d.vorname)::text)) AND ((l.nachname)::text = (d.nachname)::text)) AND (ll.partei_id = d.partei_id))))));


--
-- TOC entry 344 (class 1255 OID 59299)
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
-- TOC entry 327 (class 1255 OID 59518)
-- Name: regenerate_uuids(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION regenerate_uuids(jahr integer) RETURNS void
    LANGUAGE sql
    AS $_$

	DELETE FROM berechtigten_uuid WHERE jahr = $1;

	WITH berechtigten_count AS
	(
		SELECT sum(wahlberechtigte) c FROM get_wahlkreis_by_jahr($1)
	)
	INSERT INTO berechtigten_uuid (id, jahr) SELECT uuid_generate_v4(), $1 FROM generate_series(1, (SELECT c from berechtigten_count)); 
	
$_$;


--
-- TOC entry 306 (class 1255 OID 16583)
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
-- TOC entry 310 (class 1255 OID 25198)
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
-- TOC entry 314 (class 1255 OID 41812)
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
-- TOC entry 342 (class 1255 OID 59239)
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
-- TOC entry 339 (class 1255 OID 59238)
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
-- TOC entry 335 (class 1255 OID 59234)
-- Name: stimmen_land_eine_partei(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION stimmen_land_eine_partei(partei_id integer) RETURNS SETOF type_land_stimmen
    LANGUAGE sql ROWS 500
    AS $_$
SELECT land_id, stimmen FROM partei_land_stimmen_einzug WHERE partei_id = $1;
$_$;


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 293 (class 1255 OID 16716)
-- Name: import_bundeslaender(); Type: FUNCTION; Schema: raw2005; Owner: -
--

CREATE FUNCTION import_bundeslaender() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO "Land" ("name", "jahr") SELECT DISTINCT "Land", 2005 FROM raw2005.wahlkreise;
$$;


--
-- TOC entry 292 (class 1255 OID 16719)
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
-- TOC entry 300 (class 1255 OID 16865)
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
-- TOC entry 309 (class 1255 OID 16900)
-- Name: map_wahlkreis(integer); Type: FUNCTION; Schema: raw2005; Owner: -
--

CREATE FUNCTION map_wahlkreis(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2005.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;$_$;


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 301 (class 1255 OID 16720)
-- Name: import_bundeslaender(); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION import_bundeslaender() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO "land" ("name", "jahr") SELECT DISTINCT "Bundesland", 2009 FROM raw2009.landeslisten;
$$;


--
-- TOC entry 302 (class 1255 OID 16391)
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
-- TOC entry 358 (class 1255 OID 16392)
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
-- TOC entry 299 (class 1255 OID 16635)
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
-- TOC entry 296 (class 1255 OID 16394)
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
-- TOC entry 317 (class 1255 OID 59089)
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
-- TOC entry 303 (class 1255 OID 16589)
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
-- TOC entry 361 (class 1255 OID 16662)
-- Name: map_direktkandidat(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_direktkandidat(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_direktkandidaten WHERE id_old = $1 LIMIT 1;$_$;


--
-- TOC entry 360 (class 1255 OID 16689)
-- Name: map_landeskandidat(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_landeskandidat(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_landeskandidaten WHERE id_old = $1 LIMIT 1;$_$;


--
-- TOC entry 304 (class 1255 OID 16645)
-- Name: map_landesliste(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_landesliste(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_landeslisten WHERE id_old = $1 LIMIT 1;$_$;


--
-- TOC entry 298 (class 1255 OID 16646)
-- Name: map_wahlkreis(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_wahlkreis(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;$_$;


SET search_path = public, pg_catalog;

--
-- TOC entry 222 (class 1259 OID 33477)
-- Name: zweitstimmen_aggregation; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zweitstimmen_aggregation (
    partei_id integer,
    wahlkreis_id integer NOT NULL,
    stimmen bigint,
    stimmen_vorperiode bigint,
    id integer NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 33459)
-- Name: zweitstimmen_prozent; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW zweitstimmen_prozent AS
    WITH zweitstimmen_pro_partei AS (SELECT zweitstimmen_aggregation.partei_id, sum(zweitstimmen_aggregation.stimmen) AS stimmen FROM zweitstimmen_aggregation zweitstimmen_aggregation GROUP BY zweitstimmen_aggregation.partei_id), zweitstimmen_gesamt AS (SELECT sum(zweitstimmen_aggregation.stimmen) AS gesamtstimmen FROM zweitstimmen_aggregation zweitstimmen_aggregation WHERE (zweitstimmen_aggregation.partei_id IS NOT NULL)) SELECT zspp.partei_id, (((100)::numeric * zspp.stimmen) / ges.gesamtstimmen) AS prozent FROM zweitstimmen_pro_partei zspp, zweitstimmen_gesamt ges ORDER BY (((100)::numeric * zspp.stimmen) / ges.gesamtstimmen) DESC;


--
-- TOC entry 239 (class 1259 OID 41752)
-- Name: ergebnisse_zweitstimme_diagramm; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW ergebnisse_zweitstimme_diagramm AS
    (SELECT zweitstimmen_prozent.partei_id, (zweitstimmen_prozent.prozent)::numeric(3,1) AS prozent FROM zweitstimmen_prozent WHERE (zweitstimmen_prozent.partei_id IS NOT NULL) LIMIT 6) UNION ALL (WITH rest AS (SELECT zweitstimmen_prozent.prozent FROM zweitstimmen_prozent WHERE (zweitstimmen_prozent.partei_id IS NOT NULL) OFFSET 6) SELECT NULL::integer AS partei_id, (sum(rest.prozent))::numeric(3,1) AS prozent FROM rest);


--
-- TOC entry 180 (class 1259 OID 16424)
-- Name: partei; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE partei (
    name character varying(150),
    id integer NOT NULL
);


SET search_path = adapter, pg_catalog;

--
-- TOC entry 264 (class 1259 OID 59417)
-- Name: ergebnisse_zweitstimme_diagramm_name; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW ergebnisse_zweitstimme_diagramm_name AS
    SELECT p.name, zsd.prozent FROM public.ergebnisse_zweitstimme_diagramm zsd, public.partei p WHERE (p.id = zsd.partei_id) UNION ALL SELECT 'Andere'::character varying AS name, ergebnisse_zweitstimme_diagramm.prozent FROM public.ergebnisse_zweitstimme_diagramm WHERE (ergebnisse_zweitstimme_diagramm.partei_id IS NULL);


SET search_path = public, pg_catalog;

--
-- TOC entry 249 (class 1259 OID 59240)
-- Name: direktkandidat_gewinner_land_partei; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidat_gewinner_land_partei AS
    SELECT dg.direktkandidat_id AS kandidat_id, l.id AS land_id, p.id AS partei_id FROM direktkandidat_gewinner dg, direktkandidat d, land l, partei p, wahlkreis wk WHERE ((((dg.direktkandidat_id = d.id) AND (d.partei_id = p.id)) AND (dg.wahlkreis_id = wk.id)) AND (wk.land_id = l.id));


--
-- TOC entry 250 (class 1259 OID 59244)
-- Name: wahl_gewinner_aux; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW wahl_gewinner_aux AS
    WITH direktkandidaten_anzahl AS (SELECT direktkandidat_gewinner_land_partei.land_id, direktkandidat_gewinner_land_partei.partei_id, count(*) AS direkt_sitze FROM direktkandidat_gewinner_land_partei GROUP BY direktkandidat_gewinner_land_partei.land_id, direktkandidat_gewinner_land_partei.partei_id), aux AS (SELECT spb.partei_id, spb.land_id, COALESCE(w.direkt_sitze, (0)::bigint) AS direkt_sitze, spb.sitze AS zweit_sitze FROM (sitze_alle_parteien_bundesland() spb(partei_id, land_id, sitze) LEFT JOIN direktkandidaten_anzahl w ON (((spb.land_id = w.land_id) AND (spb.partei_id = w.partei_id))))) SELECT aux.partei_id, aux.land_id, aux.direkt_sitze, aux.zweit_sitze, (aux.direkt_sitze - aux.zweit_sitze) AS diff FROM aux;


--
-- TOC entry 2522 (class 0 OID 0)
-- Dependencies: 250
-- Name: VIEW wahl_gewinner_aux; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW wahl_gewinner_aux IS 'Stellt pro Partei und Land die Anzahl der gewonnenen Direktmandate, sowie die Anzahl der Sitze laut Zweitstimme dar.
Außerdem wird die Differenz dieser Werte angegeben. Darauß lässt sich die Anzahl der Überhangmandate (Wert positiv), oder die Anzahl der Kandidaten, die von der Landesliste nachrutschen müssen (Wert negativ) bestimmen.';


--
-- TOC entry 251 (class 1259 OID 59255)
-- Name: wahl_gewinner; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW wahl_gewinner AS
    SELECT direktkandidat_gewinner_land_partei.kandidat_id, 'Direktkandidat'::gewinner_typ AS typ, direktkandidat_gewinner_land_partei.land_id, direktkandidat_gewinner_land_partei.partei_id FROM direktkandidat_gewinner_land_partei UNION ALL SELECT k.id AS kandidat_id, 'Landeskandidat'::gewinner_typ AS typ, l.land_id, l.partei_id FROM landeskandidat_ohne_direktmandat_bereinigt() k(id, vorname, nachname, listenrang, landesliste_id), landesliste l, wahl_gewinner_aux wga WHERE (((((k.landesliste_id = l.id) AND (l.land_id = wga.land_id)) AND (l.partei_id = wga.partei_id)) AND (wga.diff < 0)) AND (k.listenrang <= abs(wga.diff)));


--
-- TOC entry 2523 (class 0 OID 0)
-- Dependencies: 251
-- Name: VIEW wahl_gewinner; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW wahl_gewinner IS 'Listet die Gewinner der Wahl auf (mit Land und Partei). Dabei wird bei jedem Kandidaten dazugeschrieben ob es sich um einen Direktmandat oder ein Listenmandat handelt.';


SET search_path = adapter, pg_catalog;

--
-- TOC entry 260 (class 1259 OID 59399)
-- Name: mitglieder_bundestag; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW mitglieder_bundestag AS
    SELECT dk.vorname, dk.nachname, p.name AS partei_name FROM public.wahl_gewinner g, public.direktkandidat dk, public.partei p WHERE (((dk.id = g.kandidat_id) AND (g.typ = 'Direktkandidat'::public.gewinner_typ)) AND (dk.partei_id = p.id)) UNION ALL SELECT lk.vorname, lk.nachname, p.name AS partei_name FROM public.wahl_gewinner g, public.landeskandidat lk, public.landesliste ll, public.partei p WHERE ((((lk.id = g.kandidat_id) AND (g.typ = 'Landeskandidat'::public.gewinner_typ)) AND (lk.landesliste_id = ll.id)) AND (ll.partei_id = p.id)) ORDER BY 2;


--
-- TOC entry 261 (class 1259 OID 59404)
-- Name: sitzverteilung_pro_partei_name; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW sitzverteilung_pro_partei_name AS
    SELECT p.name AS partei_name, count(*) AS sitze FROM public.wahl_gewinner wg, public.partei p WHERE (p.id = wg.partei_id) GROUP BY wg.partei_id, p.name;


--
-- TOC entry 272 (class 1259 OID 59527)
-- Name: ueberhangmandate; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW ueberhangmandate AS
    SELECT p.name AS partei_name, l.name AS land_name, wa.diff AS anzahl FROM public.wahl_gewinner_aux wa, public.partei p, public.land l WHERE (((wa.diff > 0) AND (wa.partei_id = p.id)) AND (wa.land_id = l.id));


--
-- TOC entry 256 (class 1259 OID 59338)
-- Name: wahlbeteiligung; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW wahlbeteiligung AS
    WITH abgegebene_stimmen AS (SELECT erststimmen_aggregation.wahlkreis_id, sum(erststimmen_aggregation.stimmen) AS stimmen FROM public.erststimmen_aggregation GROUP BY erststimmen_aggregation.wahlkreis_id) SELECT wk.id AS wahlkreis_id, wk.name, wk.wahlberechtigte, abs.stimmen, (((abs.stimmen * (100)::numeric) / (wk.wahlberechtigte)::numeric))::numeric(4,2) AS beteiligung FROM public.wahlkreis wk, abgegebene_stimmen abs WHERE (abs.wahlkreis_id = wk.id);


SET search_path = public, pg_catalog;

--
-- TOC entry 171 (class 1259 OID 16401)
-- Name: erststimme; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE erststimme (
    id integer NOT NULL,
    wahlkreis_id integer,
    direktkandidat_id integer
);


--
-- TOC entry 172 (class 1259 OID 16404)
-- Name: Erststimme_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Erststimme_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2524 (class 0 OID 0)
-- Dependencies: 172
-- Name: Erststimme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Erststimme_id_seq" OWNED BY erststimme.id;


--
-- TOC entry 242 (class 1259 OID 59077)
-- Name: erststimme_q7; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE erststimme_q7 (
    id integer DEFAULT nextval('"Erststimme_id_seq"'::regclass) NOT NULL,
    wahlkreis_id integer,
    direktkandidat_id integer
);


--
-- TOC entry 269 (class 1259 OID 59469)
-- Name: erststimmen_aggregation_q7; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW erststimmen_aggregation_q7 AS
    WITH agg_erststimme_q7 AS (SELECT eq7.direktkandidat_id, eq7.wahlkreis_id, count(*) AS stimmen FROM erststimme_q7 eq7 GROUP BY eq7.direktkandidat_id, eq7.wahlkreis_id) SELECT aeq7.direktkandidat_id, aeq7.wahlkreis_id, aeq7.stimmen, ea.stimmen_vorperiode FROM agg_erststimme_q7 aeq7, erststimmen_aggregation ea WHERE (((ea.wahlkreis_id = aeq7.wahlkreis_id) AND ((ea.direktkandidat_id IS NULL) AND (aeq7.direktkandidat_id IS NULL))) OR (ea.direktkandidat_id = aeq7.direktkandidat_id));


SET search_path = adapter, pg_catalog;

--
-- TOC entry 276 (class 1259 OID 59551)
-- Name: wahlbeteiligung_q7; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW wahlbeteiligung_q7 AS
    WITH abgegebene_stimmen AS (SELECT ea.wahlkreis_id, sum(ea.stimmen) AS stimmen FROM public.erststimmen_aggregation_q7 ea GROUP BY ea.wahlkreis_id) SELECT wk.id AS wahlkreis_id, wk.name, wk.wahlberechtigte, abs.stimmen, (((abs.stimmen * (100)::numeric) / (wk.wahlberechtigte)::numeric))::numeric(4,2) AS beteiligung FROM public.wahlkreis wk, abgegebene_stimmen abs WHERE (abs.wahlkreis_id = wk.id);


--
-- TOC entry 262 (class 1259 OID 59409)
-- Name: wahlkreissieger_partei_erststimme; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW wahlkreissieger_partei_erststimme AS
    SELECT wk.name AS wahlkreis, p.name AS partei_name, dk.vorname, dk.nachname FROM public.wahlkreis wk, public.partei p, public.direktkandidat dk, public.wahl_gewinner wg WHERE (((((wg.typ)::text = 'Direktkandidat'::text) AND (wg.kandidat_id = dk.id)) AND (p.id = wg.partei_id)) AND (dk.wahlkreis_id = wk.id));


--
-- TOC entry 263 (class 1259 OID 59413)
-- Name: wahlkreissieger_partei_zweitstimme; Type: VIEW; Schema: adapter; Owner: -
--

CREATE VIEW wahlkreissieger_partei_zweitstimme AS
    SELECT wk.name AS wahlkreis, p.name AS partei_name FROM public.zweitstimmen_aggregation za1, public.zweitstimmen_aggregation za2, public.partei p, public.wahlkreis wk WHERE (((za1.wahlkreis_id = za2.wahlkreis_id) AND (za1.partei_id = p.id)) AND (za1.wahlkreis_id = wk.id)) GROUP BY za1.wahlkreis_id, p.name, za1.stimmen, wk.name HAVING (za1.stimmen = max(za2.stimmen));


SET search_path = alt, pg_catalog;

--
-- TOC entry 240 (class 1259 OID 41770)
-- Name: prozent_partei_zweitstimmen; Type: VIEW; Schema: alt; Owner: -
--

CREATE VIEW prozent_partei_zweitstimmen AS
    WITH stimmen_pro_partei AS (SELECT zweitstimmen_aggregation.partei_id, sum(zweitstimmen_aggregation.stimmen) AS stimmen FROM public.zweitstimmen_aggregation GROUP BY zweitstimmen_aggregation.partei_id), gesamtstimmen AS (SELECT sum(zweitstimmen_aggregation.stimmen) AS stimmen FROM public.zweitstimmen_aggregation) SELECT sp.partei_id, (sp.stimmen / gs.stimmen) AS prozent FROM stimmen_pro_partei sp, gesamtstimmen gs;


SET search_path = public, pg_catalog;

--
-- TOC entry 170 (class 1259 OID 16399)
-- Name: Direktkandidat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Direktkandidat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2525 (class 0 OID 0)
-- Dependencies: 170
-- Name: Direktkandidat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Direktkandidat_id_seq" OWNED BY direktkandidat.id;


--
-- TOC entry 175 (class 1259 OID 16412)
-- Name: Land_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Land_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2526 (class 0 OID 0)
-- Dependencies: 175
-- Name: Land_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Land_id_seq" OWNED BY land.id;


--
-- TOC entry 177 (class 1259 OID 16417)
-- Name: Landeskandidat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Landeskandidat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2527 (class 0 OID 0)
-- Dependencies: 177
-- Name: Landeskandidat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Landeskandidat_id_seq" OWNED BY landeskandidat.id;


--
-- TOC entry 179 (class 1259 OID 16422)
-- Name: Landesliste_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Landesliste_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2528 (class 0 OID 0)
-- Dependencies: 179
-- Name: Landesliste_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Landesliste_id_seq" OWNED BY landesliste.id;


--
-- TOC entry 181 (class 1259 OID 16427)
-- Name: Partei_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Partei_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2529 (class 0 OID 0)
-- Dependencies: 181
-- Name: Partei_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Partei_id_seq" OWNED BY partei.id;


--
-- TOC entry 183 (class 1259 OID 16437)
-- Name: Wahlkreis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Wahlkreis_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2530 (class 0 OID 0)
-- Dependencies: 183
-- Name: Wahlkreis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Wahlkreis_id_seq" OWNED BY wahlkreis.id;


--
-- TOC entry 184 (class 1259 OID 16439)
-- Name: zweitstimme; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zweitstimme (
    id integer NOT NULL,
    wahlkreis_id integer,
    landesliste_id integer
);


--
-- TOC entry 185 (class 1259 OID 16442)
-- Name: Zweitstimme_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Zweitstimme_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2531 (class 0 OID 0)
-- Dependencies: 185
-- Name: Zweitstimme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Zweitstimme_id_seq" OWNED BY zweitstimme.id;


--
-- TOC entry 253 (class 1259 OID 59293)
-- Name: anzahl_direktmandat_auch_landeskandidat; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW anzahl_direktmandat_auch_landeskandidat AS
    SELECT d.partei_id, w.land_id, count(*) AS count FROM direktkandidat_gewinner dg, direktkandidat d, wahlkreis w WHERE (((dg.direktkandidat_id = d.id) AND (d.wahlkreis_id = w.id)) AND (EXISTS (SELECT l.id, l.vorname, l.nachname, l.listenrang, l.landesliste_id, ll.id, ll.listenplatz, ll.land_id, ll.partei_id FROM landeskandidat l, landesliste ll WHERE ((((l.landesliste_id = ll.id) AND ((l.vorname)::text = (d.vorname)::text)) AND ((l.nachname)::text = (d.nachname)::text)) AND (ll.partei_id = d.partei_id))))) GROUP BY d.partei_id, w.land_id;


--
-- TOC entry 271 (class 1259 OID 59512)
-- Name: berechtigten_uuid; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE berechtigten_uuid (
    id uuid NOT NULL,
    used boolean DEFAULT false,
    jahr integer
);


--
-- TOC entry 244 (class 1259 OID 59094)
-- Name: direktkandidat_differenz_auf_ersten; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidat_differenz_auf_ersten AS
    SELECT p.id AS partei_id, dk.id AS kandidat_id, (ea1.stimmen - (SELECT ea.stimmen FROM erststimmen_aggregation ea, partei p, direktkandidat dk1 WHERE ((((dk1.wahlkreis_id = ea.wahlkreis_id) AND (dk1.partei_id = p.id)) AND (dk1.id = ea.direktkandidat_id)) AND (ea.wahlkreis_id = dk.wahlkreis_id)) ORDER BY ea.stimmen DESC LIMIT 1)) AS diff FROM partei p, direktkandidat dk, erststimmen_aggregation ea1 WHERE ((p.id = dk.partei_id) AND (dk.id = ea1.direktkandidat_id));


--
-- TOC entry 245 (class 1259 OID 59106)
-- Name: direktkandidat_differenz_auf_zweiten; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidat_differenz_auf_zweiten AS
    SELECT p.id AS partei_id, dk.id AS kandidat_id, (ea1.stimmen - (SELECT ea.stimmen FROM erststimmen_aggregation ea, partei p, direktkandidat dk1 WHERE (((dk1.partei_id = p.id) AND (dk1.id = ea.direktkandidat_id)) AND (ea.wahlkreis_id = dk.wahlkreis_id)) ORDER BY ea.stimmen DESC OFFSET 1 LIMIT 1)) AS diff FROM partei p, direktkandidat dk, erststimmen_aggregation ea1 WHERE ((p.id = dk.partei_id) AND (dk.id = ea1.direktkandidat_id));


--
-- TOC entry 274 (class 1259 OID 59541)
-- Name: direktkandidat_gewinner_q7; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidat_gewinner_q7 AS
    WITH max_stimmen_per_wahlkreis AS (SELECT ea2.wahlkreis_id, max(ea2.stimmen) AS max_stimmen FROM erststimmen_aggregation_q7 ea2 GROUP BY ea2.wahlkreis_id) SELECT ea.wahlkreis_id, ea.direktkandidat_id, (ea.stimmen)::integer AS stimmen FROM erststimmen_aggregation_q7 ea, max_stimmen_per_wahlkreis mspw WHERE ((ea.wahlkreis_id = mspw.wahlkreis_id) AND (ea.stimmen = mspw.max_stimmen));


--
-- TOC entry 275 (class 1259 OID 59545)
-- Name: direktkandidat_gewinner_land_partei_q7; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidat_gewinner_land_partei_q7 AS
    SELECT dg.direktkandidat_id AS kandidat_id, l.id AS land_id, p.id AS partei_id FROM direktkandidat_gewinner_q7 dg, direktkandidat d, land l, partei p, wahlkreis wk WHERE ((((dg.direktkandidat_id = d.id) AND (d.partei_id = p.id)) AND (dg.wahlkreis_id = wk.id)) AND (wk.land_id = l.id));


--
-- TOC entry 236 (class 1259 OID 41732)
-- Name: direktkandidaten_pro_partei; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidaten_pro_partei AS
    SELECT d.partei_id, count(*) AS anzahl_direktkandidaten FROM direktkandidat_gewinner dg, direktkandidat d WHERE (dg.direktkandidat_id = d.id) GROUP BY d.partei_id;


SET search_path = stimmen2009, pg_catalog;

--
-- TOC entry 201 (class 1259 OID 24943)
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
-- Name: direktkandidat_stimmen; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW direktkandidat_stimmen AS
    SELECT public.get_direktkandidat_id_by_wahlkreis_partei_jahr("ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Partei", 2009) AS kandidat_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen, public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text IN (SELECT partei.name FROM public.partei)) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 204 (class 1259 OID 25001)
-- Name: erststimme_ungueltige; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW erststimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 215 (class 1259 OID 25180)
-- Name: erststimme_insges; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW erststimme_insges AS
    SELECT direktkandidat_stimmen.kandidat_id, direktkandidat_stimmen.stimmen, direktkandidat_stimmen.wahlkreis_id FROM direktkandidat_stimmen UNION ALL SELECT NULL::integer AS kandidat_id, erststimme_ungueltige.stimmen, erststimme_ungueltige.wahlkreis_id FROM erststimme_ungueltige;


SET search_path = public, pg_catalog;

--
-- TOC entry 219 (class 1259 OID 33447)
-- Name: erststimmen_aggregation_ausKerg; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW "erststimmen_aggregation_ausKerg" AS
    SELECT erststimme_insges.kandidat_id AS direktkandidat_id, erststimme_insges.stimmen, erststimme_insges.wahlkreis_id FROM stimmen2009.erststimme_insges;


--
-- TOC entry 277 (class 1259 OID 59586)
-- Name: erststimmen_aggregation_full; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW erststimmen_aggregation_full AS
    WITH agg_erststimme AS (SELECT e.direktkandidat_id, e.wahlkreis_id, count(*) AS stimmen FROM erststimme e GROUP BY e.direktkandidat_id, e.wahlkreis_id) SELECT ae.direktkandidat_id, ae.wahlkreis_id, ae.stimmen FROM agg_erststimme ae;


--
-- TOC entry 267 (class 1259 OID 59445)
-- Name: erststimmen_aggregation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE erststimmen_aggregation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2532 (class 0 OID 0)
-- Dependencies: 267
-- Name: erststimmen_aggregation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE erststimmen_aggregation_id_seq OWNED BY erststimmen_aggregation.id;


--
-- TOC entry 254 (class 1259 OID 59301)
-- Name: hat_direktmandat; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW hat_direktmandat AS
    SELECT DISTINCT p.id FROM partei p, wahl_gewinner wg WHERE ((p.id = wg.partei_id) AND (wg.typ = 'Direktkandidat'::gewinner_typ));


--
-- TOC entry 173 (class 1259 OID 16406)
-- Name: jahr; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jahr (
    jahr integer NOT NULL
);


--
-- TOC entry 237 (class 1259 OID 41736)
-- Name: parteien_einzug; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW parteien_einzug AS
    SELECT zweitstimmen_prozent.partei_id FROM zweitstimmen_prozent WHERE (zweitstimmen_prozent.prozent > (5)::numeric) UNION SELECT direktkandidaten_pro_partei.partei_id FROM direktkandidaten_pro_partei WHERE (direktkandidaten_pro_partei.anzahl_direktkandidaten > 2);


--
-- TOC entry 247 (class 1259 OID 59230)
-- Name: partei_land_stimmen_einzug; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW partei_land_stimmen_einzug AS
    SELECT za.partei_id, w.land_id, (sum(za.stimmen))::bigint AS stimmen FROM zweitstimmen_aggregation za, wahlkreis w WHERE ((za.wahlkreis_id = w.id) AND (za.partei_id IN (SELECT parteien_einzug.partei_id FROM parteien_einzug))) GROUP BY za.partei_id, w.land_id;


--
-- TOC entry 241 (class 1259 OID 41778)
-- Name: partei_stimmen_pro_land; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW partei_stimmen_pro_land AS
    SELECT za.partei_id, w.land_id, sum(za.stimmen) AS stimmen FROM zweitstimmen_aggregation za, wahlkreis w WHERE (za.wahlkreis_id = w.id) GROUP BY za.partei_id, w.land_id;


--
-- TOC entry 217 (class 1259 OID 25211)
-- Name: scherperfaktoren; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scherperfaktoren (
    faktor numeric NOT NULL
);


--
-- TOC entry 224 (class 1259 OID 41672)
-- Name: scherper_auswertung_bund; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW scherper_auswertung_bund AS
    WITH stimmen_partei AS (SELECT pe.partei_id, sum(za.stimmen) AS stimmen FROM zweitstimmen_aggregation za, parteien_einzug pe WHERE (za.partei_id = pe.partei_id) GROUP BY pe.partei_id) SELECT sp.partei_id, (sp.stimmen / f.faktor) AS gewicht FROM stimmen_partei sp, scherperfaktoren f ORDER BY (sp.stimmen / f.faktor) DESC;


--
-- TOC entry 238 (class 1259 OID 41744)
-- Name: sitzverteilung_ohne_ueberhangmandate; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW sitzverteilung_ohne_ueberhangmandate AS
    WITH leute AS (SELECT scherper_auswertung_bund.partei_id, scherper_auswertung_bund.gewicht FROM scherper_auswertung_bund LIMIT 598) SELECT leute.partei_id, count(leute.partei_id) AS sitze FROM leute GROUP BY leute.partei_id;


--
-- TOC entry 255 (class 1259 OID 59318)
-- Name: wahlbeteiligung; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW wahlbeteiligung AS
    WITH abgegebene_stimmen AS (SELECT e.wahlkreis_id, sum(e.stimmen) AS stimmen FROM erststimmen_aggregation e GROUP BY e.wahlkreis_id) SELECT w.id AS wahlkreis_id, (((100)::numeric * a.stimmen) / (w.wahlberechtigte)::numeric) AS beteiligung FROM wahlkreis w, abgegebene_stimmen a WHERE (w.id = a.wahlkreis_id);


--
-- TOC entry 243 (class 1259 OID 59080)
-- Name: zweitstimme_q7; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zweitstimme_q7 (
    id integer DEFAULT nextval('"Zweitstimme_id_seq"'::regclass) NOT NULL,
    wahlkreis_id integer,
    landesliste_id integer
);


SET search_path = stimmen2009, pg_catalog;

--
-- TOC entry 203 (class 1259 OID 24989)
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
-- Name: landesliste_stimmen; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW landesliste_stimmen AS
    SELECT public.get_landesliste_id_by_wahlkreis_partei_jahr(ee."Gebiet", ee."Partei", 2009) AS landesliste_id, ee."Stimmen" AS stimmen, public.get_wahlkreis_id_by_jahr_and_name(2009, ee."Gebiet") AS wahlkreis_id FROM "ZweitstimmenEndgueltig" ee WHERE (((((ee."Partei")::text IN (SELECT partei.name FROM public.partei)) AND (ee."GehoertZu" IS NOT NULL)) AND ((ee."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND (ee."Stimmen" IS NOT NULL));


--
-- TOC entry 207 (class 1259 OID 25138)
-- Name: zweitstimme_ungueltige; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW zweitstimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ZweitstimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ZweitstimmenEndgueltig"."Stimmen" AS stimmen FROM "ZweitstimmenEndgueltig" WHERE ((((("ZweitstimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ZweitstimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ZweitstimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ZweitstimmenEndgueltig"."Stimmen" IS NOT NULL));


SET search_path = public, pg_catalog;

--
-- TOC entry 218 (class 1259 OID 33439)
-- Name: zweitstimmen_aggregation_ausKerg; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW "zweitstimmen_aggregation_ausKerg" AS
    SELECT ll.partei_id, s.wahlkreis_id, s.stimmen FROM stimmen2009.landesliste_stimmen s, landesliste ll WHERE (s.landesliste_id = ll.id) UNION ALL SELECT NULL::integer AS partei_id, s.wahlkreis_id, s.stimmen FROM stimmen2009.zweitstimme_ungueltige s;


--
-- TOC entry 278 (class 1259 OID 59590)
-- Name: zweitstimmen_aggregation_full; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW zweitstimmen_aggregation_full AS
    WITH aggregierte_zweitstimmen AS (SELECT ll.partei_id, z.wahlkreis_id, count(*) AS stimmen FROM zweitstimme z, landesliste ll WHERE (z.landesliste_id = ll.id) GROUP BY ll.partei_id, z.wahlkreis_id) SELECT az.partei_id, az.wahlkreis_id, az.stimmen FROM aggregierte_zweitstimmen az UNION ALL SELECT NULL::integer AS partei_id, zweitstimme.wahlkreis_id, count(*) AS stimmen FROM zweitstimme WHERE (zweitstimme.landesliste_id IS NULL) GROUP BY zweitstimme.wahlkreis_id;


--
-- TOC entry 268 (class 1259 OID 59455)
-- Name: zweitstimmen_aggregation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE zweitstimmen_aggregation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2533 (class 0 OID 0)
-- Dependencies: 268
-- Name: zweitstimmen_aggregation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE zweitstimmen_aggregation_id_seq OWNED BY zweitstimmen_aggregation.id;


--
-- TOC entry 270 (class 1259 OID 59473)
-- Name: zweitstimmen_aggregation_q7; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW zweitstimmen_aggregation_q7 AS
    WITH aggregierte_zweitstimmen_q7 AS (SELECT ll.partei_id, z.wahlkreis_id, count(*) AS stimmen FROM zweitstimme_q7 z, landesliste ll WHERE (z.landesliste_id = ll.id) GROUP BY ll.partei_id, z.wahlkreis_id) (SELECT azq7.partei_id, azq7.wahlkreis_id, azq7.stimmen, za.stimmen_vorperiode FROM aggregierte_zweitstimmen_q7 azq7, zweitstimmen_aggregation za WHERE ((za.partei_id = azq7.partei_id) AND (za.wahlkreis_id = azq7.wahlkreis_id)) UNION ALL SELECT za.partei_id, za.wahlkreis_id, za.stimmen, za.stimmen_vorperiode FROM zweitstimmen_aggregation za, (SELECT DISTINCT aggregierte_zweitstimmen_q7.wahlkreis_id FROM aggregierte_zweitstimmen_q7) wks WHERE ((za.partei_id = 1) AND (wks.wahlkreis_id = za.wahlkreis_id))) UNION ALL SELECT NULL::integer AS partei_id, zweitstimme_q7.wahlkreis_id, count(*) AS stimmen, (0)::bigint AS stimmen_vorperiode FROM zweitstimme_q7 WHERE (zweitstimme_q7.landesliste_id IS NULL) GROUP BY zweitstimme_q7.wahlkreis_id;


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 196 (class 1259 OID 16866)
-- Name: bundeslandkuerzel; Type: TABLE; Schema: raw2005; Owner: -; Tablespace: 
--

CREATE TABLE bundeslandkuerzel (
    name character varying(100),
    kuerzel_5 character varying(5),
    kuerzel_2 character varying(2) NOT NULL
);


--
-- TOC entry 198 (class 1259 OID 16895)
-- Name: mapid_wahlkreise; Type: TABLE; Schema: raw2005; Owner: -; Tablespace: 
--

CREATE TABLE mapid_wahlkreise (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 193 (class 1259 OID 16697)
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
-- Name: wahlbewerber_mit_land; Type: VIEW; Schema: raw2005; Owner: -
--

CREATE VIEW wahlbewerber_mit_land AS
    SELECT wb."Vorname", wb."Name", wb."Partei", wb."Wahlkreis", wb."Land", wb."Platz", wb.id, kz.name AS land_name FROM wahlbewerber wb, bundeslandkuerzel kz WHERE ((wb."Land")::text = (kz.kuerzel_2)::text);


--
-- TOC entry 199 (class 1259 OID 24910)
-- Name: wahlbewerber_direktkandidat; Type: VIEW; Schema: raw2005; Owner: -
--

CREATE VIEW wahlbewerber_direktkandidat AS
    SELECT w.id, w."Vorname", w."Name", w."Wahlkreis", public.get_partei_id_by_name(w."Partei") AS partei_id FROM wahlbewerber_mit_land w WHERE (w."Wahlkreis" IS NOT NULL);


--
-- TOC entry 194 (class 1259 OID 16701)
-- Name: wahlbewerber_id_seq; Type: SEQUENCE; Schema: raw2005; Owner: -
--

CREATE SEQUENCE wahlbewerber_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2534 (class 0 OID 0)
-- Dependencies: 194
-- Name: wahlbewerber_id_seq; Type: SEQUENCE OWNED BY; Schema: raw2005; Owner: -
--

ALTER SEQUENCE wahlbewerber_id_seq OWNED BY wahlbewerber.id;


--
-- TOC entry 200 (class 1259 OID 24914)
-- Name: wahlbewerber_landesliste; Type: VIEW; Schema: raw2005; Owner: -
--

CREATE VIEW wahlbewerber_landesliste AS
    SELECT w.id, w."Vorname", w."Name", w."Wahlkreis", public.get_partei_id_by_name(w."Partei") AS partei_id FROM wahlbewerber_mit_land w WHERE (w."Wahlkreis" IS NULL);


--
-- TOC entry 195 (class 1259 OID 16709)
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
-- Name: landeslisten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE landeslisten (
    "Listennummer" integer NOT NULL,
    "Bundesland" character varying(100),
    "Partei" character varying(100)
);


--
-- TOC entry 187 (class 1259 OID 16447)
-- Name: listenplaetze; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE listenplaetze (
    "Landesliste" integer NOT NULL,
    "Kandidat" integer NOT NULL,
    "Position" integer
);


--
-- TOC entry 214 (class 1259 OID 25169)
-- Name: mapid_direktkandidaten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_direktkandidaten (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 213 (class 1259 OID 25164)
-- Name: mapid_landeskandidaten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_landeskandidaten (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 212 (class 1259 OID 25159)
-- Name: mapid_landeslisten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_landeslisten (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 211 (class 1259 OID 25154)
-- Name: mapid_wahlkreise; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_wahlkreise (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 188 (class 1259 OID 16450)
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
-- Name: wahlbewerber_mit_titel; Type: VIEW; Schema: raw2009; Owner: -
--

CREATE VIEW wahlbewerber_mit_titel AS
    SELECT CASE WHEN (w."Titel" IS NULL) THEN (w."Vorname")::text ELSE (((w."Titel")::text || ' '::text) || (w."Vorname")::text) END AS "Vorname", w."Nachname", w."Partei", w."Jahrgang", w."Kandidatennummer" FROM wahlbewerber w;


--
-- TOC entry 189 (class 1259 OID 16453)
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
-- Name: wahlbewerber_direktkandidat; Type: VIEW; Schema: raw2009; Owner: -
--

CREATE VIEW wahlbewerber_direktkandidat AS
    SELECT w."Kandidatennummer", ww."Vorname", ww."Nachname", ww."Wahlkreis", public.get_partei_id_by_name(ww."Partei") AS partei_id FROM wahlbewerber_mit_wahlkreis ww, wahlbewerber_mit_titel w WHERE (((((ww."Vorname")::text = w."Vorname") AND ((ww."Nachname")::text = (w."Nachname")::text)) AND (ww."Jahrgang" = w."Jahrgang")) AND ((public.get_partei_id_by_name(ww."Partei") IS NULL) OR ((ww."Partei")::text = (w."Partei")::text)));


--
-- TOC entry 191 (class 1259 OID 16460)
-- Name: wahlbewerber_landesliste; Type: VIEW; Schema: raw2009; Owner: -
--

CREATE VIEW wahlbewerber_landesliste AS
    SELECT CASE WHEN (w."Titel" IS NULL) THEN (w."Vorname")::text ELSE (((w."Titel")::text || ' '::text) || (w."Vorname")::text) END AS "VornameTitel", w."Nachname", w."Partei", w."Jahrgang", w."Kandidatennummer", lp."Landesliste", lp."Position" FROM wahlbewerber w, listenplaetze lp WHERE (w."Kandidatennummer" = lp."Kandidat");


--
-- TOC entry 192 (class 1259 OID 16464)
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
-- Name: direktkandidat_stimmen; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW direktkandidat_stimmen AS
    SELECT public.get_direktkandidat_id_by_wahlkreis_partei_jahr("ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Partei", 2009) AS kandidat_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen, public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text IN (SELECT partei.name FROM public.partei)) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id, nummer, wahlberechtigte)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 232 (class 1259 OID 41707)
-- Name: direktkandidat_uebrige; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW direktkandidat_uebrige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Übrige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id, nummer, wahlberechtigte)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 228 (class 1259 OID 41691)
-- Name: erststimme_ungueltige; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW erststimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id, nummer, wahlberechtigte)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 229 (class 1259 OID 41695)
-- Name: erststimme_insges; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW erststimme_insges AS
    SELECT direktkandidat_stimmen.kandidat_id, direktkandidat_stimmen.stimmen, direktkandidat_stimmen.wahlkreis_id FROM direktkandidat_stimmen UNION ALL SELECT NULL::integer AS kandidat_id, erststimme_ungueltige.stimmen, erststimme_ungueltige.wahlkreis_id FROM erststimme_ungueltige;


--
-- TOC entry 233 (class 1259 OID 41711)
-- Name: erststimmen_statistik; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW erststimmen_statistik AS
    SELECT "ErststimmenEndgueltig"."Nr", "ErststimmenEndgueltig"."GehoertZu", "ErststimmenEndgueltig"."Partei", "ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Stimmen" FROM "ErststimmenEndgueltig" WHERE ("ErststimmenEndgueltig"."GehoertZu" IS NULL);


--
-- TOC entry 230 (class 1259 OID 41699)
-- Name: landesliste_stimmen; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW landesliste_stimmen AS
    SELECT public.get_landesliste_id_by_wahlkreis_partei_jahr(ee."Gebiet", ee."Partei", 2009) AS landesliste_id, ee."Stimmen" AS stimmen, public.get_wahlkreis_id_by_jahr_and_name(2009, ee."Gebiet") AS wahlkreis_id FROM "ZweitstimmenEndgueltig" ee WHERE (((((ee."Partei")::text IN (SELECT partei.name FROM public.partei)) AND (ee."GehoertZu" IS NOT NULL)) AND ((ee."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id, nummer, wahlberechtigte)))) AND (ee."Stimmen" IS NOT NULL));


--
-- TOC entry 231 (class 1259 OID 41703)
-- Name: zweitstimme_ungueltige; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW zweitstimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ZweitstimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ZweitstimmenEndgueltig"."Stimmen" AS stimmen FROM "ZweitstimmenEndgueltig" WHERE ((((("ZweitstimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ZweitstimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ZweitstimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id, nummer, wahlberechtigte)))) AND ("ZweitstimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 234 (class 1259 OID 41715)
-- Name: zweitstimme_insges; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW zweitstimme_insges AS
    SELECT landesliste_stimmen.landesliste_id, landesliste_stimmen.stimmen, landesliste_stimmen.wahlkreis_id FROM landesliste_stimmen UNION ALL SELECT NULL::integer AS landesliste_id, zweitstimme_ungueltige.stimmen, zweitstimme_ungueltige.wahlkreis_id FROM zweitstimme_ungueltige;


--
-- TOC entry 235 (class 1259 OID 41719)
-- Name: zweitstimmen_statistik; Type: VIEW; Schema: stimmen2005; Owner: -
--

CREATE VIEW zweitstimmen_statistik AS
    SELECT "ZweitstimmenEndgueltig"."Nr", "ZweitstimmenEndgueltig"."GehoertZu", "ZweitstimmenEndgueltig"."Partei", "ZweitstimmenEndgueltig"."Gebiet", "ZweitstimmenEndgueltig"."Stimmen" FROM "ZweitstimmenEndgueltig" WHERE ("ZweitstimmenEndgueltig"."GehoertZu" IS NULL);


SET search_path = stimmen2009, pg_catalog;

--
-- TOC entry 206 (class 1259 OID 25108)
-- Name: direktkandidat_uebrige; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW direktkandidat_uebrige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Übrige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 208 (class 1259 OID 25142)
-- Name: erststimmen_statistik; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW erststimmen_statistik AS
    SELECT "ErststimmenEndgueltig"."Nr", "ErststimmenEndgueltig"."GehoertZu", "ErststimmenEndgueltig"."Partei", "ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Stimmen" FROM "ErststimmenEndgueltig" WHERE ("ErststimmenEndgueltig"."GehoertZu" IS NULL);


--
-- TOC entry 216 (class 1259 OID 25184)
-- Name: zweitstimme_insges; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW zweitstimme_insges AS
    SELECT landesliste_stimmen.landesliste_id, landesliste_stimmen.stimmen, landesliste_stimmen.wahlkreis_id FROM landesliste_stimmen UNION ALL SELECT NULL::integer AS landesliste_id, zweitstimme_ungueltige.stimmen, zweitstimme_ungueltige.wahlkreis_id FROM zweitstimme_ungueltige;


--
-- TOC entry 209 (class 1259 OID 25146)
-- Name: zweitstimmen_statistik; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW zweitstimmen_statistik AS
    SELECT "ZweitstimmenEndgueltig"."Nr", "ZweitstimmenEndgueltig"."GehoertZu", "ZweitstimmenEndgueltig"."Partei", "ZweitstimmenEndgueltig"."Gebiet", "ZweitstimmenEndgueltig"."Stimmen" FROM "ZweitstimmenEndgueltig" WHERE ("ZweitstimmenEndgueltig"."GehoertZu" IS NULL);


SET search_path = public, pg_catalog;

--
-- TOC entry 2407 (class 2604 OID 16467)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY direktkandidat ALTER COLUMN id SET DEFAULT nextval('"Direktkandidat_id_seq"'::regclass);


--
-- TOC entry 2408 (class 2604 OID 16468)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimme ALTER COLUMN id SET DEFAULT nextval('"Erststimme_id_seq"'::regclass);


--
-- TOC entry 2417 (class 2604 OID 59447)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimmen_aggregation ALTER COLUMN id SET DEFAULT nextval('erststimmen_aggregation_id_seq'::regclass);


--
-- TOC entry 2409 (class 2604 OID 16469)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY land ALTER COLUMN id SET DEFAULT nextval('"Land_id_seq"'::regclass);


--
-- TOC entry 2410 (class 2604 OID 16470)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY landeskandidat ALTER COLUMN id SET DEFAULT nextval('"Landeskandidat_id_seq"'::regclass);


--
-- TOC entry 2411 (class 2604 OID 16471)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY landesliste ALTER COLUMN id SET DEFAULT nextval('"Landesliste_id_seq"'::regclass);


--
-- TOC entry 2412 (class 2604 OID 16472)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY partei ALTER COLUMN id SET DEFAULT nextval('"Partei_id_seq"'::regclass);


--
-- TOC entry 2413 (class 2604 OID 16474)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wahlkreis ALTER COLUMN id SET DEFAULT nextval('"Wahlkreis_id_seq"'::regclass);


--
-- TOC entry 2414 (class 2604 OID 16475)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme ALTER COLUMN id SET DEFAULT nextval('"Zweitstimme_id_seq"'::regclass);


--
-- TOC entry 2416 (class 2604 OID 59457)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimmen_aggregation ALTER COLUMN id SET DEFAULT nextval('zweitstimmen_aggregation_id_seq'::regclass);


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 2415 (class 2604 OID 16703)
-- Name: id; Type: DEFAULT; Schema: raw2005; Owner: -
--

ALTER TABLE ONLY wahlbewerber ALTER COLUMN id SET DEFAULT nextval('wahlbewerber_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- TOC entry 2422 (class 2606 OID 16477)
-- Name: Direktkandidat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_pkey" PRIMARY KEY (id);


--
-- TOC entry 2426 (class 2606 OID 16479)
-- Name: Erststimme_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_pkey" PRIMARY KEY (id);


--
-- TOC entry 2430 (class 2606 OID 16481)
-- Name: Jahr_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jahr
    ADD CONSTRAINT "Jahr_pkey" PRIMARY KEY (jahr);


--
-- TOC entry 2432 (class 2606 OID 16483)
-- Name: Land_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY land
    ADD CONSTRAINT "Land_pkey" PRIMARY KEY (id);


--
-- TOC entry 2434 (class 2606 OID 16485)
-- Name: Landeskandidat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY landeskandidat
    ADD CONSTRAINT "Landeskandidat_pkey" PRIMARY KEY (id);


--
-- TOC entry 2437 (class 2606 OID 16487)
-- Name: Landesliste_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_pkey" PRIMARY KEY (id);


--
-- TOC entry 2441 (class 2606 OID 16631)
-- Name: Partei_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partei
    ADD CONSTRAINT "Partei_name_key" UNIQUE (name);


--
-- TOC entry 2443 (class 2606 OID 16489)
-- Name: Partei_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partei
    ADD CONSTRAINT "Partei_pkey" PRIMARY KEY (id);


--
-- TOC entry 2445 (class 2606 OID 16493)
-- Name: Wahlkreis_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlkreis
    ADD CONSTRAINT "Wahlkreis_pkey" PRIMARY KEY (id);


--
-- TOC entry 2448 (class 2606 OID 16495)
-- Name: Zweitstimme_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_pkey" PRIMARY KEY (id);


--
-- TOC entry 2498 (class 2606 OID 59517)
-- Name: berechtigten_uuid_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY berechtigten_uuid
    ADD CONSTRAINT berechtigten_uuid_pkey PRIMARY KEY (id);


--
-- TOC entry 2489 (class 2606 OID 59467)
-- Name: erststimme_q7_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY erststimme_q7
    ADD CONSTRAINT erststimme_q7_pkey PRIMARY KEY (id);


--
-- TOC entry 2483 (class 2606 OID 59454)
-- Name: erststimmen_aggregation_direktkandidat_id_wahlkreis_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY erststimmen_aggregation
    ADD CONSTRAINT erststimmen_aggregation_direktkandidat_id_wahlkreis_id_key UNIQUE (direktkandidat_id, wahlkreis_id);


--
-- TOC entry 2485 (class 2606 OID 59452)
-- Name: erststimmen_aggregation_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY erststimmen_aggregation
    ADD CONSTRAINT erststimmen_aggregation_pkey PRIMARY KEY (id);


--
-- TOC entry 2474 (class 2606 OID 25218)
-- Name: scherperfaktoren_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scherperfaktoren
    ADD CONSTRAINT scherperfaktoren_pkey PRIMARY KEY (faktor);


--
-- TOC entry 2494 (class 2606 OID 59434)
-- Name: zweitstimme_q7_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zweitstimme_q7
    ADD CONSTRAINT zweitstimme_q7_pkey PRIMARY KEY (id);


--
-- TOC entry 2477 (class 2606 OID 59465)
-- Name: zweitstimmen_aggregation_partei_id_wahlkreis_id_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zweitstimmen_aggregation
    ADD CONSTRAINT zweitstimmen_aggregation_partei_id_wahlkreis_id_key UNIQUE (partei_id, wahlkreis_id);


--
-- TOC entry 2479 (class 2606 OID 59463)
-- Name: zweitstimmen_aggregation_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zweitstimmen_aggregation
    ADD CONSTRAINT zweitstimmen_aggregation_pkey PRIMARY KEY (id);


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 2460 (class 2606 OID 16713)
-- Name: Wahlkreise2005_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlkreise
    ADD CONSTRAINT "Wahlkreise2005_pkey" PRIMARY KEY ("Nummer");


--
-- TOC entry 2462 (class 2606 OID 16870)
-- Name: bundeslandkuerzel_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bundeslandkuerzel
    ADD CONSTRAINT bundeslandkuerzel_pkey PRIMARY KEY (kuerzel_2);


--
-- TOC entry 2464 (class 2606 OID 16899)
-- Name: mapid_wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_wahlkreise
    ADD CONSTRAINT mapid_wahlkreise_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2458 (class 2606 OID 16708)
-- Name: wahlbewerber_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlbewerber
    ADD CONSTRAINT wahlbewerber_pkey PRIMARY KEY (id);


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 2450 (class 2606 OID 16497)
-- Name: landeslisten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY landeslisten
    ADD CONSTRAINT landeslisten_pkey PRIMARY KEY ("Listennummer");


--
-- TOC entry 2452 (class 2606 OID 16499)
-- Name: listenplaetze_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT listenplaetze_pkey PRIMARY KEY ("Landesliste", "Kandidat");


--
-- TOC entry 2472 (class 2606 OID 25173)
-- Name: mapid_direktkandidaten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_direktkandidaten
    ADD CONSTRAINT mapid_direktkandidaten_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2470 (class 2606 OID 25168)
-- Name: mapid_landeskandidaten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_landeskandidaten
    ADD CONSTRAINT mapid_landeskandidaten_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2468 (class 2606 OID 25163)
-- Name: mapid_landeslisten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_landeslisten
    ADD CONSTRAINT mapid_landeslisten_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2466 (class 2606 OID 25158)
-- Name: mapid_wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_wahlkreise
    ADD CONSTRAINT mapid_wahlkreise_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2454 (class 2606 OID 16501)
-- Name: wahlbewerber_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlbewerber
    ADD CONSTRAINT wahlbewerber_pkey PRIMARY KEY ("Kandidatennummer");


--
-- TOC entry 2456 (class 2606 OID 16503)
-- Name: wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlkreise
    ADD CONSTRAINT wahlkreise_pkey PRIMARY KEY ("WahlkreisNr");


SET search_path = public, pg_catalog;

--
-- TOC entry 2423 (class 1259 OID 59600)
-- Name: direktkandidat_partei_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX direktkandidat_partei_id_idx ON direktkandidat USING btree (partei_id);


--
-- TOC entry 2424 (class 1259 OID 59599)
-- Name: direktkandidat_wahlkreis_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX direktkandidat_wahlkreis_id_idx ON direktkandidat USING btree (wahlkreis_id);


--
-- TOC entry 2427 (class 1259 OID 25179)
-- Name: erststimme_direktkandidat_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX erststimme_direktkandidat_id_idx ON erststimme USING btree (direktkandidat_id);


--
-- TOC entry 2487 (class 1259 OID 59557)
-- Name: erststimme_q7_direktkandidat_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX erststimme_q7_direktkandidat_id_idx ON erststimme_q7 USING btree (direktkandidat_id);


--
-- TOC entry 2490 (class 1259 OID 59558)
-- Name: erststimme_q7_wahlkreis_id_direktkandidat_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX erststimme_q7_wahlkreis_id_direktkandidat_id_idx ON erststimme_q7 USING btree (wahlkreis_id, direktkandidat_id);


--
-- TOC entry 2491 (class 1259 OID 59556)
-- Name: erststimme_q7_wahlkreis_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX erststimme_q7_wahlkreis_id_idx ON erststimme_q7 USING btree (wahlkreis_id);


--
-- TOC entry 2428 (class 1259 OID 25178)
-- Name: erststimme_wahlkreis_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX erststimme_wahlkreis_id_idx ON erststimme USING btree (wahlkreis_id);


--
-- TOC entry 2481 (class 1259 OID 59597)
-- Name: erststimmen_aggregation_direktkandidat_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX erststimmen_aggregation_direktkandidat_id_idx ON erststimmen_aggregation USING btree (direktkandidat_id);


--
-- TOC entry 2486 (class 1259 OID 59598)
-- Name: erststimmen_aggregation_wahlkreis_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX erststimmen_aggregation_wahlkreis_id_idx ON erststimmen_aggregation USING btree (wahlkreis_id);


--
-- TOC entry 2435 (class 1259 OID 59604)
-- Name: landeskandidat_landesliste_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX landeskandidat_landesliste_id_idx ON landeskandidat USING btree (landesliste_id);


--
-- TOC entry 2438 (class 1259 OID 59602)
-- Name: landesliste_land_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX landesliste_land_id_idx ON landesliste USING btree (land_id);


--
-- TOC entry 2439 (class 1259 OID 59603)
-- Name: landesliste_partei_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX landesliste_partei_id_idx ON landesliste USING btree (partei_id);


--
-- TOC entry 2446 (class 1259 OID 59601)
-- Name: wahlkreis_land_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX wahlkreis_land_id_idx ON wahlkreis USING btree (land_id);


--
-- TOC entry 2492 (class 1259 OID 59560)
-- Name: zweitstimme_q7_landesliste_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX zweitstimme_q7_landesliste_id_idx ON zweitstimme_q7 USING btree (landesliste_id);


--
-- TOC entry 2495 (class 1259 OID 59559)
-- Name: zweitstimme_q7_wahlkreis_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX zweitstimme_q7_wahlkreis_id_idx ON zweitstimme_q7 USING btree (wahlkreis_id);


--
-- TOC entry 2496 (class 1259 OID 59561)
-- Name: zweitstimme_q7_wahlkreis_id_landesliste_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX zweitstimme_q7_wahlkreis_id_landesliste_id_idx ON zweitstimme_q7 USING btree (wahlkreis_id, landesliste_id);


--
-- TOC entry 2475 (class 1259 OID 59595)
-- Name: zweitstimmen_aggregation_partei_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX zweitstimmen_aggregation_partei_id_idx ON zweitstimmen_aggregation USING btree (partei_id);


--
-- TOC entry 2480 (class 1259 OID 59596)
-- Name: zweitstimmen_aggregation_wahlkreis_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX zweitstimmen_aggregation_wahlkreis_id_idx ON zweitstimmen_aggregation USING btree (wahlkreis_id);


--
-- TOC entry 2499 (class 2606 OID 16504)
-- Name: Direktkandidat_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES partei(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2500 (class 2606 OID 16509)
-- Name: Direktkandidat_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2501 (class 2606 OID 25005)
-- Name: Erststimme_direktkandidat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_direktkandidat_id_fkey" FOREIGN KEY (direktkandidat_id) REFERENCES direktkandidat(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2502 (class 2606 OID 25010)
-- Name: Erststimme_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2503 (class 2606 OID 16524)
-- Name: Land_jahr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY land
    ADD CONSTRAINT "Land_jahr_fkey" FOREIGN KEY (jahr) REFERENCES jahr(jahr) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2504 (class 2606 OID 16529)
-- Name: Landeskandidat_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landeskandidat
    ADD CONSTRAINT "Landeskandidat_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES landesliste(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2505 (class 2606 OID 16534)
-- Name: Landesliste_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_land_id_fkey" FOREIGN KEY (land_id) REFERENCES land(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2506 (class 2606 OID 16539)
-- Name: Landesliste_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES partei(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2507 (class 2606 OID 59083)
-- Name: Wahlkreis_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY wahlkreis
    ADD CONSTRAINT "Wahlkreis_land_id_fkey" FOREIGN KEY (land_id) REFERENCES land(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2508 (class 2606 OID 25015)
-- Name: Zweitstimme_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES landesliste(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2509 (class 2606 OID 25020)
-- Name: Zweitstimme_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2512 (class 2606 OID 59565)
-- Name: zweitstimme_q7_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme_q7
    ADD CONSTRAINT zweitstimme_q7_landesliste_id_fkey FOREIGN KEY (landesliste_id) REFERENCES landesliste(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2513 (class 2606 OID 59570)
-- Name: zweitstimme_q7_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme_q7
    ADD CONSTRAINT zweitstimme_q7_wahlkreis_id_fkey FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 2510 (class 2606 OID 16564)
-- Name: listenplaetze_Kandidat_fkey; Type: FK CONSTRAINT; Schema: raw2009; Owner: -
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT "listenplaetze_Kandidat_fkey" FOREIGN KEY ("Kandidat") REFERENCES wahlbewerber("Kandidatennummer");


--
-- TOC entry 2511 (class 2606 OID 16569)
-- Name: listenplaetze_Landesliste_fkey; Type: FK CONSTRAINT; Schema: raw2009; Owner: -
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT "listenplaetze_Landesliste_fkey" FOREIGN KEY ("Landesliste") REFERENCES landeslisten("Listennummer");


-- Completed on 2013-01-28 13:53:51

--
-- PostgreSQL database dump complete
--

