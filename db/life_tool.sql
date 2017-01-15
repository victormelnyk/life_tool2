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
-- Name: pm; Type: SCHEMA; Schema: -; Owner: lt_admin
--

CREATE SCHEMA pm;


ALTER SCHEMA pm OWNER TO lt_admin;

--
-- Name: us; Type: SCHEMA; Schema: -; Owner: lt_admin
--

CREATE SCHEMA us;


ALTER SCHEMA us OWNER TO lt_admin;

--
-- Name: wa; Type: SCHEMA; Schema: -; Owner: lt_admin
--

CREATE SCHEMA wa;


ALTER SCHEMA wa OWNER TO lt_admin;

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

CREATE DOMAIN t_id AS integer
	CONSTRAINT chk_t_id CHECK ((VALUE > 0));


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
-- Name: fn_root_path_calc(t_id, t_id, name, name, t_string_short, t_string_short); Type: FUNCTION; Schema: df; Owner: lt_admin
--

CREATE FUNCTION fn_root_path_calc(aid t_id, aparent_id t_id, atable_schema name, atable_name name, aid_field_name t_string_short, aparent_id_field_name t_string_short) RETURNS t_string_short
    LANGUAGE plpgsql
    AS $$
DECLARE
  lid df.t_id;
  lparent_id df.t_id;
  lresult df.t_string_short;
BEGIN
  lid = aid;
  lparent_id = aparent_id;
  lresult = '.' || lid || '.';

  WHILE (lparent_id IS NOT NULL) LOOP
    EXECUTE 'SELECT ' || aid_field_name || ', ' || aparent_id_field_name || ' '
      'FROM ' || atable_schema || '.' || atable_name || ' '
      'WHERE ' || aid_field_name || ' = ' || lparent_id
    INTO lid, lparent_id;

    lresult =  '.' || lid || lresult;
  END LOOP;

  RETURN lresult;
END;
$$;


ALTER FUNCTION df.fn_root_path_calc(aid t_id, aparent_id t_id, atable_schema name, atable_name name, aid_field_name t_string_short, aparent_id_field_name t_string_short) OWNER TO lt_admin;

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
  NEW.user_id = us.fn_get_logged_user_id();

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
  NEW.user_id = us.fn_get_logged_user_id();
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
  NEW.user_id = us.fn_get_logged_user_id();

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
  NEW.user_id = us.fn_get_logged_user_id();
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
  NEW.user_id = us.fn_get_logged_user_id();
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
  NEW.user_id = us.fn_get_logged_user_id();
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

SET search_path = pm, pg_catalog;

--
-- Name: t_activities_bi(); Type: FUNCTION; Schema: pm; Owner: lt_admin
--

CREATE FUNCTION t_activities_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.owner_id = us.fn_get_logged_owner_id();
  NEW.activity_id = df.fn_get_next_random_pk_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME, '', 1000, 9999);--!!owner_condition
  NEW.created_by = us.fn_get_logged_user_id();

  NEW.date_from = us.fn_timestamp_to_utc_timestamp(NEW.date_from);
  NEW.date_to = us.fn_timestamp_to_utc_timestamp(NEW.date_to);

  NEW.is_deleted = FALSE;
  NEW.date_created = df.fn_utc_timestamp();

  NEW.sys_activity_id = df.fn_get_next_field_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME, 'sys_activity_id');

  RETURN NEW;
END;
$$;


ALTER FUNCTION pm.t_activities_bi() OWNER TO lt_admin;

--
-- Name: t_activities_bu(); Type: FUNCTION; Schema: pm; Owner: lt_admin
--

CREATE FUNCTION t_activities_bu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (NEW.date_from <> OLD.date_from) THEN
    NEW.date_from = us.fn_timestamp_to_utc_timestamp(NEW.date_from);
  END IF;
  IF (NEW.date_to <> OLD.date_to) THEN
    NEW.date_to = us.fn_timestamp_to_utc_timestamp(NEW.date_to);
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION pm.t_activities_bu() OWNER TO lt_admin;

--
-- Name: t_task_messages_bi(); Type: FUNCTION; Schema: pm; Owner: lt_admin
--

CREATE FUNCTION t_task_messages_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.owner_id = us.fn_get_logged_owner_id();
  NEW.message_id = df.fn_get_next_random_pk_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME, '', 1000, 9999);--!!owner_condition
  NEW.created_by = us.fn_get_logged_user_id();

  NEW.is_deleted = FALSE;
  NEW.date_created = df.fn_utc_timestamp();

  NEW.sys_message_id = df.fn_get_next_field_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME, 'sys_message_id');

  RETURN NEW;
END;
$$;


ALTER FUNCTION pm.t_task_messages_bi() OWNER TO lt_admin;

--
-- Name: t_task_users_bi(); Type: FUNCTION; Schema: pm; Owner: lt_admin
--

CREATE FUNCTION t_task_users_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.date_created = df.fn_utc_timestamp();

  RETURN NEW;
END;
$$;


ALTER FUNCTION pm.t_task_users_bi() OWNER TO lt_admin;

--
-- Name: t_tasks_au(); Type: FUNCTION; Schema: pm; Owner: lt_admin
--

CREATE FUNCTION t_tasks_au() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE pm.tasks
  SET root_path = NEW.root_path
  WHERE owner_id       = NEW.owner_id
    AND parent_task_id = NEW.task_id;

  RETURN OLD;
END;
$$;


ALTER FUNCTION pm.t_tasks_au() OWNER TO lt_admin;

