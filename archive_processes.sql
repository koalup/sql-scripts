--ps -ef | awk '/ora_arc[0-9]_vcprd[1-3]/ {print $2}' | xargs kill -9

set lin 300 pages 200
break on report
compute sum of MB_REMAINING on report
col MB_REMAINING format 99990.99
col event format a30
col wait_class format a10
col PCT_COMPLETE format 9990.99
select 
   e.inst_id, 
   e.instance_name, 
   a.name, 
   b.state,
   c.wait_class, 
   c.event, 
   c.process, 
   c.state, 
   c.seq#,
   --c.blocking_session,
   c.seconds_in_wait, 
   d.status, 
   d.thread#, 
   d.sequence#, 
   f.blocks TOTAL_BLOCKS, 
   d.block# CURRENT_BLOCK,
   f.blocks-d.BLOCK#+1 BLOCKS_REMAINING,
   d.blocks CHUNK_BLOCKS,
   ((f.blocks-d.BLOCK#-1)*f.block_size)/1024/1024 MB_REMAINING,
   (d.block#/f.blocks)*100 PCT_COMPLETE
from 
   gv$bgprocess a,
   gv$archive_processes b,
   gv$session c,
   gv$managed_standby d,
   gv$instance e,
   v$archived_log f
where	
   a.inst_id=b.inst_id and
   b.inst_id=c.inst_id and
   c.inst_id=d.inst_id and
   d.inst_id=e.inst_id and
   a.NAME='ARC'||b.PROCESS and
   a.paddr=c.paddr and
   c.process=to_char(d.pid) and
   d.thread#=f.thread# and
   d.sequence#=f.sequence# and
   f.standby_dest='NO' and
   b.state<>'IDLE'
order by 
   e.inst_id, 
   a.name 
;



select e.inst_id, e.instance_name, a.name, b.state, b.LOG_SEQUENCE, c.event, c.process, c.state, c.seconds_in_wait
from 
   gv$bgprocess a,
   gv$archive_processes b,
   gv$session c,
   gv$managed_standby d,
   gv$instance e
where	
   a.inst_id=b.inst_id and
   b.inst_id=c.inst_id and
   c.inst_id=d.inst_id and
   d.inst_id=e.inst_id and
   a.NAME='ARC'||b.PROCESS and
   a.paddr=c.paddr and
   c.process=d.pid and
   b.state<>'IDLE'
order by 
   e.inst_id, 
   a.name 
;



alter system set log_archive_dest_1='location=use_db_recovery_file_dest valid_for="all_logfiles,all_roles"' scope=both;