select sample_time, count(*) 
from 
   dba_hist_active_sess_history 
   --v$active_session_history
where 
     SAMPLE_TIME BETWEEN 
        TO_TIMESTAMP('2013-03-12 00:00:00','YYYY-MM-DD HH24:MI:SS') AND 
        TO_TIMESTAMP('2013-03-13 00:00:00','YYYY-MM-DD HH24:MI:SS')
group by SAMPLE_TIME 
order by SAMPLE_TIME
;


-- by sql_id
select SQL_ID, SQL_CHILD_NUMBER, SQL_PLAN_HASH_VALUE, count(*) cnt
from dba_hist_active_sess_history where 
     SAMPLE_TIME BETWEEN 
        TO_TIMESTAMP('2013-03-12 07:00:00','YYYY-MM-DD HH24:MI:SS') AND 
        TO_TIMESTAMP('2013-03-12 19:30:00','YYYY-MM-DD HH24:MI:SS')
group by SQL_ID, SQL_CHILD_NUMBER, SQL_PLAN_HASH_VALUE
order by cnt
;

-- by plan_hash_value
select SQL_PLAN_HASH_VALUE, count(*) cnt
from dba_hist_active_sess_history where 
     SAMPLE_TIME BETWEEN 
        TO_TIMESTAMP('2013-03-12 07:00:00','YYYY-MM-DD HH24:MI:SS') AND 
        TO_TIMESTAMP('2013-03-12 19:30:00','YYYY-MM-DD HH24:MI:SS')
group by SQL_PLAN_HASH_VALUE
order by cnt
;

set lin 400 pages 400
set trimspool on
col sample_time format a30
col instance_number format a2
col event format a30
col username format a11
col program format a30 trunc
col BLOCKING_INST_ID format 9
col seconds format 9999990.9999
BREAK ON SAMPLE_TIME SKIP page
compute count of session_id on sample_time
SELECT 
      A.SAMPLE_TIME
     ,to_char(A.INSTANCE_NUMBER) INSTANCE_NUMBER
     ,B.USERNAME
     ,A.SESSION_ID
     ,A.EVENT
     ,A.SEQ#
     ,A.SESSION_STATE
     ,(A.WAIT_TIME + A.TIME_WAITED)/1000000 SECONDS
     --A.DELTA_TIME/1000000 DELTA_SECS
     ,A.SQL_ID
     ,A.SQL_PLAN_HASH_VALUE
     ,A.CURRENT_OBJ#
	 ,A.BLOCKING_INST_ID
     ,A.BLOCKING_SESSION
     ,A.BLOCKING_SESSION_STATUS
     --,to_char(A.BLOCKING_INST_ID) BLOCKING_INST_ID
     --,A.PROGRAM
     --,A.PLSQL_ENTRY_OBJECT_ID
     --,A.PLSQL_ENTRY_SUBPROGRAM_ID
FROM
     DBA_HIST_ACTIVE_SESS_HISTORY A,
     DBA_USERS B
WHERE
		A.USER_ID=B.USER_ID 
--	AND B.USERNAME NOT IN ('DBSNMP','SYS')
--	AND (A.WAIT_TIME + A.TIME_WAITED)/1000000 > 10 
--	AND A.EVENT IS NULL 
--	AND A.SQL_ID='2b2z50m2hdvct' 
	AND SAMPLE_TIME BETWEEN 
        TO_TIMESTAMP('2016-02-15 16:55:00','YYYY-MM-DD HH24:MI:SS') AND 
        TO_TIMESTAMP('2016-02-15 17:00:00','YYYY-MM-DD HH24:MI:SS')
ORDER BY SAMPLE_TIME, session_id;




set lin 400 pages 400
col sample_time format a30
col instance_number format 9
col event format a25 trunc
col username format a10
BREAK ON SAMPLE_TIME SKIP page
SELECT 
     A.SAMPLE_TIME,
     A.INST_ID,
     B.USERNAME,
     A.SESSION_ID,
     A.EVENT,
     A.SEQ#,
     A.SESSION_STATE,
--     (A.WAIT_TIME + A.TIME_WAITED)/1000000 SECONDS,
     A.SQL_ID,
     A.SQL_CHILD_NUMBER,
     A.BLOCKING_SESSION,
     A.PROGRAM,
     A.SQL_PLAN_HASH_VALUE
FROM
     GV$ACTIVE_SESSION_HISTORY A,
     DBA_USERS B
