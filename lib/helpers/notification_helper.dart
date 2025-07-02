import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationHelper {
  static final Uri _url = Uri.parse(
    'https://fcm.googleapis.com/v1/projects/flutter-maps-44621/messages:send',
  );

  static Future<String> getAccessToken() async {
    try {
      debugPrint('🔐 Starting token generation...');
      final serviceAccountJson ={
        "type": "service_account",
        "project_id": "flutter-maps-44621",
        "private_key_id": "26c50d433248ca605f1601d890cdd116efa7f5cf",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCziiYqimTbSkmi\nnAEM5j2IdJ7AI39weSPF02UF+D/hJAr2HZ1BEgrTsNsQpKnRf+JmDZHBhuCpJELP\nqUpeTbRzBJVaQh8JzotVc1dbA6+5uttLY08EgM0NNuoyfO1BrmDfCtB90QpdXiB8\nHxEwSDQymdxUSOT75peUuyBsBJ9E+084SEWVnWoETq1IcXSAwz606dve+AOC9vQJ\nmaOkxt8j8lMc9aODoekQMDHake0q80k+cE7KL/AC56Va6PcVZc7o4PkzNjLcngFD\nxGpUr+rRec7OjRhcRpLXRATOXzVkhw6lcZgBSKjX1eO68A3dsmHlPs3OSk2/NRlT\nABHYK9PvAgMBAAECggEAALBhiB1C2NKWqMCXgnCpwMnNyCf6t7hHSl2O0DCNMjR8\ntEgVz+edUgWmOZCgNDUc7c5Uhl0ZpJyGgxx/tA/xRtW4KwIA830u7LOGHMvNU1Wj\nvMzTQ02pO8k/qdTv5iYgqgp1FV6Ffyk6z68g1kIYrS8I+OvUsSDH6SK0s6Vq5Q1e\nMNXfF+/0iiXnWzqdbTVbOY2je6kinFuow+4FWVKKPtGZJ7ccgd0AfUyvzOIf2XjW\n31/iqjtoW3UGcAwu6P6Aczwu+YNu22KOKAZEw8MivEJzObK/xGNWBH4CrAXWkFB/\n1hUBUtHebJq3WRgmTqsIp4CFtEyGqV+IG8lBjenVAQKBgQDkvs8OUfp1bBO5fIps\nxLpGO5S9St6N5NpY9VLtR8mFxQPNPejAwxsUgrNQ8sFnzfKDhJ8zbJBvKwbkCnaz\nPnumkhuFHwt4bSCVIXvMTrqbRey486Tmt7Phnyuoz+MAxHTj7kCFPVU8nFGOoK7o\nIVGKXXFub5pZB+BmKcbybZHFAQKBgQDI7nfC6P6W1+f9VNaV6QsTB/n7KBUcjxPT\n/ZdZ5P3J/eHTa8HYFwnHhayeKYuTg//ppK/8M059axVInrN0AkPJ8Vrewc/CQUPe\nkM0obN3mzw1a67psioMC00uYhl0SXtyS93r3deLjWmtxSZbAIdICPtfZsvAfkfsk\n12urtozo7wKBgQDXWXfPcIhN8dDkCIa9fbwskL0oNIsvpOuXYmaO8s2bfW5l1EoC\n5+vftGii5dgFJROSk9HZdPTJZAWZvOwhNcrtd5InEqIW3w4UuDA3mUr/EaaaPO7b\nMslLuTE+PXDl8Q5m44+koKhVZok1sLrZ2TxN+kjnAnSaKtss81nUNClPAQKBgQCY\n5c3ARaglhNoFzh8UKCfDLZit48xc1QtTj28yeqwcntLPHPp+wtkwOKooGJkbgaCl\nXCqGkUwy599kSU9pAagv7TcmtvivaxaIMEvNbTpWPkx9WU+c9LHI3pxxzhzYs9LJ\nCwVJdS1XsCB+Lm9GePXju4ppIF7UxzMCz+Ig4mLLhQKBgEaZlHyZiFwwXF9YQBbZ\njkqv9JM8x+qj+NVT2nqVhQ5K1gxb0le0IPV4OqkAg3AzXq8Ofq8RfYX/wKRkN1Rr\nYZjffL6xE7fEYGOx0IcaxnS9N7365reXfFDBJANnqsDqUrIQVJ4+9KPx4IjsjaYX\nM0R1S9YucsaMGR/Dq0IXHhCO\n-----END PRIVATE KEY-----\n",
        "client_email": "firebase-adminsdk-fbsvc@flutter-maps-44621.iam.gserviceaccount.com",
        "client_id": "105806840546313820790",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40flutter-maps-44621.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }
      ;

      final scopes = [
        'https://www.googleapis.com/auth/firebase.messaging',
      ];

      final credentials =
          auth.ServiceAccountCredentials.fromJson(serviceAccountJson);
      final client = await auth.clientViaServiceAccount(credentials, scopes);
      final token = client.credentials.accessToken.data;

      debugPrint('✅ Access token generated');
      client.close();
      return token;
    } catch (e) {
      debugPrint('❌ Failed to generate access token: $e');
      rethrow;
    }
  }

  static Future<void> sendNotification(
      String title, String body, String deviceToken) async {
    try {
      debugPrint('📲 Preparing to send notification...');
      final accessToken = await getAccessToken();
      debugPrint('📦 FCM Token used: $deviceToken');

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

      debugPrint('📤 Sending request to FCM...');
      final response = await http.post(
        _url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      debugPrint('📥 FCM Response: ${response.statusCode}');
      debugPrint('🧾 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Notification sent successfully');
      } else {
        debugPrint('❌ Failed to send notification');
      }
    } catch (e) {
      debugPrint('❌ Error sending notification: $e');
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

  static Future<void> addInAppNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'timestamp': Timestamp.now(),
      'isRead': false,
    });
  }

}
