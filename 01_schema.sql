-- =============================================================================
-- GCA Cybersecurity Risk Scoring — SQL Schema
-- =============================================================================
-- Relational redesign of the GCA chatbot's Excel-based data pipeline.
-- Original system: risk_scoring.xlsx + training_effectiveness_monthly.xlsx
-- This schema replaces the Excel DAL with a normalized PostgreSQL database.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- ORGANIZATIONS
-- Represents the small businesses / nonprofits GCA serves.
-- -----------------------------------------------------------------------------
CREATE TABLE organizations (
    org_id          SERIAL PRIMARY KEY,
    org_name        VARCHAR(200)    NOT NULL,
    industry        VARCHAR(100),
    employee_count  INT,
    created_at      DATE            NOT NULL DEFAULT CURRENT_DATE
);

-- -----------------------------------------------------------------------------
-- ROLE GROUPS
-- The 6 functional groups tracked per org: Engineer, Finance, HR,
-- Managers, Sales, Technical.
-- -----------------------------------------------------------------------------
CREATE TABLE role_groups (
    role_group_id   SERIAL PRIMARY KEY,
    org_id          INT             NOT NULL REFERENCES organizations(org_id),
    role_name       VARCHAR(100)    NOT NULL,   -- e.g. 'Engineer', 'HR'
    headcount       INT             NOT NULL,
    UNIQUE (org_id, role_name)
);

-- -----------------------------------------------------------------------------
-- RISK SCORES  (maps to risk_scoring.xlsx)
-- One row per role group per month.
-- Risk_Score: 0–100, lower = better posture.
-- Risk_Tier: Low / Medium / High derived from score bands.
-- -----------------------------------------------------------------------------
CREATE TABLE risk_scores (
    risk_score_id           SERIAL PRIMARY KEY,
    org_id                  INT             NOT NULL REFERENCES organizations(org_id),
    role_group_id           INT             NOT NULL REFERENCES role_groups(role_group_id),
    month                   DATE            NOT NULL,   -- first day of month, e.g. 2025-01-01
    risk_score              NUMERIC(5,2)    NOT NULL CHECK (risk_score BETWEEN 0 AND 100),
    risk_tier               VARCHAR(10)     NOT NULL CHECK (risk_tier IN ('Low', 'Medium', 'High')),
    avg_click_rate_pct      NUMERIC(5,2),              -- % of users who clicked a phishing sim
    avg_reporting_rate_pct  NUMERIC(5,2),              -- % of users who reported a phishing sim
    training_completed_pct  NUMERIC(5,2),              -- % of users who finished training
    recommended_action      TEXT,
    UNIQUE (org_id, role_group_id, month)
);

-- -----------------------------------------------------------------------------
-- TRAINING EFFECTIVENESS  (maps to training_effectiveness_monthly.xlsx)
-- One row per role group per month.
-- Joined to risk_scores on (org_id, role_group_id, month).
-- -----------------------------------------------------------------------------
CREATE TABLE training_effectiveness (
    training_id                 SERIAL PRIMARY KEY,
    org_id                      INT             NOT NULL REFERENCES organizations(org_id),
    role_group_id               INT             NOT NULL REFERENCES role_groups(role_group_id),
    month                       DATE            NOT NULL,
    users_exposed               INT             NOT NULL,   -- # users who received phishing sim
    click_rate_pct              NUMERIC(5,2),
    reporting_rate_pct          NUMERIC(5,2),
    median_time_to_report_min   NUMERIC(6,2),              -- how fast users report phishing
    incident_count              INT             DEFAULT 0,  -- real security incidents that month
    UNIQUE (org_id, role_group_id, month)
);

-- -----------------------------------------------------------------------------
-- INTERVENTIONS
-- Tracks recommended actions that were actually deployed, and their outcomes.
-- Allows validating whether interventions improved risk scores over time.
-- -----------------------------------------------------------------------------
CREATE TABLE interventions (
    intervention_id     SERIAL PRIMARY KEY,
    org_id              INT             NOT NULL REFERENCES organizations(org_id),
    role_group_id       INT             NOT NULL REFERENCES role_groups(role_group_id),
    intervention_type   VARCHAR(100)    NOT NULL,   -- e.g. 'Phishing Simulation', 'MFA Rollout'
    deployed_month      DATE            NOT NULL,
    target_metric       VARCHAR(100),               -- which metric this targets
    notes               TEXT
);

-- -----------------------------------------------------------------------------
-- INDEXES for common join/filter patterns
-- -----------------------------------------------------------------------------
CREATE INDEX idx_risk_scores_org_month       ON risk_scores (org_id, month);
CREATE INDEX idx_risk_scores_role_month      ON risk_scores (role_group_id, month);
CREATE INDEX idx_training_org_month          ON training_effectiveness (org_id, month);
CREATE INDEX idx_training_role_month         ON training_effectiveness (role_group_id, month);
CREATE INDEX idx_interventions_org           ON interventions (org_id, deployed_month);
