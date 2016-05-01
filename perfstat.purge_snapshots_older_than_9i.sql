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

		delete from stats$snapshot where instance_number = inst_num and dbid = db_id and snap_id between lo_snap and hi_snap;

		execute immediate 'alter session set hash_area_size=1048576';

		delete --+ index_ffs(st) 
		  from stats$sqltext st
		 where (hash_value, text_subset) not in
		       (select --+ hash_aj full(ss) no_expand 
		               hash_value, text_subset
		          from stats$sql_summary ss
		         where (   (   snap_id     < lo_snap
		                    or snap_id     > hi_snap
		                   )
		                   and dbid            = db_id
		                   and instance_number = inst_num
		               )
		            or (   dbid            != db_id
		                or instance_number != inst_num)
		        );

		delete --+ index_ffs(sso)
		  from stats$seg_stat_obj sso
		 where (dbid, dataobj#, obj#) not in
		       (select --+ hash_aj full(ss) no_expand
		              dbid, dataobj#, obj#
		          from stats$seg_stat ss
		         where ( (   snap_id     < lo_snap
		                  or snap_id     > hi_snap
		                 )
		                 and dbid            = db_id
		                 and instance_number = inst_num
		               )
		            or (   dbid            != db_id
		                or instance_number != inst_num)
		        );


		delete from stats$undostat us where dbid = db_id and instance_number = inst_num and snap_id between lo_snap and hi_snap;

		delete from stats$database_instance di
		where instance_number = inst_num
		and dbid = db_id
		and not exists (select 1
                     from stats$snapshot s
                    where s.dbid            = di.dbid
                      and s.instance_number = di.instance_number
                      and s.startup_time    = di.startup_time);


		delete from stats$statspack_parameter sp
		where instance_number = inst_num
		and dbid  = dbid
		and not exists (select 1
                     from stats$snapshot s
                    where s.dbid            = sp.dbid
                      and s.instance_number = sp.instance_number);



		COMMIT;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		RAISE;
END;
/