--
-- Name: t_tasks_bi(); Type: FUNCTION; Schema: pm; Owner: lt_admin
--

CREATE FUNCTION t_tasks_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.owner_id = us.fn_get_logged_owner_id();
  NEW.task_id = df.fn_get_next_random_pk_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME, '', 1000, 9999);--!!owner_condition
  NEW.created_by = us.fn_get_logged_user_id();

  IF (NEW.processed_state_id IS NULL) THEN
    NEW.processed_state_id = 1/*New*/;
  END IF;

  IF (NEW.is_deleted IS NULL) THEN
    NEW.is_deleted = FALSE;
  END IF;

  NEW.date_created = df.fn_utc_timestamp();
  NEW.root_path = df.fn_root_path_calc(NEW.task_id, NEW.parent_task_id,
    TG_TABLE_SCHEMA, TG_TABLE_NAME, 'task_id', 'parent_task_id');--!!owner_condition

  NEW.sys_task_id = df.fn_get_next_field_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME, 'sys_task_id');

  RETURN NEW;
END;
$$;


ALTER FUNCTION pm.t_tasks_bi() OWNER TO lt_admin;

--
-- Name: t_tasks_bu(); Type: FUNCTION; Schema: pm; Owner: lt_admin
--

CREATE FUNCTION t_tasks_bu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.root_path = df.fn_root_path_calc(NEW.task_id, NEW.parent_task_id,
    TG_TABLE_SCHEMA, TG_TABLE_NAME, 'task_id', 'parent_task_id');--!!owner_condition

  RETURN NEW;
END;
$$;


ALTER FUNCTION pm.t_tasks_bu() OWNER TO lt_admin;

SET search_path = us, pg_catalog;

--
-- Name: fn_get_logged_group_id(); Type: FUNCTION; Schema: us; Owner: lt_admin
--

CREATE FUNCTION fn_get_logged_group_id() RETURNS df.t_id
    LANGUAGE plpgsql
    AS $$
DECLARE
  lgroup_id df.t_id;
BEGIN
  IF df.fn_temp_table_exist('tmp_logged_groups') THEN
    SELECT LG.group_id
    INTO lgroup_id
    FROM tmp_logged_groups LG;
  END IF;

  IF (lgroup_id IS NULL) THEN
    RAISE EXCEPTION 'Group not set';
  END IF;

  RETURN lgroup_id;
END;
$$;


ALTER FUNCTION us.fn_get_logged_group_id() OWNER TO lt_admin;

--
-- Name: fn_get_logged_user_id(); Type: FUNCTION; Schema: us; Owner: lt_admin
--

CREATE FUNCTION fn_get_logged_user_id() RETURNS df.t_id
    LANGUAGE plpgsql
    AS $$
DECLARE
  luser_id df.t_id;
BEGIN
  IF df.fn_temp_table_exist('tmp_logged_users') THEN
    SELECT LU.user_id
    INTO luser_id
    FROM tmp_logged_users LU;
  END IF;

  IF (luser_id IS NULL) THEN
    RAISE EXCEPTION 'Nobody Logged';
  END IF;

  RETURN luser_id;
END;
$$;


ALTER FUNCTION us.fn_get_logged_user_id() OWNER TO lt_admin;

--
-- Name: fn_logon(df.t_string_short, t_password); Type: FUNCTION; Schema: us; Owner: lt_admin
--

CREATE FUNCTION fn_logon(alogin df.t_string_short, apassword t_password, OUT rlogon_result df.t_tinyint_id, OUT ruser_id df.t_id) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
  --logon result
  LR_OK CONSTANT df.t_tinyint_id := 1;
  LR_LOGIN_OR_PASSWOR_IS_INCORRECT CONSTANT df.t_tinyint_id := 2;
  LR_ACCOUNT_HAS_BEEN_LOCKED CONSTANT df.t_tinyint_id := 3;
  LR_ACCOUNT_IS_DISABLED CONSTANT df.t_tinyint_id := 4;

  ACCOUNT_LOCK_TIMEOUT CONSTANT TIME := TIME '00:15';
  MAX_BAD_LOGON_ATTEMPTS CONSTANT df.t_tinyint := 3;

  lnow df.t_timestamp := df.fn_utc_timestamp();
  luser record;
BEGIN
  DROP TABLE IF EXISTS tmp_logged_users;

  SELECT U.user_id, U.password, U.is_active, U.is_deleted, U.date_lock
  INTO luser
  FROM us.users U
  WHERE U.login = alogin;

  ruser_id := luser.user_id;
  IF (ruser_id IS NULL) THEN
    rlogon_result = LR_LOGIN_OR_PASSWOR_IS_INCORRECT;
    RETURN;
  END IF;

  IF (luser.date_lock IS NOT NULL) THEN
    IF ((lnow - luser.date_lock) < ACCOUNT_LOCK_TIMEOUT) THEN
      UPDATE us.users
      SET
        bad_logon_attempts = bad_logon_attempts + 1,
        date_last_bad_logon_attempt = lnow
      WHERE user_id = ruser_id;
      rlogon_result := LR_ACCOUNT_HAS_BEEN_LOCKED;
      RETURN;
    ELSE
      UPDATE us.users
      SET
        bad_logon_attempts = 0,
        date_lock = NULL
      WHERE user_id = ruser_id;
    end if;
  end if;

  IF (luser.password <> apassword) THEN
    rlogon_result := LR_LOGIN_OR_PASSWOR_IS_INCORRECT;
  ELSEIF (NOT luser.is_active OR luser.is_deleted) THEN
    rlogon_result := LR_ACCOUNT_IS_DISABLED;
  ELSE
    rlogon_result := LR_OK;
  END IF;

  IF (rlogon_result = LR_OK) THEN
    PERFORM us.fn_set_logged_user_id(ruser_id);
  ELSE
    UPDATE us.users
    SET
      bad_logon_attempts = bad_logon_attempts + 1,
      date_last_bad_logon_attempt = lnow,
      date_lock = CASE WHEN (bad_logon_attempts + 1 >= MAX_BAD_LOGON_ATTEMPTS)
        AND (rlogon_result = LR_LOGIN_OR_PASSWOR_IS_INCORRECT)
        THEN lnow ELSE NULL END
    WHERE user_id = ruser_id;
  END IF;
