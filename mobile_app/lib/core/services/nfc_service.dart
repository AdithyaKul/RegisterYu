import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  Future<bool> isNfcAvailable() async {
    try {
      return await NfcManager.instance.isAvailable();
    } catch (e) {
      return false;
    }
  }

  void startSession({
    required Function(String tagId) onDiscovered,
    Function(String error)? onError,
  }) {
    // Basic polling options for ISO14443 and ISO15693 (common for tags)
    NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
      onDiscovered: (NfcTag tag) async {
        try {
          final data = tag.data;
          String tagId = 'Unknown';
          
          // Helper to safely access the map - cast explicitly to handle type inference issues
          final Map<String, dynamic> tagData = Map<String, dynamic>.from(data as Map);

          if (tagData.containsKey('nfca')) {
            tagId = _parseBytes(tagData['nfca']['identifier']);
          } else if (tagData.containsKey('mifare')) {
             tagId = _parseBytes(tagData['mifare']['identifier']);
          } else if (tagData.containsKey('isodep')) {
             tagId = _parseBytes(tagData['isodep']['identifier']);
          } 
          // Add more tag types checks as needed

          debugPrint('NFC Tag Discovered: $tagId');
          onDiscovered(tagId);
          
          NfcManager.instance.stopSession(); 
        } catch (e) {
          if (onError != null) onError(e.toString());
          NfcManager.instance.stopSession();
        }
      },
    );
  }

  String _parseBytes(List<dynamic> bytes) {
    return bytes.map((b) => (b as int).toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
  }

  void stopSession() {
    NfcManager.instance.stopSession();
  }
}
