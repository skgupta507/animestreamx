import 'package:animestream/core/database/database.dart';
import 'package:animestream/ui/models/sources.dart';
import 'package:animestream/ui/models/subtitles.dart';

class SettingsModal {
  final int? skipDuration;
  final int? megaSkipDuration;
  final bool? showErrors;
  final bool? receivePreReleases;
  final bool? amoledBackground;
  final String? preferredQuality; // 1080p | 720p |480p | 360p as string
  final double? navbarTranslucency; //value from 0 to 1
  final bool? fasterDownloads;
  final String? preferredProvider;
  final bool? darkMode;
  final bool? materialTheme;
  final bool? isDev;
  final String? downloadPath;
  final Databases? database;
  final bool? enableSuperSpeeds;

  SettingsModal({
    this.megaSkipDuration,
    this.skipDuration,
    this.showErrors,
    this.receivePreReleases,
    this.amoledBackground,
    this.preferredQuality,
    this.navbarTranslucency,
    this.fasterDownloads,
    this.preferredProvider,
    this.darkMode,
    this.materialTheme,
    this.isDev,
    this.downloadPath,
    this.database,
    this.enableSuperSpeeds,
  });

  factory SettingsModal.fromMap(Map<dynamic, dynamic> map) {
    return SettingsModal(
      megaSkipDuration: map['megaSkipDuration'] ?? 85,
      skipDuration: map['skipDuration'] ?? 10,
      showErrors: map['showErrors'] ?? false,
      receivePreReleases: map['receivePreReleases'] ?? false,
      amoledBackground: map['amoledBackground'] ?? false,
      preferredQuality: map['preferredQuality'] ?? "720p",
      navbarTranslucency: map['navbarTranslucency'] ?? 0.5,
      fasterDownloads: map['fasterDownloads'] ?? false,
      preferredProvider: map['preferredProvider'] ?? sources[0],
      darkMode: map['darkMode'] ?? true,
      materialTheme: map['materialTheme'] ?? false,
      isDev: map['isDev'] ?? false,
      downloadPath: map['downloadPath'] ?? '/storage/emulated/0/Download/animestream',
      database: DatabaseFromString.getDb(map['database'] ?? "anilist"),
      enableSuperSpeeds: map['enableSuperSpeeds'] ?? false,
    );
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'skipDuration': skipDuration,
      'megaSkipDuration': megaSkipDuration,
      'showErrors': showErrors,
      'receivePreReleases': receivePreReleases,
      'amoledBackground': amoledBackground,
      'preferredQuality': preferredQuality,
      'navbarTranslucency': navbarTranslucency,
      'fasterDownloads': fasterDownloads,
      'preferredProvider': preferredProvider,
      'darkMode': darkMode,
      'materialTheme': materialTheme,
      'isDev': isDev,
      'downloadPath': downloadPath,
      'database': database?.name,
      'enableSuperSpeeds': enableSuperSpeeds,
    };
  }
}

class UserPreferencesModal {
  final bool? episodeGridView;
  final SubtitleSettings? subtitleSettings;

  UserPreferencesModal({this.episodeGridView, this.subtitleSettings});

  factory UserPreferencesModal.fromMap(Map<dynamic, dynamic> map) {
    return UserPreferencesModal(
      episodeGridView: map['episodeGridView'] ?? false,
      subtitleSettings: SubtitleSettings.fromMap(map['subtitleSettings'] ?? SubtitleSettings().toMap()),
    );
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'episodeGridView': episodeGridView ?? false,
      'subtitleSettings': subtitleSettings?.toMap() ?? SubtitleSettings().toMap(),
    };
  }
}