END;
$$;


ALTER FUNCTION us.fn_logon(alogin df.t_string_short, apassword t_password, OUT rlogon_result df.t_tinyint_id, OUT ruser_id df.t_id) OWNER TO lt_admin;

--
-- Name: fn_set_logged_group_id(df.t_id); Type: FUNCTION; Schema: us; Owner: lt_admin
--

CREATE FUNCTION fn_set_logged_group_id(agroup_id df.t_id) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  lgroup_id df.t_id;
BEGIN
  DROP TABLE IF EXISTS tmp_logged_groups;

  SELECT G.group_id
  INTO lgroup_id
  FROM us.groups G
  WHERE G.group_id = agroup_id;

  IF (lgroup_id IS NULL) THEN
    RAISE EXCEPTION 'Group not exist';
  ELSE
    CREATE TEMPORARY TABLE tmp_logged_groups (group_id df.t_id NOT NULL);
    INSERT INTO tmp_logged_groups (group_id) VALUES (lgroup_id);
  END IF;
END;
$$;


ALTER FUNCTION us.fn_set_logged_group_id(agroup_id df.t_id) OWNER TO lt_admin;

--
-- Name: fn_set_logged_user_id(df.t_id); Type: FUNCTION; Schema: us; Owner: lt_admin
--

CREATE FUNCTION fn_set_logged_user_id(auser_id df.t_id) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  luser_id df.t_id;
BEGIN
  DROP TABLE IF EXISTS tmp_logged_users;

  SELECT U.user_id
  INTO luser_id
  FROM us.users U
  WHERE U.user_id = auser_id;

  IF (luser_id IS NULL) THEN
    RAISE EXCEPTION 'User not exist';
  ELSE
    CREATE TEMPORARY TABLE tmp_logged_users (user_id df.t_id NOT NULL);
    INSERT INTO tmp_logged_users (user_id) VALUES (auser_id);

    UPDATE us.users
    SET
      date_last_logon = df.fn_utc_timestamp(),
      bad_logon_attempts = 0
    WHERE user_id = auser_id;
  END IF;
END;
$$;


ALTER FUNCTION us.fn_set_logged_user_id(auser_id df.t_id) OWNER TO lt_admin;

--
-- Name: fn_timestamp_to_local_str(df.t_timestamp); Type: FUNCTION; Schema: us; Owner: lt_admin
--

CREATE FUNCTION fn_timestamp_to_local_str(avalue df.t_timestamp) RETURNS df.t_string_short
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (
    SELECT df.fn_timestamp_to_local_str(avalue, U.time_zone)
    FROM us.users U
    WHERE U.user_id = us.fn_get_logged_user_id());
END;
$$;


ALTER FUNCTION us.fn_timestamp_to_local_str(avalue df.t_timestamp) OWNER TO lt_admin;

--
-- Name: fn_timestamp_to_utc_timestamp(df.t_timestamp); Type: FUNCTION; Schema: us; Owner: lt_admin
--

CREATE FUNCTION fn_timestamp_to_utc_timestamp(avalue df.t_timestamp) RETURNS df.t_timestamp
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN (
    SELECT df.fn_timestamp_to_utc_timestamp(avalue, U.time_zone)
    FROM us.users U
    WHERE U.user_id = us.fn_get_logged_user_id());
END;
$$;


ALTER FUNCTION us.fn_timestamp_to_utc_timestamp(avalue df.t_timestamp) OWNER TO lt_admin;

--
-- Name: t_computers_bi(); Type: FUNCTION; Schema: us; Owner: lt_admin
--

CREATE FUNCTION t_computers_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.user_id = us.fn_get_logged_user_id();
  NEW.computer_id = df.fn_get_next_pk_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME,
    'user_id = ' || NEW.user_id);

  NEW.date_created = df.fn_utc_timestamp();

  RETURN NEW;
END;
$$;


ALTER FUNCTION us.t_computers_bi() OWNER TO lt_admin;

--
-- Name: t_users_bi(); Type: FUNCTION; Schema: us; Owner: lt_admin
--

CREATE FUNCTION t_users_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.bad_logon_attempts = 0;
  NEW.is_deleted = FALSE;
  NEW.date_created  = df.fn_utc_timestamp();

  RETURN NEW;
END;
$$;


ALTER FUNCTION us.t_users_bi() OWNER TO lt_admin;

SET search_path = wa, pg_catalog;

--
-- Name: t_activities_bi(); Type: FUNCTION; Schema: wa; Owner: lt_admin
--

