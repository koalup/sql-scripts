ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD.HH24:MI';
SET NUMFORMAT 999,999,999,999.0 LIN 400 PAGES 200 TAB OFF
COL END_SNAP FORMAT 99999
COL SNAPSHOTS FORMAT A15
COL DAY FORMAT A3
COL BEGIN_TIME FORMAT A20
COL END_TIME FORMAT A20
BREAK ON DAY SKIP PAGE
SELECT
   TO_CHAR(C.BEGIN_INTERVAL_TIME,'DY') "DAY"
	,C.SNAP_ID-1 ||'-'|| C.SNAP_ID "SNAPSHOTS"
	,TO_CHAR(C.BEGIN_INTERVAL_TIME,'YYYY-MM-DD HH24:MI') "BEGIN_TIME"
  ,TO_CHAR(C.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI') "END_TIME"
	,SUM(DECODE(B.STAT_NAME,'redo size',					        (B.VALUE - A.VALUE)/(SYSDATE+((C.END_INTERVAL_TIME-C.BEGIN_INTERVAL_TIME)*86400) - SYSDATE))) "redo size/s"
	,SUM(DECODE(B.STAT_NAME,'session logical reads',		  (B.VALUE - A.VALUE)/(SYSDATE+((C.END_INTERVAL_TIME-C.BEGIN_INTERVAL_TIME)*86400) - SYSDATE))) "logical reads/s"
	,SUM(DECODE(B.STAT_NAME,'db block changes',				    (B.VALUE - A.VALUE)/(SYSDATE+((C.END_INTERVAL_TIME-C.BEGIN_INTERVAL_TIME)*86400) - SYSDATE))) "block changes/s"
	,SUM(DECODE(B.STAT_NAME,'physical reads',				      (B.VALUE - A.VALUE)/(SYSDATE+((C.END_INTERVAL_TIME-C.BEGIN_INTERVAL_TIME)*86400) - SYSDATE))) "physical rd/s"
	,SUM(DECODE(B.STAT_NAME,'physical writes',				    (B.VALUE - A.VALUE)/(SYSDATE+((C.END_INTERVAL_TIME-C.BEGIN_INTERVAL_TIME)*86400) - SYSDATE))) "physical wri/s"
	,SUM(DECODE(B.STAT_NAME,'physical read total bytes',	(B.VALUE - A.VALUE)/(SYSDATE+((C.END_INTERVAL_TIME-C.BEGIN_INTERVAL_TIME)*86400) - SYSDATE))) "phys rd bytes/s"
	,SUM(DECODE(B.STAT_NAME,'physical write total bytes',	(B.VALUE - A.VALUE)/(SYSDATE+((C.END_INTERVAL_TIME-C.BEGIN_INTERVAL_TIME)*86400) - SYSDATE))) "phys wri bytes/s"
	,SUM(DECODE(B.STAT_NAME,'execute count',				      (B.VALUE - A.VALUE)/(SYSDATE+((C.END_INTERVAL_TIME-C.BEGIN_INTERVAL_TIME)*86400) - SYSDATE))) "executions/s"
  ,SUM(DECODE(B.STAT_NAME,'user commits',               (B.VALUE - A.VALUE)/(SYSDATE+((C.END_INTERVAL_TIME-C.BEGIN_INTERVAL_TIME)*86400) - SYSDATE))) 
  +SUM(DECODE(B.STAT_NAME,'user rollbacks',             (B.VALUE - A.VALUE)/(SYSDATE+((C.END_INTERVAL_TIME-C.BEGIN_INTERVAL_TIME)*86400) - SYSDATE))) "transactions/s"
  ,SUM(DECODE(B.STAT_NAME,'user calls',                 (B.VALUE - A.VALUE)/(SYSDATE+((C.END_INTERVAL_TIME-C.BEGIN_INTERVAL_TIME)*86400) - SYSDATE))) "calls/s"
FROM
	DBA_HIST_SYSSTAT A, 
	DBA_HIST_SYSSTAT B,
	DBA_HIST_SNAPSHOT C
WHERE 
	    B.SNAP_ID = A.SNAP_ID+1
	AND B.STAT_NAME = A.STAT_NAME
	AND B.INSTANCE_NUMBER = A.INSTANCE_NUMBER
	AND B.SNAP_ID=C.SNAP_ID 
	AND B.INSTANCE_NUMBER = C.INSTANCE_NUMBER
	AND B.STAT_NAME in (
    'redo size',
    'session logical reads',
    'physical reads',
    'db block changes',
    'physical writes',
    'physical read total bytes',
    'physical write total bytes',
    'execute count',
    'user commits',
    'user rollbacks',
    'user calls'
  )
  AND C.END_INTERVAL_TIME > trunc(sysdate) - nvl(to_number('&SHOW_DAYS'),1)
GROUP BY
   TO_CHAR(C.BEGIN_INTERVAL_TIME,'DY')
  ,C.SNAP_ID-1 ||'-'|| C.SNAP_ID
  ,TO_CHAR(C.BEGIN_INTERVAL_TIME,'YYYY-MM-DD HH24:MI')
  ,TO_CHAR(C.END_INTERVAL_TIME,'YYYY-MM-DD HH24:MI')
ORDER BY
	SNAPSHOTS
;







                                                                                                                                      Avg Active
  I# Instance  Host       Startup         Begin Snap Time End Snap Time   Release         Elapsed Time(min) DB time(min) Up Time(hrs)   Sessions Platform
---- --------- ---------- --------------- --------------- --------------- --------------- ----------------- ------------ ------------ ---------- ---------------
   1 DD4531    y0319t791  16-Feb-16 17:08 19-Feb-16 17:30 19-Feb-16 18:00 11.2.0.3.0                  30.03         0.15        72.86       0.01 Linux x86 64-bi
   2 DD4532    y0319t792  16-Feb-16 21:38 19-Feb-16 17:30 19-Feb-16 18:00 11.2.0.3.0                  30.03         0.16        68.37       0.01 Linux x86 64-bi
   3 DD4533    y0319t793  18-Feb-16 12:07 19-Feb-16 17:30 19-Feb-16 18:00 11.2.0.3.0                  30.03         0.13        29.89       0.00 Linux x86 64-bi


Database Summary
~~~~~~~~~~~~~~~~
              Database                    Snapshot Ids     Number of Instances     Number of Hosts     Report Total (minutes)
------------------------------------   -----------------   ------------------   ------------------   ------------------------
         Id Name      RAC Block Size      Begin      End   In Report    Total   In Report    Total       DB time Elapsed time
----------- --------- --- ----------   -------- --------   --------- --------   --------- --------   ----------- ------------
  473377021 DD453     YES       8192      35846    35847           3        3           3        3          0.45        30.03

System Statistics - Per Second       DB/Inst: DD453/DD4531  Snaps: 35846-35847

             Logical     Physical     Physical         Redo        Block         User
  I#         Reads/s      Reads/s     Writes/s   Size (k)/s    Changes/s      Calls/s      Execs/s     Parses/s   Logons/s       Txns/s
---- --------------- ------------ ------------ ------------ ------------ ------------ ------------ ------------ ---------- ------------
   1          822.33          0.1          0.4          1.4        202.9          0.3          2.3          0.4       0.02          0.0
   2          807.67          0.1          0.5          1.4        195.6          0.5          2.7          0.7       0.02          0.1
   3          749.87          0.1          0.3          1.0        183.2          0.3          2.0          0.3       0.02          0.0
 ~~~ ~~~~~~~~~~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~~ ~~~~~~~~~~~~
 Sum        2,379.87          0.3          1.1          3.7        581.7          1.1          7.0          1.4       0.05          0.1
 Avg          793.29          0.1          0.4          1.2        193.9          0.4          2.3          0.5       0.02          0.0
 Std           38.31          0.0          0.1          0.2         10.0          0.1          0.3          0.2       0.00          0.0
                          --------------------------------------------------------------------------------------------------------------------



END_SNAP END_TIME                   redo size/s    logical reads/s    block changes/s   physical reads/s  physical writes/s physical read bytes/s physical write bytes/s       executions/s
-------- ------------------- ------------------ ------------------ ------------------ ------------------ ------------------ --------------------- ---------------------- ------------------
   35839 2016-02-19.14:30:08            3,991.3            2,341.7              569.9                 .4                1.2           1,372,182.9              128,381.6                7.3
   35840 2016-02-19.15:00:04            3,820.2            2,402.4              588.8                 .3                1.1             690,986.0              126,632.3                7.1
   35841 2016-02-19.15:30:09            3,867.5            2,331.8              569.3                 .4                1.1           1,372,029.6              127,703.9                7.2
   35842 2016-02-19.16:00:14            3,890.7            2,397.5              586.5                 .4                1.2             689,066.9              128,975.5                7.1
   35843 2016-02-19.16:30:16            3,874.9            2,344.4              572.2                 .4                1.2           1,374,036.2              128,841.2                7.2
   35844 2016-02-19.17:00:18            3,811.0            2,400.8              587.5                 .3                1.1             688,948.5              126,128.7                7.0
   35845 2016-02-19.17:30:21            3,920.9            2,331.3              568.2                 .3                1.1           1,372,519.5              126,627.3                7.2
   35846 2016-02-19.18:00:23            3,839.1            2,379.9              581.7                 .3                1.1             689,334.8              126,960.0                7.0
   35847 2016-02-19.18:30:04            3,686.3            2,359.0              575.2                 .3                1.1           1,383,594.1              126,775.3                7.3



              Snap Id      Snap Time      Sessions Curs/Sess
            --------- ------------------- -------- ---------
Begin Snap:      8019 16-Feb-16 09:30:25     2,649       3.1
  End Snap:      8020 16-Feb-16 10:00:27     2,650       3.1
   Elapsed:               30.02 (mins)
   DB Time:              740.93 (mins)

Cache Sizes                       Begin        End
~~~~~~~~~~~                  ---------- ----------
               Buffer Cache:    22,656M    22,656M  Std Block Size:         8K
           Shared Pool Size:    20,480M    20,480M      Log Buffer:   288,028K

Load Profile              Per Second    Per Transaction   Per Exec   Per Call
~~~~~~~~~~~~         ---------------    --------------- ---------- ----------
      DB Time(s):               24.7                0.0       0.00       0.00
       DB CPU(s):                5.8                0.0       0.00       0.00
       Redo size:        3,673,851.0            3,431.4
   Logical reads:        1,058,783.8              988.9
   Block changes:           22,942.9               21.4
  Physical reads:            3,394.2                3.2
 Physical writes:              657.0                0.6
      User calls:           31,624.6               29.5
          Parses:                8.9                0.0
     Hard parses:                0.0                0.0
W/A MB processed:              117.5                0.1
          Logons:                0.1                0.0
        Executes:           13,281.2               12.4
       Rollbacks:              547.9                0.5
    Transactions:            1,070.7

END_SNAP END_TIME                    redo size/s    logical reads/s    block changes/s   physical reads/s  physical writes/s physical read bytes/s physical write bytes/s       executions/s
-------- -------------------- ------------------ ------------------ ------------------ ------------------ ------------------ --------------------- ---------------------- ------------------
    8020 2016-02-16.10:30:28         2,646,039.7        1,242,049.9           17,745.4            2,406.1              522.1          22,524,498.7           17,866,331.5            8,688.2


set lines 140 pages 45
accept num_days prompt 'Enter the number of days to report on [default is 0.5]: '
set verify off

col SNAPSHOTTIME format a15
col REDO_GRAPH format a20
col READ_GRAPH format a20
col WRITE_GRAPH format a20
 
SELECT redo_hist.snap_id AS SnapshotID
,      TO_CHAR(redo_hist.snaptime, 'DD-MON HH24:MI:SS') as SnapshotTime
,      ROUND(redo_hist.statval/elapsed_time/1048576,2) AS Redo_MBsec
,      SUBSTR(RPAD('*', 20 * ROUND ((redo_hist.statval/elapsed_time) / MAX (redo_hist.statval/elapsed_time) OVER (), 2), '*'), 1, 20) AS Redo_Graph
,      ROUND(physical_read_hist.statval/elapsed_time/1048576,2) AS Read_MBsec
,      SUBSTR(RPAD('*', 20 * ROUND ((physical_read_hist.statval/elapsed_time) / MAX (physical_read_hist.statval/elapsed_time) OVER (), 2), '*'), 1, 20) AS Read_Graph
,      ROUND(physical_write_hist.statval/elapsed_time/1048576,2) AS Write_MBsec
,      SUBSTR(RPAD('*', 20 * ROUND ((physical_write_hist.statval/elapsed_time) / MAX (physical_write_hist.statval/elapsed_time) OVER (), 2), '*'), 1, 20) AS Write_Graph
FROM (SELECT s.snap_id
            ,g.value AS stattot
            ,s.end_interval_time AS snaptime
            ,NVL(DECODE(GREATEST(VALUE, NVL(lag (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                 ORDER BY s.snap_id), 0)), VALUE, VALUE - LAG (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                     ORDER BY s.snap_id), VALUE), 0) AS statval
            ,(EXTRACT(day FROM s.end_interval_time)-EXTRACT(day FROM s.begin_interval_time))*86400 +
             (EXTRACT(hour FROM s.end_interval_time)-EXTRACT(hour FROM s.begin_interval_time))*3600 +
             (EXTRACT(minute FROM s.end_interval_time)-EXTRACT(minute FROM s.begin_interval_time))*60 +
             (EXTRACT(second FROM s.end_interval_time)-EXTRACT(second FROM s.begin_interval_time)) as elapsed_time
        FROM dba_hist_snapshot s,
             dba_hist_sysstat g,
             v$instance i
       WHERE s.snap_id = g.snap_id
         AND s.begin_interval_time >= sysdate-NVL('&num_days', 0.5)
         AND s.instance_number = i.instance_number
         AND s.instance_number = g.instance_number
         AND g.stat_name = 'redo size') redo_hist,
     (SELECT s.snap_id
            ,g.value AS stattot
            ,NVL(DECODE(GREATEST(VALUE, NVL(lag (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                 ORDER BY s.snap_id), 0)), VALUE, VALUE - LAG (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                     ORDER BY s.snap_id), VALUE), 0) AS statval
        FROM dba_hist_snapshot s,
             dba_hist_sysstat g,
             v$instance i
       WHERE s.snap_id = g.snap_id
         AND s.begin_interval_time >= sysdate-NVL('&num_days', 0.5)
         AND s.instance_number = i.instance_number
         AND s.instance_number = g.instance_number
         AND g.stat_name = 'physical read total bytes') physical_read_hist,
     (SELECT s.snap_id
            ,g.value AS stattot
            ,NVL(DECODE(GREATEST(VALUE, NVL(lag (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                 ORDER BY s.snap_id), 0)), VALUE, VALUE - LAG (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                     ORDER BY s.snap_id), VALUE), 0) AS statval
        FROM dba_hist_snapshot s,
             dba_hist_sysstat g,
             v$instance i
       WHERE s.snap_id = g.snap_id
         AND s.begin_interval_time >= sysdate-NVL('&num_days', 0.5)
         AND s.instance_number = i.instance_number
         AND s.instance_number = g.instance_number
         AND g.stat_name = 'physical write total bytes') physical_write_hist
WHERE redo_hist.snap_id = physical_read_hist.snap_id
  AND redo_hist.snap_id = physical_write_hist.snap_id
ORDER BY 1;

---------------------------------------------------------------

SELECT redo_hist.snap_id AS SnapshotID
,      TO_CHAR(redo_hist.snaptime, 'DD-MON HH24:MI:SS') as SnapshotTime
,      ROUND(redo_hist.statval/elapsed_time,2) AS Redo_Size
--,      SUBSTR(RPAD('*', 20 * ROUND ((redo_hist.statval/elapsed_time) / MAX (redo_hist.statval/elapsed_time) OVER (), 2), '*'), 1, 20) AS Redo_Graph
,      ROUND(physical_read_hist.statval/elapsed_time,1) AS Physical_Reads
--,      SUBSTR(RPAD('*', 20 * ROUND ((physical_read_hist.statval/elapsed_time) / MAX (physical_read_hist.statval/elapsed_time) OVER (), 2), '*'), 1, 20) AS Read_Graph
,      ROUND(physical_write_hist.statval/elapsed_time,1) AS Physical_Writes
--,      SUBSTR(RPAD('*', 20 * ROUND ((physical_write_hist.statval/elapsed_time) / MAX (physical_write_hist.statval/elapsed_time) OVER (), 2), '*'), 1, 20) AS Write_Graph
,	   ROUND(logical_read_hist.statval/elapsed_time,1) AS Logical_Reads
FROM (SELECT s.snap_id
            ,g.value AS stattot
            ,s.end_interval_time AS snaptime
            ,NVL(DECODE(GREATEST(VALUE, NVL(lag (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                 ORDER BY s.snap_id), 0)), VALUE, VALUE - LAG (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                     ORDER BY s.snap_id), VALUE), 0) AS statval
            ,(EXTRACT(day FROM s.end_interval_time)-EXTRACT(day FROM s.begin_interval_time))*86400 +
             (EXTRACT(hour FROM s.end_interval_time)-EXTRACT(hour FROM s.begin_interval_time))*3600 +
             (EXTRACT(minute FROM s.end_interval_time)-EXTRACT(minute FROM s.begin_interval_time))*60 +
             (EXTRACT(second FROM s.end_interval_time)-EXTRACT(second FROM s.begin_interval_time)) as elapsed_time
        FROM dba_hist_snapshot s,
             dba_hist_sysstat g,
             v$instance i
       WHERE s.snap_id = g.snap_id
         AND s.begin_interval_time >= sysdate-NVL('&num_days', 0.5)
         AND s.instance_number = i.instance_number
         AND s.instance_number = g.instance_number
         AND g.stat_name = 'redo size') redo_hist,
     (SELECT s.snap_id
            ,g.value AS stattot
            ,NVL(DECODE(GREATEST(VALUE, NVL(lag (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                 ORDER BY s.snap_id), 0)), VALUE, VALUE - LAG (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                     ORDER BY s.snap_id), VALUE), 0) AS statval
        FROM dba_hist_snapshot s,
             dba_hist_sysstat g,
             v$instance i
       WHERE s.snap_id = g.snap_id
         AND s.begin_interval_time >= sysdate-NVL('&num_days', 0.5)
         AND s.instance_number = i.instance_number
         AND s.instance_number = g.instance_number
         AND g.stat_name = 'physical reads') physical_read_hist,
     (SELECT s.snap_id
            ,g.value AS stattot
            ,NVL(DECODE(GREATEST(VALUE, NVL(lag (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                 ORDER BY s.snap_id), 0)), VALUE, VALUE - LAG (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                     ORDER BY s.snap_id), VALUE), 0) AS statval
        FROM dba_hist_snapshot s,
             dba_hist_sysstat g,
             v$instance i
       WHERE s.snap_id = g.snap_id
         AND s.begin_interval_time >= sysdate-NVL('&num_days', 0.5)
         AND s.instance_number = i.instance_number
         AND s.instance_number = g.instance_number
         AND g.stat_name = 'physical writes') physical_write_hist,
     (SELECT s.snap_id
            ,g.value AS stattot
            ,NVL(DECODE(GREATEST(VALUE, NVL(lag (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                 ORDER BY s.snap_id), 0)), VALUE, VALUE - LAG (VALUE) OVER (PARTITION BY s.dbid, s.instance_number, g.stat_name
                     ORDER BY s.snap_id), VALUE), 0) AS statval
        FROM dba_hist_snapshot s,
             dba_hist_sysstat g,
             v$instance i
       WHERE s.snap_id = g.snap_id
         AND s.begin_interval_time >= sysdate-NVL('&num_days', 0.5)
         AND s.instance_number = i.instance_number
         AND s.instance_number = g.instance_number
         AND g.stat_name = 'session logical reads') logical_read_hist
WHERE redo_hist.snap_id = physical_read_hist.snap_id
  AND redo_hist.snap_id = physical_write_hist.snap_id
  AND redo_hist.snap_id = logical_read_hist.snap_id
ORDER BY 1;


select dbid, extract( day from snap_interval) *24*60+extract( hour from snap_interval) *60+extract( minute from snap_interval ) snapshot_interval,
extract( day from retention) *24*60+extract( hour from retention) *60+extract( minute from retention ) retention_interval,
topnsql
from dba_hist_wr_control;


exec dbms_workload_repository.modify_snapshot_settings(retention=>43200, interval=>60, topnsql=>100, dbid=>1992878807);
exec dbms_workload_repository.modify_snapshot_settings(retention=>43200);















