USE Master

Go
CREATE DATABASE Session ON (
	Name= Session, 
	FileName='D:\Database\Session.mdf'
) 
LOG ON (
	Name= Session_log, 
	FileName='D:\Database\Session_log.ldf'
) 
Go

EXEC SP_HELPDB Session

ALTER DATABASE Session
 MODIFY FILE (name=Session, maxsize=100MB)
 Go
 EXEC SP_HELPDB Session
 Go
