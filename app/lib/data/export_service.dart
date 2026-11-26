import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'app_repository.dart';

/// Writes the user's data to a JSON file and opens the system share sheet,
/// so the user decides where it goes (Drive, email, Files...).
class ExportService {
  ExportService(this._repo);
  final AppRepository _repo;

  Future<File> writeExportFile() async {
    final data = await _repo.exportData();
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    final file = File(p.join(dir.path, 'wealthwise-export-$stamp.json'));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file;
  }

  Future<void> shareExport() async {
    final file = await writeExportFile();
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'application/json')],
      subject: 'My WealthWise AI data',
    ));
  }
}
