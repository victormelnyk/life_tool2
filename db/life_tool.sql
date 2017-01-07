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

CREATE DOMAIN t_boolean AS boolean;


ALTER DOMAIN t_boolean OWNER TO lt_admin;

--
-- Name: t_id; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_id AS integer;


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

CREATE DOMAIN t_string_large AS character varying(255);


ALTER DOMAIN t_string_large OWNER TO lt_admin;

--
-- Name: t_string_short; Type: DOMAIN; Schema: df; Owner: lt_admin
--

CREATE DOMAIN t_string_short AS character varying(50);


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
-- Name: fn_get_next_field_value(name, name, name, t_string_large); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_get_next_field_value(atable_schema name, atable_name name, afield_name name, acondition t_string_large DEFAULT ''::character varying) RETURNS t_id
    LANGUAGE plpgsql
    AS $$
DECLARE
  lresult df.t_id;
  lsql df.t_string_large;
BEGIN
  lsql = 'SELECT COALESCE(MAX(' || afield_name || ') + 1, 1) FROM ' ||
    atable_schema || '.' || atable_name;

  IF acondition <> '' THEN
    lsql = lsql || ' WHERE ' || acondition;
  END IF;

  EXECUTE lsql
  INTO lresult;

  RETURN lresult;
END;
$$;


ALTER FUNCTION df.fn_get_next_field_value(atable_schema name, atable_name name, afield_name name, acondition t_string_large) OWNER TO lt_admin;

--
-- Name: fn_get_next_pk_value(name, name, t_string_large); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_get_next_pk_value(atable_schema name, atable_name name, acondition t_string_large DEFAULT ''::character varying) RETURNS t_id
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN df.fn_get_next_field_value(atable_schema, atable_name, 
    df.fn_get_pk_field_name(atable_schema, atable_name), acondition);
END;
$$;


ALTER FUNCTION df.fn_get_next_pk_value(atable_schema name, atable_name name, acondition t_string_large) OWNER TO lt_admin;

--
-- Name: fn_get_next_random_pk_value(name, name, t_string_short, t_id, t_id); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_get_next_random_pk_value(atable_schema name, atable_name name, acondition t_string_short DEFAULT ''::character varying, afrom t_id DEFAULT 0, ato t_id DEFAULT 0) RETURNS t_id
    LANGUAGE plpgsql
    AS $$
DECLARE
  lis_exist df.t_boolean;
  lresult df.t_id;
  lsql df.t_string_large;
  lfield_name df.t_string_short;
BEGIN
  lfield_name = df.fn_get_pk_field_name(atable_schema, atable_name);

  LOOP
    IF (afrom <> 0) AND (ato <> 0) THEN
      lresult = df.fn_random_id_range(afrom, ato);
    ELSE
      lresult = df.fn_random_id();  
    END IF;
    
    lsql = 'SELECT EXISTS(SELECT * FROM ' || 
      atable_schema || '.' || atable_name || ' WHERE ';
      
    IF acondition <> '' THEN 
      lsql = lsql || acondition || ' AND ';
    END IF;  
    
    lsql = lsql || lfield_name || ' = ' || lresult || ')';
    
    EXECUTE lsql
    INTO lis_exist;
        
    IF NOT lis_exist THEN
      EXIT;
    END IF;
  END LOOP;

  RETURN lresult;
END;
$$;


ALTER FUNCTION df.fn_get_next_random_pk_value(atable_schema name, atable_name name, acondition t_string_short, afrom t_id, ato t_id) OWNER TO lt_admin;

--
-- Name: fn_get_pk_field_name(name, name); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_get_pk_field_name(atable_schema name, atable_name name) RETURNS t_string_short
    LANGUAGE plpgsql
    AS $$
DECLARE
  lresult df.t_string_short;
BEGIN
  SELECT KCU.column_name
  INTO lresult
  FROM information_schema.table_constraints TC
    INNER JOIN information_schema.key_column_usage KCU
      ON  KCU.table_catalog   = TC.table_catalog
      AND KCU.table_schema    = TC.table_schema
      AND KCU.table_name      = TC.table_name
      AND KCU.constraint_name = TC.constraint_name
  WHERE TC.table_catalog   = current_catalog
    AND TC.table_schema    = atable_schema
    AND TC.table_name      = atable_name
    AND TC.constraint_type = 'PRIMARY KEY'
  ORDER BY KCU.ordinal_position DESC
  LIMIT 1;

  RETURN lresult;
END;
$$;


ALTER FUNCTION df.fn_get_pk_field_name(atable_schema name, atable_name name) OWNER TO lt_admin;

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
-- Name: fn_timestamp_to_local_str(t_timestamp, t_string_short); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_timestamp_to_local_str(avalue t_timestamp, atimezome t_string_short DEFAULT 'Europe/Kiev'::character varying) RETURNS t_string_short
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (
    SELECT df.fn_timestamp_to_str(avalue + TZN.utc_offset)
    FROM pg_timezone_names TZN
    WHERE TZN.name = atimezome);
END;
$$;


ALTER FUNCTION df.fn_timestamp_to_local_str(avalue t_timestamp, atimezome t_string_short) OWNER TO lt_admin;

--
-- Name: fn_timestamp_to_str(t_timestamp); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_timestamp_to_str(avalue t_timestamp) RETURNS t_string_short
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN to_char(avalue, 'yyyy-MM-dd HH24:MI:SS');
END;
$$;


ALTER FUNCTION df.fn_timestamp_to_str(avalue t_timestamp) OWNER TO lt_admin;

--
-- Name: fn_timestamp_to_utc_timestamp(t_timestamp, t_string_short); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_timestamp_to_utc_timestamp(avalue t_timestamp, atimezome t_string_short DEFAULT 'Europe/Kiev'::character varying) RETURNS t_timestamp
    LANGUAGE plpgsql
    AS $$
BEGIN  
  RETURN (
    SELECT avalue - TZN.utc_offset 
    FROM pg_timezone_names TZN
    WHERE TZN.name = atimezome);
END;
$$;


ALTER FUNCTION df.fn_timestamp_to_utc_timestamp(avalue t_timestamp, atimezome t_string_short) OWNER TO lt_admin;

--
-- Name: fn_utc_timestamp(); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_utc_timestamp() RETURNS t_timestamp
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN clock_timestamp() AT TIME ZONE 'UTC';
END;
$$;


ALTER FUNCTION df.fn_utc_timestamp() OWNER TO lt_admin;

--
-- PostgreSQL database dump complete
--

