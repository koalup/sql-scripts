
SET LIN 400 PAGES 200
COL "INST SID,SER SPID SRV STAT USR" FORMAT A50 TRUNC
COL "MACHINE,OSUSER,PROCESS,PROG" FORMAT A60 TRUNC
COL "EVENT,CLASS,STATE,SEQ,WT,SIW" FORMAT A75 TRUNC
COL "SQL_INFO" FORMAT A20
COL "PREV_SQL_INFO" FORMAT A20
COL "BLOCKERS" FORMAT A15 TRUNC
COL "FINAL_BLOCKERS" FORMAT A15 TRUNC
COL "QCSID,SNDR" FORMAT A10

SELECT
	 A.INST_ID || ' ' || A.SID || ','|| A.SERIAL# ||' '|| B.SPID ||' '|| A.SERVER ||' '|| A.STATUS ||' '|| A.USERNAME "INST SID,SER SPID SRV STAT USR"
	,A.MACHINE || ',' || A.OSUSER ||','|| A.PROCESS || ',' || A.PROGRAM "MACHINE,OSUSER,PROCESS,PROG"
	,A.EVENT || ',' || A.WAIT_CLASS || ',' || A.STATE || ',' || A.SEQ# || ',' || A.WAIT_TIME || ',' || A.SECONDS_IN_WAIT "EVENT,CLASS,STATE,SEQ,WT,SIW"
--	,A.P1  || ',' || A.P2 || ',' || A.P3 P_INFO
	,'''' || A.SQL_ID || '''' || ',' || A.SQL_CHILD_NUMBER SQL_INFO
--	,'''' || A.PREV_SQL_ID || '''' || ',' || A.PREV_CHILD_NUMBER PREV_SQL_INFO
--	,A.BLOCKING_INSTANCE ||','|| A.BLOCKING_SESSION || ',' || A.BLOCKING_SESSION_STATUS "BLOCKERS"
	,A.BLOCKING_SESSION || ',' || A.BLOCKING_SESSION_STATUS "BLOCKERS"
	,A.FINAL_BLOCKING_INSTANCE ||','|| A.FINAL_BLOCKING_SESSION || ',' || A.FINAL_BLOCKING_SESSION_STATUS "FINAL_BLOCKERS"
--	,C.QCSID || ',' || decode(bitand(A.P1, 65535),65535, 'QC', 'P'||to_char(bitand(A.P1, 65535),'fm000')) "QCSID,SNDR"
--	,A.PLSQL_ENTRY_OBJECT_ID, A.PLSQL_ENTRY_SUBPROGRAM_ID
	,A.LAST_CALL_ET
--	,A.SQL_EXEC_START
FROM
	GV$SESSION A,
	GV$PROCESS B,
	GV$PX_SESSION C
WHERE
		A.INST_ID=B.INST_ID 
	AND	A.PADDR=B.ADDR 
	AND A.INST_ID=C.INST_ID(+)
	AND A.SID=C.SID(+)
	AND A.TYPE='USER'
--	AND A.STATE='WAITING'
--	AND A.SID in (582)
--      AND MACHINE IN ('x0319vp22','x0319vp33')
--    AND A.USERNAME in ('SYS','XP1K')
--	AND SQL_ID='16tcybz02a481'
	AND	(	
			A.WAIT_CLASS <> 'Idle' 
		OR	A.STATUS='ACTIVE' 
--		OR	A.SID in (194,236) 
		OR	A.USERNAME in ('X1FD')
--		OR	A.PROGRAM like ''
--		OR	A.SQL_ID in ('')
--		OR      A.MACHINE like 'tkdwhdb01%'
--		OR	(A.INST_ID,A.SID) IN (SELECT BLOCKING_INSTANCE,BLOCKING_SESSION FROM V$SESSION WHERE BLOCKING_INSTANCE IS NOT NULL AND BLOCKING_SESSION IS NOT NULL)
--		OR	(A.SID) IN (SELECT BLOCKING_SESSION FROM V$SESSION WHERE BLOCKING_SESSION IS NOT NULL)
	) 
--	AND	A.USERNAME NOT IN ('DBSNMP','SYSMAN','SKOLEV','BGMON')
--	AND A.SID NOT IN (SELECT SID FROM V$MYSTAT WHERE ROWNUM=1)
ORDER BY  A.INST_ID, A.SID
;


select 
	 s.sid
	,s.serial# 
	,s.username
	,s.machine
	,p.spid 
	,s.module 
	,s.process 
	,s.program 
	,s.sql_hash_value 
	,w.event 
	,w.seq# 
	,w.state 
	,w.wait_time 
	,w.seconds_in_wait 
from 
	v$session s, 
	v$session_wait w, 
	v$process p
where 
	s.sid=w.sid and
	s.paddr=p.addr and
	w.event!='SQL*Net message from client' and
	s.username is not null
;


break on QCSID skip page
compute count of sid on QCSID
SELECT
	 C.QCSID
	,A.INST_ID || ',' || A.SID || ','|| A.SERIAL# ||','|| B.SPID ||','|| A.STATUS ||','|| A.USERNAME "INST,SID,SER,SPID,STAT,USER"
	,A.MACHINE || ',' || A.OSUSER ||','|| A.PROCESS || ',' || A.PROGRAM "CLIENT_INFO"
	,A.EVENT || ',' || A.WAIT_CLASS || ',' || A.STATE || ',' || A.SEQ# || ',' || A.WAIT_TIME || ',' || A.SECONDS_IN_WAIT "EVENT,CLASS,SATE,SEQ,WT,SIW"
--	,A.P1  || ',' || A.P2 || ',' || A.P3 P_INFO
	,'''' || A.SQL_ID || '''' || ',' || A.SQL_CHILD_NUMBER SQL_INFO
--	,'''' || A.PREV_SQL_ID || '''' || ',' || A.PREV_CHILD_NUMBER PREV_SQL_INFO
	,A.BLOCKING_INSTANCE ||','|| A.BLOCKING_SESSION || ',' || A.BLOCKING_SESSION_STATUS "BLOCKERS"
--	,A.FINAL_BLOCKING_INSTANCE ||','|| A.FINAL_BLOCKING_SESSION || ',' || A.FINAL_BLOCKING_SESSION_STATUS "FINAL_BLOCKERS"
	,decode(bitand(A.P1, 65535),65535, 'QC', 'P'||to_char(bitand(A.P1, 65535),'fm000')) as SNDR
	,A.LAST_CALL_ET
FROM
	GV$SESSION A,
	GV$PROCESS B,
	GV$PX_SESSION C
WHERE
	    A.INST_ID=B.INST_ID
	AND A.INST_ID=C.INST_ID
	AND A.PADDR=B.ADDR
	AND A.SID = C.SID
	AND A.SERIAL# = C.SERIAL#
ORDER BY
	C.QCSID, A.SID
;

set SERVEROUTPUT on
undef p1
declare
    inst varchar(20);
    sender varchar(20);
begin
   select bitand(&&p1, 16711680) - 65535 as SNDRINST,
    decode(bitand(&&p1, 65535),65535, 'QC', 'P'||to_char(bitand(&&p1, 65535),'fm000') ) as SNDR
    into inst , sender
   from dual
   where bitand(&&p1, 268435456) = 268435456;
    dbms_output.put_line('Instance = '||inst);
    dbms_output.put_line('Sender = '||sender );
end;
/ 


/* 

  Why use a text index on varchar(140) column
  KEYWORDS_TEXT is not indexed
  Needs a rebuild
  


*/


@snapper ash=SQL_ID+SQL_CHILD_NUMBER+EVENT 5 1 all