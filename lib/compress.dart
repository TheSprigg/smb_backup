import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:archive/archive_io.dart';
import 'package:smb_backup/exception/compress_exception.dart';

class Compress {
  static Future<void> compress(String sourceDir, String tempDir, String outputFilename) async {    
    try {
      var encoder = ZipFileEncoder();
      await encoder.zipDirectory(Directory(sourceDir), filename: p.join(tempDir, outputFilename));
    } catch(exc) {
      throw CompressException(exc.toString());
    }
  }
}