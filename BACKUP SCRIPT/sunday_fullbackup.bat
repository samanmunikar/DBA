connect target saman/saman@saman;

run{
allocate channel d1 type disk; 
setlimit channel d1 kbytes 2097150 maxopenfiles 32 readrate 200; 
set maxcorrupt for datafile 1,2,3,4,5,6 to 0; 
backup  
incremental level 0
skip inaccessible 
tag sunday_BACKUP 
format 'C:\Oracle\flash_recovery_area\AUTOBACKUP\df_%Y_%M_%D_s%s_p%p' 
database; 
copy current controlfile to 'C:\Oracle\flash_recovery_area\AUTOBACKUP\cf_%Y_%M_%D_s%s_p%p.ctl'; 
sql 'alter system archive log current'; 
backup 
format 'C:\Oracle\flash_recovery_area\AUTOBACKUP\al_%Y_%M_%D_s%s_p%p' 
archivelog all 
delete input; 
release channel d1;
}