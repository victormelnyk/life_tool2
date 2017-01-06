--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: df; Type: SCHEMA; Schema: -; Owner: lt_admin
--

CREATE SCHEMA df;


ALTER SCHEMA df OWNER TO lt_admin;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = df, pg_catalog;

--
-- Name: t_boolean; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_boolean AS boolean NOT NULL;


ALTER DOMAIN t_boolean OWNER TO lt_admin;

--
-- Name: t_id; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_id AS integer NOT NULL;


ALTER DOMAIN t_id OWNER TO lt_admin;

--
-- Name: t_integer; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_integer AS integer;


ALTER DOMAIN t_integer OWNER TO lt_admin;

--
-- Name: t_interval; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_interval AS interval;


ALTER DOMAIN t_interval OWNER TO lt_admin;

--
-- Name: t_money; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_money AS numeric(10,2);


ALTER DOMAIN t_money OWNER TO lt_admin;

--
-- Name: t_smallint; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_smallint AS smallint;


ALTER DOMAIN t_smallint OWNER TO lt_admin;

--
-- Name: t_string_large; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_string_large AS character varying(255) NOT NULL;


ALTER DOMAIN t_string_large OWNER TO lt_admin;

--
-- Name: t_string_short; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_string_short AS character varying(50) NOT NULL;


ALTER DOMAIN t_string_short OWNER TO lt_admin;

--
-- Name: t_text; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_text AS text;


ALTER DOMAIN t_text OWNER TO lt_admin;

--
-- Name: t_timestamp; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_timestamp AS timestamp without time zone;


ALTER DOMAIN t_timestamp OWNER TO lt_admin;

--
-- Name: t_tinyint; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_tinyint AS smallint
	CONSTRAINT chk_t_tinyint CHECK (((VALUE >= 0) OR (VALUE <= 255)));


ALTER DOMAIN t_tinyint OWNER TO lt_admin;

--
-- Name: t_tinyint_id; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_tinyint_id AS smallint NOT NULL
	CONSTRAINT chk_t_tinyint_id CHECK (((VALUE >= 0) OR (VALUE <= 255)));


ALTER DOMAIN t_tinyint_id OWNER TO lt_admin;

--
-- Name: fn_random_i(); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_random_i() RETURNS t_integer
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN trunc(random() * 2^32) - 2^31;
END;
$$;


ALTER FUNCTION df.fn_random_i() OWNER TO lt_admin;

--
-- Name: fn_random_id(); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_random_id() RETURNS t_id
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN 1 + trunc(random() * (2^31 - 1));
END;
$$;


ALTER FUNCTION df.fn_random_id() OWNER TO lt_admin;

--
-- Name: fn_random_id_range(t_id, t_id); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_random_id_range(afrom t_id, ato t_id) RETURNS t_id
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN afrom + trunc(random() * (ato - afrom + 1));
END;
$$;


ALTER FUNCTION df.fn_random_id_range(afrom t_id, ato t_id) OWNER TO lt_admin;

--
-- PostgreSQL database dump complete
--

