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
-- Name: mn; Type: SCHEMA; Schema: -; Owner: lt_admin
--

CREATE SCHEMA mn;


ALTER SCHEMA mn OWNER TO lt_admin;

--
-- Name: us; Type: SCHEMA; Schema: -; Owner: lt_admin
--

CREATE SCHEMA us;


ALTER SCHEMA us OWNER TO lt_admin;

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

SET search_path = us, pg_catalog;

--
-- Name: t_password; Type: DOMAIN; Schema: us; Owner: lt_admin
--

CREATE DOMAIN t_password AS character varying(60);


ALTER DOMAIN t_password OWNER TO lt_admin;

--
-- Name: t_random_part; Type: DOMAIN; Schema: us; Owner: lt_admin
--

CREATE DOMAIN t_random_part AS character varying(22);


ALTER DOMAIN t_random_part OWNER TO lt_admin;

SET search_path = df, pg_catalog;

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
-- Name: fn_temp_table_exist(name); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_temp_table_exist(atable_name name) RETURNS t_boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN EXISTS( 
    SELECT *
    FROM information_schema.tables T
    WHERE T.table_name = atable_name
      AND T.table_type = 'LOCAL TEMPORARY');
END;
$$;


ALTER FUNCTION df.fn_temp_table_exist(atable_name name) OWNER TO lt_admin;

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

SET search_path = mn, pg_catalog;

--
-- Name: fn_clear(); Type: FUNCTION; Schema: mn; Owner: lt_admin
--

CREATE FUNCTION fn_clear() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM mn.operations;
  DELETE FROM mn.transactions;
  DELETE FROM mn.descriptions;
  DELETE FROM mn.categories;
  DELETE FROM mn.accounts;
  DELETE FROM mn.currencies;
END;
$$;


ALTER FUNCTION mn.fn_clear() OWNER TO lt_admin;

--
-- Name: t_accounts_bi(); Type: FUNCTION; Schema: mn; Owner: lt_admin
--

CREATE FUNCTION t_accounts_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.owner_id = us.fn_get_logged_user_id();

  RETURN NEW;
END;
$$;


ALTER FUNCTION mn.t_accounts_bi() OWNER TO lt_admin;

--
-- Name: t_categories_bi(); Type: FUNCTION; Schema: mn; Owner: lt_admin
--

CREATE FUNCTION t_categories_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.owner_id = us.fn_get_logged_user_id();
  NEW.category_id = df.fn_get_next_pk_value(TG_TABLE_SCHEMA, TG_TABLE_NAME,
    'owner_id = ' || NEW.owner_id);
  NEW.is_deleted = FALSE;

  RETURN NEW;
END;
$$;


ALTER FUNCTION mn.t_categories_bi() OWNER TO lt_admin;

--
-- Name: t_currencies_bi(); Type: FUNCTION; Schema: mn; Owner: lt_admin
--

CREATE FUNCTION t_currencies_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.owner_id = us.fn_get_logged_user_id();

  RETURN NEW;
END;
$$;


ALTER FUNCTION mn.t_currencies_bi() OWNER TO lt_admin;

--
-- Name: t_descriptions_bi(); Type: FUNCTION; Schema: mn; Owner: lt_admin
--

CREATE FUNCTION t_descriptions_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.owner_id = us.fn_get_logged_user_id();
  NEW.description_id = df.fn_get_next_pk_value(TG_TABLE_SCHEMA, TG_TABLE_NAME,
    'owner_id = ' || NEW.owner_id);

  RETURN NEW;
END;
$$;


ALTER FUNCTION mn.t_descriptions_bi() OWNER TO lt_admin;

--
-- Name: t_operations_bi(); Type: FUNCTION; Schema: mn; Owner: lt_admin
--

CREATE FUNCTION t_operations_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.owner_id = us.fn_get_logged_user_id();
  NEW.lno = df.fn_get_next_field_value(TG_TABLE_SCHEMA, TG_TABLE_NAME, 'lno',
    'owner_id = ' || NEW.owner_id);

  NEW.is_deleted = FALSE;
  NEW.date_created = df.fn_utc_timestamp();

  NEW.sys_operation_id = df.fn_get_next_field_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME, 'sys_operation_id');

  RETURN NEW;
END;
$$;


ALTER FUNCTION mn.t_operations_bi() OWNER TO lt_admin;

--
-- Name: t_transactions_bi(); Type: FUNCTION; Schema: mn; Owner: lt_admin
--

CREATE FUNCTION t_transactions_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.owner_id = us.fn_get_logged_user_id();
  NEW.transaction_id = df.fn_get_next_random_pk_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME, '', 1000, 9999);
  NEW.lno = df.fn_get_next_field_value(TG_TABLE_SCHEMA, TG_TABLE_NAME, 'lno',
    'owner_id = ' || NEW.owner_id);

  IF NEW.is_real IS NULL THEN
    NEW.is_real = TRUE;
  END IF;

  NEW.is_deleted = FALSE;
  NEW.date_created = df.fn_utc_timestamp();

  NEW.sys_transaction_id = df.fn_get_next_field_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME, 'sys_transaction_id');

  RETURN NEW;
