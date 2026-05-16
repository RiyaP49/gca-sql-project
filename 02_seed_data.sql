-- =============================================================================
-- GCA Cybersecurity Risk Scoring — Seed Data
-- =============================================================================
-- Synthetic data matching the structure of the original Excel files:
--   risk_scoring.xlsx      (72 rows: 6 role groups × 12 months)
--   training_effectiveness_monthly.xlsx  (72 rows: 6 role groups × 12 months)
-- One organization, one full calendar year (2025-01 through 2025-12).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Organization
-- -----------------------------------------------------------------------------
INSERT INTO organizations (org_name, industry, employee_count, created_at)
VALUES ('Greenfield Community Services', 'Nonprofit', 310, '2024-06-01');
-- org_id = 1

-- -----------------------------------------------------------------------------
-- Role groups  (6 groups matching original Excel)
-- -----------------------------------------------------------------------------
INSERT INTO role_groups (org_id, role_name, headcount) VALUES
(1, 'Engineer',  42),
(1, 'Finance',   38),
(1, 'HR',        25),
(1, 'Managers',  30),
(1, 'Sales',     85),
(1, 'Technical', 90);
-- role_group_ids: Engineer=1, Finance=2, HR=3, Managers=4, Sales=5, Technical=6

-- =============================================================================
-- RISK SCORES  (6 groups × 12 months = 72 rows)
-- Trend: scores improve mid-year after an intervention wave, with HR and Sales
-- remaining elevated throughout — realistic pattern for a nonprofit.
-- =============================================================================
INSERT INTO risk_scores
    (org_id, role_group_id, month, risk_score, risk_tier,
     avg_click_rate_pct, avg_reporting_rate_pct, training_completed_pct, recommended_action)