WHERE
     A.USER_ID=B.USER_ID AND 
     --SAMPLE_TIME > SYSDATE-1/288
     B.USERNAME NOT IN ('SYS','DBSNMP') AND
     SAMPLE_TIME BETWEEN 
        TO_TIMESTAMP('2014-12-10 14:30:00','YYYY-MM-DD HH24:MI:SS') AND 
        TO_TIMESTAMP('2014-12-10 18:00:00','YYYY-MM-DD HH24:MI:SS')
ORDER BY SAMPLE_TIME;


SET LIN 200 PAGES 400
BREAK ON SAMPLE_TIME SKIP 2
COL WAIT_CLASS FORMAT a15
COL TOT_SECONDS FORMAT 9999990.99
COL MIN_SECONDS FORMAT 9999990.99
COL MAX_SECONDS FORMAT 9999990.99
COL AVG_SECONDS FORMAT 9999990.99
COL MED_SECONDS FORMAT 9999990.99
COL STD_SECONDS FORMAT 9999990.99
COL "SECONDS/SESSIONS" format 999990.9999999
SELECT 
     TO_CHAR(SAMPLE_TIME,'YYYY-MM-DD HH24') SAMPLE_TIME,
     NVL(WAIT_CLASS,'NULL'),
     COUNT(*) SESSIONS,
     SUM(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) TOT_SECONDS,
     MIN(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) MIN_SECONDS, 
     MAX(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) MAX_SECONDS,
     AVG(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) AVG_SECONDS,
     MEDIAN(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) MED_SECONDS,
     STDDEV(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) MED_SECONDS,
     (sum(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000))/count(*) "SECONDS/SESSIONS"
FROM 
     --DBA_HIST_ACTIVE_SESS_HISTORY
     GV$ACTIVE_SESSION_HISTORY
--WHERE
     --WAIT_CLASS = 'Application' AND
     --INSTANCE_NUMBER=3 AND
     --SAMPLE_TIME BETWEEN TO_TIMESTAMP('2011-03-15 00:00:00','YYYY-MM-DD HH24:MI:SS') AND TO_TIMESTAMP('2011-03-17 00:00:00','YYYY-MM-DD HH24:MI:SS')
GROUP BY 
     TO_CHAR(SAMPLE_TIME,'YYYY-MM-DD HH24'), NVL(WAIT_CLASS,'NULL')
--HAVING 
     --(sum(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000))/count(*) > 1
ORDER BY 1
/




COL EVENT FORMAT a60
COL TOT_SECONDS FORMAT 9999990.99
COL MIN_SECONDS FORMAT 9999990.99
COL MAX_SECONDS FORMAT 9999990.99
COL AVG_SECONDS FORMAT 9999990.99
COL MED_SECONDS FORMAT 9999990.99
COL STD_SECONDS FORMAT 9999990.99
COL "SECONDS/SESSIONS" format 999990.9999999
SELECT 
     TO_CHAR(SAMPLE_TIME,'YYYY-MM-DD HH24') SAMPLE_TIME,
     EVENT,
     COUNT(*) SESSIONS,
     SUM(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) TOT_SECONDS,
     MIN(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) MIN_SECONDS, 
     MAX(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) MAX_SECONDS,
     AVG(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) AVG_SECONDS,
     MEDIAN(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) MED_SECONDS,
     STDDEV(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) MED_SECONDS,
     (sum(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000))/count(*) "SECONDS/SESSIONS"
FROM 
     --DBA_HIST_ACTIVE_SESS_HISTORY
     GV$ARCHIVE_SESSION_HISTORY
WHERE
     --EVENT IS NOT NULL AND
     --WAIT_CLASS <> 'Idle' AND 
     --INSTANCE_NUMBER=3 AND
     --SAMPLE_TIME BETWEEN TO_TIMESTAMP('2011-03-14 00:00:00','YYYY-MM-DD HH24:MI:SS') AND TO_TIMESTAMP('2011-03-14 23:59:59','YYYY-MM-DD HH24:MI:SS')
GROUP BY 
     TO_CHAR(SAMPLE_TIME,'YYYY-MM-DD HH24'), EVENT
     --HAVING MAX(TIME_WAITED/1000000)+sum(WAIT_TIME/1000000) > 1
ORDER BY 1
/





---- 10g

