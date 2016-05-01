col READ_GB format 9999990.99
col WRITE_GB format 9999990.99
set lin 400 pages 200
col operation format a30
col status format a25
col ELAPSED_MIN format 9999990.99

alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS (DY)';

break on SESSION_RECID on SESSION_STAMP skip page
compute sum of ELAPSED_MIN on SESSION_STAMP
compute sum of WRITE_GB on SESSION_STAMP
select 
	SESSION_RECID,
	SESSION_STAMP,
	START_TIME, 
	END_TIME, 
	(END_TIME-START_TIME)*1440 ELAPSED_MIN,
	INPUT_BYTES/1024/1024/1024 READ_GB, 
	OUTPUT_BYTES/1024/1024/1024 WRITE_GB, 
	OPERATION, OBJECT_TYPE, 
	STATUS 
from 
	v$rman_status 
where 
	OPERATION like 'BACKUP%' order by START_TIME
;

col READ_GB format 9999990.99
col WRITE_GB format 9999990.99
set lin 200 pages 200
col operation format a30
col status format a20
col object_type format a30

alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS (DY)';
select 
	START_TIME, 
	END_TIME, 
	DB_NAME,
	INPUT_BYTES/1024/1024/1024 READ_GB, 
	OUTPUT_BYTES/1024/1024/1024 WRITE_GB, 
	OPERATION, OBJECT_TYPE, 
	STATUS 
from 
	rc_rman_status 
where 
	OPERATION like 'BACKUP%' 
order by 
	START_TIME
;


select output from v$rman_output where SESSION_RECID=&RECID and SESSION_STAMP=&STAMP;
