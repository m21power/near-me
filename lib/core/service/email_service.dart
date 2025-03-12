import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:near_me/core/constants/api_key.dart';
import 'package:near_me/core/error/failure.dart';

class EmailService {
  static Future<Either<Failure, Unit>> sendOtpEmail(
      String recipientEmail, String otp) async {
    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final headers = {
      'Authorization': 'Bearer ${ApiKey.optKey}',
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
              
              <!-- 🖼️ Image at the Top -->
              <img src="https://drive.google.com/uc?export=view&id=10WQVzOmvtoM9XRZoT-TP-P077MRsxzDb" 
                   alt="Welcome Image" 
                   style="max-width: 100%; height: auto; width: 300px; margin-bottom: 20px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);">
              
              <!-- 👋 Friendly Welcome Message -->
              <h2 style="color: #2e6f95;">Welcome to NearMe!</h2>
              <p style="font-size: 18px; color: #333;">
                We're excited to have you on board. To complete your registration, please use the OTP code below.
              </p>

              <!-- 🔢 OTP Code -->
              <p style="font-size: 18px; font-weight: bold; color: #2e6f95; background-color: #f0f8ff; display: inline-block; padding: 10px 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);">
                $otp
              </p>

              <!-- 📝 Instructions -->
              <p style="font-size: 16px; color: #555;">
                Copy the code above and enter it in the app to verify your email. <br><br>
                If you did not request this, you can safely ignore this email.
              </p>

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
        return right(unit);
      } else {
        print('Failed to send email: ${response.body}');
        return Left(
            ServerFailure(message: "Failed to send email: ${response.body}"));
      }
    } catch (e) {
      print('Error sending email: $e');
      return Left(ServerFailure(message: "Error sending email: $e"));
    }
  }
}
