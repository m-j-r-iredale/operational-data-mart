-- Operational Data Mart Schema
-- PostgreSQL

-- ============================================================
-- Dimensions
-- ============================================================

CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    day_of_week SMALLINT NOT NULL,
    day_of_month SMALLINT NOT NULL,
    day_of_year SMALLINT NOT NULL,
    week_number SMALLINT NOT NULL,
    month_number SMALLINT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter_number SMALLINT NOT NULL,
    year_number SMALLINT NOT NULL
);

CREATE TABLE dim_agent (
    agent_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agent_id VARCHAR(50) NOT NULL UNIQUE,
    agent_name VARCHAR(50) NOT NULL,
    manager_name VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    grade VARCHAR(2) NOT NULL,
    date_hire DATE NOT NULL,
    date_left DATE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_task_type (
    task_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_type TEXT NOT NULL UNIQUE,
    task_category VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_organisation (
    organisation_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    organisation_name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_customer (
    customer_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE dim_account (
    account_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_number TEXT NOT NULL UNIQUE,
    account_type VARCHAR(20),
    organisation_name VARCHAR(100)
);

-- ============================================================
-- Central fact table
-- ============================================================

CREATE TABLE fact_admin (
    transaction_key INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_id TEXT NOT NULL UNIQUE,
    date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    date_start_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    date_complete_key INTEGER REFERENCES dim_date(date_key),
    organisation_key INTEGER REFERENCES dim_organisation(organisation_key),
    source_organisation_name TEXT NOT NULL,
    customer_name TEXT,
    task_key INTEGER NOT NULL REFERENCES dim_task_type(task_key),
    task_status TEXT NOT NULL,
    days_to_complete INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- Bridge tables
-- ============================================================

CREATE TABLE bridge_admin_agent (
    transaction_key INTEGER NOT NULL,
    agent_key INTEGER NOT NULL,
    agent_role VARCHAR(30) NOT NULL,
    CONSTRAINT pk_bridge_admin_agent
        PRIMARY KEY (transaction_key, agent_role),
    CONSTRAINT fk_bridge_admin_agent_transaction
        FOREIGN KEY (transaction_key)
        REFERENCES fact_admin(transaction_key),
    CONSTRAINT fk_bridge_admin_agent_agent
        FOREIGN KEY (agent_key)
        REFERENCES dim_agent(agent_key),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE bridge_admin_account (
    transaction_key INTEGER NOT NULL,
    account_key INTEGER NOT NULL,
    CONSTRAINT pk_bridge_admin_account
        PRIMARY KEY (transaction_key, account_key),
    CONSTRAINT fk_bridge_admin_account_transaction
        FOREIGN KEY (transaction_key)
        REFERENCES fact_admin(transaction_key),
    CONSTRAINT fk_bridge_admin_account_account
        FOREIGN KEY (account_key)
        REFERENCES dim_account(account_key),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- One-to-one fact extension tables
-- ============================================================

CREATE TABLE ext_fact_admin_bcards (
    transaction_key INTEGER PRIMARY KEY REFERENCES fact_admin(transaction_key) ON DELETE CASCADE,
    if_replacement TEXT,
    other_doc TEXT,
    ch_name TEXT,
    return_reason TEXT,
    pack_saved INTEGER REFERENCES dim_date(date_key),
    date_refer INTEGER REFERENCES dim_date(date_key),
    refer_diarised INTEGER REFERENCES dim_date(date_key),
    date_destroyed INTEGER REFERENCES dim_date(date_key),
    id_adv_request INTEGER REFERENCES dim_date(date_key),
    id_adv_rec INTEGER REFERENCES dim_date(date_key),
    check_process TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ext_fact_admin_closed (
    transaction_key INTEGER PRIMARY KEY REFERENCES fact_admin(transaction_key) ON DELETE CASCADE,
    cust_id TEXT,
    request_type TEXT,
    continue_end_relationship TEXT,
    return_status TEXT,
    return_reason TEXT,
    return_date INTEGER REFERENCES dim_date(date_key),
    date_fee_removed INTEGER REFERENCES dim_date(date_key),
    closing_bal INTEGER,
    pay_method TEXT,
    date_acc_opened INTEGER REFERENCES dim_date(date_key),
    date_acc_closed INTEGER REFERENCES dim_date(date_key),
    closure_reason TEXT,
    notes TEXT,
    cust_serv_det TEXT,
    pay_time_det TEXT,
    price_det TEXT,
    other_notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ext_fact_admin_trustees (
    transaction_key INTEGER PRIMARY KEY REFERENCES fact_admin(transaction_key) ON DELETE CASCADE,
    transact_cust_id INTEGER,
    trutsee_name TEXT,
    transact_trustee_id TEXT,
    trutsee_dob INTEGER,
    trustee_mob INTEGER,
    trustee_email TEXT,
    trutsee_address TEXT,
    date_id_req INTEGER REFERENCES dim_date(date_key),
    date_id_rec INTEGER REFERENCES dim_date(date_key),
    id_other_process TEXT,
    date_case_ref INTEGER REFERENCES dim_date(date_key),
    date_ref_chased INTEGER REFERENCES dim_date(date_key),
    date_ref_ret INTEGER REFERENCES dim_date(date_key),
    date_pack_saved INTEGER REFERENCES dim_date(date_key),
    comments TEXT,
    date_email_sent INTEGER REFERENCES dim_date(date_key),
    ref_folder_y_n TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ext_fact_admin_new_accounts (
    transaction_key INTEGER PRIMARY KEY REFERENCES fact_admin(transaction_key) ON DELETE CASCADE,
    fi_name TEXT,
    cust_id INTEGER,
    contact_name TEXT,
    contact_id INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ext_fact_admin_coc (
    transaction_key INTEGER PRIMARY KEY REFERENCES fact_admin(transaction_key) ON DELETE CASCADE,
    other_detail TEXT,
    risk TEXT,
    date_return INTEGER REFERENCES dim_date(date_key),
    nsia_no_match TEXT,
    nsia_inc_name TEXT,
    idv_req TEXT,
    adv_req TEXT,
    other TEXT,
    date_saved INTEGER REFERENCES dim_date(date_key),
    date_rec_back INTEGER REFERENCES dim_date(date_key),
    date_ref INTEGER REFERENCES dim_date(date_key),
    date_ref_drd INTEGER REFERENCES dim_date(date_key),
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ext_fact_admin_audits (
    transaction_key INTEGER PRIMARY KEY REFERENCES fact_admin(transaction_key) ON DELETE CASCADE,
    audit_change_auditor VARCHAR(20),
    dec_req TEXT,
    ret_note TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ext_fact_admin_misc (
    transaction_key INTEGER PRIMARY KEY REFERENCES fact_admin(transaction_key) ON DELETE CASCADE,
    dec_req TEXT,
    add_info TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ext_fact_admin_tele_pw (
    transaction_key INTEGER PRIMARY KEY REFERENCES fact_admin(transaction_key) ON DELETE CASCADE,
    sign_acc TEXT,
    pwd_ok TEXT,
    all_box TEXT,
    note TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ext_fact_admin_online_users (
    transaction_key INTEGER PRIMARY KEY REFERENCES fact_admin(transaction_key) ON DELETE CASCADE,
    name TEXT,
    org_transact_id TEXT,
    spotlight_status TEXT,
    date_id_req INTEGER REFERENCES dim_date(date_key),
    date_id_rec INTEGER REFERENCES dim_date(date_key),
    id_other_process TEXT,
    date_case_ref INTEGER REFERENCES dim_date(date_key),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ext_fact_admin_acc_corrections (
    transaction_key INTEGER PRIMARY KEY REFERENCES fact_admin(transaction_key) ON DELETE CASCADE,
    org_transact_id INTEGER,
    incor_transact_per TEXT,
    incor_transact_org TEXT,
    spotlit_cor TEXT,
    transact_cor TEXT,
    erasure_status TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);