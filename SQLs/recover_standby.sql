--VALIDAR SEQUENCE E SCN
select 'x',to_char(sequence#) from v$log_history where recid = (select max(recid) from v$log_history);--39
select CURRENT_SCN from v$database;

--Aplicar o pfile initorcl.ora no /u01/app/oracle/product/19.0.0/dbhome_1/dbs/ no banco espelho
create pfile='/u01/app/oracle/backup/rman/initorcl.ora' from spfile;

--Criar controlfile standby pelo banco prod
alter database create standby controlfile as '/u01/app/oracle/backup/rman/controlfile_standby.ctl';

--Mover controlfile
mv initorcl.ora '/u01/app/oracle/product/19.0.0/dbhome_1/dbs/';

-- Com os backups, iniciar o standby
set dbid 1621069880;
startup nomount;

restore standby controlfile from '/u01/app/oracle/backup/rman/controlfile_standby.ctl';
restore spfile from '/u01/app/oracle/backup/rman/SPFILE_03_07_2022_1109096661.arch';

alter database mount;

--Catalogar os backups
catalog start with '/u01/app/oracle/backup/rman/';

--Aplicar archivelogs
list backup of archivelog all;
restore archivelog from logseq 20 until logseq 30;

--Iniciar restore e recover
RUN
{
restore database;
recover database;
}

--ATIVAR Banco Standby

-->> prod
      alter system archive log current;
-->> standby
      startup NOMOUNT;
      alter database mount standby database;
      alter database activate standby database;
      shutdown immediate;
      startup;






configure backup optimization on;
configure retention policy to redundancy 7;
configure device type disk parallelism 1;
configure channel 1 device type disk format '/u01/app/oracle/backup/rman/RMAN_ARCH_%d_%s_%p_%T.arch';
configure channel device type disk maxpiecesize 2G;
configure maxsetsize to 10G;
configure controlfile autobackup on;
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '/u01/app/oracle/backup/rman/autobackup/CONTROL_FILE_AUTOBKP_%F.bkp';
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/u01/app/oracle/backup/rman/autobackup/snapctrlfile.ctl';
crosscheck archivelog all;
delete expired archivelog all;

alter system switch logfile;
alter system switch logfile;
alter system switch logfile;
alter system checkpoint;
run {
backup as compressed backupset full database tag 'FULL_BD' format '/u01/app/oracle/backup/rman/full_bd-%T-%I-%d-%s.bkp';
backup current controlfile format '/u01/app/oracle/backup/rman/CONTROL_FILE_%t_dbid%I.rman';
BACKUP SPFILE TAG 'SPFILE' FORMAT '/u01/app/oracle/backup/rman/SPFILE_%D_%M_%Y_%t.arch';
backup archivelog all format '/u01/app/oracle/backup/rman/arch_%t_set%s_piece%p_dbid%I.rman';
}
delete noprompt archivelog all completed before 'sysdate - (12/24)';
