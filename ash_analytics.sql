/* Some References

-- http://blog.tanelpoder.com/2011/10/24/what-the-heck-is-the-sql-execution-id-sql_exec_id/
-- http://www.kylehailey.com/finding-the-slowest-sql-execution-of-the-same-query/

*/

/* Ignore this SQL. My first attempt to wrap my brain around SQL_EXEC_ID 

ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';

SET LIN 500 PAGES 1000
COL INSTANCE_NUMBER FORMAT 99
COL USERNAME FORMAT A10
COL END FORMAT A40
COL DURATION FORMAT A40
COL SQL_OPNAME format A15
COL "SID,SERIAL#" FORMAT A15
COL ELAPSED_S 	FORMAT 9999990.99
COL DURATION_S  FORMAT 9999990.99
COL ELAPSED_SPE FORMAT 9999990.99

SELECT 
	 --A.INSTANCE_NUMBER
	 A.SESSION_ID
	,A.SESSION_SERIAL#
--	,A.QC_INSTANCE_ID
	,A.QC_SESSION_ID 
	,A.QC_SESSION_SERIAL# 
	,B.USERNAME
	,A.SQL_ID
	,A.SQL_PLAN_HASH_VALUE
	,A.SQL_EXEC_ID
	,A.SQL_EXEC_START 
	,MAX(A.SAMPLE_TIME) "END" 
	,MAX(A.SAMPLE_TIME)-SQL_EXEC_START "DURATION" 
FROM 
	--DBA_HIST_ACTIVE_SESS_HISTORY A,
	V$ACTIVE_SESSION_HISTORY A,
	DBA_USERS B
WHERE 
		A.USER_ID = B.USER_ID
	AND B.USERNAME = 'DCDS_ETL'
	--AND A.SAMPLE_TIME >= SYSDATE - 1
	AND SQL_ID IN ('cmdp2tvmfgpwp','fy6pd1ktmv4bj')
GROUP BY 
	 --A.INSTANCE_NUMBER
	 A.SESSION_ID
	,A.SESSION_SERIAL#
--	,A.QC_INSTANCE_ID
	,A.QC_SESSION_ID 
	,A.QC_SESSION_SERIAL# 
	,B.USERNAME
	,A.SQL_ID
	,A.SQL_PLAN_HASH_VALUE
	,A.SQL_EXEC_ID
	,A.SQL_EXEC_START 
ORDER BY SQL_EXEC_START;

*/



/* 

This is the main query that I'm working to flush out. Beware, it might not be entirely accurate as it's still a work in progress.

I basically wanted to document what SQL's were being run throughout the entire ETL process and how long each SQL took. They always run the 
whole thing as the DCDS_ETL user, so I focused on sessions logged in as that user. 

* Executions may not be accurate in a RAC environment AND/OR if there are other users executing the same SQL that are being filtered out 
  in the WHERE clause. This is because of how SQL_EXEC_ID is calculated. I need to work on it. (See Tanel's blog). If you create two sessions and
  and execute the same SQL, the SQL_EXEC_ID is incremented globally. Looks like SQL_EXEC_ID gets reset every time the cursor is loaded into memory or if the 
  counter wraps around. 

* The subquery is the meat of it. It tries to determine the duration of each execution of a given SQL_ID based on SQL_EXEC_ID, SQL_EXEC_START. 
  I then roll it up and try to group it even more. 
  
* PX_SESSIONS are interesting, I wanted to keep track of the time spent by the coordinator running the query, not each individual slave. That's why I put all 
  those DECODE's in there. Maybe there's a better way. I also have a hackish way to count the number of slaves. All it really tells you is that it was a PX query
  but nothing more meaningful than that, so maybe a Y/N value would be more appropriate. 
  
* The ETL can create many sessions in the database and each session can run the same SQL (with binds). In the rollup it will tell you how many different sessions
  ran the same SQL, ie COUNT(SID_SER). 

*/


SET LIN 500 PAGES 1000
COL INSTANCE_NUMBER FORMAT 99
COL USERNAME FORMAT A10
COL END FORMAT A40
COL DURATION FORMAT A40
COL SQL_OPNAME format A15
COL "SID,SERIAL#" FORMAT A15
COL ELAPSED_S 	FORMAT 9999990.99
COL DURATION_S  FORMAT 9999990.99
COL ELAPSED_SPE FORMAT 9999990.99
SET LONG 99999 LONGC 80
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';

