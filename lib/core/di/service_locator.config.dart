// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../shared/interfaces/performance_service_interface.dart' as _i787;
import '../../shared/interfaces/secure_storage_interface.dart' as _i78;
import '../../shared/interfaces/tts_service_interface.dart' as _i80;
import '../../shared/services/performance_service.dart' as _i910;
import '../../shared/services/secure_storage_service.dart' as _i152;
import '../../shared/services/tts_service.dart' as _i706;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i78.ISecureStorage>(() => _i152.SecureStorageService());
    gh.lazySingleton<_i80.ITTSService>(() => _i706.TTSService());
    gh.lazySingleton<_i787.IPerformanceService>(
        () => _i910.PerformanceService());
    return this;
  }
}
