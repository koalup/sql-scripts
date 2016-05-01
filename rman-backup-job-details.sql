set lin 200 pages 200
alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';
col INPUT_BYTES_DISPLAY format a10
col OUTPUT_BYTES_DISPLAY format a10
col INPUT_BYTES_PER_SEC_DISPLAY format a10
col OUTPUT_BYTES_PER_SEC_DISPLAY format a10
col status format a10
select 
	START_TIME, 
	END_TIME, 
	INPUT_BYTES_DISPLAY, 
	OUTPUT_BYTES_DISPLAY, 
	INPUT_BYTES_PER_SEC_DISPLAY, 
	OUTPUT_BYTES_PER_SEC_DISPLAY, 
	COMPRESSION_RATIO,
	STATUS 
from 
	v$rman_backup_job_details
order by start_time
;