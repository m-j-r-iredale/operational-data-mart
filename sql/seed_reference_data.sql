-- Reference / demonstration data
-- All example people and values below are fictional.

INSERT INTO dim_date (
    date_key, full_date, day_name,
    day_of_week, day_of_month, day_of_year,
    week_number, month_number, month_name,
    quarter_number, year_number
)
SELECT
    TO_CHAR(date_base, 'YYYYMMDD')::INTEGER AS date_key,
    date_base AS full_date,
    TRIM(TO_CHAR(date_base, 'Day')) AS day_name,
    EXTRACT(ISODOW FROM date_base)::SMALLINT AS day_of_week,
    EXTRACT(DAY FROM date_base)::SMALLINT AS day_of_month,
    EXTRACT(DOY FROM date_base)::SMALLINT AS day_of_year,
    EXTRACT(WEEK FROM date_base)::SMALLINT AS week_number,
    EXTRACT(MONTH FROM date_base)::SMALLINT AS month_number,
    TRIM(TO_CHAR(date_base, 'Month')) AS month_name,
    EXTRACT(QUARTER FROM date_base)::SMALLINT AS quarter_number,
    EXTRACT(ISOYEAR FROM date_base)::SMALLINT AS year_number
FROM GENERATE_SERIES(
    '2020-01-01'::DATE,
    '2030-12-31'::DATE,
    INTERVAL '1 day'
) AS date_base;

INSERT INTO dim_agent (
    agent_id, agent_name, manager_name,
    status, grade, date_hire, date_left
)
VALUES
    ('AB', 'Alan Box', 'Matt', 'FTC', 'A', TO_DATE('29/09/1992', 'DD/MM/YYYY'), NULL),
    ('CD', 'Caroline Dumond', 'Matt', 'FTC', 'A', TO_DATE('30/09/1992', 'DD/MM/YYYY'), NULL),
    ('EF', 'Ent Fond', 'Matt', 'FTC', 'A', TO_DATE('01/10/1992', 'DD/MM/YYYY'), NULL),
    ('GH', 'Gif Hello', 'Matt', 'FTC', 'D', TO_DATE('02/10/1992', 'DD/MM/YYYY'), NULL),
    ('JK', 'Jay Kay', 'Matt', 'FTC', 'C', TO_DATE('03/10/1992', 'DD/MM/YYYY'), NULL),
    ('LM', 'Lyon Matt', 'Matt', 'FTC', 'C', TO_DATE('04/10/1992', 'DD/MM/YYYY'), NULL),
    ('NP', 'Nick Pimm', 'Matt', 'Temp', 'C', TO_DATE('05/10/1992', 'DD/MM/YYYY'), NULL),
    ('QR', 'Quentin Rochester', 'Sara', 'Perm', 'B', TO_DATE('06/10/1992', 'DD/MM/YYYY'), NULL),
    ('ST', 'Sara Tomboli', 'Sara', 'Perm', 'B', TO_DATE('07/10/1992', 'DD/MM/YYYY'), NULL),
    ('VW', 'Volks Wagon', 'Sara', 'Perm', 'B', TO_DATE('08/10/1992', 'DD/MM/YYYY'), NULL);

INSERT INTO dim_task_type (task_type)
VALUES
    ('Change of Signatory'),
    ('Change of Contact'),
    ('Change of Signatory/Change of Contact'),
    ('Closed Account'),
    ('Business Card'),
    ('Business Card Replacement'),
    ('Misc'),
    ('Audit Paper'),
    ('Audit Portal'),
    ('2nd/Online Users'),
    ('Bounce Back'),
    ('Gone Away'),
    ('Deceased'),
    ('Corrections'),
    ('Migration Issues'),
    ('QA Process'),
    ('Telephone Passwords');