CREATE FUNCTION t_activities_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  lnow df.t_timestamp;
BEGIN
  lnow = df.fn_utc_timestamp();

  NEW.owner_id = us.fn_get_logged_owner_id();
  NEW.user_id = us.fn_get_logged_user_id();
  NEW.activity_id = df.fn_get_next_pk_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME,
    'owner_id = ' || NEW.owner_id ||
      ' AND user_id = ' || NEW.user_id ||
      ' AND computer_id = ' || NEW.computer_id ||
      ' AND application_id = ' || NEW.application_id ||
      ' AND window_id = ' || NEW.window_id
  );

  IF NEW.date_from IS NULL THEN
    NEW.date_from = lnow;
  END IF;
  IF NEW.date_to IS NULL THEN
    NEW.date_to = lnow;
  END IF;

  NEW.date_created = lnow;

  RETURN NEW;
END;
$$;


ALTER FUNCTION wa.t_activities_bi() OWNER TO lt_admin;

--
-- Name: t_activities_bu(); Type: FUNCTION; Schema: wa; Owner: lt_admin
--

CREATE FUNCTION t_activities_bu() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.date_to IS NULL THEN
    NEW.date_to = df.fn_utc_timestamp();
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION wa.t_activities_bu() OWNER TO lt_admin;

--
-- Name: t_applications_bi(); Type: FUNCTION; Schema: wa; Owner: lt_admin
--

CREATE FUNCTION t_applications_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.owner_id = us.fn_get_logged_owner_id();
  NEW.application_id = df.fn_get_next_random_pk_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME, 'owner_id = ' || NEW.owner_id, 1000, 9999);

  NEW.date_created = df.fn_utc_timestamp();

  NEW.sys_application_id = df.fn_get_next_field_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME, 'sys_application_id');--!!owner_condition

  RETURN NEW;
END;
$$;


ALTER FUNCTION wa.t_applications_bi() OWNER TO lt_admin;

--
-- Name: t_windows_bi(); Type: FUNCTION; Schema: wa; Owner: lt_admin
--

CREATE FUNCTION t_windows_bi() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.owner_id = us.fn_get_logged_owner_id();
  NEW.window_id = df.fn_get_next_random_pk_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME,
    'owner_id = ' || NEW.owner_id ||
      ' AND application_id = ' ||  NEW.application_id,
    1000, 9999);

  NEW.date_created = df.fn_utc_timestamp();

  NEW.sys_window_id = df.fn_get_next_field_value(
    TG_TABLE_SCHEMA, TG_TABLE_NAME, 'sys_window_id');--!!owner_condition

  RETURN NEW;
END;
$$;


ALTER FUNCTION wa.t_windows_bi() OWNER TO lt_admin;

SET search_path = mn, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: mn; Owner: lt_admin
--

CREATE TABLE accounts (
    group_id df.t_id NOT NULL,
    user_id df.t_id NOT NULL,
    account_id df.t_id NOT NULL,
    currency_id df.t_id NOT NULL,
    name df.t_string_short NOT NULL
);


ALTER TABLE accounts OWNER TO lt_admin;

--
-- Name: categories; Type: TABLE; Schema: mn; Owner: lt_admin
--

CREATE TABLE categories (
    group_id df.t_id NOT NULL,
    user_id df.t_id NOT NULL,
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
    group_id df.t_id NOT NULL,
    user_id df.t_id NOT NULL,
    currency_id df.t_id NOT NULL,
    name df.t_string_short NOT NULL
);


ALTER TABLE currencies OWNER TO lt_admin;

--
-- Name: descriptions; Type: TABLE; Schema: mn; Owner: lt_admin
--

CREATE TABLE descriptions (
    group_id df.t_id NOT NULL,
    user_id df.t_id NOT NULL,
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
    group_id df.t_id NOT NULL,
    user_id df.t_id NOT NULL,
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
    group_id df.t_id NOT NULL,
    user_id df.t_id NOT NULL,
    transaction_id df.t_id NOT NULL,
    category_id df.t_id NOT NULL,
    description_id df.t_id,
    is_real df.t_boolean NOT NULL,
    date_transaction df.t_timestamp NOT NULL,
    lno df.t_integer NOT NULL,
    is_deleted df.t_boolean NOT NULL,
    date_created df.t_timestamp NOT NULL,
    sys_transaction_id df.t_id NOT NULL
);


ALTER TABLE transactions OWNER TO lt_admin;

SET search_path = pm, pg_catalog;

--
-- Name: activities; Type: TABLE; Schema: pm; Owner: lt_admin
--

CREATE TABLE activities (
    owner_id df.t_id NOT NULL,
    activity_id df.t_id NOT NULL,
    task_id df.t_id NOT NULL,
    created_by df.t_id NOT NULL,
    date_from df.t_timestamp NOT NULL,
    date_to df.t_timestamp NOT NULL,
    real_time df.t_interval NOT NULL,
    message df.t_text NOT NULL,
    is_deleted df.t_boolean NOT NULL,
    date_created df.t_timestamp NOT NULL,
    sys_activity_id df.t_id NOT NULL
);


ALTER TABLE activities OWNER TO lt_admin;

--
-- Name: processed_states; Type: TABLE; Schema: pm; Owner: lt_admin
--

CREATE TABLE processed_states (
    processed_state_id df.t_tinyint_id NOT NULL,
    name df.t_string_short NOT NULL
);


ALTER TABLE processed_states OWNER TO lt_admin;

--
-- Name: task_messages; Type: TABLE; Schema: pm; Owner: lt_admin
--

