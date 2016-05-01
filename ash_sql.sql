select * from table (
  dbms_workload_repository.ash_report_text(
    (select dbid from v$database ),
    (select instance_number from v$instance),
    SYSDATE - 60/1440 ,
    SYSDATE,
    0,0,null,
    '&sql_id'
  )   
)