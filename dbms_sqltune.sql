-- http://docs.oracle.com/cd/E11882_01/appdev.112/e25788/d_sqltun.htm#CHDIHAIH

set lin 400 pages 10000 long 99999999 longc 400

SELECT 
  DBMS_SQLTUNE.REPORT_SQL_MONITOR_LIST(
    sql_id                    => NULL,
    session_id                => NULL,
    session_serial            => NULL,
    inst_id                   => NULL,
    active_since_date         => NULL,
    active_since_sec          => 3600,
    last_refresh_time         => NULL,
    report_level              => 'TYPICAL',
    auto_refresh              => NULL,
    base_path                 => NULL,
    type                      => 'TEXT'
  ) from dual;

SELECT 
  DBMS_SQLTUNE.REPORT_SQL_MONITOR(
    sql_id                    => '078d1p4k5vy1t',
    session_id                => NULL,
    session_serial            => NULL,
    sql_exec_start            => NULL, -- to_date('2013-04-08 23:00:00','YYYY-MM-DD HH24:MI:SS'),
    sql_exec_id               => NULL,
    inst_id                   => NULL,
    start_time_filter         => NULL,
    end_time_filter           => NULL,
    instance_id_filter        => NULL,
    parallel_filter           => NULL,
    plan_line_filter          => NULL,
    event_detail              => 'YES',
    bucket_max_count          => 128,
    bucket_interval           => NULL,
    base_path                 => NULL,
    last_refresh_time         => NULL,
    report_level              => 'ALL',
    type                      => 'TEXT',
    sql_plan_hash_value       => NULL
  ) from dual;

SELECT
  DBMS_SQLTUNE.REPORT_SQL_DETAIL(
    sql_id                   => '078d1p4k5vy1t',
    sql_plan_hash_value      => NULL,
    start_time               => NULL,
    duration                 => NULL,
    inst_id                  => NULL,
    dbid                     => NULL,
    event_detail             => 'YES',
    bucket_max_count         => 128,
    bucket_interval          => NULL,
    top_n                    => 10,
    report_level             => 'ALL',
    type                     => 'ACTIVE'
  ) from dual;
