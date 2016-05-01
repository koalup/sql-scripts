PROCEDURE "DO_DDL" (m_sql varchar2) as
  in_use exception;
  pragma exception_init(in_use, -54);
begin
  while true loop
    begin
      execute immediate m_sql;
      exit;
    exception
      when in_use then null;
    end;
    dbms_lock.sleep(0.01);

  end loop;
end;
