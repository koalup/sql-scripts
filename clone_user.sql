col x format a200
set lin 200 pages 0 long 99999 verify off
define src=SCH_EPM
define dst=SCH_EPM
exec dbms_metadata.set_transform_param(dbms_metadata.SESSION_TRANSFORM,'SQLTERMINATOR',TRUE);
select replace(dbms_metadata.get_ddl('USER','&src'),'&src','&dst') x from dual;
select replace(dbms_metadata.get_granted_ddl('SYSTEM_GRANT','&src'),'&src','&dst') x from dual;
select replace(dbms_metadata.get_granted_ddl('OBJECT_GRANT','&src'),'&src','&dst') x from dual;
select replace(dbms_metadata.get_granted_ddl('ROLE_GRANT','&src'),'&src','&dst') x from dual;