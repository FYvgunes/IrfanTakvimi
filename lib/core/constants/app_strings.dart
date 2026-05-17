import 'package:flutter/widgets.dart';

class AppStrings {
  final String languageCode;
  const AppStrings(this.languageCode);

  static const supportedLocales = <Locale>[
    Locale('tr'),
    Locale('en'),
    Locale('ar'),
  ];

  static const _table = <String, Map<String, String>>{
    'tr': {
      'tab_today': 'Bugün',
      'tab_calendar': 'Takvim',
      'tab_qibla': 'Kıble',
      'tab_hadiths': 'Hadisler',
      'tab_settings': 'Ayarlar',
      'settings_title': 'Ayarlar',
      'section_notifications': 'Bildirimler',
      'section_location': 'Konum',
      'section_language': 'Dil',
      'section_about': 'Hakkında',
      'notif_title': 'Namaz vakti bildirimleri',
      'notif_subtitle': '5 vakit için yerel hatırlatma gönderir',
      'select_manual_location': 'Manuel Konum Seç',
      'select_manual_location_sub': 'Ülke, il ve ilçe seçimi',
      'use_gps': 'GPS Konumunu Kullan',
      'gps_status_inactive': 'GPS şu an kullanılmıyor',
      'gps_status_active': 'GPS aktif',
      'gps_status_denied': 'İzin reddedildi — manuel konum kullanılıyor',
      'gps_threshold_title': 'GPS güncelleme eşiği',
      'gps_threshold_sub':
          'Bu mesafeyi aştığınızda vakitler yeniden hesaplanır.',
      'language_picker_label': 'Uygulama dili',
      'lang_tr': 'Türkçe',
      'lang_en': 'İngilizce',
      'lang_ar': 'Arapça',
      'about_app': 'İrfan Takvimi',
      'about_version': 'Sürüm 0.1.0',
      'about_credit':
          'Hadis içerikleri yalnızca Riyad as-Salihin gibi doğrulanmış kaynaklardan alınmıştır.',
    },
    'en': {
      'tab_today': 'Today',
      'tab_calendar': 'Calendar',
      'tab_qibla': 'Qibla',
      'tab_hadiths': 'Hadiths',
      'tab_settings': 'Settings',
      'settings_title': 'Settings',
      'section_notifications': 'Notifications',
      'section_location': 'Location',
      'section_language': 'Language',
      'section_about': 'About',
      'notif_title': 'Prayer time notifications',
      'notif_subtitle': 'Sends local reminders for the 5 daily prayers',
      'select_manual_location': 'Select Manual Location',
      'select_manual_location_sub': 'Country, city and district selection',
      'use_gps': 'Use GPS Location',
      'gps_status_inactive': 'GPS is not currently in use',
      'gps_status_active': 'GPS active',
      'gps_status_denied': 'Permission denied — using manual location',
      'gps_threshold_title': 'GPS update threshold',
      'gps_threshold_sub':
          'Prayer times are recomputed once you move beyond this distance.',
      'language_picker_label': 'Application language',
      'lang_tr': 'Turkish',
      'lang_en': 'English',
      'lang_ar': 'Arabic',
      'about_app': 'İrfan Takvimi',
      'about_version': 'Version 0.1.0',
      'about_credit':
          'Hadith content is sourced exclusively from verified collections such as Riyad as-Salihin.',
    },
    'ar': {
      'tab_today': 'اليوم',
      'tab_calendar': 'التقويم',
      'tab_qibla': 'القبلة',
      'tab_hadiths': 'الأحاديث',
      'tab_settings': 'الإعدادات',
      'settings_title': 'الإعدادات',
      'section_notifications': 'الإشعارات',
      'section_location': 'الموقع',
      'section_language': 'اللغة',
      'section_about': 'حول',
      'notif_title': 'إشعارات أوقات الصلاة',
      'notif_subtitle': 'يرسل تذكيرات محلية للصلوات الخمس',
      'select_manual_location': 'اختر الموقع يدويًا',
      'select_manual_location_sub': 'اختيار الدولة والمدينة والحي',
      'use_gps': 'استخدام موقع GPS',
      'gps_status_inactive': 'GPS غير مستخدم حاليًا',
      'gps_status_active': 'GPS نشط',
      'gps_status_denied': 'تم رفض الإذن — يتم استخدام الموقع اليدوي',
      'gps_threshold_title': 'حد تحديث GPS',
      'gps_threshold_sub':
          'يُعاد حساب أوقات الصلاة عند تجاوز هذه المسافة.',
      'language_picker_label': 'لغة التطبيق',
      'lang_tr': 'التركية',
      'lang_en': 'الإنجليزية',
      'lang_ar': 'العربية',
      'about_app': 'تقويم العرفان',
      'about_version': 'الإصدار 0.1.0',
      'about_credit':
          'محتوى الأحاديث مأخوذ حصريًا من مصادر موثقة مثل رياض الصالحين.',
    },
  };

  String t(String key) {
    return _table[languageCode]?[key] ?? _table['tr']![key] ?? key;
  }

  static AppStrings of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppStrings(locale.languageCode);
  }
}