CREATE TABLE task_messages (
    owner_id df.t_id NOT NULL,
    message_id df.t_id NOT NULL,
    task_id df.t_id NOT NULL,
    created_by df.t_id NOT NULL,
    message df.t_text NOT NULL,
    is_deleted df.t_boolean NOT NULL,
    date_created df.t_timestamp NOT NULL,
    sys_message_id df.t_id NOT NULL
);


ALTER TABLE task_messages OWNER TO lt_admin;

--
-- Name: task_users; Type: TABLE; Schema: pm; Owner: lt_admin
--

CREATE TABLE task_users (
    owner_id df.t_id NOT NULL,
    task_id df.t_id NOT NULL,
    user_id df.t_id NOT NULL,
    date_created df.t_timestamp NOT NULL
);


ALTER TABLE task_users OWNER TO lt_admin;

--
-- Name: tasks; Type: TABLE; Schema: pm; Owner: lt_admin
--

CREATE TABLE tasks (
    owner_id df.t_id NOT NULL,
    task_id df.t_id NOT NULL,
    parent_task_id df.t_id,
    created_by df.t_id NOT NULL,
    title df.t_string_large NOT NULL,
    description df.t_text,
    processed_state_id df.t_tinyint_id NOT NULL,
    is_deleted df.t_boolean NOT NULL,
    date_created df.t_timestamp NOT NULL,
    sys_task_id df.t_id NOT NULL,
    root_path df.t_string_short NOT NULL
);


ALTER TABLE tasks OWNER TO lt_admin;

SET search_path = us, pg_catalog;

--
-- Name: computers; Type: TABLE; Schema: us; Owner: lt_admin
--

CREATE TABLE computers (
    user_id df.t_id NOT NULL,
    computer_id df.t_id NOT NULL,
    name df.t_string_large NOT NULL,
    short_name df.t_string_short,
    date_created df.t_timestamp NOT NULL
);


ALTER TABLE computers OWNER TO lt_admin;

--
-- Name: group_users; Type: TABLE; Schema: us; Owner: lt_admin
--

CREATE TABLE group_users (
    group_id df.t_id NOT NULL,
    user_id df.t_id NOT NULL
);


ALTER TABLE group_users OWNER TO lt_admin;

--
-- Name: groups; Type: TABLE; Schema: us; Owner: lt_admin
--

CREATE TABLE groups (
    group_id df.t_id NOT NULL,
    name df.t_string_short NOT NULL
);


ALTER TABLE groups OWNER TO lt_admin;

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
    date_last_logon df.t_timestamp,
    bad_logon_attempts df.t_integer NOT NULL,
    is_active df.t_boolean NOT NULL,
    time_zone df.t_string_short,
    date_last_bad_logon_attempt df.t_timestamp
);


ALTER TABLE users OWNER TO lt_admin;

--
-- Name: vw_logged_groups; Type: VIEW; Schema: us; Owner: lt_admin
--

CREATE VIEW vw_logged_groups AS
 SELECT fn_get_logged_group_id() AS gropu_id;


ALTER TABLE vw_logged_groups OWNER TO lt_admin;

--
-- Name: vw_logged_users; Type: VIEW; Schema: us; Owner: lt_admin
--

CREATE VIEW vw_logged_users AS
 SELECT fn_get_logged_user_id() AS user_id;


ALTER TABLE vw_logged_users OWNER TO lt_admin;

SET search_path = wa, pg_catalog;

--
-- Name: activities; Type: TABLE; Schema: wa; Owner: lt_admin
--

CREATE TABLE activities (
    owner_id df.t_id NOT NULL,
    user_id df.t_id NOT NULL,
    computer_id df.t_id NOT NULL,
    application_id df.t_id NOT NULL,
    window_id df.t_id NOT NULL,
    activity_id df.t_id NOT NULL,
    date_from df.t_timestamp NOT NULL,
    date_to df.t_timestamp NOT NULL,
    date_created df.t_timestamp NOT NULL
);


ALTER TABLE activities OWNER TO lt_admin;

--
-- Name: applications; Type: TABLE; Schema: wa; Owner: lt_admin
--

CREATE TABLE applications (
    owner_id df.t_id NOT NULL,
    application_id df.t_id NOT NULL,
    file_name df.t_string_large NOT NULL,
    date_created df.t_timestamp NOT NULL,
    sys_application_id df.t_id NOT NULL
);


ALTER TABLE applications OWNER TO lt_admin;

--
-- Name: windows; Type: TABLE; Schema: wa; Owner: lt_admin
--

CREATE TABLE windows (
    owner_id df.t_id NOT NULL,
    application_id df.t_id NOT NULL,
    window_id df.t_id NOT NULL,
    title df.t_string_large NOT NULL,
    date_created df.t_timestamp NOT NULL,
    sys_window_id df.t_id NOT NULL
);


ALTER TABLE windows OWNER TO lt_admin;

SET search_path = mn, pg_catalog;

--
-- Name: accounts pk_accounts; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT pk_accounts PRIMARY KEY (group_id, user_id, account_id);


--
-- Name: categories pk_categories; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT pk_categories PRIMARY KEY (group_id, user_id, category_id);


--
-- Name: currencies pk_currencies; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY currencies
    ADD CONSTRAINT pk_currencies PRIMARY KEY (group_id, user_id, currency_id);


--
-- Name: descriptions pk_descriptions; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY descriptions
    ADD CONSTRAINT pk_descriptions PRIMARY KEY (group_id, user_id, description_id);


