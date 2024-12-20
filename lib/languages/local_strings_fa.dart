import 'package:get/get.dart';

class LocalStringsFa extends Translations {

  @override
  Map<String, Map<String, String>> get keys => {
    'fa_AF': {
      'app_name' : 'بازار بازی',
      'notification_title' : 'بازار بازی',


      // Games
      'games' : 'بازیها',
      'games_list' : 'فهرست بازیها',
      'wall_blaster': 'دیوار شکن',
      'ludo_world_war' : 'جنگ جهانی لودو',
      'quiz_list': 'فهرست بازی‌هایی لغتی',
      'add_question_hint' : 'سوالی دآری که میخواهی در هر کدام از این بازیها اضافه شود؟ دکمه پایین را بزن',
      'question_hint' : 'سؤال',
      'add_question_title': 'ارسال سؤال',
      'correct_answer_hint' : 'جواب درست',
      'pick_quiz_hint' : 'به کدام آزمون اضافه شود؟',
      'question': 'سؤال',
      'your_answer': 'پاسخ شما',
      'correct_answer': 'پاسخ درست',
      'correct_answers': 'پاسخ‌های صحیح',
      'wrong_answers' : 'پاسخ های اشتباه',
      'wrong_answer' : 'پاسخ اشتباه',
      'more_information_add_quiz' : 'اطلاعات بیشتر. مثلا مناطق که استفاده میشود ...',
      'enter_your_answer_here' : 'جواب خود را اینجا وارد کنید...',
      "game_result": "نتایج بازی",
      'question_is_answered' : 'شما قبلاً به این پرسش پاسخ داده‌اید',
      'pick_an_answer' : 'سؤال انتخواب نکردی ',
      'points_earned': 'امتیازها',
      'you_can_do_better': 'آرزوی نتیجه بهتر در دور بعدی',
      'not_bad': 'تلاش خوبی بود، ادامه بده',
      'well_done': 'بهترین نتیجه!',
      'excellent': ' عالی!',
      'with_options': 'با گزینه‌',
      'without_options': 'بدون گزینه‌',
      'show_result': 'نمایش نتیجه',
      'show_the_answer': 'نمایش جواب',
      'see_result_first': 'لطفاً ابتدا نتیجه را مشاهده کنید.',
      'end_of_family_game': 'این پایان آزمون بود. Play Bazaar امیدوار است که لذت برده باشید. دکمه زیر را فشار دهید تا به لیست بازی‌ها بازگردید.',
      'you_won_conguratulation': 'شما برنده شدید! تبریک!',
      'you_lost_word_was': 'شما باختید! کلمه این بود:',
      'incorrect_guess': 'حدس اشتباه:',


      //Personal information
      'name': ' نام  ',
      'lastname': ' فامیلی ',
      'email' : ' ایمیل  ',
      'password' : 'رمز ورود',
      're_password' : 'تکرار رمز ورود',
      'enter_your_password': 'رمز عبور خود را وارد کنید',
      'points': ' امتیاز  ',
      'aboutme' : 'درباره من',
      'me' : ' من  ',
      'optional' : '\\(اختیاری)',
      'status' : 'وضعیت  ',
      'online': 'فعال',
      'offline' : 'غیر فعال',

      // Group
      'private': 'خصوصی',
      'public': 'عمومی',
      'groups': 'گروه‌ها',
      'group_password_hint' : 'رمز ورود انتخاب کن ... ',
      'enter_group_password' : 'این گروه خصوصی می باشد!',
      'group_admin': 'رئیس گروه: ',
      'about_this_group' : 'درباره این گروه',
      'group': 'گروه: ',
      'creating_group_title': 'ساخت گروه',
      'creating_group_description': 'جزئیات گروه را انتخاب کنید',
      'group_password_title' : 'گروه خصوصی می باشد !',
      'enter_group_password_label' : 'رمز ورودی گروه ...',
      'group_name_hint' : 'اسم گروه...',
      'group_created' : 'گروه شما با موفقیت ثبت شد ',
      'leaving' : 'خروج',
      'number_of_members': 'تعداد اعضا',
      'group_names_valid_size' : 'نام گروه نباید خالی یا بیش از ۲۵ کاراکتر باشد',
      'group_name_unvalid_characters': 'نام گروه نباید شامل کاراکتر\'_\'باشد',
      'private_group_is_selected': 'شما یک گروه خصوصی انتخاب کرده‌اید، و یک گروه خصوصی باید رمز عبوری حداقل با ۴ کاراکتر داشته باشد',
      'you_became_a_member': 'شما عضو شدید',
      'already_member': 'قبلاً عضو شده‌اید',
      'not_group_member': 'شما عضو این گروه نیستید',
      'group_not_found': 'گروه پیدا نشد',


      // Others
      'language' : 'Languages',
      'account': 'حساب کاربری',
      'farsi' : 'فارسی , دری',
      'english' : 'English',
      'requests': 'درخواست ها ',
      'my_page' : 'خانه',
      'my_chat' : 'پیامها',
      'logout' : 'خروج ',
      'my_friends': 'لیست دوستان ',
      'delete_friend' : 'حذف از دوستی',
      'delete_friendship': 'حذف دوستی با',
      'my_memberships' : "عضویت های من",
      'write_message_here': "پیام خود را اینجا بنویس ...",
      'search_friends' : 'جستجو به دنبال دوست جدید ...',
      'search_in_friends': 'جستجو در میان دوستان...',
      'msg_friend_not_found': 'دوستی با این نام پیدا نشد',
      'search_groups' : 'جستجو به دنبال گروه جدید ...',
      'search' : 'جستجو',
      'choose_language' : 'انتخاب زبان',
      'not_have_account' : 'تا حالا ثبت نام نیستی؟  ',
      'make_account_here' : 'اینجا ثبت نام کن  ',
      'not_valid_email' : 'یک ایمیل معتبر وارد کن لطفا',
      'your_message_here' : 'پیام خود را اینجا بنویس ...',
      'do_have_account' : 'قبلا حساب باز کردی؟ ',
      'login_from_here' : 'از اینجا وارد شو ',
      'reset_password': 'بازیابی رمز عبور',
      'enter_your_email': 'ایمیل خود را وارد کنید',
      'send_reset_link': 'ارسال لینک بازیابی',
      'reset_link_sent': 'لینک بازیابی رمز عبور ارسال شد! ایمیل خود را بررسی کنید.',
      'forgot_password': 'رمز عبور خود را فراموش کرده‌اید؟',
      'received_requests' : 'درخواست های دریافتی',
      'description' : 'توضیحات',
      'no_description' : 'توضیحات وجود ندارد ',
      'path': 'درخواست اضافه شدن به بازی',
      'request_cancelled': 'درخواست لغو شد',
      'request_sent': 'درخواست ارسال شد',
      'search_not_found': 'داده‌ای با این پارامتر جستجو یافت نشد',
      'details': 'جزئیات',
      'select' : 'انتخاب کنید',
      'sounds': 'صداها',
      'say_hi': 'سلام کن به',
      'guide': 'راهنما',
      'danger_zone': 'منطقه خطر',


      // Friends
      'friends' : 'دوستان',
      'empty_friend_list': 'شما هنوز دوستی ندارید',
      'friend_request': 'درخواست دوستی',
      'friends_messages': 'پیام از طرف دوستان',


      // Buttons
      'btn_chats' : 'پیام‌ها',
      'btn_home': 'خانه',
      'btn_cancel': 'لغو',
      'btn_create': 'ثبت کن',
      'btn_login' : 'ورود',
      'btn_membership_request' : 'درخواست عضویت',
      'btn_accept' : 'تایید',
      'btn_decline': 'رد کن ',
      'btn_leaving_group': 'ترک گروه',
      'btn_edit' : 'ویرایش',
      'btn_save' : 'ذخیره',
      'btn_next' : 'سوال بعدی',
      'btn_result' : 'نتایج بازی',
      'btn_send_question' : 'ارسال سؤال',
      'btn_send' : 'ارسال',
      'btn_continue' : 'ادامه',
      'btn_review_question' : 'بازبینی درخواست ها',
      'btn_approve' : 'تایید',
      'btn_reject' : 'رد کن',
      'btn_resent' : 'ارسال مجدد ایمیل',
      'btn_sounds': 'صدای دکمه ها',
      'btn_awaiting_response': 'در انتظار پاسخ',
      'btn_approve_request': 'قبول درخواست',
      'btn_cancel_request': 'لغو درخواست',
      'btn_request_friendship' : 'درخواست دوستی',
      'btn_restart': 'راه‌اندازی مجدد',
      'btn_ok': 'باشه',
      'btn_delete_account': 'حذف حساب',
      'btn_new_game': 'بازی جدید',
      'hangman': 'بازی جلاد',



      //  Settings
      'settings': 'تنظیمات',


      // Notifcation - generall
      'notification': 'پیام',
      'notifications' : 'پیامک ها',
      'question_added' : 'سوال شما با موفقیت ثبت شد',
      'question_added_to_quiz' : 'سوال با موفقیت ثبت شد',
      'quetion_added_title': 'موفقیت',
      'fill_all_input' : 'خانه که مربوط به سوال و جواب ها هست باید پر شود',
      'fill_all_input_title': 'فرستادن سؤال',


      // Snackbar Message
      'leaving_group': 'مطمئن هستی از اینکه گروه را ترک میکنی؟',
      'leaving_group_succed' : 'با موفقیت از گروه خارج شدی',
      'group_membership_succed' : 'با موفقیت عضو گروه شدی',
      'leaving_group_failed' : 'به دلیل بروز خطا، امکان حذف شما از گروه وجود نداشت. لطفاً دوباره تلاش کنید',
      'group_membership_failed' : 'به دلیل بروز خطا، امکان اضافه کردن شما به گروه وجود نداشت. لطفاً دوباره تلاش کنید',
      'not_found_title' : 'شما در هیچ گروهی عضویت نداری!',
      'not_found_message': ' ۱: دکمه پایین سمت چپ (+) را برای ایجاد گروه خودت فشار بده  \n ۲: علامت جستجو بالا سمت چپ را برای جستجوی گروه که دیگران ایجاد کرده فشار بده',
      'friend_notfound': 'کاربری با این نام پیدا نشد!',
      'registration_succed': 'ثبت نام شما با موفقیت انجام شد',
      'authentication_failed' : 'حراز هویت ناموفق بود. لطفاً دوباره تلاش کنید',
      'unexpected_result' : 'اتفاق غیر منتظره رخ داد, لطفا دوباره تلاش کن',
      'members_notfound' : 'هیچ عضوی  پیدا نشد',
      'name_is_required' : 'وارد کردن نام ضروری است!',
      'approved_friend_request': 'درخواست دوستی شما پذیرفته شد ',
      'declined_friend_request' : 'درخواست دستی شما را رد کرد',
      'received_friend_request_body': 'دریافت درخواست جدید از طرف',
      'received_friend_request_title': 'درخواست دوستی جدید',
      'removed_from_friends' : 'از لیست دوستان شما حذف شد',
      'something_went_wrong' : 'خطایی رخ داد, لطفا دوباره تلاش کنید',
      'wrong_group_password' : 'رمز را که وارد کردید اشتباه بود!',
      'email_exist' : 'ایمیل وارد شده قبلا استفاده شده. اگر رمز ورود خود را فراموش کرده اید درخواست رمزجدید نمایید لطفا!',
      'too_weak_password': 'رمز ورود شما ضعیف است. لطفا رمز قوی تری متشکل از آلفبای کوچک, بزرک و شماره وارد کنید!',
      'user_not_found' : 'کاربر با این مشخصات یافت نشد, لطفا ایمیل و پسورد خودرا چک کنید!',
      'too-many-requests': 'تعداد دفعات تلاش برای ورود بیش از حد است. لطفاً بعداً دوباره تلاش کنید.',
      'verification_email_sent': 'ایمیل تأیید ارسال شد. ایمیل خود را باز کرده و حساب خدرا تایید کنید!',
      'reassign_text': 'آیا ایمیل خود را به اشتباه وارد کرده‌اید؟ روی دکمه زیر کلیک کنید.',
      'signed_as' : 'ورود با آدرس ',
      'verify_email_counter' : 'به دلایل امنیتی، لطفاً ایمیل خود را ظرف ۲۴ ساعت تأیید کنید. در غیر این صورت، حساب کاربری شما به صورت دائمی حذف خواهد شد!',
      'verify_email_title' : 'ایمیل خود را تأیید کنید',
      'check_your_inbox' : 'لطفاً وارد ایمیل خود شوید و روی لینک تایید فشار بده',
      'invalid_email_format' : 'فرمت ایمیل نامعتبر می باشد',
      'different_password' : 'رمز اول و دوم باید یکی باشد',
      'no_review_questions' : 'درخواستی وجود ندارد ',
      'account_removed_not_verifying_email': 'حساب کاربری شما به دلیل عدم تأیید ایمیل به طور دائم حذف شده است',
      'account_removed_permanantly' : 'حساب کاربری شما به طور دائم حذف شده است',
      'relogin_to_delete_your_account' : 'برای حذف حساب کاربری خود، لطفاً دوباره وارد شوید تا هویت خود را تأیید کنید.',
      'didnt_made_changes' : 'شما هیچ تغییری برای ذخیره کردن انجام نداده‌اید',
      'your_changes_succed' : 'اطلاعات شما با موفقیت تغییر یافت',
      'account_succed_but_info_failed' : 'حساب شما ایجاد شده است، اما نام و نام خانوادگی شما ذخیره نشد. لطفاً از طریق گزینه ویرایش آن را اضافه کنید',
      'delete_account_guidance': 'حذف حساب شما تمام داده‌های شما را به طور دائمی حذف کرده و بلافاصله اجرا می‌شود. این اقدام غیرقابل برگشت است. اگر روزی بخواهید برگردید، باید یک حساب جدید ایجاد کنید.',
      'delete_account_warning': 'آیا مطمئن هستید که می‌خواهید حساب خود را به طور دائمی حذف کنید؟',
      'delete_account_reauth_description': 'برای ادامه حذف حساب، لطفاً رمز عبور فعلی خود را وارد کنید. اگر رمز عبور خود را فراموش کرده‌اید، لطفاً از حساب خود خارج شوید و روی لینک "فراموشی رمز عبور" در صفحه ورود کلیک کنید تا آن را تغییر دهید.',
      'account_deletion_succed': 'حساب شما با موفقیت حذف شد.',
      'change_path' : 'مسیر را از زیر تغییر دهید',
      'error_while_sending_message': 'پیام شما ارسال نشد. دوباره تلاش کنید!',
      'allowed_message_length_1000' : 'لطفاً پیام خود را به کمتر از ۱۰۰۰ کاراکتر محدود کنید',
      'allowed_message_length_300' : 'لطفاً پیام خود را به کمتر از ۳۰۰ کاراکتر محدود کنید',
      'current_message_length' : 'طول فعلی پیام',
      'reached_start_of_conversation': 'به ابتدای گفتگو رسیده‌اید',
      'auto_destractor_message': 'پیام‌ها به طور خودکار پس از ۵ روز حذف می‌شوند',
      'chat_creation_failed': 'ایجاد چت ناموفق بود',
      'failed_to_accept_friend_request': 'قبول درخواست دوستی ناموفق بود',



      // سیاست حفظ حریم خصوصی
      'policy_title': 'حریم خصوصی',
      'policy_introduction_title': 'سیاست حفظ حریم خصوصی',
      'policy_introduction_description': 'دربازار بازی، ما به حریم خصوصی شما اولویت می‌دهیم و متعهد به تأمین امنیت اطلاعات شخصی شما هستیم. این سیاست حفظ حریم خصوصی توضیح می‌دهد که چگونه اطلاعات شما را هنگام استفاده از اپلیکیشن ما مدیریت، ذخیره و محافظت می‌کنیم.',

      'policy_info_collection_title': 'جمع‌آوری و ذخیره اطلاعات',
      'policy_info_collection_description': 'وقتی از اپلیکیشن بازار بازی استفاده می‌کنید، ممکن است برخی از اطلاعات شخصی شما، شامل نام، آدرس ایمیل و سایر جزئیات مورد نیاز برای ایجاد حساب کاربری و عملکرد اپلیکیشن را جمع‌آوری کنیم. تمام اطلاعات جمع‌آوری‌شده به‌صورت امن در پایگاه داده ما ذخیره می‌شود که توسط Firestore، یک سرویس ابری متعلق به گوگل، میزبانی می‌شود.',

      'policy_data_security_and_thirdparty_title': 'امنیت داده‌ها و دسترسی به اشخاص ثالث',
      'policy_data_security_and_thirdparty_description_part1': 'ما اطلاعات شخصی شما را با هیچ شرکت ثالثی به اشتراک نمی‌گذاریم، نمی‌فروشیم و توزیع نمی‌کنیم. اطلاعات شما تنها برای ارائه خدمات از طریق اپلیکیشن بازار بازی استفاده می‌شود. داده‌های شما در سرورهای فایربیس در فرانکفورت، آلمان ذخیره می‌شود.',
      'policy_data_security_and_thirdparty_description_part2': 'در حالی که اطلاعات شما در Firestore ذخیره می‌شود که متعلق به گوگل است، این به معنای آن نیست که گوگل مجاز به استفاده از اطلاعات شخصی شما برای هر هدفی غیرمرتبط با اپلیکیشن ما باشد. گوگل مسئولیت حفظ امنیت خدمات ابری خود را بر عهده دارد و ما اطمینان می‌دهیم که اطلاعات شما بر اساس تدابیر امنیتی سختگیرانه گوگل محافظت می‌شود.',

      'policy_forbidden_usage_title': 'شرایط استفاده',
      'policy_forbidden_usage_description': '''در Play Bazaar، ما تلاش می‌کنیم تا تجربه‌ای عالی برای کاربران خود فراهم کنیم و یک جامعه امن، محترمانه و لذت‌بخش ایجاد کنیم. برای حفظ این استاندارد، قوانین خاصی برای استفاده از گروه‌ها و پیام‌های خصوصی وضع شده است.  
هرگونه سخنان نفرت‌آمیز، تبعیض، آزار و اذیت، یا به اشتراک‌گذاری محتوای توهین‌آمیز یا نامناسب به شدت ممنوع است. بحث‌هایی که شامل نژادپرستی، جنسیت‌گرایی یا موضوعات حساس باشند، می‌تواند به پیامدهایی مانند محدودیت موقت یا دائمی برای شرکت در گروه‌ها یا ارسال پیام‌های خصوصی منجر شود.       
       با استفاده از این قابلیت‌ها، شما موافقت می‌کنید که به این قوانین پایبند باشید و به ایجاد یک محیط مثبت و محترمانه برای همه کمک کنید.''',

      'policy_agreement_title': 'موافقت با سیاست حفظ حریم خصوصی',
      'policy_agreement_description': 'با استفاده از اپلیکیشن Play Bazaar، شما این سیاست حفظ حریم خصوصی را تأیید و قبول می‌کنید. سرورهای Firebase که در یک کشور اروپایی قرار دارند برای پردازش داده‌ها استفاده می‌شوند. ما شما را تشویق می‌کنیم که این سیاست را به طور منظم بررسی کنید، زیرا استفاده مستمر از اپ نشان‌دهنده پذیرش هرگونه تغییر یا به‌روزرسانی است.',

      'policy_updates_title': 'به‌روزرسانی سیاست‌ها',
      'policy_updates_description': 'ما حق داریم هر زمان این سیاست حفظ حریم خصوصی را به‌روزرسانی یا اصلاح کنیم. هرگونه تغییرات ایجاد شده در این صفحه منعکس خواهد شد و ادامه استفاده شما از اپلیکیشن به معنای موافقت شما با این تغییرات است.',

      // تماس با ما
      'contact_us_title': 'تماس با ما',
      'contact_us_description': 'اگر سوال یا نگرانی در مورد این سیاست حفظ حریم خصوصی دارید، لطفاً با ما از طریق kh.techn@gmail.com تماس بگیرید.',


      // Long message
      'empty_quizz_message' : 'این بازی در حال حاضر فاقد کلمات است و ما به کمک شما نیاز داریم. لطفاً به صفحه قبلی برگردید و در پایین صفحه دکمه «ارسال سؤال» را فشار دهید و کلماتی که می‌خواهید به این بازی اضافه شوند را برای ما ارسال کنید. از لطف و زحمات شما سپاسگزاریم',
      'email_verification_intro' : 'به Play Bazaar خوش آمدید! یک ایمیل تایید به ایمیل شما ارسال شده است. لطفاً ایمیل خود را تایید کنید تا فرآیند تکمیل شود. ما هر عضو را در Play Bazaar تایید می‌کنیم تا اطمینان حاصل کنیم که پلتفرم ما فضایی امن است که در آن هر کاربر یک انسان واقعی است.',

      'quiz_play_guide': '''
        بازی‌های لغتی فعلاً شما را یا مستقیماً به صفحه بازی هدایت می‌کند و یا از شما می‌خواهد که انتخاب کنید "با گزینه" یا "بدون گزینه" می‌خواهید بازی کنید. در زیر هر دو شرایط برای شما توضیح داده شده است.
        
        **با گزینه**
        اگر انتخاب شما "با گزینه" باشد، این انتخاب برای هر سؤال چهار گزینه دارد که باید یکی از جواب‌ها را انتخاب کنید تا به سؤال بعدی بروید. پس از ۱۰ سؤال، نتایج نمایش داده می‌شود و امتیازاتی که کسب کرده‌اید مشخص خواهد شد.
        ۱. هر پاسخ درست ۳ امتیاز
        ۲. هر پاسخ اشتباه ۱ امتیاز منفی
        
        **بدون گزینه**
        اگر در جمع دوستان نشسته‌اید و به سرگرمی نیاز دارید، این گزینه مخصوص شماست. در اینجا سؤال به شما نمایش داده می‌شود تا همه نظر خود را بگویند. پس از اینکه همه نظرشان را گفتند، دکمه "نمایش جواب" را فشار دهید تا پاسخ درست مشخص شود. در این گزینه، دادن امتیاز به عهده خود شماست.
        ''',

        'notification_permission_description': '''لطفاً به ما اجازه دهید تا در صورت دریافت پیام خصوصی از دوستان، درخواست دوستی یا پیشنهادات ویژه از Play Bazaar به شما اطلاع دهیم. شما همیشه می‌توانید این اجازه را لغو کنید یا برای سرویس‌های خاصی در تنظیمات ارسال اعلان را غیرفعال کنید.''',

    }
  };

}