import 'package:dart_ping/dart_ping.dart';
import 'package:smb_backup/exception/w_o_l_exception.dart';
import 'package:wake_on_lan/wake_on_lan.dart';

class WakeOnLan {
  static final Duration _waitDuration = Duration(minutes: 10);
  
  static Future<void> wakeUpIfNecessary(String smbIp, String smbBroadcastIp, String smbMac) async {
    var isAlive = await WakeOnLan._checkIfAwake(smbIp);
    if(!isAlive) {
      await WakeOnLan._wakeOnLan(smbBroadcastIp, smbMac);
      await Future.delayed(_waitDuration);
      isAlive = await WakeOnLan._checkIfAwake(smbIp);
      if(!isAlive) {
        throw WoLException('could not wake NAS');
      }
    }
  }

  static Future<void> _wakeOnLan(String broadcastIp, String macAddress) async {
    final macValidation = MACAddress.validate(macAddress);
    final ipValidation = IPAddress.validate(broadcastIp);

    if(macValidation.state && ipValidation.state) {
      MACAddress macAd = MACAddress(macAddress);
      IPAddress ipAd = IPAddress(broadcastIp);

      WakeOnLAN wakeOnLan = WakeOnLAN(ipAd, macAd);

      await wakeOnLan.wake(
        repeat: 5,
        repeatDelay: const Duration(milliseconds: 500),
      );
    }
    else {
      throw WoLException('Error validating mac or broadcast ip');
    }
  }

  static Future<bool> _checkIfAwake(String ip) async {
    final ping = Ping(ip, count: 5);
    final pingData = await ping.stream.first;
    await ping.stop();
    return pingData.error == null;
  }
}