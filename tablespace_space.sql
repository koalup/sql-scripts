set lin 200 pages 200
col tablespace_name format a30
col actual_gb format 99990.99
col max_gb format 99990.99
col free_gb format 99990.99
col used_gb format 99990.99
col freeable_gb format 99990.99
SELECT 
 tablespace_name as tablespace_name
 ,tbspc.contents as contents
 ,currentsize_bytes/1024/1024/1024 as actual_gb
 ,maxsize_bytes/1024/1024/1024 as max_gb
 ,free_bytes/1024/1024/1024 as free_gb
 ,used_bytes/1024/1024/1024 as used_gb
 ,(currentsize_bytes-used_bytes)/1024/1024/1024 as freeable_gb
 ,100-100*round(used_bytes/maxsize_bytes,2) as eff_pct_free
 ,100-100*round(used_bytes/currentsize_bytes,2) as act_pct_free
 ,autoextensible_files as autoextensible_files
 ,total_files as total_files
 ,tbspc.status as status
from ( 
 select tbspc.tablespace_name as tablespace_name,
 count(1) as total_files,
 sum( bytes ) as currentsize_bytes, 
 sum( greatest(maxbytes,bytes)) as maxsize_bytes,
 (sum( greatest(maxbytes,bytes ))) - (sum( bytes ) - tbspc_free.free_bytes) as free_bytes ,
 sum ( bytes ) - nvl(tbspc_free.free_bytes,0) as used_bytes,
 tbspc.contents as contents,
 tbspc.status as status,
 sum(decode(autoextensible,'YES',1,0)) as autoextensible_files
 from dba_tablespaces tbspc, 
 dba_data_files df,
 (select tablespace_name, 
 nvl(sum(bytes),0) as free_bytes 
 from dba_free_space
 group by tablespace_name) tbspc_free
 where tbspc.tablespace_name = df.tablespace_name 
 and tbspc.tablespace_name = tbspc_free.tablespace_name(+)
 and tbspc.contents NOT IN ( 'TEMPORARY')
 group by tbspc.tablespace_name
 ,contents
 ,tbspc.status
 ,nvl(tbspc_free.free_bytes,0)
 , tbspc_free.free_bytes
) tbspc order by 1;