import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyCacheManager extends CacheManager {
  static const key = "customCache";

  MyCacheManager()
      : super(
          Config(
            key,
            stalePeriod: Duration(days: 7),
            maxNrOfCacheObjects: 100,
            repo: JsonCacheInfoRepository(
                databaseName: null), // ❌ Disables sqflite
          ),
        );
}
