For your reference, this is how I loaded the plan. 

0gyj3akt4hqna        4120562747

First, I loaded the bad plan that was in memory and set it to be disabled in the baseline. This will give us a reference:

SET SERVEROUTPUT ON
DECLARE
  l_plans_loaded  PLS_INTEGER;
BEGIN
  l_plans_loaded := DBMS_SPM.load_plans_from_cursor_cache(
    sql_id => '248csppx0g8h2',
    enabled=> 'NO'
  );
  DBMS_OUTPUT.put_line('Plans Loaded: ' || l_plans_loaded);
END;
/




Second, I created an sql tuning set (required when loading plans from AWR)

begin
  dbms_sqltune.create_sqlset (
    sqlset_name => 'f6yj3sk7p5747_from_awr',
    description => 'load f6yj3sk7p5747 from awr'
  );
end;
/

begin
  dbms_sqltune.delete_sqlset (
    sqlset_name => 'f6yj3sk7p5747_from_awr'
  );
end;
/


I had to get the AWR snapshot id's that the good plan was in:

select snap_id from dba_hist_active_sess_history where sql_id='248csppx0g8h2' and SQL_PLAN_HASH_VALUE=4188821491;

Then I loaded the plan from awr into the sql tuning set (passing in the begin and end snapshot id's)

declare
  ref_cur DBMS_SQLTUNE.SQLSET_CURSOR;
begin
  open ref_cur for
  select VALUE(p) from table(DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(&begin_snap, &end_snap, basic_filter=>'plan_hash_value=&plan_hash', attribute_list =>'ALL')) p;
  DBMS_SQLTUNE.LOAD_SQLSET('&sqlset_name', ref_cur);
end;
/


select * from DBA_SQLSET where NAME='&sqlset_name';
select count(*) from DBA_SQLSET_PLANS where SQLSET_NAME='&sqlset_name'


Then I loaded the plan into the baseline from the sql tuning set (and set it to be disabled)

set serveroutput on
declare
v_int pls_integer;
begin
   v_int := dbms_spm.load_plans_from_sqlset (sqlset_name => '&sqlset_name',sqlset_owner => 'SYS',basic_filter => 'sql_id=''&sql_id'' and plan_hash_value = ''&plan_hash''',fixed => 'NO',enabled => 'NO');
   DBMS_OUTPUT.PUT_line(v_int);
end;
/

Then I enabled the sql baseline

SET SERVEROUTPUT ON
DECLARE
  l_plans_altered  PLS_INTEGER;
BEGIN
  l_plans_altered := DBMS_SPM.alter_sql_plan_baseline(
    sql_handle      => '&sql_handle',
    plan_name       => '&plan_name',
    attribute_name  => 'enabled',
    attribute_value => 'NO'
  );
  DBMS_OUTPUT.put_line('Plans Altered: ' || l_plans_altered);
END;
/

Check the baselines:

COL SIGNATURE FORMAT 99999999999999999999999
COL SQL_TEXT TRUNC
COL SQL_HANDLE format a30
col plan_name format a30
col CREATED format a30
SELECT 
		SIGNATURE,
        SQL_HANDLE, 
        PLAN_NAME, 
		CREATED,
		SQL_TEXT,
        ENABLED, 
        ACCEPTED, 
        FIXED
        --OPTIMIZER_COST
        --EXECUTIONS
        --ELAPSED_TIME/1000000,
        --CPU_TIME,
        --BUFFER_GETS,
        --DISK_READS      
FROM   DBA_SQL_PLAN_BASELINES WHERE ENABLED='YES' AND ACCEPTED='YES'
ORDER BY CREATED;


col sql_text trunc
col sql_handle format a30
col plan_name format a30
col signature format 9999999999999999999999
select signature, sql_handle, PLAN_NAME, created, SQL_TEXT from dba_sql_plan_baselines where enabled='YES' and accepted='YES';


Check the plan for a specific baseline:

SELECT * FROM   TABLE(DBMS_XPLAN.display_sql_plan_baseline(plan_name=>'&plan_name'));
