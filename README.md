# SMB Backup
Dart script that compresses a folder and stores it on a smb share (including WoL if server is not available). On error it can send an email.

## Make it run
Script will run with the following cli parameters set.
```
$ dart run bin/smb_backup.dart -h
-i, --ip                      ip of the server to reach
-b, --broadcast-ip            broadcast of the subnet (needed for WoL)
-m, --mac                     mac address of the server (needed for WoL)
-s, --source                  directory to compress
-t, --tmp-folder              temp folder (will be cleared afterwards)
-f, --filename                output filename
-d, --destination             destination path on smb share
-u, --user                    user used for smb connect
-p, --password                password used for smb connect
-e, --[no-]send-error-mail    send mail on error
    --smtp-server             smtp server for sending error mail
    --smtp-user               smtp user for sending error mail
    --smtp-password           smtp password for sending error mail
    --smtp-receiver           smtp receiver for sending error mail
-h, --help                    Usage instructions
```
