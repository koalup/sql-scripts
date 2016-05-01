CREATE OR REPLACE PROCEDURE PURGE_SHAPSHOTS_OLDER_THAN (num_days IN number DEFAULT 7)
IS
        db_id			v$database.dbid%TYPE;
	db_name			v$database.name%TYPE;
	inst_num		v$instance.instance_number%TYPE;
	inst_name		v$instance.instance_name%TYPE;
	lo_snap			stats$snapshot.snap_id%TYPE;
	hi_snap			stats$snapshot.snap_id%TYPE;
	snapshots_purged	number;
BEGIN
        SELECT	d.dbid, d.name, i.instance_number, i.instance_name INTO	db_id, db_name, inst_num, inst_name FROM v$database d, v$instance i;
	
	SELECT	min(s.snap_id), max(s.snap_id) INTO lo_snap, hi_snap
	FROM	stats$snapshot s, stats$database_instance di 
	WHERE	s.dbid = db_id AND di.dbid = db_id AND s.instance_number = inst_num AND di.instance_number = inst_num AND di.startup_time = s.startup_time AND s.snap_time <= sysdate-num_days;

	IF lo_snap IS NOT NULL AND hi_snap IS NOT NULL THEN
		DBMS_OUTPUT.PUT_LINE(db_id||','||db_name||','||inst_num||','||inst_name||','||lo_snap||','||hi_snap);
		snapshots_purged := statspack.purge(i_begin_snap=>lo_snap, i_end_snap=>hi_snap, i_snap_range=>true, i_extended_purge=>true,i_dbid=>db_id,i_instance_number=>inst_num);
		DBMS_OUTPUT.PUT_LINE('Number of Snapshots purged: '||snapshots_purged);
		COMMIT;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		RAISE;
END;
/
