
class NotificationTranslations {
  static final Map<String, Map<String, String>> translations = {
    'ar': notificationTranslationsAr,
    'dk': notificationTranslationsDa,
    'en': notificationTranslationsEn,
    'fa': notificationTranslationsFa,

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

const Map<String, String> notificationTranslationsAr = {
  'notification': 'اعلان',
  'received_friend_request_title': 'طلب صداقة',
  'received_friend_request_body': 'لقد تلقيت طلب صداقة من',
  'received_new_message_title': 'رسالة جديدة',
  'received_new_message_body': 'لقد تلقيت رسالة جديدة من',
};

const Map<String, String> notificationTranslationsDa = {
  'notification': 'Notifikation',
  'received_friend_request_title': 'Venneanmodning',
  'received_friend_request_body': 'Du har modtaget en venneanmodning fra',
  'received_new_message_title': 'Ny besked',
  'received_new_message_body': 'En ny besked fra',
};

const Map<String, String> notificationTranslationsEn = {
  'notification': 'Notification',
  'received_friend_request_title': 'Friend request',
  'received_friend_request_body': 'You have received a friend request from',
  'received_new_message_title': 'New message',
  'received_new_message_body': 'Received a new message from',

};

const Map<String, String> notificationTranslationsFa = {
  'notification': 'پیام',
  'received_friend_request_title': 'درخواست دوستی',
  'received_friend_request_body': 'دریافت درخواست جدید از طرف',
  'received_new_message_title': 'پیام جدید',
  'received_new_message_body': 'دریافت پیام جدید از طرف ',
};


