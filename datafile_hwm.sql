set lin 200 pages 200 serverout on long 999999
DECLARE
     v_block_size     number;
     v_file_size     number;
     v_file_free     number;
     v_tablespace     dba_tablespaces.tablespace_name%type := '&tablespace_name';
     CURSOR c_hwm IS
	select a.file_id, a.autoextensible, nvl(b.hwm,0) hwm from 
		dba_data_files a,
 		(select file_id, max(block_id+blocks-1) hwm from dba_extents where tablespace_name=v_tablespace group by file_id) b
	where 
		    a.file_id = b.file_id (+)
		and a.tablespace_name=v_tablespace
	order 
		by a.file_id
;
BEGIN
     EXECUTE IMMEDIATE 'select block_size from dba_tablespaces where tablespace_name='''||v_tablespace||'''' INTO v_block_size;
     DBMS_OUTPUT.PUT_LINE(
          rpad('file_id',10)	||
		  rpad('autoext',10)	||
          rpad('total_mb',20)	||
          rpad('free_mb',20)	||
          rpad('hwm_mb',20)     ||
          rpad('freeable_mb',20)
     );
    
     FOR r_hwm IN c_hwm LOOP
          EXECUTE IMMEDIATE 'select bytes from v$datafile where file#='||r_hwm.file_id INTO v_file_size;
          EXECUTE IMMEDIATE 'select sum(bytes) from dba_free_space where file_id='||r_hwm.file_id INTO v_file_free;
          DBMS_OUTPUT.PUT_LINE(
               rpad(r_hwm.file_id,10)                    ||
			   rpad(r_hwm.autoextensible,10)					||
               rpad(round(v_file_size/1024/1024,2),20)          ||
               rpad(round(v_file_free/1024/1024,2),20)               ||
               rpad(round((r_hwm.hwm*v_block_size)/1024/1024,2),20)     ||
               rpad(round((v_file_size-(r_hwm.hwm*v_block_size))/1024/1024,2),20) ||
			   'alter database datafile '||r_hwm.file_id||' resize '||(ceil((r_hwm.hwm*v_block_size)/1024/1024)+1)||'m;'			   
          );
     END LOOP;
END;
/