END;
$$;


ALTER FUNCTION mn.t_transactions_bi() OWNER TO lt_admin;

SET search_path = us, pg_catalog;

--
-- Name: fn_get_logged_owner_id(); Type: FUNCTION; Schema: us; Owner: lt_admin
--

CREATE FUNCTION fn_get_logged_owner_id() RETURNS df.t_id
    LANGUAGE plpgsql
    AS $$
DECLARE
  lowner_id df.t_id;
BEGIN
  IF df.fn_temp_table_exist('tmp_us_logged_owners') THEN
    SELECT LO.owner_id
    INTO lowner_id
    FROM tmp_us_logged_owners LO;
  END IF;

  IF (lowner_id IS NULL) THEN
    RAISE EXCEPTION 'Owner not set';
  END IF;

  RETURN lowner_id;
END;
$$;


ALTER FUNCTION us.fn_get_logged_owner_id() OWNER TO lt_admin;

--
-- Name: fn_get_logged_user_id(); Type: FUNCTION; Schema: us; Owner: lt_admin
--

CREATE FUNCTION fn_get_logged_user_id() RETURNS df.t_id
    LANGUAGE plpgsql
    AS $$
DECLARE
  luser_id df.t_id;
BEGIN
  IF df.fn_temp_table_exist('tmp_us_logged_users') THEN
    SELECT LU.user_id
    INTO luser_id
    FROM tmp_us_logged_users LU;
  END IF;

  IF (luser_id IS NULL) THEN
    RAISE EXCEPTION 'Nobody Logged';
  END IF;

  RETURN luser_id;
END;
$$;


ALTER FUNCTION us.fn_get_logged_user_id() OWNER TO lt_admin;

SET search_path = mn, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: mn; Owner: lt_admin
--

CREATE TABLE accounts (
    owner_id df.t_id NOT NULL,
    account_id df.t_id NOT NULL,
    currency_id df.t_id NOT NULL,
    name df.t_string_short NOT NULL
);


ALTER TABLE accounts OWNER TO lt_admin;

--
-- Name: categories; Type: TABLE; Schema: mn; Owner: lt_admin
--

CREATE TABLE categories (
    owner_id df.t_id NOT NULL,
    category_id df.t_id NOT NULL,
    parent_id df.t_id,
    name df.t_string_short NOT NULL,
    is_deleted df.t_boolean NOT NULL
);


ALTER TABLE categories OWNER TO lt_admin;

--
-- Name: currencies; Type: TABLE; Schema: mn; Owner: lt_admin
--

CREATE TABLE currencies (
    owner_id df.t_id NOT NULL,
    currency_id df.t_id NOT NULL,
    name df.t_string_short NOT NULL
);


ALTER TABLE currencies OWNER TO lt_admin;

--
-- Name: descriptions; Type: TABLE; Schema: mn; Owner: lt_admin
--

CREATE TABLE descriptions (
    owner_id df.t_id NOT NULL,
    description_id df.t_id NOT NULL,
    description df.t_text NOT NULL
);


ALTER TABLE descriptions OWNER TO lt_admin;

--
-- Name: operation_types; Type: TABLE; Schema: mn; Owner: lt_admin
--

CREATE TABLE operation_types (
    operation_type_id df.t_tinyint_id NOT NULL,
    name df.t_string_short NOT NULL
);


ALTER TABLE operation_types OWNER TO lt_admin;

--
-- Name: operations; Type: TABLE; Schema: mn; Owner: lt_admin
--

CREATE TABLE operations (
    owner_id df.t_id NOT NULL,
    transaction_id df.t_id NOT NULL,
    operation_type_id df.t_tinyint_id NOT NULL,
    account_id df.t_id NOT NULL,
    sum df.t_money NOT NULL,
    lno df.t_integer NOT NULL,
    is_deleted df.t_boolean NOT NULL,
    date_created df.t_timestamp NOT NULL,
    sys_operation_id df.t_id NOT NULL
);


ALTER TABLE operations OWNER TO lt_admin;

--
-- Name: transactions; Type: TABLE; Schema: mn; Owner: lt_admin
--

CREATE TABLE transactions (
    owner_id df.t_id NOT NULL,
    transaction_id df.t_id NOT NULL,
    category_id df.t_id NOT NULL,
    description_id df.t_id,
    is_real df.t_boolean NOT NULL,
    lno df.t_integer NOT NULL,
    date_transaction df.t_timestamp NOT NULL,
    is_deleted df.t_boolean NOT NULL,
    date_created df.t_timestamp NOT NULL,
    sys_transaction_id df.t_id NOT NULL
);


ALTER TABLE transactions OWNER TO lt_admin;

SET search_path = us, pg_catalog;

--
-- Name: users; Type: TABLE; Schema: us; Owner: lt_admin
--