--
-- Name: operation_types pk_operation_types; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operation_types
    ADD CONSTRAINT pk_operation_types PRIMARY KEY (operation_type_id);


--
-- Name: operations pk_operations; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT pk_operations PRIMARY KEY (group_id, user_id, transaction_id, operation_type_id);


--
-- Name: transactions pk_transactions; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT pk_transactions PRIMARY KEY (group_id, user_id, transaction_id);


--
-- Name: accounts uq_accounts__name; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT uq_accounts__name UNIQUE (group_id, user_id, name);


--
-- Name: categories uq_categories__name; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT uq_categories__name UNIQUE (group_id, user_id, name);


--
-- Name: currencies uq_currencies__name; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY currencies
    ADD CONSTRAINT uq_currencies__name UNIQUE (group_id, user_id, name);


--
-- Name: descriptions uq_descriptions__description; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY descriptions
    ADD CONSTRAINT uq_descriptions__description UNIQUE (user_id, description);


--
-- Name: operations uq_operations__acount_id; Type: CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT uq_operations__acount_id UNIQUE (group_id, user_id, transaction_id, account_id);


SET search_path = pm, pg_catalog;

--
-- Name: activities pk_activities; Type: CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT pk_activities PRIMARY KEY (owner_id, activity_id);


--
-- Name: processed_states pk_processed_states; Type: CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY processed_states
    ADD CONSTRAINT pk_processed_states PRIMARY KEY (processed_state_id);


--
-- Name: task_messages pk_task_messages; Type: CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY task_messages
    ADD CONSTRAINT pk_task_messages PRIMARY KEY (owner_id, message_id);


--
-- Name: task_users pk_task_users; Type: CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY task_users
    ADD CONSTRAINT pk_task_users PRIMARY KEY (owner_id, task_id, user_id);


--
-- Name: tasks pk_tasks; Type: CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT pk_tasks PRIMARY KEY (owner_id, task_id);


SET search_path = us, pg_catalog;

--
-- Name: computers pk_computers; Type: CONSTRAINT; Schema: us; Owner: lt_admin
--

ALTER TABLE ONLY computers
    ADD CONSTRAINT pk_computers PRIMARY KEY (user_id, computer_id);


--
-- Name: group_users pk_group_users; Type: CONSTRAINT; Schema: us; Owner: lt_admin
--

ALTER TABLE ONLY group_users
    ADD CONSTRAINT pk_group_users PRIMARY KEY (group_id, user_id);


--
-- Name: groups pk_groups; Type: CONSTRAINT; Schema: us; Owner: lt_admin
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT pk_groups PRIMARY KEY (group_id);


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


SET search_path = wa, pg_catalog;

--
-- Name: activities pk_activities; Type: CONSTRAINT; Schema: wa; Owner: lt_admin
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT pk_activities PRIMARY KEY (owner_id, user_id, computer_id, application_id, window_id, activity_id);


--
-- Name: applications pk_applications; Type: CONSTRAINT; Schema: wa; Owner: lt_admin
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT pk_applications PRIMARY KEY (owner_id, application_id);


--
-- Name: windows pk_windows; Type: CONSTRAINT; Schema: wa; Owner: lt_admin
--

ALTER TABLE ONLY windows
    ADD CONSTRAINT pk_windows PRIMARY KEY (owner_id, application_id, window_id);


--
-- Name: activities uq_activities; Type: CONSTRAINT; Schema: wa; Owner: lt_admin
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT uq_activities UNIQUE (owner_id, user_id, computer_id, date_from, date_to);


SET search_path = mn, pg_catalog;

--
-- Name: accounts t_accounts_bi; Type: TRIGGER; Schema: mn; Owner: lt_admin
--

CREATE TRIGGER t_accounts_bi BEFORE INSERT ON accounts FOR EACH ROW EXECUTE PROCEDURE t_accounts_bi();


--
-- Name: categories t_categories_bi; Type: TRIGGER; Schema: mn; Owner: lt_admin
--

CREATE TRIGGER t_categories_bi BEFORE INSERT ON categories FOR EACH ROW EXECUTE PROCEDURE t_categories_bi();


--
-- Name: currencies t_currencies_bi; Type: TRIGGER; Schema: mn; Owner: lt_admin
--

CREATE TRIGGER t_currencies_bi BEFORE INSERT ON currencies FOR EACH ROW EXECUTE PROCEDURE t_currencies_bi();


--
-- Name: descriptions t_descriptions_bi; Type: TRIGGER; Schema: mn; Owner: lt_admin
--

CREATE TRIGGER t_descriptions_bi BEFORE INSERT ON descriptions FOR EACH ROW EXECUTE PROCEDURE t_descriptions_bi();


--
-- Name: operations t_operations_bi; Type: TRIGGER; Schema: mn; Owner: lt_admin
--

CREATE TRIGGER t_operations_bi BEFORE INSERT ON operations FOR EACH ROW EXECUTE PROCEDURE t_operations_bi();


--
-- Name: transactions t_transactions_bi; Type: TRIGGER; Schema: mn; Owner: lt_admin
--

CREATE TRIGGER t_transactions_bi BEFORE INSERT ON transactions FOR EACH ROW EXECUTE PROCEDURE t_transactions_bi();


SET search_path = pm, pg_catalog;

--
-- Name: activities t_activities_bi; Type: TRIGGER; Schema: pm; Owner: lt_admin
--

CREATE TRIGGER t_activities_bi BEFORE INSERT ON activities FOR EACH ROW EXECUTE PROCEDURE t_activities_bi();


