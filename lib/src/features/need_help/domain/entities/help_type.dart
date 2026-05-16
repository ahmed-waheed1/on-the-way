import '../../../../shared/app_assets.dart';

enum HelpType {
  carBreakdown,
  flatTire,
  medicalHelp,
  weather;

  String get title => switch (this) {
        HelpType.carBreakdown => 'Car Breakdown',
        HelpType.flatTire => 'Flat Tire',
        HelpType.medicalHelp => 'Medical Help',
        HelpType.weather => 'Weather',
      };

  String get subtitle => switch (this) {
        HelpType.carBreakdown => 'Mechanical or engine issues',
        HelpType.flatTire => 'Puncture or tire damage',
        HelpType.medicalHelp => 'Emergency medical assistance',
        HelpType.weather => 'Describe the weather status',
      };

  String get iconPath => switch (this) {
        HelpType.carBreakdown => AppAssets.carBreakdown,
        HelpType.flatTire => AppAssets.flatTire,
        HelpType.medicalHelp => AppAssets.medicalHelp,
        HelpType.weather => AppAssets.weatherIcon,
      };
}
