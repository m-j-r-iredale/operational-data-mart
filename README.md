# CAF Bank Operational Data Mart

A PostgreSQL dimensional data mart designed to support operational analysis and create a structured foundation for future customer-data and CRM-style architecture.

## Project Context

The customer division of the bank was operating with limited modern data infrastructure and no accessible operational CRM providing a consistent view of customer activity.

Operational information existed across different processes and workstreams, but it was fragmented, siloed and difficult to analyse consistently. More detailed customer information also existed within older legacy systems, but modernising that data formed part of a much larger transformation programme.

The aim of this project was therefore to build a practical analytical database that could support immediate operational reporting while creating a path toward a more structured customer-data environment.

## Design Approach

The database follows a Kimball-inspired, bottom-up dimensional design centred on one operational business process: administrative cases handled by the customer division.

The central `fact_admin` table is defined at the grain of one administrative transaction or case item per row.

Around this fact table, the model uses reusable dimensions for:

- Dates
- Agents
- Task types
- Organisations
- Customers
- Accounts

Surrogate keys are used throughout the dimensional model so the analytical database does not depend directly on source-system identifiers.

Where a transaction can involve multiple agents or multiple accounts, bridge tables are used rather than repeating fields within the fact table.

Workflow-specific attributes are stored in one-to-one extension tables, allowing the central fact table to remain compact while still supporting more specialised administrative processes.

## Data Model

The core model includes:

### Fact Table

- `fact_admin`

### Dimensions

- `dim_date`
- `dim_agent`
- `dim_task_type`
- `dim_organisation`
- `dim_customer`
- `dim_account`

### Bridge Tables

- `bridge_admin_agent`
- `bridge_admin_account`

### Extension Tables

- `ext_fact_admin_bcards`
- `ext_fact_admin_closed`
- `ext_fact_admin_trustees`
- `ext_fact_admin_new_accounts`
- `ext_fact_admin_coc`
- `ext_fact_admin_audits`
- `ext_fact_admin_misc`
- `ext_fact_admin_tele_pw`
- `ext_fact_admin_online_users`
- `ext_fact_admin_acc_corrections`

## Customer and Organisation Data

Customer and organisation data required a different treatment from the rest of the dimensional model.

Operational source data contained customer and organisation information in free-text or source-specific formats, so it was not suitable for automatically populating durable master records.

The intended process was:

**Operational transaction captured → source customer/organisation information recorded → data reviewed and cleaned → matched against legacy data → inserted into customer/organisation dimensions → fact record linked to a durable surrogate key**

For this reason, `dim_customer` and `dim_organisation` are included in the model even though they are not yet fully populated or linked through the initial ETL process.

The design allows these dimensions to become progressively enriched master records as customer and organisation data is cleaned, reconciled and matched over time.

## Key Design Decisions

- Define the fact table at a clear transaction-level grain
- Use surrogate keys throughout the dimensional model
- Use bridge tables for many-to-many relationships
- Use one-to-one extension tables for specialist workflows
- Separate raw operational customer information from durable master records
- Design data integrity into the schema through keys, constraints and relationships
- Support immediate operational analysis while leaving room for future architectural development

## Repository Structure

```text
operational-data-mart/
├── README.md
├── sql/
│   ├── schema.sql
│   └── seed_reference_data.sql
├── diagrams/
│   └── .gitkeep
└── .gitignore
```

## SQL Files

### `schema.sql`

Contains the PostgreSQL table definitions, primary keys, foreign keys, bridge tables and workflow-specific extension tables.

### `seed_reference_data.sql`

Contains:

- date-dimension population logic
- fictional agent records
- administrative task-type reference data

All demonstration records are fictional and are included only to illustrate the structure of the model.

## Technologies

- PostgreSQL
- SQL
- Dimensional modelling
- Kimball-inspired data architecture

## Key Learnings

- Database design starts with understanding the business process, not writing SQL
- Clear fact-table grain is essential for reliable analytical modelling
- Many-to-many relationships should be modelled explicitly
- Data-quality and integrity rules are easier to manage when they are built into the schema
- A dimensional model can support immediate reporting while also creating a foundation for future customer-data integration

## Related Project

The second part of this project covers the Python ETL pipeline used to validate operational source data and load it into the dimensional model.
