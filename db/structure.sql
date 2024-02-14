SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: add_account_entry(integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_account_entry(account_id integer, value integer, description character varying) RETURNS TABLE(success boolean, message character varying, current_balance integer, current_limit integer)
    LANGUAGE plpgsql
    AS $$
        declare
          current_credit_limit integer;
          current_balance integer;
          new_balance integer;
        begin

          select credit_limit, balance
            into current_credit_limit, current_balance
            from accounts
            where id = account_id
            for update;

          new_balance = current_balance + value;

          if new_balance < current_credit_limit * -1 then
            return query
              select s, em, cb, cl
                from (
                  values (false, 'credit_limit_exceeded'::VARCHAR, current_balance, current_credit_limit)
                  ) s(s, em, cb, cl);
            return;
          end if;

          update accounts
            set balance = new_balance,
                updated_at = now()
            where id = account_id;

          insert into account_entries (value, description, account_id, created_at, updated_at)
            values (value, description, account_id, now(), now());

          return query
            select s, m, nb, cl
              from (
                values (true, 'ok'::VARCHAR, new_balance, current_credit_limit)
              ) s(s, m, nb, cl);
        end;
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_entries (
    id bigint NOT NULL,
    value integer NOT NULL,
    description text,
    account_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: account_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_entries_id_seq OWNED BY public.account_entries.id;


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id bigint NOT NULL,
    balance integer DEFAULT 0 NOT NULL,
    credit_limit integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: account_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_entries ALTER COLUMN id SET DEFAULT nextval('public.account_entries_id_seq'::regclass);


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: account_entries account_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_entries
    ADD CONSTRAINT account_entries_pkey PRIMARY KEY (id);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: index_account_entries_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_account_entries_on_account_id ON public.account_entries USING btree (account_id);


--
-- Name: account_entries fk_rails_f205c9af50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_entries
    ADD CONSTRAINT fk_rails_f205c9af50 FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20240211202540'),
('20240211201944'),
('20240211201746');

