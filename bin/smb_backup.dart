import 'dart:io';

import 'package:args/args.dart';
import 'package:smb_backup/compress.dart';
import 'package:smb_backup/exception/compress_exception.dart';
import 'package:smb_backup/exception/smb_exception.dart';
import 'package:smb_backup/exception/w_o_l_exception.dart';
import 'package:smb_backup/mail.dart';
import 'package:smb_backup/smb.dart';
import 'package:smb_backup/wake_on_lan.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('ip', abbr: 'i', help: 'ip of the server to reach')
    ..addOption('broadcast-ip', abbr: 'b', help: 'broadcast of the subnet (needed for WoL)')
    ..addOption('mac', abbr: 'm', help: 'mac address of the server (needed for WoL)')
    ..addOption('source', abbr: 's', help: 'directory to compress')
    ..addOption('tmp-folder', abbr: 't', help: 'temp folder (will be cleared afterwards)')
    ..addOption('filename', abbr: 'f', help: 'output filename')
    ..addOption('destination', abbr: 'd', help: 'destination path on smb share')
    ..addOption('user', abbr: 'u', help: 'user used for smb connect')
    ..addOption('password', abbr: 'p', help: 'password used for smb connect')
    ..addFlag('send-error-mail', abbr: 'e', help: 'send mail on error')
    ..addOption('smtp-server', help: 'smtp server for sending error mail')
    ..addOption('smtp-user', help: 'smtp user for sending error mail')
    ..addOption('smtp-password', help: 'smtp password for sending error mail')
    ..addOption('smtp-receiver', help: 'smtp receiver for sending error mail')
    ..addFlag('help', abbr: 'h',negatable: false, help: 'Usage instructions');
  ArgResults argResults = parser.parse(arguments);
  
  if(argResults.wasParsed('help')) {
    print(parser.usage);
    exit(0);
  }
  
  try {
    await WakeOnLan.wakeUpIfNecessary(argResults['ip'],argResults['broadcast-ip'],argResults['mac']);
    await Compress.compress(argResults['source'], argResults['tmp-folder'], argResults['filename']);
    await Smb.upload(argResults['destination'], argResults['tmp-folder'], argResults['filename'], argResults['ip'], argResults['user'], argResults['password']);
  
  } on WoLException catch (exc) {
    if(argResults.wasParsed('send-error-mail')) {
      await Mail.sendMail(argResults['smtp-server'], argResults['smtp-user'], argResults['smtp-password'], exc.message, 'Backup error: ${argResults['source']} [wol]', argResults['smtp-receiver']);
    }
  } on CompressException catch (exc) {
    if(argResults.wasParsed('send-error-mail')) {
      await Mail.sendMail(argResults['smtp-server'], argResults['smtp-user'], argResults['smtp-password'], exc.message, 'Backup error: ${argResults['source']} [compress]', argResults['smtp-receiver']);
    }
  } on SmbException catch (exc) {
    if(argResults.wasParsed('send-error-mail')) {
      await Mail.sendMail(argResults['smtp-server'], argResults['smtp-user'], argResults['smtp-password'], exc.message, 'Backup error: ${argResults['source']} [smb]', argResults['smtp-receiver']);
    }
  }
  exit(0);
}
