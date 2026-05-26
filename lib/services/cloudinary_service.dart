import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _cloudName = 'dsfgaaeaz';
  static const String _uploadPreset = 'andres';

  static Future<String?> uploadImage(XFile file) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = _uploadPreset;
      final bytes = await file.readAsBytes();
      final fileName = file.name.isNotEmpty ? file.name : 'upload.jpg';
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

      final response = await request.send();
      if (response.statusCode == 200) {
        final data = jsonDecode(await response.stream.bytesToString());
        return data['secure_url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
