import 'document_upload_temp_storage_stub.dart'
    if (dart.library.io) 'document_upload_temp_storage_io.dart' as impl;

import 'dart:typed_data';

Future<String?> saveBytesToTempUpload(Uint8List bytes, String fileName) =>
    impl.saveBytesToTempUpload(bytes, fileName);

Future<void> deleteTempUploadFile(String path) => impl.deleteTempUploadFile(path);
