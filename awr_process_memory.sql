DBA_HIST_PROCESS_MEM_SUMMARY


select extract( day from snap_interval) *24*60+extract( hour from snap_interval) *60+extract( minute from snap_interval ) snapshot_interval,
extract( day from retention) *24*60+extract( hour from retention) *60+extract( minute from retention ) retention_interval,
topnsql
from dba_hist_wr_control
where dbid=2049790782;



exec dbms_workload_repository.modify_snapshot_settings(retention=>20160, interval=>15, topnsql=>100, dbid=>2049790782);



BREAK ON snap_begin SKIP 1 ON snap_end skip page
compute sum of alloc_avg_mb on snap_end
compute sum of alloc_total_mb on snap_end
SELECT
    CAST(begin_interval_time AS DATE) snap_begin
  , TO_CHAR(CAST(end_interval_time AS DATE), 'HH24:MI') snap_end
  , category
  , num_processes
  , NON_ZERO_ALLOCS
  , used_total/1024/1024 used_total_mb
  , allocated_total/1024/1024 alloc_total_mb
  , allocated_avg/1024/1024 alloc_avg_mb
  , ALLOCATED_STDDEV/1024/1024 alloc_stddev_mb
  , allocated_max/1024/1024     ALLOCATED_MAX_MB
  , max_allocated_max/1024/1024 MAX_ALLOCATED_MAX_MB
FROM
    dba_hist_snapshot
  NATURAL JOIN
    dba_hist_process_mem_summary
WHERE
    begin_interval_time > SYSDATE - 1/6
--AND category = 'SQL'
ORDER BY
    snap_begin
  , category
/



select type, count(*) from v$session group by type;

select 
	count(*), 
	sum(alloc)/1024/1024 "sum_alloc",
	avg(alloc)/1024/1024 "avg_alloc", 
	median(alloc)/1024/1024 "median_alloc", 
	stddev(alloc)/1024/1024 "stddev_alloc", 
	avg(alloc_max)/1024/1024, 
	median(alloc_max)/1024/1024, 
	stddev(alloc_max)/1024/1024 from (
select pid, sum(allocated) alloc, sum(max_allocated) alloc_max from v$process_memory group by pid
);

create table bg_process_memory as select * from v$process_memory;

select 
	count(*), 
	sum(alloc)/1024/1024 "sum_alloc",
	avg(alloc)/1024/1024 "avg_alloc", 
	median(alloc)/1024/1024 "median_alloc", 
	stddev(alloc)/1024/1024 "stddev_alloc", 
	avg(alloc_max)/1024/1024, 
	median(alloc_max)/1024/1024, 
	stddev(alloc_max)/1024/1024 from (
select pid, sum(allocated) alloc, sum(max_allocated) alloc_max from bg_process_memory 
	--where category != 'Freeable' 
group by pid
);


select snap_id, max(NUM_PROCESSES), sum(ALLOCATED_TOTAL)/1024/1024, (sum(ALLOCATED_TOTAL)/max(NUM_PROCESSES))/1024/1024
from dba_hist_process_mem_summary
--where snap_id=1988
group by snap_id order by snap_id
;
	

SELECT
	 TO_CHAR(B.BEGIN_INTERVAL_TIME,'YYYY-MM-DD') "DATE"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'00',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "00"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'01',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "01"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'02',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "02"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'03',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "03"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'04',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "04"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'05',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "05"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'06',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "06"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'07',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "07"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'08',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "08"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'09',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "09"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'10',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "10"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'11',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "11"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'12',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "12"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'13',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "13"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'14',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "14"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'15',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "15"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'16',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "16"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'17',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "17"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'18',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "18"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'19',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "19"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'20',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "20"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'21',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "21"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'22',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "22"
	,AVG(DECODE(TO_CHAR(B.BEGIN_INTERVAL_TIME,'HH24'),'23',((A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024))) "23"
FROM
	(SELECT SNAP_ID, INSTANCE_NUMBER, MAX(NUM_PROCESSES) NUM_PROCESSES, SUM(ALLOCATED_TOTAL) ALLOCATED_TOTAL FROM DBA_HIST_PROCESS_MEM_SUMMARY GROUP BY SNAP_ID, INSTANCE_NUMBER) A,
	DBA_HIST_SNAPSHOT B
WHERE
		A.SNAP_ID = B.SNAP_ID
	AND A.INSTANCE_NUMBER = B.INSTANCE_NUMBER
GROUP BY
	TO_CHAR(B.BEGIN_INTERVAL_TIME,'YYYY-MM-DD')
ORDER BY
	"DATE"
;	

SELECT
	AVG(A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024
FROM
	(SELECT SNAP_ID, INSTANCE_NUMBER, MAX(NUM_PROCESSES) NUM_PROCESSES, SUM(ALLOCATED_TOTAL) ALLOCATED_TOTAL FROM DBA_HIST_PROCESS_MEM_SUMMARY GROUP BY SNAP_ID, INSTANCE_NUMBER) A,
	DBA_HIST_SNAPSHOT B
WHERE
		A.SNAP_ID = B.SNAP_ID
	AND A.INSTANCE_NUMBER = B.INSTANCE_NUMBER
	AND A.SNAP_ID>=1412
;	

AVG(A.ALLOCATED_TOTAL/A.NUM_PROCESSES)/1024/1024
------------------------------------------------
                                      2.46117725



BREAK ON snap_begin SKIP 1 ON snap_end skip page
compute avg of alloc_avg_mb on snap_end
compute sum of alloc_total_mb on snap_end
SELECT
   CAST(begin_interval_time AS DATE) snap_begin
  , TO_CHAR(CAST(end_interval_time AS DATE), 'HH24:MI') snap_end
  , category
  , num_processes
  , NON_ZERO_ALLOCS
  , used_total/1024/1024 used_total_mb
  , allocated_total/1024/1024 alloc_total_mb
  , allocated_avg/1024/1024 alloc_avg_mb
  , ALLOCATED_STDDEV/1024/1024 alloc_stddev_mb
  , allocated_max/1024/1024     ALLOCATED_MAX_MB
  , max_allocated_max/1024/1024 MAX_ALLOCATED_MAX_MB
FROM
    dba_hist_snapshot
  NATURAL JOIN
    dba_hist_process_mem_summary
WHERE
    --begin_interval_time > SYSDATE - 1/6 and
	snap_id = 1988
	--AND category != 'Freeable'
ORDER BY
    snap_begin
  , category
/



select 