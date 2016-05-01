declare
  jobno number;
  instno number;
  mwhat varchar2(1000);
begin
mwhat := 'BEGIN
EXECUTE IMMEDIATE ''DELETE FROM SYS.AUD$ WHERE NTIMESTAMP# < SYSDATE - 90'';
COMMIT;
END;';
  select instance_number into instno from v$instance;
  dbms_job.submit(jobno, mwhat, trunc(sysdate+1/24,'HH'), 'trunc(SYSDATE+1/24,''HH'')', TRUE, instno);
  commit;
end;
/