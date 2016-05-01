set linesize 132
col user_name format a15
col user_form_name format a40
col event format a30
col user_name print
select 
	fu.user_name,
	fft.user_form_name,
	vs.sid,
vsw.event
FROM APPLSYS.FND_USER FU,
applsys.fnd_form_tl fft,
applsys.fnd_logins fl,  
applsys.fnd_login_resp_forms flrf, v$session vs, v$session_wait vsw
where fu.user_id = fl.user_id
and fl.login_id = flrf.login_id
and flrf.form_id = fft.form_id
and flrf.audsid = vs.audsid
and vs.sid = vsw.sid
and flrf.end_time is null
--and fu.user_name='SGREGGS'
--and vs.sid = 1088
order by vs.sid;