import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:near_me/core/constants/api_key.dart';

class EmailService {
  final String _sendGridApiKey =
      ApiKey.optKey; // Replace with your SendGrid API key

  Future<void> sendOtpEmail(String recipientEmail, String otp) async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final headers = {
      'Authorization': 'Bearer $_sendGridApiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode(
      {
        'personalizations': [
          {
            'to': [
              {'email': recipientEmail}
            ],
            'subject': 'Your OTP Code',
          }
        ],
        'from': {
          'email':
              'nearbyme21@gmail.com' // Replace with your SendGrid verified email
        },
        'content': [
          {
            'type': 'text/html',
            'value': '''
        <html>
          <body style="font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 0; text-align: center;">
            <div style="max-width: 600px; margin: auto; background-color: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
              <h2 style="color: #2e6f95;">Hello!</h2>
              <p style="font-size: 18px; color: #333;">
                Your OTP code is <strong style="font-size: 24px; color: #2e6f95;">$otp</strong>.
              </p>
              <p style="font-size: 16px; color: #555;">
                Please copy the code above and enter it in the app to complete your verification. <br><br>
                If you did not request this, please ignore this email.
              </p>
              <img src="https://drive.google.com/uc?export=view&id=10WQVzOmvtoM9XRZoT-TP-P077MRsxzDb" alt="Amenities Image" style="max-width: 100%; height: auto; width: 300px; margin: 20px 0; border-radius: 8px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);">
              <footer style="margin-top: 20px; font-size: 12px; color: #888;">
                <p>&copy; 2025 NearMe. All rights reserved.</p>
              </footer>
            </div>
          </body>
        </html>
      '''
          }
        ]
      },
    );

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 202) {
        print('OTP email sent successfully');
      } else {
        print('Failed to send email: ${response.body}');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}
