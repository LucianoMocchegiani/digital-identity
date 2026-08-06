import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:isar4_encryption_spike/spike_secret.dart';
import 'package:path/path.dart' as p;

const _correctKey = '01234567890123456789012345678901';
const _wrongKey = 'wrong-key-01234567890123456789012';

Future<Isar> _openIsar({
  required String directory,
  required String name,
  required String encryptionKey,
}) {
  return Isar.openAsync(
    schemas: [SpikeSecretSchema],
    directory: directory,
    name: name,
    engine: IsarEngine.sqlite,
    encryptionKey: encryptionKey,
    inspector: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    final libPath = p.normalize(
      p.join(Directory.current.path, 'native', 'isar.dll'),
    );
    if (!File(libPath).existsSync()) {
      fail(
        'Falta $libPath. Descargar isar_windows_x64.dll desde '
        'https://github.com/isar/isar/releases/tag/4.0.0-dev.14',
      );
    }
    await Isar.initialize(libPath);

    tempDir = await Directory.systemTemp.createTemp('isar4-encryption-spike-');
  });

  tearDown(() async {
    for (final name in ['encrypted', 'wrong-key']) {
      try {
        final isar = Isar.get(schemas: [SpikeSecretSchema], name: name);
        isar.close(deleteFromDisk: true);
      } catch (_) {
        // instancia no abierta en este test
      }
    }
  });

  tearDownAll(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('clave correcta permite leer datos escritos', () async {
    final dbPath = p.join(tempDir.path, 'correct');
    await Directory(dbPath).create(recursive: true);

    final isar = await _openIsar(
      directory: dbPath,
      name: 'encrypted',
      encryptionKey: _correctKey,
    );

    await isar.writeAsync((isar) {
      isar.spikeSecrets.put(
        SpikeSecret()
          ..id = isar.spikeSecrets.autoIncrement()
          ..secretId = 'pin-test'
          ..payload = 'super-secreto',
      );
    });

    final stored = await isar.spikeSecrets
        .where()
        .secretIdEqualTo('pin-test')
        .findFirstAsync();
    expect(stored?.payload, 'super-secreto');

    isar.close(deleteFromDisk: true);
  });

  test('clave incorrecta falla al abrir la misma base', () async {
    final dbPath = p.join(tempDir.path, 'wrong-key-case');
    await Directory(dbPath).create(recursive: true);

    final isar = await _openIsar(
      directory: dbPath,
      name: 'encrypted',
      encryptionKey: _correctKey,
    );
    await isar.writeAsync((isar) {
      isar.spikeSecrets.put(
        SpikeSecret()
          ..id = isar.spikeSecrets.autoIncrement()
          ..secretId = 'pin-test'
          ..payload = 'super-secreto',
      );
    });
    isar.close();

    await expectLater(
      _openIsar(
        directory: dbPath,
        name: 'encrypted',
        encryptionKey: _wrongKey,
      ),
      throwsA(isA<EncryptionError>()),
    );
  });
}