SELECT 
	SQL_ID, 
	SQL_OPNAME,
	(MAX(SQL_EXEC_ID)-MIN(SQL_EXEC_ID))+1 EXECUTIONS, 
	COUNT(SID_SER) SESSIONS,
	SUM(PX_SESSIONS) PX_SESSIONS,
	SUM(EXTRACT(HOUR FROM DURATION)*60*60 + EXTRACT(MINUTE FROM DURATION)*60 + EXTRACT(SECOND FROM DURATION)) ELAPSED_S,
	--(MAX(SQL_EXEC_END) - MIN(SQL_EXEC_START))*24*60*60 DURATION_S,
	(SUM(EXTRACT(HOUR FROM DURATION)*60*60 + EXTRACT(MINUTE FROM DURATION)*60 + EXTRACT(SECOND FROM DURATION))) / ((MAX(SQL_EXEC_ID)-MIN(SQL_EXEC_ID))+1)  ELAPSED_SPE,
	MIN(SQL_EXEC_START),
	MAX(SQL_EXEC_END)
FROM (
	SELECT
		 TO_CHAR(DECODE(A.QC_SESSION_ID,NULL,A.SESSION_ID,A.QC_SESSION_ID) ||','|| DECODE(A.QC_SESSION_SERIAL#,NULL,A.SESSION_SERIAL#,A.QC_SESSION_SERIAL#)) "SID_SER"
		,SUM(DECODE(A.QC_SESSION_ID,NULL,0,1)) PX_SESSIONS
		,A.SQL_ID
		,A.SQL_OPNAME
		,A.SQL_EXEC_ID
		,A.SQL_EXEC_START
		,CAST(MAX(A.SAMPLE_TIME) AS DATE) "SQL_EXEC_END"
		,MAX(A.SAMPLE_TIME) - SQL_EXEC_START "DURATION" 
	FROM 
		DBA_HIST_ACTIVE_SESS_HISTORY A,
		--V$ACTIVE_SESSION_HISTORY A,
		DBA_USERS B
	WHERE 
			A.USER_ID = B.USER_ID
		AND B.USERNAME = 'DCDS_ETL'
		--AND A.SAMPLE_TIME >= SYSDATE - 1
		AND A.SAMPLE_TIME BETWEEN TO_TIMESTAMP('2014-03-06 00:00:00','YYYY-MM-DD HH24:MI:SS') AND TO_TIMESTAMP('2014-03-07 00:00:00','YYYY-MM-DD HH24:MI:SS')
		AND A.SQL_EXEC_ID IS NOT NULL
		--AND A.SQL_OPNAME NOT IN ('INSERT','UPDATE')
		--AND SQL_ID='956978fcf5jj6'
	GROUP BY
		 TO_CHAR(DECODE(A.QC_SESSION_ID,NULL,A.SESSION_ID,A.QC_SESSION_ID) ||','|| DECODE(A.QC_SESSION_SERIAL#,NULL,A.SESSION_SERIAL#,A.QC_SESSION_SERIAL#))
		,A.SQL_ID
		,A.SQL_OPNAME
		,A.SQL_EXEC_ID
		,A.SQL_EXEC_START 
) 
GROUP BY 
	SQL_ID,
	SQL_OPNAME
ORDER BY 
	MIN(SQL_EXEC_START)
;


/* SUMMARY WITH SQL_TEXT
You can SET MARK HTML ON to produce html table that you can put in an html file 
*/


SET LIN 500 PAGES 1000
COL INSTANCE_NUMBER FORMAT 99
COL USERNAME FORMAT A10
COL END FORMAT A40
COL DURATION FORMAT A40
COL SQL_OPNAME format A15
COL "SID,SERIAL#" FORMAT A15
COL ELAPSED_S 	FORMAT 9999990.99
COL DURATION_S  FORMAT 9999990.99
COL ELAPSED_SPE FORMAT 9999990.99
SET LONG 99999 LONGC 80
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS';
SELECT
	C.SQL_ID,
	SQL_OPNAME,
	EXECUTIONS,
	SESSIONS,
	PX_SESSIONS,
	ELAPSED_S,
	ELAPSED_SPE,
	MIN_EXEC_START,
	MAX_EXEC_END,
	D.SQL_TEXT
FROM
	(
		SELECT 
			SQL_ID, 
			SQL_OPNAME,
			(MAX(SQL_EXEC_ID)-MIN(SQL_EXEC_ID))+1 EXECUTIONS, 
			COUNT(SID_SER) SESSIONS,
			SUM(PX_SESSIONS) PX_SESSIONS,
			SUM(EXTRACT(HOUR FROM DURATION)*60*60 + EXTRACT(MINUTE FROM DURATION)*60 + EXTRACT(SECOND FROM DURATION)) ELAPSED_S,
			--(MAX(SQL_EXEC_END) - MIN(SQL_EXEC_START))*24*60*60 DURATION_S,
			(SUM(EXTRACT(HOUR FROM DURATION)*60*60 + EXTRACT(MINUTE FROM DURATION)*60 + EXTRACT(SECOND FROM DURATION))) / ((MAX(SQL_EXEC_ID)-MIN(SQL_EXEC_ID))+1)  ELAPSED_SPE,
			MIN(SQL_EXEC_START) MIN_EXEC_START,
			MAX(SQL_EXEC_END) MAX_EXEC_END
		FROM (
				SELECT
					 TO_CHAR(DECODE(A.QC_SESSION_ID,NULL,A.SESSION_ID,A.QC_SESSION_ID) ||','|| DECODE(A.QC_SESSION_SERIAL#,NULL,A.SESSION_SERIAL#,A.QC_SESSION_SERIAL#)) "SID_SER"
					,SUM(DECODE(A.QC_SESSION_ID,NULL,0,1)) PX_SESSIONS
					,A.SQL_ID
					,A.SQL_OPNAME
					,A.SQL_EXEC_ID
					,A.SQL_EXEC_START
					,CAST(MAX(A.SAMPLE_TIME) AS DATE) "SQL_EXEC_END"
					,MAX(A.SAMPLE_TIME) - SQL_EXEC_START "DURATION" 
				FROM 
					DBA_HIST_ACTIVE_SESS_HISTORY A,
					--V$ACTIVE_SESSION_HISTORY A,
					DBA_USERS B
				WHERE 
						A.USER_ID = B.USER_ID
					AND B.USERNAME = 'DCDS_ETL'
					--AND A.SAMPLE_TIME >= SYSDATE - 1
					--AND A.SAMPLE_TIME BETWEEN TO_TIMESTAMP('2014-03-06 00:00:00','YYYY-MM-DD HH24:MI:SS') AND TO_TIMESTAMP('2014-03-07 00:00:00','YYYY-MM-DD HH24:MI:SS')
					AND A.SQL_EXEC_ID IS NOT NULL
					--AND A.SQL_OPNAME NOT IN ('INSERT','UPDATE')
					--AND SQL_ID='4ma3u76n0t501'
					--AND ((A.SESSION_ID = 1896 AND A.SESSION_SERIAL#=17397) OR (A.QC_SESSION_ID = 1896 AND A.QC_SESSION_SERIAL#=17397))
				GROUP BY
					 TO_CHAR(DECODE(A.QC_SESSION_ID,NULL,A.SESSION_ID,A.QC_SESSION_ID) ||','|| DECODE(A.QC_SESSION_SERIAL#,NULL,A.SESSION_SERIAL#,A.QC_SESSION_SERIAL#))
					,A.SQL_ID
					,A.SQL_OPNAME
					,A.SQL_EXEC_ID
					,A.SQL_EXEC_START 
			) 
		GROUP BY 
			SQL_ID,
			SQL_OPNAME
	) C,
	DBA_HIST_SQLTEXT D
WHERE
	C.SQL_ID = D.SQL_ID(+)
ORDER BY
	MIN_EXEC_START
;






-- GOOGLE CHARTS TEST

/* 

	The above query produces data that is hard to visualize. I basically took the subquery from above, and tweaked it so that it formats the data for google charts. 

*/

	SELECT
		'['||
		''''||TO_CHAR(DECODE(A.QC_SESSION_ID,NULL,A.SESSION_ID,A.QC_SESSION_ID) ||','|| DECODE(A.QC_SESSION_SERIAL#,NULL,A.SESSION_SERIAL#,A.QC_SESSION_SERIAL#))||''','||
		''''||A.SQL_ID||' ('||A.SQL_OPNAME||')'','||
		'new Date('||TO_CHAR(A.SQL_EXEC_START,'YYYY')||','||TO_CHAR(A.SQL_EXEC_START,'MM')||','||TO_CHAR(A.SQL_EXEC_START,'DD')||','||TO_CHAR(A.SQL_EXEC_START,'HH24')||','||TO_CHAR(A.SQL_EXEC_START,'MI')||','||TO_CHAR(A.SQL_EXEC_START,'SS')||',000),'||
		'new Date('||TO_CHAR(MAX(A.SAMPLE_TIME),'YYYY')||','||TO_CHAR(MAX(A.SAMPLE_TIME),'MM')||','||TO_CHAR(MAX(A.SAMPLE_TIME),'DD')||','||TO_CHAR(MAX(A.SAMPLE_TIME),'HH24')||','||TO_CHAR(MAX(A.SAMPLE_TIME),'MI')||','||TO_CHAR(MAX(A.SAMPLE_TIME),'SS')||','||TO_CHAR(MAX(A.SAMPLE_TIME),'FF3')||')'||
		--'new Date(0,0,0,'||TO_CHAR(A.SQL_EXEC_START,'HH24')||','||TO_CHAR(A.SQL_EXEC_START,'MI')||','||TO_CHAR(A.SQL_EXEC_START,'SS')||',000),'||
		--'new Date(0,0,0,'||TO_CHAR(MAX(A.SAMPLE_TIME),'HH24')||','||TO_CHAR(MAX(A.SAMPLE_TIME),'MI')||','||TO_CHAR(MAX(A.SAMPLE_TIME),'SS')||','||TO_CHAR(MAX(A.SAMPLE_TIME),'FF3')||')'||
		'],' GC
	FROM 
		DBA_HIST_ACTIVE_SESS_HISTORY A,
		--V$ACTIVE_SESSION_HISTORY A,
		DBA_USERS B
	WHERE 
			A.USER_ID = B.USER_ID
		AND B.USERNAME = 'DCDS_ETL'
		--AND A.SAMPLE_TIME >= SYSDATE - 1
		AND A.SAMPLE_TIME BETWEEN TO_TIMESTAMP('2014-03-06 00:00:00','YYYY-MM-DD HH24:MI:SS') AND TO_TIMESTAMP('2014-03-07 00:00:00','YYYY-MM-DD HH24:MI:SS')
		AND A.SQL_EXEC_ID IS NOT NULL
		--AND A.SQL_OPNAME NOT IN ('INSERT','UPDATE')
		--AND SQL_ID='956978fcf5jj6'
	GROUP BY
		 TO_CHAR(DECODE(A.QC_SESSION_ID,NULL,A.SESSION_ID,A.QC_SESSION_ID) ||','|| DECODE(A.QC_SESSION_SERIAL#,NULL,A.SESSION_SERIAL#,A.QC_SESSION_SERIAL#))
		,A.SQL_ID
		,A.SQL_OPNAME
		,A.SQL_EXEC_ID
		,A.SQL_EXEC_START
	ORDER BY
		A.SQL_EXEC_START
;


-- HTML Code

/* 
<html>
<head>
<title>ASH Analytics</title>
<style type="text/css">

#timeline {
	width: 100%; 
	height: 50%;
}

table {
	font-family:Arial, Helvetica, sans-serif;
	font-size:10px;
	border: 1px solid;
	border-spacing: 0px;
}

tbody {
	display: block;
	height: 400px;
	overflow-y: scroll;
}


td {
	border: 1px solid;
	vertical-align:top;
}

th {
	font-size:12px;
	padding: 5px;
	border: 1px solid;
}

</style>	
</head>
<body>
<script type="text/javascript" src="https://www.google.com/jsapi?autoload={'modules':[{'name':'visualization','version':'1','packages':['timeline']}]}"></script>
<script type="text/javascript">

google.setOnLoadCallback(drawChart);
function drawChart() {

  var container = document.getElementById('timeline');
  var chart = new google.visualization.Timeline(container);

  var dataTable = new google.visualization.DataTable();
  dataTable.addColumn({ type: 'string', id: 'SID,SERIAL' });
  dataTable.addColumn({ type: 'string', id: 'SQL_ID' });
  dataTable.addColumn({ type: 'date', id: 'Start' });
  dataTable.addColumn({ type: 'date', id: 'End' });
  dataTable.addRows([
  
  
  

  *** PASTE THE RESULTS OF THE ABOVE SQL (take out the very last comma) ***




  ]);

	var options = {
		avoidOverlappingGridLines: false,
		title: 'My Timeline'
	};

	chart.draw(dataTable, options);

}
</script>


<h2>Timeline</h2>

<form> 
	Width:<input type='text' id='userInput1' value='100%' />
	Height:<input type='text' id='userInput2' value='50%' />
	<input type='button' onclick="
		document.getElementById('timeline').style.width=document.getElementById('userInput1').value; 
		document.getElementById('timeline').style.height=document.getElementById('userInput2').value; 
		drawChart();" 
	value='Change' />
</form>

<div style="width:100%; overflow:scroll;"><div id="timeline"></div></div>

	*** PASTE THE SUMMARY WITH SQL_TEXT HTML FORMATTED OUTPUT HERE ***

</body>
</html>

*/