CREATE TABLE users (
    user_id df.t_id NOT NULL,
    login df.t_string_short NOT NULL,
    name df.t_string_large NOT NULL,
    password t_password NOT NULL,
    random_part t_random_part NOT NULL,
    is_deleted df.t_boolean NOT NULL,
    date_created df.t_timestamp NOT NULL,
    date_lock df.t_timestamp,
    date_last_bad_logon_attempt df.t_id,
    date_last_logon df.t_timestamp,
    bad_logon_attempts df.t_integer NOT NULL,
    is_active df.t_boolean NOT NULL,
    time_zone df.t_string_short
);


ALTER TABLE users OWNER TO lt_admin;

SET search_path = mn, pg_catalog;

--
-- Name: accounts pk_accounts; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT pk_accounts PRIMARY KEY (owner_id, account_id);


--
-- Name: categories pk_categories; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT pk_categories PRIMARY KEY (owner_id, category_id);


--
-- Name: currencies pk_currencies; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY currencies
    ADD CONSTRAINT pk_currencies PRIMARY KEY (owner_id, currency_id);


--
-- Name: descriptions pk_descriptions; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY descriptions
    ADD CONSTRAINT pk_descriptions PRIMARY KEY (owner_id, description_id);


--
-- Name: operation_types pk_operation_types; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operation_types
    ADD CONSTRAINT pk_operation_types PRIMARY KEY (operation_type_id);


--
-- Name: operations pk_operations; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT pk_operations PRIMARY KEY (owner_id, transaction_id, operation_type_id);


--
-- Name: transactions pk_transactions; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT pk_transactions PRIMARY KEY (owner_id, transaction_id);


--
-- Name: accounts uq_accounts__name; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT uq_accounts__name UNIQUE (owner_id, name);


--
-- Name: categories uq_categories__name; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT uq_categories__name UNIQUE (owner_id, name);


--
-- Name: currencies uq_currencies__name; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY currencies
    ADD CONSTRAINT uq_currencies__name UNIQUE (owner_id, name);


--
-- Name: descriptions uq_descriptions__description; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY descriptions
    ADD CONSTRAINT uq_descriptions__description UNIQUE (owner_id, description);


--
-- Name: operations uq_operations__acount_id; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT uq_operations__acount_id UNIQUE (owner_id, transaction_id, account_id);


SET search_path = us, pg_catalog;

--
-- Name: users pk_users; Type: CONSTRAINT; Schema: us; Owner: lt_admin
--

ALTER TABLE ONLY users
    ADD CONSTRAINT pk_users PRIMARY KEY (user_id);


--
-- Name: users uq_users; Type: CONSTRAINT; Schema: us; Owner: lt_admin
--

ALTER TABLE ONLY users
    ADD CONSTRAINT uq_users UNIQUE (login);


SET search_path = mn, pg_catalog;

--
-- Name: accounts fk_accounts__currencies; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT fk_accounts__currencies FOREIGN KEY (owner_id, currency_id) REFERENCES currencies(owner_id, currency_id);


--
-- Name: accounts fk_accounts__users; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT fk_accounts__users FOREIGN KEY (owner_id) REFERENCES us.users(user_id);


--
-- Name: categories fk_categories__categories; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT fk_categories__categories FOREIGN KEY (owner_id, parent_id) REFERENCES categories(owner_id, category_id);


--
-- Name: categories fk_categories__users; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT fk_categories__users FOREIGN KEY (owner_id) REFERENCES us.users(user_id);


--
-- Name: currencies fk_currencies__users; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY currencies
    ADD CONSTRAINT fk_currencies__users FOREIGN KEY (owner_id) REFERENCES us.users(user_id);


--
-- Name: descriptions fk_descriptions__users; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY descriptions
    ADD CONSTRAINT fk_descriptions__users FOREIGN KEY (owner_id) REFERENCES us.users(user_id);


--
-- Name: operations fk_operations__accounts; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT fk_operations__accounts FOREIGN KEY (owner_id, account_id) REFERENCES accounts(owner_id, account_id);


--
-- Name: operations fk_operations__operation_types; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT fk_operations__operation_types FOREIGN KEY (operation_type_id) REFERENCES operation_types(operation_type_id);


--
-- Name: operations fk_operations__transactions; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT fk_operations__transactions FOREIGN KEY (owner_id, transaction_id) REFERENCES transactions(owner_id, transaction_id);


--
-- Name: operations fk_operations__users; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT fk_operations__users FOREIGN KEY (owner_id) REFERENCES us.users(user_id);


--
-- Name: transactions fk_transactions__categories; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT fk_transactions__categories FOREIGN KEY (owner_id, category_id) REFERENCES categories(owner_id, category_id);


--
-- Name: transactions fk_transactions__descriptions; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT fk_transactions__descriptions FOREIGN KEY (owner_id, description_id) REFERENCES descriptions(owner_id, description_id);


--
-- Name: transactions fk_transactions__users; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT fk_transactions__users FOREIGN KEY (owner_id) REFERENCES us.users(user_id);


--
-- PostgreSQL database dump complete
--

