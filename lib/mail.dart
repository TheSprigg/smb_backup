import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class Mail {
  static Future<void> sendMail(String smtp, String user, String password, String message, String subject, String to) async {
    final server = SmtpServer(smtp, port: 465, username: user, password: password, ssl:true);
    final mess = Message()
      ..from = Address(user, user)
      ..recipients.add(to)
      ..subject = subject
      ..text = message;

    await send(mess, server);
  }
}