----------------------------------
-- For script re-run
----------------------------------
DELETE from action_instance_history where action_instance_no in
(
select action_instance_no from action_instance
where schedule_no in (select schedule_no from schedule where name = 'ZRefreshMaterializedViewDaily')
);
DELETE FROM ACTION_INSTANCE WHERE BUSINESS_ACTION_NO =(SELECT BUSINESS_ACTION_NO from  TV_BUSINESS_ACTION where name = 'ZRefreshMaterializedViewDaily');
DELETE FROM schedule_history where schedule_no in (select schedule_no from schedule where name = 'ZRefreshMaterializedViewDaily');
DELETE FROM schedule where name  = 'ZRefreshMaterializedViewDaily';
DELETE FROM TV_STATIC_ACTION_PARAMETER WHERE BUSINESS_ACTION_NO = (select business_action_no from TV_BUSINESS_ACTION where name = 'ZRefreshMaterializedViewDaily');
DELETE FROM TV_BUSINESS_ACTION where name = 'ZRefreshMaterializedViewDaily';

----------------------------------
-- Create New Business Action
----------------------------------
INSERT INTO TV_BUSINESS_ACTION (NAME, ACTION_CLASS_NAME, BA_TYPE, REV_TEXT) VALUES ('ZRefreshMaterializedViewDaily', 'com.ec.eccommon.genericmodel.model.ejb.GenericRunSqlAction', 'SCHEDULER', 'EC To Kepler - Materialized View');

INSERT INTO TV_STATIC_ACTION_PARAMETER (NAME, PARAMETER_TYPE, PARAMETER_SUB_TYPE, MANDATORY, BUSINESS_ACTION_NO, PARAMETER_STATIC_VALUE) VALUES ('procedure.name', 'BASIC_TYPE', 'STRING', 'Y', (select business_action_no from TV_BUSINESS_ACTION where name = 'ZRefreshMaterializedViewDaily'), 'z_system_tools.refreshMaterializedViewDaily');
INSERT INTO TV_STATIC_ACTION_PARAMETER (NAME, PARAMETER_TYPE, PARAMETER_SUB_TYPE, MANDATORY, BUSINESS_ACTION_NO, PARAMETER_STATIC_VALUE) VALUES ('procedure.type', 'BASIC_TYPE', 'STRING', 'Y', (select business_action_no from TV_BUSINESS_ACTION where name = 'ZRefreshMaterializedViewDaily'), 'procedure');

---------------------------------------------------------------------------------------
-- SCHEDULER --ZRefreshMaterializedViewDaily
---------------------------------------------------------------------------------------
INSERT INTO TV_SCHEDULE (NAME, ENABLED, FUNCTIONAL_AREA_ID, DESCRIPTION, START_DATE, STATEFUL_IND, REV_TEXT) VALUES ('ZRefreshMaterializedViewDaily', 'Y', EcDp_Objects.GetObjIDFromCode('FUNCTIONAL_AREA', 'EC'), 'Refresh Daily', TO_DATE('2023-01-01T00:00:00','YYYY-MM-DD"T"HH24:MI:SS'), 'Y', 'EC To Kepler - Materialized View');

UPDATE TV_SCHEDULE_DETAILS SET USERNAME = 'sched', LOG_LEVEL = 'DEBUG', IGNORE_MISFIRE = 'Y', RETAIN_COUNT = 30 WHERE NAME = 'ZRefreshMaterializedViewDaily';

INSERT INTO TV_ACTION_INSTANCE (BUSINESS_ACTION_NO, DESCRIPTION, EXEC_ORDER, SCHEDULE_NO, ISOLATED_TX_IND, REV_TEXT) VALUES ((SELECT BUSINESS_ACTION_NO FROM BUSINESS_ACTION WHERE NAME = 'ZRefreshMaterializedViewDaily'), 'Refresh Kepler Materialized View', 10, (SELECT SCHEDULE_NO FROM TV_SCHEDULE WHERE NAME = 'ZRefreshMaterializedViewDaily'), 'N', 'EC To Kepler - Materialized View');

UPDATE TV_JOB_SCHEDULE SET SCHEDULE_TYPE = 'DAILY' WHERE name = 'ZRefreshMaterializedViewDaily'; 

UPDATE SCHEDULE SET PIN_TO = 'master:ec-server' WHERE NAME = 'ZRefreshMaterializedViewDaily';

COMMIT;