/* 

MYSQL stored procedure to export sip_trace
into a more 'readable' format.

Fred Posner <fred@qxork.com>
2015-08-21

*/

delimiter //
drop procedure if exists kamailio_siptrace_callid //
CREATE PROCEDURE `kamailio_siptrace_callid`( 
  callid_var varchar(255)
)
begin
 if exists (select id from kamailio.sip_trace where callid = callid_var)
 then
  select CONCAT(time_stamp, ' (', method, ') ', status, '\n', fromip, ' -> ', toip, '\n', msg) 
  from kamailio.sip_trace 
  where callid = callid_var
  order by id 
  into outfile '/tmp/sip_trace.txt' 
  fields escaped by '';
 else
  select CONCAT(callid_var, 'not found') as comment into outfile '/tmp/sip_trace.txt' fields escaped by '';
 end if;
end //
delimiter ;