set lin 400 pages 400
col sample_time format a30
col instance_number format a2
col event format a30
col program format a30
col BLOCKING_INST_ID format a2
col seconds format 9999990.9999
BREAK ON SAMPLE_TIME SKIP 2
SELECT 
     A.SAMPLE_TIME,
     to_char(A.INSTANCE_NUMBER) INSTANCE_NUMBER,
     B.USERNAME,
     A.SESSION_ID,
     A.EVENT,
     A.SEQ#,
     A.SESSION_STATE,
     A.WAIT_TIME,
     A.TIME_WAITED,
     --A.DELTA_TIME/1000000 DELTA_SECS,
     A.SQL_ID,
     A.SQL_PLAN_HASH_VALUE,
     A.CURRENT_OBJ#,
     A.BLOCKING_SESSION,
     A.BLOCKING_SESSION_STATUS,
     --to_char(A.BLOCKING_INST_ID) BLOCKING_INST_ID,
     A.PROGRAM
FROM
     DBA_HIST_ACTIVE_SESS_HISTORY A,
     DBA_USERS B
WHERE
     A.USER_ID=B.USER_ID AND
     --(A.WAIT_TIME + A.TIME_WAITED)/1000000 > 10 AND
     --A.EVENT IS NULL AND
     SAMPLE_TIME BETWEEN 
        TO_TIMESTAMP('2012-06-12 05:05:00','YYYY-MM-DD HH24:MI:SS') AND 
        TO_TIMESTAMP('2012-06-12 05:06:00','YYYY-MM-DD HH24:MI:SS')
ORDER BY SAMPLE_TIME;



set lin 400 pages 400
col sample_time format a30
col instance_number format a2
col event format a30
col program format a30
col BLOCKING_INST_ID format a2
col seconds format 9999990.9999
BREAK ON SAMPLE_TIME SKIP 2
SELECT 
     A.SAMPLE_TIME,
     A.INST_ID,
     B.USERNAME,
     A.SESSION_ID,
     A.EVENT,
     A.SEQ#,
     A.SESSION_STATE,
     A.WAIT_TIME,
     A.TIME_WAITED,
     --A.DELTA_TIME/1000000 DELTA_SECS,
     A.SQL_ID,
     A.SQL_PLAN_HASH_VALUE,
     A.CURRENT_OBJ#,
     A.BLOCKING_SESSION,
     A.BLOCKING_SESSION_STATUS,
     --to_char(A.BLOCKING_INST_ID) BLOCKING_INST_ID,
     A.PROGRAM
FROM
     gv$active_session_history A,
     DBA_USERS B
WHERE
     A.USER_ID=B.USER_ID AND
     --(A.WAIT_TIME + A.TIME_WAITED)/1000000 > 10 AND
     --A.EVENT = 'enq: TM - contention'
     SAMPLE_TIME BETWEEN 
        TO_TIMESTAMP('2012-06-12 05:05:00','YYYY-MM-DD HH24:MI:SS') AND 
        TO_TIMESTAMP('2012-06-12 05:06:00','YYYY-MM-DD HH24:MI:SS')
ORDER BY SAMPLE_TIME;




set lin 400 pages 400
col sample_time format a30
col instance_number format a2
col event format a30
col program format a30
col BLOCKING_INST_ID format a2
col seconds format 9999990.9999
BREAK ON SAMPLE_TIME SKIP 2
SELECT distinct(sql_id)
FROM
     gv$active_session_history A,
     DBA_USERS B
WHERE
     A.USER_ID=B.USER_ID AND
     --(A.WAIT_TIME + A.TIME_WAITED)/1000000 > 10 AND
     A.EVENT = 'enq: TM - contention'
--     SAMPLE_TIME BETWEEN 
--        TO_TIMESTAMP('2012-06-12 05:05:00','YYYY-MM-DD HH24:MI:SS') AND 
--        TO_TIMESTAMP('2012-06-12 05:06:00','YYYY-MM-DD HH24:MI:SS')
ORDER BY SAMPLE_TIME;




--------------------------------------------------


set lin 400 pages 400
col sample_time format a30
col instance_number format 9
BREAK ON SAMPLE_TIME SKIP 2
SELECT 
     A.SAMPLE_TIME,
     A.INST_ID,
     B.USERNAME,
     A.SESSION_ID,
     A.EVENT,
     A.SEQ#,
     A.SESSION_STATE,
     (A.WAIT_TIME + A.TIME_WAITED)/1000000 SECONDS,
     A.SQL_ID,
     A.SQL_CHILD_NUMBER,
     A.BLOCKING_SESSION,
     A.PROGRAM
FROM
     GV$ACTIVE_SESSION_HISTORY A,
     DBA_USERS B