--
-- Name: activities t_activities_bu; Type: TRIGGER; Schema: pm; Owner: lt_admin
--

CREATE TRIGGER t_activities_bu BEFORE UPDATE ON activities FOR EACH ROW EXECUTE PROCEDURE t_activities_bu();


--
-- Name: task_messages t_task_messages_bi; Type: TRIGGER; Schema: pm; Owner: lt_admin
--

CREATE TRIGGER t_task_messages_bi BEFORE INSERT ON task_messages FOR EACH ROW EXECUTE PROCEDURE t_task_messages_bi();


--
-- Name: task_users t_task_users_bi; Type: TRIGGER; Schema: pm; Owner: lt_admin
--

CREATE TRIGGER t_task_users_bi BEFORE INSERT ON task_users FOR EACH ROW EXECUTE PROCEDURE t_task_users_bi();


--
-- Name: tasks t_tasks_au; Type: TRIGGER; Schema: pm; Owner: lt_admin
--

CREATE TRIGGER t_tasks_au AFTER INSERT OR UPDATE ON tasks FOR EACH ROW EXECUTE PROCEDURE t_tasks_au();


--
-- Name: tasks t_tasks_bi; Type: TRIGGER; Schema: pm; Owner: lt_admin
--

CREATE TRIGGER t_tasks_bi BEFORE INSERT ON tasks FOR EACH ROW EXECUTE PROCEDURE t_tasks_bi();


--
-- Name: tasks t_tasks_bu; Type: TRIGGER; Schema: pm; Owner: lt_admin
--

CREATE TRIGGER t_tasks_bu BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE PROCEDURE t_tasks_bu();


SET search_path = us, pg_catalog;

--
-- Name: computers t_computers_bi; Type: TRIGGER; Schema: us; Owner: lt_admin
--

CREATE TRIGGER t_computers_bi BEFORE INSERT ON computers FOR EACH ROW EXECUTE PROCEDURE t_computers_bi();


--
-- Name: users t_users_bi; Type: TRIGGER; Schema: us; Owner: lt_admin
--

CREATE TRIGGER t_users_bi BEFORE INSERT ON users FOR EACH ROW EXECUTE PROCEDURE t_users_bi();


SET search_path = wa, pg_catalog;

--
-- Name: windows bi_windows_bi; Type: TRIGGER; Schema: wa; Owner: lt_admin
--

CREATE TRIGGER bi_windows_bi BEFORE INSERT ON windows FOR EACH ROW EXECUTE PROCEDURE t_windows_bi();


--
-- Name: activities t_activities_bi; Type: TRIGGER; Schema: wa; Owner: lt_admin
--

CREATE TRIGGER t_activities_bi BEFORE INSERT ON activities FOR EACH ROW EXECUTE PROCEDURE t_activities_bi();


--
-- Name: activities t_activities_bu; Type: TRIGGER; Schema: wa; Owner: lt_admin
--

CREATE TRIGGER t_activities_bu BEFORE UPDATE ON activities FOR EACH ROW EXECUTE PROCEDURE t_activities_bu();


--
-- Name: applications t_applications_bi; Type: TRIGGER; Schema: wa; Owner: lt_admin
--

CREATE TRIGGER t_applications_bi BEFORE INSERT ON applications FOR EACH ROW EXECUTE PROCEDURE t_applications_bi();


SET search_path = mn, pg_catalog;

--
-- Name: accounts fk_accounts__currencies; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT fk_accounts__currencies FOREIGN KEY (group_id, user_id, currency_id) REFERENCES currencies(group_id, user_id, currency_id);


--
-- Name: accounts fk_accounts__groups; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT fk_accounts__groups FOREIGN KEY (group_id) REFERENCES us.groups(group_id);


--
-- Name: accounts fk_accounts__users; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT fk_accounts__users FOREIGN KEY (user_id) REFERENCES us.users(user_id);


--
-- Name: categories fk_categories__categories; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT fk_categories__categories FOREIGN KEY (group_id, user_id, parent_id) REFERENCES categories(group_id, user_id, category_id);


--
-- Name: categories fk_categories__groups; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT fk_categories__groups FOREIGN KEY (group_id) REFERENCES us.groups(group_id);


--
-- Name: categories fk_categories__users; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT fk_categories__users FOREIGN KEY (user_id) REFERENCES us.users(user_id);


--
-- Name: currencies fk_currencies__groups; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY currencies
    ADD CONSTRAINT fk_currencies__groups FOREIGN KEY (group_id) REFERENCES us.groups(group_id);


--
-- Name: currencies fk_currencies__users; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY currencies
    ADD CONSTRAINT fk_currencies__users FOREIGN KEY (user_id) REFERENCES us.users(user_id);


--
-- Name: descriptions fk_descriptions__groups; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY descriptions
    ADD CONSTRAINT fk_descriptions__groups FOREIGN KEY (group_id) REFERENCES us.groups(group_id);


--
-- Name: descriptions fk_descriptions__users; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY descriptions
    ADD CONSTRAINT fk_descriptions__users FOREIGN KEY (user_id) REFERENCES us.users(user_id);


--
-- Name: operations fk_operations__accounts; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT fk_operations__accounts FOREIGN KEY (group_id, user_id, account_id) REFERENCES accounts(group_id, user_id, account_id);


--
-- Name: operations fk_operations__groups; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT fk_operations__groups FOREIGN KEY (group_id) REFERENCES us.groups(group_id);