VALUES
-- Engineer
(1,1,'2025-01-01',28,'Low',   4.2,72.1,91.0,'Maintain current posture'),
(1,1,'2025-02-01',26,'Low',   3.9,74.5,92.0,'Maintain current posture'),
(1,1,'2025-03-01',25,'Low',   3.7,75.0,93.5,'Maintain current posture'),
(1,1,'2025-04-01',24,'Low',   3.5,76.2,94.0,'Maintain current posture'),
(1,1,'2025-05-01',23,'Low',   3.3,77.0,95.0,'Maintain current posture'),
(1,1,'2025-06-01',22,'Low',   3.1,78.5,96.0,'Maintain current posture'),
(1,1,'2025-07-01',21,'Low',   2.9,79.0,96.5,'Maintain current posture'),
(1,1,'2025-08-01',20,'Low',   2.8,80.1,97.0,'Maintain current posture'),
(1,1,'2025-09-01',20,'Low',   2.7,80.5,97.5,'Maintain current posture'),
(1,1,'2025-10-01',19,'Low',   2.6,81.0,98.0,'Maintain current posture'),
(1,1,'2025-11-01',19,'Low',   2.5,81.5,98.0,'Maintain current posture'),
(1,1,'2025-12-01',18,'Low',   2.4,82.0,98.5,'Maintain current posture'),
-- Finance
(1,2,'2025-01-01',61,'High',  14.8,31.2,68.0,'Deploy phishing simulation immediately'),
(1,2,'2025-02-01',59,'Medium',13.5,33.0,71.0,'Increase simulation frequency'),
(1,2,'2025-03-01',57,'Medium',12.9,35.5,74.0,'Increase simulation frequency'),
(1,2,'2025-04-01',54,'Medium',11.8,38.0,77.0,'Targeted awareness campaign'),
(1,2,'2025-05-01',51,'Medium',10.5,41.2,80.0,'Targeted awareness campaign'),
(1,2,'2025-06-01',48,'Medium', 9.8,44.0,83.0,'Targeted awareness campaign'),
(1,2,'2025-07-01',44,'Medium', 8.9,47.5,86.0,'Continue current interventions'),
(1,2,'2025-08-01',41,'Medium', 8.1,50.0,88.0,'Continue current interventions'),
(1,2,'2025-09-01',38,'Medium', 7.4,53.2,90.0,'Continue current interventions'),
(1,2,'2025-10-01',35,'Low',    6.8,56.0,91.5,'Maintain and monitor'),
(1,2,'2025-11-01',33,'Low',    6.2,58.5,93.0,'Maintain and monitor'),
(1,2,'2025-12-01',31,'Low',    5.8,61.0,94.0,'Maintain and monitor'),
-- HR
(1,3,'2025-01-01',55,'Medium',11.2,38.5,72.0,'Targeted awareness campaign'),
(1,3,'2025-02-01',54,'Medium',10.9,39.8,74.5,'Targeted awareness campaign'),
(1,3,'2025-03-01',52,'Medium',10.3,41.5,76.0,'Targeted awareness campaign'),
(1,3,'2025-04-01',50,'Medium', 9.8,43.0,78.0,'Targeted awareness campaign'),
(1,3,'2025-05-01',48,'Medium', 9.2,45.5,80.5,'Increase simulation frequency'),
(1,3,'2025-06-01',46,'Medium', 8.7,47.0,82.0,'Increase simulation frequency'),
(1,3,'2025-07-01',44,'Medium', 8.2,49.5,84.0,'Continue current interventions'),
(1,3,'2025-08-01',42,'Medium', 7.8,51.0,85.5,'Continue current interventions'),
(1,3,'2025-09-01',40,'Medium', 7.3,53.5,87.0,'Continue current interventions'),
(1,3,'2025-10-01',38,'Medium', 6.9,55.0,88.5,'Maintain and monitor'),
(1,3,'2025-11-01',36,'Low',    6.4,57.5,90.0,'Maintain and monitor'),
(1,3,'2025-12-01',35,'Low',    6.1,59.0,91.5,'Maintain and monitor'),
-- Managers
(1,4,'2025-01-01',42,'Medium', 8.5,52.0,79.0,'Increase simulation frequency'),
(1,4,'2025-02-01',41,'Medium', 8.2,53.5,80.5,'Increase simulation frequency'),
(1,4,'2025-03-01',39,'Medium', 7.8,55.0,82.0,'Increase simulation frequency'),
(1,4,'2025-04-01',37,'Medium', 7.3,57.5,83.5,'Continue current interventions'),
(1,4,'2025-05-01',35,'Low',    6.9,59.0,85.0,'Maintain and monitor'),
(1,4,'2025-06-01',33,'Low',    6.4,61.5,86.5,'Maintain and monitor'),
(1,4,'2025-07-01',31,'Low',    6.0,63.0,88.0,'Maintain and monitor'),
(1,4,'2025-08-01',30,'Low',    5.7,65.0,89.0,'Maintain current posture'),
(1,4,'2025-09-01',28,'Low',    5.3,67.0,90.5,'Maintain current posture'),
(1,4,'2025-10-01',27,'Low',    5.0,68.5,91.5,'Maintain current posture'),
(1,4,'2025-11-01',26,'Low',    4.7,70.0,92.5,'Maintain current posture'),
(1,4,'2025-12-01',25,'Low',    4.5,71.5,93.5,'Maintain current posture'),
-- Sales
(1,5,'2025-01-01',72,'High',  19.5,22.0,58.0,'Deploy phishing simulation immediately'),
(1,5,'2025-02-01',71,'High',  19.0,23.5,60.5,'Deploy phishing simulation immediately'),
(1,5,'2025-03-01',69,'High',  18.2,25.0,63.0,'Deploy phishing simulation immediately'),
(1,5,'2025-04-01',66,'High',  17.0,27.5,66.0,'Increase simulation frequency'),
(1,5,'2025-05-01',63,'High',  15.8,30.0,69.0,'Increase simulation frequency'),
(1,5,'2025-06-01',60,'High',  14.5,33.0,72.0,'Increase simulation frequency'),
(1,5,'2025-07-01',56,'Medium',13.0,36.5,75.5,'Targeted awareness campaign'),
(1,5,'2025-08-01',52,'Medium',11.8,40.0,78.0,'Targeted awareness campaign'),
(1,5,'2025-09-01',49,'Medium',10.5,43.5,81.0,'Continue current interventions'),
(1,5,'2025-10-01',46,'Medium', 9.3,47.0,83.5,'Continue current interventions'),
(1,5,'2025-11-01',43,'Medium', 8.2,50.5,86.0,'Maintain and monitor'),
(1,5,'2025-12-01',40,'Medium', 7.4,54.0,88.5,'Maintain and monitor'),
-- Technical
(1,6,'2025-01-01',35,'Low',    6.5,61.0,83.0,'Maintain and monitor'),
(1,6,'2025-02-01',34,'Low',    6.2,62.5,84.5,'Maintain and monitor'),
(1,6,'2025-03-01',33,'Low',    5.9,64.0,86.0,'Maintain and monitor'),
(1,6,'2025-04-01',31,'Low',    5.5,65.5,87.5,'Maintain current posture'),
(1,6,'2025-05-01',30,'Low',    5.2,67.0,89.0,'Maintain current posture'),
(1,6,'2025-06-01',29,'Low',    4.9,68.5,90.0,'Maintain current posture'),
(1,6,'2025-07-01',27,'Low',    4.6,70.0,91.5,'Maintain current posture'),
(1,6,'2025-08-01',26,'Low',    4.3,71.5,92.5,'Maintain current posture'),
(1,6,'2025-09-01',25,'Low',    4.1,73.0,93.5,'Maintain current posture'),
(1,6,'2025-10-01',24,'Low',    3.9,74.5,94.5,'Maintain current posture'),
(1,6,'2025-11-01',23,'Low',    3.7,75.5,95.0,'Maintain current posture'),
(1,6,'2025-12-01',22,'Low',    3.5,77.0,96.0,'Maintain current posture');