WHERE
     A.USER_ID=B.USER_ID AND 
     SAMPLE_TIME > SYSDATE-1/288
ORDER BY SAMPLE_TIME;






select B.username, A.sql_id, A.SQL_CHILD_NUMBER, count(*) 
FROM
     GV$ACTIVE_SESSION_HISTORY A,
     DBA_USERS B
WHERE
     	A.USER_ID=B.USER_ID AND 
	A.SAMPLE_TIME > SYSDATE-1/288 AND
	A.event like 'latch%' or A.session_state='ON CPU'
having count(*) > 1000
group by B.username, A.sql_id, A.SQL_CHILD_NUMBER order by 4;




select B.username, A.sql_id, A.SQL_CHILD_NUMBER, count(*) 
FROM
     GV$ACTIVE_SESSION_HISTORY A,
     DBA_USERS B
WHERE
     	A.USER_ID=B.USER_ID AND 
	A.SAMPLE_TIME > SYSDATE-1/288 AND
	A.event like 'latch%' or A.session_state='ON CPU'
--having count(*) > 1000
group by B.username, A.sql_id, A.SQL_CHILD_NUMBER order by 3;


-----------------------------------------------------------------
select sql_id, sql_child_number, count(*) 
FROM
     GV$ACTIVE_SESSION_HISTORY
WHERE
	SAMPLE_TIME > SYSDATE-1/288 AND
	(event like 'latch%' or session_state='ON CPU')
group by sql_id, sql_child_number 
having count(*) > 100
order by 3;

select 'select * from table(dbms_xplan.display_cursor('''||sql_id||''','||sql_child_number||')); -- '|| cnt from (
select sql_id, sql_child_number, count(*) cnt
FROM
     GV$ACTIVE_SESSION_HISTORY
WHERE
	SAMPLE_TIME > SYSDATE-1/1440 AND
	(event like 'latch%' or session_state='ON CPU')
group by sql_id, sql_child_number 
having count(*) > 50
order by 3
)
;

-----------------------------------------------------------------



select SESSION_ID, SESSION_SERIAL#, sql_id, SQL_CHILD_NUMBER,count(*) 
FROM
     GV$ACTIVE_SESSION_HISTORY
WHERE
     SAMPLE_TIME BETWEEN 
        TO_TIMESTAMP('2012-09-11 11:00:00','YYYY-MM-DD HH24:MI:SS') AND 
        TO_TIMESTAMP('2012-09-11 11:30:00','YYYY-MM-DD HH24:MI:SS') and 
	(event like 'latch%' or session_state='ON CPU') and
	SESSION_TYPE='FOREGROUND'
having count(*) > 100
group by SESSION_ID, SESSION_SERIAL#, sql_id,SQL_CHILD_NUMBER order by 5;


select user_id, sql_id, SQL_CHILD_NUMBER,count(*) cnt
FROM
     DBA_HIST_ACTIVE_SESS_HISTORY
WHERE
     SAMPLE_TIME BETWEEN 
        TO_TIMESTAMP('2012-09-11 11:00:00','YYYY-MM-DD HH24:MI:SS') AND 
        TO_TIMESTAMP('2012-09-11 12:00:00','YYYY-MM-DD HH24:MI:SS') and 
	(event like 'latch%' or session_state='ON CPU') and
	SESSION_TYPE='FOREGROUND'
group by user_id, sql_id, SQL_CHILD_NUMBER 
having count(*) > 10
order by cnt;



select sql_id, child_number, 
       EXECUTIONS/(ELAPSED_TIME/1000000) execs_per_sec, 
       (ELAPSED_TIME/1000000)/EXECUTIONS secs_per_exec, 
       (cpu_time/1000000)/EXECUTIONS cpu_secs_per_exec,
       (BUFFER_GETS/EXECUTIONS) buffer_gets_per_exec
from v$sql where (sql_id,child_number) in (select sql_id, SQL_CHILD_NUMBER cnt
FROM
     DBA_HIST_ACTIVE_SESS_HISTORY
WHERE
     SAMPLE_TIME BETWEEN 
        TO_TIMESTAMP('2012-09-11 11:00:00','YYYY-MM-DD HH24:MI:SS') AND 
        TO_TIMESTAMP('2012-09-11 12:00:00','YYYY-MM-DD HH24:MI:SS') and 
	(event like 'latch%' or session_state='ON CPU') and
	SESSION_TYPE='FOREGROUND'
group by sql_id, SQL_CHILD_NUMBER 
having count(*) > 30)
;