--
-- Name: operations fk_operations__operation_types; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT fk_operations__operation_types FOREIGN KEY (operation_type_id) REFERENCES operation_types(operation_type_id);


--
-- Name: operations fk_operations__transactions; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT fk_operations__transactions FOREIGN KEY (group_id, user_id, transaction_id) REFERENCES transactions(group_id, user_id, transaction_id);


--
-- Name: operations fk_operations__users; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT fk_operations__users FOREIGN KEY (user_id) REFERENCES us.users(user_id);


--
-- Name: transactions fk_transactions__categories; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT fk_transactions__categories FOREIGN KEY (group_id, user_id, category_id) REFERENCES categories(group_id, user_id, category_id);


--
-- Name: transactions fk_transactions__descriptions; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT fk_transactions__descriptions FOREIGN KEY (group_id, user_id, description_id) REFERENCES descriptions(group_id, user_id, description_id);


--
-- Name: transactions fk_transactions__groups; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT fk_transactions__groups FOREIGN KEY (group_id) REFERENCES us.groups(group_id);


--
-- Name: transactions fk_transactions__users; Type: FK CONSTRAINT; Schema: mn; Owner: lt_admin
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT fk_transactions__users FOREIGN KEY (user_id) REFERENCES us.users(user_id);


SET search_path = pm, pg_catalog;

--
-- Name: activities fk_activities__tasks; Type: FK CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT fk_activities__tasks FOREIGN KEY (owner_id, task_id) REFERENCES tasks(owner_id, task_id);


--
-- Name: activities fk_activities__us_users; Type: FK CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT fk_activities__us_users FOREIGN KEY (created_by) REFERENCES us.users(user_id);


--
-- Name: task_messages fk_task_messages__tasks; Type: FK CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY task_messages
    ADD CONSTRAINT fk_task_messages__tasks FOREIGN KEY (owner_id, task_id) REFERENCES tasks(owner_id, task_id);


--
-- Name: task_messages fk_task_messages__users; Type: FK CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY task_messages
    ADD CONSTRAINT fk_task_messages__users FOREIGN KEY (created_by) REFERENCES us.users(user_id);


--
-- Name: task_users fk_task_users__tasks; Type: FK CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY task_users
    ADD CONSTRAINT fk_task_users__tasks FOREIGN KEY (owner_id, task_id) REFERENCES tasks(owner_id, task_id);


--
-- Name: task_users fk_task_users__users; Type: FK CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY task_users
    ADD CONSTRAINT fk_task_users__users FOREIGN KEY (user_id) REFERENCES us.users(user_id);


--
-- Name: tasks fk_tasks__processed_states; Type: FK CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT fk_tasks__processed_states FOREIGN KEY (processed_state_id) REFERENCES processed_states(processed_state_id);


--
-- Name: tasks fk_tasks__tasks; Type: FK CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT fk_tasks__tasks FOREIGN KEY (owner_id, parent_task_id) REFERENCES tasks(owner_id, task_id);


--
-- Name: tasks fk_tasks__users__created_by; Type: FK CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT fk_tasks__users__created_by FOREIGN KEY (created_by) REFERENCES us.users(user_id);


--
-- Name: tasks fk_tasks__users__owner_id; Type: FK CONSTRAINT; Schema: pm; Owner: lt_admin
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT fk_tasks__users__owner_id FOREIGN KEY (owner_id) REFERENCES us.users(user_id);


SET search_path = us, pg_catalog;

--
-- Name: computers fk_computers__users; Type: FK CONSTRAINT; Schema: us; Owner: lt_admin
--

ALTER TABLE ONLY computers
    ADD CONSTRAINT fk_computers__users FOREIGN KEY (user_id) REFERENCES users(user_id);


--
-- Name: group_users fk_group_users__groups; Type: FK CONSTRAINT; Schema: us; Owner: lt_admin
--

ALTER TABLE ONLY group_users
    ADD CONSTRAINT fk_group_users__groups FOREIGN KEY (group_id) REFERENCES groups(group_id);


--
-- Name: group_users fk_group_users__users; Type: FK CONSTRAINT; Schema: us; Owner: lt_admin
--

ALTER TABLE ONLY group_users
    ADD CONSTRAINT fk_group_users__users FOREIGN KEY (user_id) REFERENCES users(user_id);


SET search_path = wa, pg_catalog;

--
-- Name: activities fk_activities__computers; Type: FK CONSTRAINT; Schema: wa; Owner: lt_admin
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT fk_activities__computers FOREIGN KEY (user_id, computer_id) REFERENCES us.computers(user_id, computer_id);


--
-- Name: activities fk_activities__windows; Type: FK CONSTRAINT; Schema: wa; Owner: lt_admin
--

ALTER TABLE ONLY activities
    ADD CONSTRAINT fk_activities__windows FOREIGN KEY (owner_id, application_id, window_id) REFERENCES windows(owner_id, application_id, window_id);


--
-- Name: applications fk_applications__users; Type: FK CONSTRAINT; Schema: wa; Owner: lt_admin
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT fk_applications__users FOREIGN KEY (owner_id) REFERENCES us.users(user_id);


--
-- Name: windows fk_windows__applications; Type: FK CONSTRAINT; Schema: wa; Owner: lt_admin
--

ALTER TABLE ONLY windows
    ADD CONSTRAINT fk_windows__applications FOREIGN KEY (owner_id, application_id) REFERENCES applications(owner_id, application_id);


--
-- PostgreSQL database dump complete
--

