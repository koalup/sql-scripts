SET NUMFORMAT 999,999,999,999.0 LIN 400 PAGES 200 TAB OFF
COL DAY FORMAT A3
COL SNAPSHOTS FORMAT A15
COL BEGIN_TIME FORMAT A20
COL END_TIME FORMAT A20
BREAK ON DAY SKIP PAGE
SELECT
  TO_CHAR(C.BEGIN_INTERVAL_TIME,'DY') "DAY"
  ,C.SNAP_ID-1 ||'-'|| C.SNAP_ID "SNAPSHOTS"
  ,TO_CHAR(C.BEGIN_INTERVAL_TIME,'YYYY-MM-DD HH24:MI') "BEGIN_TIME"
  ,TO_CHAR(C.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI') "END_TIME"
  ,AVG(DECODE(B.EVENT_NAME,'db file sequential read'    ,((B.TIME_WAITED_MICRO - A.TIME_WAITED_MICRO)/1000)/nullif(B.TOTAL_WAITS-A.TOTAL_WAITS,0))) "db file sequential read"
  ,AVG(DECODE(B.EVENT_NAME,'db file scattered read'     ,((B.TIME_WAITED_MICRO - A.TIME_WAITED_MICRO)/1000)/nullif(B.TOTAL_WAITS-A.TOTAL_WAITS,0))) "db file scattered read"
  ,AVG(DECODE(B.EVENT_NAME,'direct path read'           ,((B.TIME_WAITED_MICRO - A.TIME_WAITED_MICRO)/1000)/nullif(B.TOTAL_WAITS-A.TOTAL_WAITS,0))) "direct path read"
  ,AVG(DECODE(B.EVENT_NAME,'direct path read temp'      ,((B.TIME_WAITED_MICRO - A.TIME_WAITED_MICRO)/1000)/nullif(B.TOTAL_WAITS-A.TOTAL_WAITS,0))) "direct path read temp"
  ,AVG(DECODE(B.EVENT_NAME,'direct path write'          ,((B.TIME_WAITED_MICRO - A.TIME_WAITED_MICRO)/1000)/nullif(B.TOTAL_WAITS-A.TOTAL_WAITS,0))) "direct path write"
  ,AVG(DECODE(B.EVENT_NAME,'direct path write temp'     ,((B.TIME_WAITED_MICRO - A.TIME_WAITED_MICRO)/1000)/nullif(B.TOTAL_WAITS-A.TOTAL_WAITS,0))) "direct path write temp"
  ,AVG(DECODE(B.EVENT_NAME,'log file sync'              ,((B.TIME_WAITED_MICRO - A.TIME_WAITED_MICRO)/1000)/nullif(B.TOTAL_WAITS-A.TOTAL_WAITS,0))) "log file sync"
  ,AVG(DECODE(B.EVENT_NAME,'log file parallel write'    ,((B.TIME_WAITED_MICRO - A.TIME_WAITED_MICRO)/1000)/nullif(B.TOTAL_WAITS-A.TOTAL_WAITS,0))) "log file parallel write"
  ,AVG(DECODE(B.EVENT_NAME,'log buffer space'           ,((B.TIME_WAITED_MICRO - A.TIME_WAITED_MICRO)/1000)/nullif(B.TOTAL_WAITS-A.TOTAL_WAITS,0))) "log buffer space"
FROM
  DBA_HIST_SYSTEM_EVENT A, 
  DBA_HIST_SYSTEM_EVENT B,
  DBA_HIST_SNAPSHOT C
WHERE 
      B.SNAP_ID = A.SNAP_ID+1
  AND B.EVENT_ID = A.EVENT_ID
  AND B.INSTANCE_NUMBER = A.INSTANCE_NUMBER
  AND B.SNAP_ID=C.SNAP_ID 
  AND B.INSTANCE_NUMBER = C.INSTANCE_NUMBER
  AND B.EVENT_NAME in (
     'db file sequential read'
    ,'db file scattered read' 
    ,'direct path read'       
    ,'direct path read temp'  
    ,'direct path write'      
    ,'direct path write temp' 
    ,'log file sync'          
    ,'log file parallel write'
    ,'log buffer space'
  )
  AND C.END_INTERVAL_TIME > TRUNC(SYSDATE) - NVL(TO_NUMBER('&SHOW_DAYS'),1)
GROUP BY
   TO_CHAR(C.BEGIN_INTERVAL_TIME,'DY')
  ,C.SNAP_ID-1 ||'-'|| C.SNAP_ID
  ,TO_CHAR(C.BEGIN_INTERVAL_TIME,'YYYY-MM-DD HH24:MI')
  ,TO_CHAR(C.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI')
ORDER BY
  SNAPSHOTS
;














-- NO WORKIE IN RAC...

col "db file sequential read_AVGMS" for 999.99 HEADING 'db file|sequential read| avg ms'
col "db file scattered read_AVGMS"  for 999.99 HEADING 'db file|scattered read| avg ms'
col "direct path read_AVGMS"        for 999.99 HEADING 'direct|path read| avg ms'
col "direct path read temp_AVGMS"   for 999.99 HEADING 'direct|path read temp| avg ms'
col "direct path write_AVGMS"       for 999.99 HEADING 'direct|path write| avg ms'
col "direct path write temp_AVGMS"  for 999.99 HEADING 'direct|path write temp| avg ms'
col "log file sync_AVGMS"           for 999.99 HEADING 'log file|sync| avg ms'
col "log file parallel write_AVGMS" for 999.99 HEADING 'log file|parallel write| avg ms'
col instance_number for 99 HEADING 'I';
select * from (
select s.instance_number,
       s.snap_id || '-' || to_char(s.snap_id + 1) as snaps,
       s.BEGIN_INTERVAL_TIME btime,
       e.event_name,
       total_waits count_end,
       time_waited_micro/1000 time_ms_end,
       Lag (e.time_waited_micro/1000)
              OVER( PARTITION BY e.event_name ORDER BY s.snap_id) time_ms_beg,
       Lag (e.total_waits)
              OVER( PARTITION BY e.event_name ORDER BY s.snap_id) count_beg
from
       DBA_HIST_SYSTEM_EVENT e,
       DBA_HIST_SNAPSHOT s
where  s.snap_id=e.snap_id
       and s.dbid = e.dbid
       and s.instance_number = e.instance_number
       and e.event_name in (
         'db file sequential read','db file scattered read','direct path read','direct path read temp',
         'direct path write','direct path write temp', 'log file sync','log file parallel write')
       and begin_interval_time > trunc(sysdate) - nvl(to_number('&SHOW_DAYS'),1)
) pivot_data
PIVOT (
  max(round((time_ms_end-time_ms_beg)/nullif(count_end-count_beg,0),3)) AVGMS
  for event_name in (
       'db file sequential read' as "db file sequential read" ,
       'db file scattered read'  as "db file scattered read",
       'direct path read'        as "direct path read",
       'direct path read temp'   as "direct path read temp",
       'direct path write'       as "direct path write",
       'direct path write temp'  as "direct path write temp",
       'log file sync'           as "log file sync",
       'log file parallel write' as "log file parallel write")
)
order by snaps , instance_number
;