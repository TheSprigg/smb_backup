import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:smb_backup/exception/smb_exception.dart';

import 'package:smb_connect/smb_connect.dart';

class Smb {
  static Future<void> upload(String outDir, String tmpDir, String outFilename, String smbIp, String smbUser, String smbPassword) async {
    IOSink? writer;
    SmbConnect? smbConnection;
    try {
      smbConnection = await SmbConnect.connectAuth(
        host: smbIp,
        domain: "",
        username: smbUser,
        password: smbPassword,//"Scarily-Amusable-Tabloid2",
      );
      var remoteFile = await smbConnection.file(p.join(outDir, outFilename));
      if(remoteFile.isExists) {
        smbConnection.delete(remoteFile);
      }
      remoteFile = await smbConnection.createFile(p.join(outDir, outFilename));
      writer = await smbConnection.openWrite(remoteFile);
      final localFile = File(p.join(tmpDir, outFilename));
      await writer.addStream(localFile.openRead());
    } catch(exc) {
      throw SmbException(exc.toString());
    } finally {
      writer?.flush();
      writer?.close();
      await smbConnection?.close();
    }
  }
}