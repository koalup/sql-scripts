set lin 200 pages 200
column full_alias_path format a70
column file_type format a15
column mb format 999999990.99
column directory format a60
column database format a25

break on database skip page
compute sum of mb on database

select nvl(substr(full_alias_path,1,instr(full_alias_path,'/',1,2)-1),full_alias_path) database, substr(full_alias_path,1,instr(full_alias_path,'/',-1)-1) DIRECTORY, sum(bytes/1024/1024) MB from (
select concat('+'||gname, sys_connect_by_path(aname, '/')) full_alias_path, 
       system_created, alias_directory, file_type, nvl(bytes,0) bytes
from ( select b.name gname, a.parent_index pindex, a.name aname,
              a.reference_index rindex , a.system_created, a.alias_directory,
              c.type file_type, c.bytes
       from v$asm_alias a, v$asm_diskgroup b, v$asm_file c
       where a.group_number = b.group_number
             and a.group_number = c.group_number(+)
             and a.file_number = c.file_number(+)
             and a.file_incarnation = c.incarnation(+)
     )
start with (mod(pindex, power(2, 24))) = 0
            and rindex in 
                ( select a.reference_index
                  from v$asm_alias a, v$asm_diskgroup b
                  where a.group_number = b.group_number
                        and (mod(a.parent_index, power(2, 24))) = 0
                        --and a.name = 'TRY'
			and b.name='DATA'
                )
connect by prior rindex = pindex
)
group by nvl(substr(full_alias_path,1,instr(full_alias_path,'/',1,2)-1),full_alias_path), substr(full_alias_path,1,instr(full_alias_path,'/',-1)-1)
;








Original:

############################################################
##### list_all_files.sql
##### generate a list of all the asm files / directories / aliasses for a given database
column full_alias_path format a70
column file_type format a15
 

select concat('+'||gname, sys_connect_by_path(aname, '/')) full_alias_path, 
       system_created, alias_directory, file_type
from ( select b.name gname, a.parent_index pindex, a.name aname, 
              a.reference_index rindex , a.system_created, a.alias_directory,
              c.type file_type
       from v$asm_alias a, v$asm_diskgroup b, v$asm_file c
       where a.group_number = b.group_number
             and a.group_number = c.group_number(+)
             and a.file_number = c.file_number(+)
             and a.file_incarnation = c.incarnation(+)
     )
start with (mod(pindex, power(2, 24))) = 0
            and rindex in 
                ( select a.reference_index
                  from v$asm_alias a, v$asm_diskgroup b
                  where a.group_number = b.group_number
                        and (mod(a.parent_index, power(2, 24))) = 0
                        and a.name = '&DATABASENAME'
                )
connect by prior rindex = pindex;