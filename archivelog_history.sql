
set numformat 999.0
set lin 300 pages 200
col date format a16
SELECT
	 TO_CHAR(completion_time,'YYYY-MM-DD (DY)') "DATE"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'00',(blocks*block_size)/1024/1024/1024)) "00"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'01',(blocks*block_size)/1024/1024/1024)) "01"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'02',(blocks*block_size)/1024/1024/1024)) "02"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'03',(blocks*block_size)/1024/1024/1024)) "03"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'04',(blocks*block_size)/1024/1024/1024)) "04"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'05',(blocks*block_size)/1024/1024/1024)) "05"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'06',(blocks*block_size)/1024/1024/1024)) "06"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'07',(blocks*block_size)/1024/1024/1024)) "07"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'08',(blocks*block_size)/1024/1024/1024)) "08"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'09',(blocks*block_size)/1024/1024/1024)) "09"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'10',(blocks*block_size)/1024/1024/1024)) "10"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'11',(blocks*block_size)/1024/1024/1024)) "11"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'12',(blocks*block_size)/1024/1024/1024)) "12"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'13',(blocks*block_size)/1024/1024/1024)) "13"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'14',(blocks*block_size)/1024/1024/1024)) "14"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'15',(blocks*block_size)/1024/1024/1024)) "15"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'16',(blocks*block_size)/1024/1024/1024)) "16"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'17',(blocks*block_size)/1024/1024/1024)) "17"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'18',(blocks*block_size)/1024/1024/1024)) "18"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'19',(blocks*block_size)/1024/1024/1024)) "19"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'20',(blocks*block_size)/1024/1024/1024)) "20"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'21',(blocks*block_size)/1024/1024/1024)) "21"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'22',(blocks*block_size)/1024/1024/1024)) "22"
	,SUM(DECODE(TO_CHAR(completion_time,'HH24'),'23',(blocks*block_size)/1024/1024/1024)) "23"
	,sum((blocks*block_size)/1024/1024/1024) TOTAL
	,sum((blocks*block_size)/1024/1024/1024) / 7 EST_REC
from v$archived_log
where
     standby_dest='NO'
--   and completion_time>sysdate-2
group by to_char(completion_time,'YYYY-MM-DD (DY)')
order by 1;



col gb format 999990.99
select to_char(completion_time,'YYYY-MM-DD HH24'), sum((blocks*block_size)/1024/1024/1024) GB, count(*)
from v$archived_log
where
     standby_dest='NO'
--   and completion_time>sysdate-2
group by to_char(completion_time,'YYYY-MM-DD HH24')
order by 1;



col gb format 999990.99
select to_char(completion_time,'YYYY-MM-DD') "DATE", sum((blocks*block_size)/1024/1024/1024) GB, count(*)
from v$archived_log
where
     standby_dest='NO' 
     --and completion_time>sysdate-0.5
group by to_char(completion_time,'YYYY-MM-DD')
order by 1;


col gb format 999990.99
select to_char(completion_time,'YYYY-MM-DD') "DATE", sum((blocks*block_size)/1024/1024/1024) GB, count(*)
from v$archived_log
where
     standby_dest='NO' 
—     and deleted='NO'
group by to_char(completion_time,'YYYY-MM-DD')
order by 1;