-- =============================================================================
-- TRAINING EFFECTIVENESS  (6 groups × 12 months = 72 rows)
-- =============================================================================
INSERT INTO training_effectiveness
    (org_id, role_group_id, month, users_exposed, click_rate_pct,
     reporting_rate_pct, median_time_to_report_min, incident_count)
VALUES
-- Engineer
(1,1,'2025-01-01',42, 4.2,72.1,12.5,0),(1,1,'2025-02-01',42, 3.9,74.5,11.8,0),
(1,1,'2025-03-01',42, 3.7,75.0,11.2,0),(1,1,'2025-04-01',42, 3.5,76.2,10.9,0),
(1,1,'2025-05-01',42, 3.3,77.0,10.5,0),(1,1,'2025-06-01',42, 3.1,78.5,10.1,0),
(1,1,'2025-07-01',42, 2.9,79.0, 9.8,0),(1,1,'2025-08-01',42, 2.8,80.1, 9.5,0),
(1,1,'2025-09-01',42, 2.7,80.5, 9.2,0),(1,1,'2025-10-01',42, 2.6,81.0, 9.0,0),
(1,1,'2025-11-01',42, 2.5,81.5, 8.8,0),(1,1,'2025-12-01',42, 2.4,82.0, 8.5,0),
-- Finance
(1,2,'2025-01-01',38,14.8,31.2,38.5,2),(1,2,'2025-02-01',38,13.5,33.0,36.2,2),
(1,2,'2025-03-01',38,12.9,35.5,34.0,1),(1,2,'2025-04-01',38,11.8,38.0,31.5,1),
(1,2,'2025-05-01',38,10.5,41.2,29.0,1),(1,2,'2025-06-01',38, 9.8,44.0,26.5,1),
(1,2,'2025-07-01',38, 8.9,47.5,24.2,0),(1,2,'2025-08-01',38, 8.1,50.0,22.0,0),
(1,2,'2025-09-01',38, 7.4,53.2,20.0,0),(1,2,'2025-10-01',38, 6.8,56.0,18.5,0),
(1,2,'2025-11-01',38, 6.2,58.5,17.0,0),(1,2,'2025-12-01',38, 5.8,61.0,15.8,0),
-- HR
(1,3,'2025-01-01',25,11.2,38.5,32.0,1),(1,3,'2025-02-01',25,10.9,39.8,30.5,1),
(1,3,'2025-03-01',25,10.3,41.5,29.0,1),(1,3,'2025-04-01',25, 9.8,43.0,27.5,0),
(1,3,'2025-05-01',25, 9.2,45.5,26.0,0),(1,3,'2025-06-01',25, 8.7,47.0,24.5,0),
(1,3,'2025-07-01',25, 8.2,49.5,23.2,0),(1,3,'2025-08-01',25, 7.8,51.0,22.0,0),
(1,3,'2025-09-01',25, 7.3,53.5,20.8,0),(1,3,'2025-10-01',25, 6.9,55.0,19.5,0),
(1,3,'2025-11-01',25, 6.4,57.5,18.5,0),(1,3,'2025-12-01',25, 6.1,59.0,17.5,0),
-- Managers
(1,4,'2025-01-01',30, 8.5,52.0,25.5,1),(1,4,'2025-02-01',30, 8.2,53.5,24.5,0),
(1,4,'2025-03-01',30, 7.8,55.0,23.5,0),(1,4,'2025-04-01',30, 7.3,57.5,22.5,0),
(1,4,'2025-05-01',30, 6.9,59.0,21.5,0),(1,4,'2025-06-01',30, 6.4,61.5,20.5,0),
(1,4,'2025-07-01',30, 6.0,63.0,19.5,0),(1,4,'2025-08-01',30, 5.7,65.0,18.8,0),
(1,4,'2025-09-01',30, 5.3,67.0,18.0,0),(1,4,'2025-10-01',30, 5.0,68.5,17.2,0),
(1,4,'2025-11-01',30, 4.7,70.0,16.5,0),(1,4,'2025-12-01',30, 4.5,71.5,15.8,0),
-- Sales
(1,5,'2025-01-01',85,19.5,22.0,55.0,4),(1,5,'2025-02-01',85,19.0,23.5,52.5,3),
(1,5,'2025-03-01',85,18.2,25.0,50.0,3),(1,5,'2025-04-01',85,17.0,27.5,47.5,2),
(1,5,'2025-05-01',85,15.8,30.0,45.0,2),(1,5,'2025-06-01',85,14.5,33.0,42.5,2),
(1,5,'2025-07-01',85,13.0,36.5,40.0,1),(1,5,'2025-08-01',85,11.8,40.0,37.5,1),
(1,5,'2025-09-01',85,10.5,43.5,35.0,1),(1,5,'2025-10-01',85, 9.3,47.0,32.5,0),
(1,5,'2025-11-01',85, 8.2,50.5,30.0,0),(1,5,'2025-12-01',85, 7.4,54.0,28.0,0),
-- Technical
(1,6,'2025-01-01',90, 6.5,61.0,20.5,1),(1,6,'2025-02-01',90, 6.2,62.5,19.8,0),
(1,6,'2025-03-01',90, 5.9,64.0,19.0,0),(1,6,'2025-04-01',90, 5.5,65.5,18.2,0),
(1,6,'2025-05-01',90, 5.2,67.0,17.5,0),(1,6,'2025-06-01',90, 4.9,68.5,16.8,0),
(1,6,'2025-07-01',90, 4.6,70.0,16.2,0),(1,6,'2025-08-01',90, 4.3,71.5,15.5,0),
(1,6,'2025-09-01',90, 4.1,73.0,14.8,0),(1,6,'2025-10-01',90, 3.9,74.5,14.2,0),
(1,6,'2025-11-01',90, 3.7,75.5,13.8,0),(1,6,'2025-12-01',90, 3.5,77.0,13.2,0);

-- =============================================================================
-- INTERVENTIONS
-- Deployed mid-year after Q1 assessment flagged Finance and Sales as High risk.
-- =============================================================================
INSERT INTO interventions
    (org_id, role_group_id, intervention_type, deployed_month, target_metric, notes)
VALUES
(1, 2, 'Phishing Simulation', '2025-02-01', 'avg_click_rate_pct',
    'Monthly simulations added after Finance flagged High in January'),
(1, 5, 'Phishing Simulation', '2025-02-01', 'avg_click_rate_pct',
    'Monthly simulations added after Sales flagged High in January'),
(1, 2, 'Targeted Awareness Campaign', '2025-04-01', 'avg_reporting_rate_pct',
    'Finance-specific phishing awareness module deployed'),
(1, 5, 'Targeted Awareness Campaign', '2025-04-01', 'avg_reporting_rate_pct',
    'Sales-specific social engineering awareness module deployed'),
(1, 3, 'Targeted Awareness Campaign', '2025-05-01', 'training_completed_pct',
    'HR completion rate lagging — manager push + deadline added'),
(1, 5, 'MFA Rollout', '2025-06-01', 'risk_score',
    'MFA enforced for all Sales accounts following Q2 review');
