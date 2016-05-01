select /*+ gather_plan_statistics */ count(*) from EPM_INTERFACE_ECFC_ATTRIBUTE;
select * from table (dbms_xplan.display_cursor (format=>'ALLSTATS LAST'));


select sample_time, sql_id, sql_child_number, SQL_PLAN_HASH_VALUE, SQL_EXEC_ID, to_char(SQL_EXEC_START,'YYYY-MM-DD HH24:MI:SS')
from v$active_session_history where SESSION_ID=67 and session_serial#=20075 order by sample_time


select sample_time, sql_id, sql_child_number, SQL_PLAN_HASH_VALUE, SQL_EXEC_ID, to_char(SQL_EXEC_START,'YYYY-MM-DD HH24:MI:SS')
from dba_hist_active_sess_history where SESSION_ID=5485 and session_serial#=35301 and sample_time>sysdate-1 order by sample_time