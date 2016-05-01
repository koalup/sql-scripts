select a.tablespace_name, count(b.segment_name) 
from
dba_tablespaces a,
dba_segments b
where a.tablespace_name=b.tablespace_name(+)
--and a.tablespace_name like 'PART_AUCTION%'
group by a.tablespace_name
having count(b.segment_name) = 0
order by a.tablespace_name
;


select tablespace_name, sum(bytes/1024/1024) from dba_data_files where tablespace_name in (
select a.tablespace_name
from
dba_tablespaces a,
dba_segments b
where a.tablespace_name=b.tablespace_name(+)
--and a.tablespace_name like 'PART_AUCTION%'
group by a.tablespace_name
having count(b.segment_name) = 0)
group by tablespace_name
;