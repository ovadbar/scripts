/*

AUGUST 2015
Fred Posner <fred@qxork.com>
http://qxork.com

Adapted from Aspito.com Siremis ACC

Assumes you have acc and missed_calls
using acc_db.

usage, when done:
	call kamailio_cdrs;

*/

ALTER TABLE acc add `cdr_id` integer NOT NULL default '0'; 
ALTER TABLE acc ADD INDEX `acc_callid` (callid);

ALTER TABLE missed_calls add `cdr_id` integer NOT NULL default '0'; 
ALTER TABLE missed_calls ADD INDEX `mc_callid` (callid);

CREATE TABLE `cdrs` (
  `cdr_id` bigint(20) NOT NULL auto_increment,
  `src_username` varchar(64) NOT NULL default '',
  `src_domain` varchar(128) NOT NULL default '',
  `dst_username` varchar(64) NOT NULL default '',
  `dst_domain` varchar(128) NOT NULL default '',
  `call_start_time` datetime NOT NULL default '0000-00-00 00:00:00',
  `duration` int(10) unsigned NOT NULL default '0',
  `sip_call_id` varchar(128) NOT NULL default '',
  `sip_from_tag` varchar(128) NOT NULL default '',
  `sip_to_tag` varchar(128) NOT NULL default '',
  `src_ip` varchar(64) NOT NULL default '',
  `created` datetime NOT NULL,
  PRIMARY KEY  (`cdr_id`),
  UNIQUE KEY `uk_cft` (`sip_call_id`,`sip_from_tag`,`sip_to_tag`)
);

DELIMITER //
CREATE PROCEDURE `kamailio_cdrs`()
BEGIN
  DECLARE done INT DEFAULT 0;
  DECLARE bye_record INT DEFAULT 0;
  DECLARE v_src_user,v_src_domain,v_dst_user,v_dst_domain,v_callid,v_from_tag,
     v_to_tag,v_src_ip VARCHAR(64);
  DECLARE v_inv_time, v_bye_time DATETIME;
  DECLARE inv_cursor CURSOR FOR SELECT src_user, src_domain, dst_user,
     dst_domain, time, callid,from_tag, to_tag, src_ip FROM kamailio.acc
     where method='INVITE' and cdr_id='0';
  DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;
  OPEN inv_cursor;
  REPEAT
    FETCH inv_cursor INTO v_src_user, v_src_domain, v_dst_user, v_dst_domain,
            v_inv_time, v_callid, v_from_tag, v_to_tag, v_src_ip;
    IF NOT done THEN
      SET bye_record = 0;
      SELECT 1, time INTO bye_record, v_bye_time FROM kamailio.acc WHERE
                 method='BYE' AND callid=v_callid AND ((from_tag=v_from_tag
                 AND to_tag=v_to_tag)
                 OR (from_tag=v_to_tag AND to_tag=v_from_tag))
                 ORDER BY time ASC LIMIT 1;
      IF bye_record = 1 THEN
        INSERT INTO kamailio.cdrs (src_username,src_domain,dst_username,
                 dst_domain,call_start_time,duration,sip_call_id,sip_from_tag,
                 sip_to_tag,src_ip,created) VALUES (v_src_user,v_src_domain,
                 v_dst_user,v_dst_domain,v_inv_time,
                 UNIX_TIMESTAMP(v_bye_time)-UNIX_TIMESTAMP(v_inv_time),
                 v_callid,v_from_tag,v_to_tag,v_src_ip,NOW());
        UPDATE acc SET cdr_id=last_insert_id() WHERE callid=v_callid
                 AND from_tag=v_from_tag AND to_tag=v_to_tag;
      END IF;
      SET done = 0;
    END IF;
  UNTIL done END REPEAT;
END
//
DELIMITER ;
