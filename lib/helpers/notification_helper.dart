import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationHelper {
  static final Uri _url = Uri.parse(
    'https://fcm.googleapis.com/v1/projects/flutter-maps-44621/messages:send',
  );

  static Future<String> getAccessToken() async {
    try {
      print('🔐 Starting token generation...');
      final serviceAccountJson = {
        "type": "service_account",
        "project_id": "flutter-maps-44621",
        "private_key_id": "e28c2af92928a3b37abfe90914158eeb07a5230c",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCYF1azqX1GeP0v\noa5kqkswrUzpVrBVhm/Qfg8Y/oL40XYbelvFLTTbskO6ZTtbspUFFLthX3WOdp1x\nMHC92XlJnQ5nVawtIbUx5GSNDr+an8g8Us//TWgGgYILgpJgfbGNhT4fUpb3kYI9\ntI5e+M8pOUN2oHIL+SBhnBe/No3dRMBXwkYUUx5AqVSfiznUc8OXAa9uz2XknMmc\nvol5wwbqltu6DRrvHc78TN1UnA8msSCzUmMJ+EJ58l+whGAxFASDAPFi5VCu5fJ+\nCQG4ENebrjaUXGihJZ0/WZRettDMU3JUeMfBPuev89kGwGSv2AljH0mMmbggYPGl\n/b6C+jMNAgMBAAECggEAFue86QXnlgt2pgvFheeXt1cCNEoX+GlswYuannsGIo75\nKJ4+3+00/rlUNeg1DlRQ2RkMN1f3DmOSxo8zC4SLHakHmExwx8NB1Ke+9Pd5p8HU\nmDEonhx8RC6Q9UbO4LVNXjDo8DKyBcrmQIDGyErUeDLllCIJyv/T/p9RfDytFNug\nNXg+Kms+ezr7V8HgpmGxh8m0FJ30F7ubW3ylup5V64dGqbZp5atB+HcOg7BQ+dw7\nLVld6MmAsFlB9wqr62F8d6I2wvPtG3tddhL405fuE7l++UvOdArJZWKcOtVrlsf8\nXeRgRGSmFlAK+0HB7dk93CSaSQy+XGHlHDq+T6enSQKBgQDVhFtXVG3cf4Evf8/v\nwQJtKmGrkm33kXeKjBCfll3169PvY5KyFkspejG2zqLf9dsTwocJHPOlLpxxtOgZ\n2P+vTeF2Gp4hCrcqa24OTDjExVL2YKq2jZR3ze+v5xa1KoN7ZSfr/kdzaJ6B65zF\nEzG7wyJMBRuzDZNW+p8hIHbPKwKBgQC2WjY7ZxoX7nUCCadBWrWN/sZn0IAfRsFc\nI2fnUEcEZKnc581d5jp023V9f0/ZYs/MeL4xxWa48nnsG4xtnJGqTea4hAT+KyXI\nZgINwj9Cn2F1JSYo+fXz5gbtF8VKeCsT/NX2xKebazof4MLmHpCGB0ITbeQ6RHC1\n2S2u6HQqpwKBgQClX8Z/dV1CE1+zsoMTZ6LBern7cYbK4Vh9bs7RTF2qQ+X63Fya\nornEfmhS9ukgHgR44YpFfK8ZmWiCiWPb4T7oQKIIH8WqQepsaJjtagvuHAeN3IFc\ns3vy7wZeb9Yeq7b6s/afymr88GMUrbDW028JxrGhv7Mck78y9xqZRdO/0QKBgDe3\n3uRNv5paYWRLANEmX11Q4Nztx4hG/WQi6Wezjs+X1pNKPOUZKPl16TN8iDB7UdU/\ne5YHpDiU1o4/aKxBb/ziqsHsjP4Avx25lZ0QonW/7250+HEC15U7zxf48G6twzPr\nSJGLS09g9zSwX70iz7Q0WYtIQ7lOGkZmYuAT5RL3AoGBALzTyb/0leBVOvIRaCVo\nIHmi99jOOMHzZW6MADFnOJKFIE/TRjITQ2RRY8CP0eO7b0wrz1/DCyd2nykGZkIn\n/XFb5sPkIEh9GkKbitQXooZq40YKY4XJ0P05Ay9AapEpfG8EIhmkwk0Ur/E1x+PN\nvAA+M7n8JofBXVg369EvmMOU\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-fbsvc@flutter-maps-44621.iam.gserviceaccount.com",
        "client_id": "105806840546313820790",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40flutter-maps-44621.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      };

      final scopes = [
        'https://www.googleapis.com/auth/firebase.messaging',
      ];

      final credentials =
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
      final client = await auth.clientViaServiceAccount(credentials, scopes);
      final token = client.credentials.accessToken.data;

      print('✅ Access token generated');
      client.close();
      return token;
    } catch (e) {
      print('❌ Failed to generate access token: $e');
      rethrow;
    }
  }

  static Future<void> sendNotification(
      String title, String body, String deviceToken) async {
    try {
      print('📲 Preparing to send notification...');
      final accessToken = await getAccessToken();
      print('📦 FCM Token used: $deviceToken');

      final message = {
        "message": {
          "token": deviceToken,
          "notification": {
            "title": title,
            "body": body,
          },
          "android": {
            "priority": "high",
          },
        }
      };

      print('📤 Sending request to FCM...');
      final response = await http.post(
        _url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      print('📥 FCM Response: ${response.statusCode}');
      print('🧾 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully');
      } else {
        print('❌ Failed to send notification');
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  static Future<void> notifyAdmins(String title, String body) async {
    final adminUsersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();

    for (final doc in adminUsersSnapshot.docs) {
      final data = doc.data();
      final token = data.containsKey('fcmToken') ? data['fcmToken'] : null;

      if (token != null && token is String && token.isNotEmpty) {
        try {
          await sendNotification(title, body, token);
        } catch (e) {
          debugPrint('❌ Failed to send notification to admin ${doc.id}: $e');
        }
      } else {
        debugPrint('⚠️ No FCM token found for admin ${doc.id}');
      }
    }
  }
}
