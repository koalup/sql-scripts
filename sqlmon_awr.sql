------------------------------------------------------------------------------------------------------------------------
--
-- File name:   asqlmon.sql (v1.0)
--
-- Purpose:     Report SQL-monitoring-style drill-down into where in an execution plan the execution time is spent
--
-- Author:      Tanel Poder
--
-- Copyright:   (c) http://blog.tanelpoder.com - All rights reserved.
--
-- Disclaimer:  This script is provided "as is", no warranties nor guarantees are
--              made. Use at your own risk :)
--              
-- Usage:       @asqlmon <sqlid> <child#>
--
-- Notes:       This script runs on Oracle 11g+ and you should have the
--              Diagnostics and Tuning pack licenses for using it as it queries
--              some separately licensed views.
--
------------------------------------------------------------------------------------------------------------------------

COL asqlmon_operation FOR a100
COL asqlmon_predicates FOR a100 word_wrap
COL options   FOR a30

COL asqlmon_plan_hash_value HEAD PLAN_HASH_VALUE
COL asqlmon_sql_id          HEAD SQL_ID
COL asqlmon_sql_child       HEAD CHILD#
COL asqlmon_sample_time     HEAD SAMPLE_HOUR
COL projection FOR A500

COL pct_child HEAD "Activity %" FOR A8
COL pct_child_vis HEAD "Visual" FOR A12

BREAK ON asqlmon_plan_hash_value SKIP 1 ON asqlmon_sql_id SKIP 1 ON asqlmon_sql_child SKIP 1 ON asqlmon_sample_time SKIP 1 DUP ON asqlmon_operation

WITH  sample_times AS (
    select * from dual
), 
sq AS (
SELECT
  --  to_char(ash.sample_time, 'YYYY-MM-DD HH24') sample_time
    count(*) samples
  , ash.sql_id
  , ash.sql_plan_hash_value
  , ash.sql_plan_line_id
  , ash.sql_plan_operation
  , ash.sql_plan_options
  , ash.session_state
  , ash.event
FROM
    dba_hist_active_sess_history ash
WHERE
    1=1
AND ash.sql_id = '&1'
AND ash.sql_plan_hash_value = &2
AND SAMPLE_TIME BETWEEN 
        TO_TIMESTAMP('2013-07-01 00:00:00','YYYY-MM-DD HH24:MI:SS') AND 
        TO_TIMESTAMP('2013-07-02 00:00:00','YYYY-MM-DD HH24:MI:SS')
GROUP BY
  --to_char(ash.sample_time, 'YYYY-MM-DD HH24')
    ash.sql_id
  , ash.sql_plan_hash_value
  , ash.sql_plan_line_id
  , ash.sql_plan_operation
  , ash.sql_plan_options
  , ash.session_state
  , ash.event
)
SELECT
    plan.sql_id            asqlmon_sql_id
  , plan.PLAN_HASH_VALUE   asqlmon_sql_child
--  , plan.plan_hash_value asqlmon_plan_hash_value
  , sq.samples
  , LPAD(TO_CHAR(TO_NUMBER(ROUND(RATIO_TO_REPORT(sq.samples) OVER (PARTITION BY sq.sql_id, sq.sql_plan_hash_value) * 100, 1), 999.9))||' %',8) pct_child
  , '|'||RPAD( NVL( LPAD('#', ROUND(RATIO_TO_REPORT(sq.samples) OVER (PARTITION BY sq.sql_id, sq.sql_plan_hash_value) * 10), '#'), ' '), 10,' ')||'|' pct_child_vis
  --, sq.sample_time         asqlmon_sample_time
  , plan.id 
  , LPAD(' ', depth) || plan.operation ||' '|| plan.options || NVL2(plan.object_name, ' ['||plan.object_name ||']', null) asqlmon_operation
  , sq.session_state
  , sq.event
  --, plan.object_alias || CASE WHEN plan.qblock_name IS NOT NULL THEN ' ['|| plan.qblock_name || ']' END obj_alias_qbc_name
  --, CASE WHEN plan.access_predicates IS NOT NULL THEN '[A:] '|| plan.access_predicates END || CASE WHEN plan.filter_predicates IS NOT NULL THEN ' [F:]' || plan.filter_predicates END asqlmon_predicates
  --, plan.projection
FROM
    dba_hist_sql_plan plan
  , sq
WHERE
    1=1
AND sq.sql_id(+) = plan.sql_id
--AND sq.sql_child_number(+) = plan.child_number
AND sq.sql_plan_line_id(+) = plan.id
AND sq.sql_plan_hash_value(+) = plan.plan_hash_value
AND plan.sql_id = '&1'
AND plan.PLAN_HASH_VALUE = &2
ORDER BY
  --sq.sample_time
--    plan.child_number
   plan.plan_hash_value
  , plan.id
/
