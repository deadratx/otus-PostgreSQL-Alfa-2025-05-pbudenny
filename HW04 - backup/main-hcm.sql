--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Ubuntu 17.5-1.pgdg24.04+1)
-- Dumped by pg_dump version 17.5 (Ubuntu 17.5-1.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hcm; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE hcm WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C.UTF-8';


ALTER DATABASE hcm OWNER TO postgres;

\connect hcm

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    id integer NOT NULL,
    fio character(200)
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- Name: employee_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employee_id_seq OWNER TO postgres;

--
-- Name: employee_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_id_seq OWNED BY public.employee.id;


--
-- Name: employee id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee ALTER COLUMN id SET DEFAULT nextval('public.employee_id_seq'::regclass);


--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee (id, fio) FROM stdin;
1	John Dow                                                                                                                                                                                                
2	John Dow                                                                                                                                                                                                
3	John Dow                                                                                                                                                                                                
4	John Dow                                                                                                                                                                                                
5	John Dow                                                                                                                                                                                                
6	John Dow                                                                                                                                                                                                
7	John Dow                                                                                                                                                                                                
8	John Dow                                                                                                                                                                                                
9	John Dow                                                                                                                                                                                                
10	John Dow                                                                                                                                                                                                
11	John Dow                                                                                                                                                                                                
12	John Dow                                                                                                                                                                                                
13	John Dow                                                                                                                                                                                                
14	John Dow                                                                                                                                                                                                
15	John Dow                                                                                                                                                                                                
16	John Dow                                                                                                                                                                                                
17	John Dow                                                                                                                                                                                                
18	John Dow                                                                                                                                                                                                
19	John Dow                                                                                                                                                                                                
20	John Dow                                                                                                                                                                                                
21	John Dow                                                                                                                                                                                                
22	John Dow                                                                                                                                                                                                
23	John Dow                                                                                                                                                                                                
24	John Dow                                                                                                                                                                                                
25	John Dow                                                                                                                                                                                                
26	John Dow                                                                                                                                                                                                
27	John Dow                                                                                                                                                                                                
28	John Dow                                                                                                                                                                                                
29	John Dow                                                                                                                                                                                                
30	John Dow                                                                                                                                                                                                
31	John Dow                                                                                                                                                                                                
32	John Dow                                                                                                                                                                                                
33	John Dow                                                                                                                                                                                                
34	John Dow                                                                                                                                                                                                
35	John Dow                                                                                                                                                                                                
36	John Dow                                                                                                                                                                                                
37	John Dow                                                                                                                                                                                                
38	John Dow                                                                                                                                                                                                
39	John Dow                                                                                                                                                                                                
40	John Dow                                                                                                                                                                                                
41	John Dow                                                                                                                                                                                                
42	John Dow                                                                                                                                                                                                
43	John Dow                                                                                                                                                                                                
44	John Dow                                                                                                                                                                                                
45	John Dow                                                                                                                                                                                                
46	John Dow                                                                                                                                                                                                
47	John Dow                                                                                                                                                                                                
48	John Dow                                                                                                                                                                                                
49	John Dow                                                                                                                                                                                                
50	John Dow                                                                                                                                                                                                
51	John Dow                                                                                                                                                                                                
52	John Dow                                                                                                                                                                                                
53	John Dow                                                                                                                                                                                                
54	John Dow                                                                                                                                                                                                
55	John Dow                                                                                                                                                                                                
56	John Dow                                                                                                                                                                                                
57	John Dow                                                                                                                                                                                                
58	John Dow                                                                                                                                                                                                
59	John Dow                                                                                                                                                                                                
60	John Dow                                                                                                                                                                                                
61	John Dow                                                                                                                                                                                                
62	John Dow                                                                                                                                                                                                
63	John Dow                                                                                                                                                                                                
64	John Dow                                                                                                                                                                                                
65	John Dow                                                                                                                                                                                                
66	John Dow                                                                                                                                                                                                
67	John Dow                                                                                                                                                                                                
68	John Dow                                                                                                                                                                                                
69	John Dow                                                                                                                                                                                                
70	John Dow                                                                                                                                                                                                
71	John Dow                                                                                                                                                                                                
72	John Dow                                                                                                                                                                                                
73	John Dow                                                                                                                                                                                                
74	John Dow                                                                                                                                                                                                
75	John Dow                                                                                                                                                                                                
76	John Dow                                                                                                                                                                                                
77	John Dow                                                                                                                                                                                                
78	John Dow                                                                                                                                                                                                
79	John Dow                                                                                                                                                                                                
80	John Dow                                                                                                                                                                                                
81	John Dow                                                                                                                                                                                                
82	John Dow                                                                                                                                                                                                
83	John Dow                                                                                                                                                                                                
84	John Dow                                                                                                                                                                                                
85	John Dow                                                                                                                                                                                                
86	John Dow                                                                                                                                                                                                
87	John Dow                                                                                                                                                                                                
88	John Dow                                                                                                                                                                                                
89	John Dow                                                                                                                                                                                                
90	John Dow                                                                                                                                                                                                
91	John Dow                                                                                                                                                                                                
92	John Dow                                                                                                                                                                                                
93	John Dow                                                                                                                                                                                                
94	John Dow                                                                                                                                                                                                
95	John Dow                                                                                                                                                                                                
96	John Dow                                                                                                                                                                                                
97	John Dow                                                                                                                                                                                                
98	John Dow                                                                                                                                                                                                
99	John Dow                                                                                                                                                                                                
100	John Dow                                                                                                                                                                                                
\.


--
-- Name: employee_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_id_seq', 100, true);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

