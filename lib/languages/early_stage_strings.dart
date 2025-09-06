
class EarlyStageStrings {
  static final Map<String, Map<String, String>> translations = {
    'ar': getTranslationArabic,
    'dk': getTranslationDanish,
    'en': getTranslationEnglish,
    'fa': getTranslationFarsi,

  };

  static String getTranslation(String key, String? languageCode) {
    // Sanitize language code
    final String sanitizedCode = (languageCode ?? 'en').toLowerCase().split('_')[0];

    // Try to get translation for the specified language
    final translation = translations[sanitizedCode]?[key];
    if (translation != null) {
      return translation;
    }

    // Fallback to English if translation not found
    return translations['en']?[key] ?? key;
  }
}

const Map<String, String> getTranslationArabic = {

  // Notification
  'notification': 'اعلان',
  'received_friend_request_title': 'طلب صداقة',
  'received_friend_request_body': 'لقد تلقيت طلب صداقة من',
  'received_new_message_title': 'رسالة جديدة',
  'received_new_message_body': 'لقد تلقيت رسالة جديدة من',

  // Loading app
  'loading_notifications': 'جارٍ تحميل الإشعارات...',
  'loading_configurations': 'جارٍ تحميل الإعدادات...',
  'setting_security': 'جارٍ إعداد الأمان...',
  'loading_your_data': 'جارٍ تحميل بياناتك...',
  'loading_other_services': 'جارٍ تحميل الخدمات الأخرى...',
  'done': 'تم!',
  'error_retry': 'حدث خطأ - سنحاول مرة أخرى...',
};

const Map<String, String> getTranslationDanish = {

  // Notification
  'notification': 'Notifikation',
  'received_friend_request_title': 'Venneanmodning',
  'received_friend_request_body': 'Du har modtaget en venneanmodning fra',
  'received_new_message_title': 'Ny besked',
  'received_new_message_body': 'En ny besked fra',

  // Loading app
  'loading_notifications': 'Indlæser notifikationer...',
  'loading_configurations': 'Indlæser konfigurationer...',
  'setting_security': 'Opsætter sikkerheden...',
  'loading_your_data': 'Indlæser dine data...',
  'loading_other_services': 'Indlæser andre tjenester...',
  'done': 'Klart!',
  'error_retry': 'Fejl opstod - Vi prøver igen...',

};

const Map<String, String> getTranslationEnglish = {

  // Notification
  'notification': 'Notification',
  'received_friend_request_title': 'Friend request',
  'received_friend_request_body': 'You have received a friend request from',
  'received_new_message_title': 'New message',
  'received_new_message_body': 'Received a new message from',

  // Loading app
  'loading_notifications': 'Loading notifications...',
  'loading_configurations': 'Loading configurations...',
  'setting_security': 'Setting up security...',
  'loading_your_data': 'Loading your data...',
  'loading_other_services': 'Loading other services...',
  'done': 'Done!',
  'error_retry': 'An error occurred - Retrying...',

};

const Map<String, String> getTranslationFarsi = {

  // Notification
  'notification': 'پیام',
  'received_friend_request_title': 'درخواست دوستی',
  'received_friend_request_body': 'دریافت درخواست جدید از طرف',
  'received_new_message_title': 'پیام جدید',
  'received_new_message_body': 'دریافت پیام جدید از طرف ',

  // Loading app
  'loading_notifications': 'در حال بارگذاری اعلان‌ها...',
  'loading_configurations': 'در حال بارگذاری پیکربندی‌ها...',
  'setting_security': 'در حال تنظیم امنیت...',
  'loading_your_data': 'در حال بارگذاری داده‌های شما...',
  'loading_other_services': 'در حال بارگذاری سایر خدمات...',
  'done': 'انجام شد!',
  'error_retry': 'خطا رخ داد - دوباره تلاش می‌کنیم...',
};


