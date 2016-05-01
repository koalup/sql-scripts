variable jobno number;
variable instno number;
begin
  select instance_number into :instno from v$instance;
  dbms_job.submit(:jobno, 'PURGE_SHAPSHOTS_OLDER_THAN(14);', trunc(sysdate+1/24,'HH')+1/48, 'trunc(sysdate+1/24,''HH'')+1/48', TRUE, :instno);
  commit;
end;
/
