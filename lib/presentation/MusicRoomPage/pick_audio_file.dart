import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

Future<void> pickAndUploadAudio(String roomCode) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['mp3', 'wav', 'm4a'],
  );

  if (result != null && result.files.single.path != null) {
    final file = result.files.single;
    final filePath = file.path!;
    final fileName = p.basename(filePath);

    final storageResponse = await Supabase.instance.client.storage
        .from('audios') // ensure this bucket exists in Supabase
        .upload(
          fileName,
          File(filePath),
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = Supabase.instance.client.storage
        .from('audios')
        .getPublicUrl(fileName);

    // ✅ Save to Firestore under this room
    await FirebaseFirestore.instance.collection("rooms").doc(roomCode).update({
      "audioUrl": publicUrl,
    });

    print("Uploaded audio URL: $publicUrl");
  }
}
