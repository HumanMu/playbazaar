import 'package:get/get.dart';

class LocalStringsEn extends Translations {

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      //appName
      'app_name' : 'Play Bazaar',

      // Games
      'games' : 'Games',
      'games_list': 'Games list',
      'ludo_world_war' : 'Ludo World War',
      'add_question_hint' : 'Do you have a question you would like to add to any of these games? Press the button below!',
      'question_hint' : 'Question',
      'add_question_title' : 'Sending Question',
      'pick_quiz_hint' : 'Which quiz should this be added to?',
      'your_answer': 'Your answer',
      'correct_answer' : 'Correct answer',
      'correct_answers': 'Correct answers',
      'wrong_answers' : 'Wrong answers',
      'wrong_answer' : 'Wrong answer',
      'more_information_add_quiz' : 'More information. For example, areas where it is used...',
      'enter_your_answer_here' : 'Enter your answer here...',
      'quiz_list' : 'Quiz List',
      'game_result': 'Game Results',
      'notification_title' : 'Play Bazaar',
      'question_is_answered' : 'You have already provided an answer to this question',
      'pick_an_answer' : 'Please select an answer before proceeding',
      'points_earned': 'Earned points',
      'you_can_do_better': 'Aim higher next time',
      'not_bad': 'Good effort, keep improving',
      'well_done': 'Well done!',
      'excellent': 'Excellent!',


      //Personal information
      'aboutme' : 'About me ',
      'name': 'Name  ',
      'lastname' : 'Lastname',
      'email' : 'Email  ',
      'points': 'Points  ',
      'me' : 'I am  ',
      'password': 'Password',
      're_password' : 'Re-enter your password',
      'optional' : ' \\(optional)',
      'staus' : 'Status  ',
      'online' : 'Online',
      'offline' : 'Offline',

      // group
      'private': 'Private',
      'public' : 'Public',
      'group_password_hint' : 'Enter the group password',
      'create_group_title': 'Creating group',
      'group_password_title' : 'Private group',
      'enter_group_password_label' : 'Enter group ',
      'enter_group_password' : 'This is a private group',
      'group_name_hint' : 'Choose a group name ...',
      'group_admin': 'Admin',
      'about_this_group' : 'About this group',
      'group': 'Group: ',
      'group_created' : 'Group created succesfully',
      'leaving' : 'Leaving',


      // Others
      'language' : 'انتخاب زبان',
      'farsi' : 'فارسی , دری',
      'english' : 'English',
      'requests': 'Requests',
      'my_page' : 'My Page',
      'logout' : 'Logout',
      'my_chat' : 'Messages',
      'my_friends': 'My Friends',
      'request_friendship' : 'Friend request',
      'delete_friend': 'Delete',
      'my_memberships' : "Messages",
      'write_message_here': "Write your messages here ...",
      'search_friends' : 'Search for friends ...',
      'search_groups' : 'Search for groups ...',
      'search' : 'Search',
      'choose_language' : 'Choose your favorite language',
      'not_have_account' : 'Do not have an account? ',
      'make_account_here' : 'Create your account here  ',
      'not_valid_email' : 'Enter a valid email please',
      'your_message_here' : 'Write your message here ...',
      'do_have_account' : 'Have an account? ',
      'login_from_here' : 'Login from here',

      'reset_password': 'Reset Password',
      'enter_your_email': 'Enter your email',
      'send_reset_link': 'Send Reset Link',
      'reset_link_sent': 'Password reset link sent! Check your email.',
      'forgot_password': 'Forgot Password?',
      'received_requests' : 'Recivied requests',
      'description' : 'Description',
      'no_description' : 'No description',
      'path': 'Request to be added to',
      'details': 'Details',
      'select' : 'Select',



      //Message
      'leaving_group': 'Are you sure about leaving the group?',
      'leaving_group_succed' : 'You left the group succesfully',
      'group_membershit_succed' : 'Your membershipt approved',
      'not_found_title': 'Your are not a member of any group!',
      'not_found_message': 'For creating your own group, click the button bellow, or search for a group',
      'friend_notfound': 'Could not find any friend!',
      'registration_succed': 'Your account has been created succesfully',
      'authentication_failed' : 'Authentication failed. Please try again',
      'unexpected_result' : 'An unexpected result, try again please',
      'members_notfound' : 'Could not find any members',
      'name_is_required' : 'Name is required',
      'approved_friend_request': 'Added to the list of your friend',
      'declined_friend_request' : 'Declined friend request',
      'removed_from_friends' : 'Removed from your friend list',
      'something_went_wrong' : 'Something went wrong, try again please',
      'wrong_group_password' : 'The password provided was invalid',
      'email_exist' : 'The email entered has already been used. If you have forgotten your password, please request a new one!',
      'too_weak_password' : 'Your password is weak. Please enter a stronger password consisting of lowercase and uppercase letters and numbers!',
      'invalid_email_format' : 'Email format is not correct',
      'different_password' : 'Your passwords does not match',
      'no_review_questions' : 'No questions to review ',
      'user_not_found' : 'No user found with these credentials. Please check your email and password!',
      'too_many_requests': 'Too many login attempts. Please try again later!',
      'verification_email_sent': 'Verification email sent!',
      'signed_as' : 'Signed as',
      'verify_email_counter' : 'For security reasons, please verify your email within 24 hours. Failure to do so will result in the permanent deletion of your account!',
      'account_removed_not_verifying_email': 'Your account has been permanently deleted due to the failure to verify your email address.',
      'account_removed_permanantly' : 'Your account has been permanently deleted',
      'relogin_to_delete_your_account' : 'To delete your account, please reauthenticate by signing in again.',
      'didnt_made_changes' : 'You have not made any changes to be saved',
      'your_changes_succed' : 'Your information has been changed successfully',
      'account_succed_but_info_failed': 'Your account has been created, but your first and last name could not be saved. Please add them through the edit option',
      'check_your_inbox' : 'Please log into your email and click on the verification link',
      'change_path' : 'Change the path below',
      'error_while_sending_message': 'Could not send your message. Please try again!',
      'allowed_message_length' : 'Please limit your message to under 1000 characters.',
      'current_message_length' : 'Current message length',




      // Notifcation
      'question_added' : 'Your question added successfully',
      'question_added_to_quiz': 'Question added successfully',
      'quetion_added_title': 'Successful',
      'fill_all_input' : 'All fields related to the questions and answers must be filled out',
      'fill_all_input_title': 'Sending Question',


      // friends
      'friends' : 'Friends',

      // Buttons
      'btn_chats' : 'Messages',
      'btn_home': 'Home',
      'btn_cancel': 'Cancel',
      'btn_create': 'Create',
      'btn_login' : 'Login',
      'btn_membershipt_request' : 'Request Membership',
      'btn_accept' : 'Accept',
      'btn_leaving_group': 'Leave group',
      'btn_edit' : 'Edit',
      'btn_save' : 'Save',
      'btn_next' : 'Next Question',
      'btn_result' : 'View Results',
      'btn_send_question' : 'Send Questions',
      'btn_send' : 'Send',
      'btn_continue' : 'Continue',
      'btn_review_question' : 'Review Question',
      'btn_approve' : 'Approve',
      'btn_reject' : 'Reject',
      'btn_resent' : 'Resent Email',





      //  Policy
      'policy_title': 'Policy',
      'policy_introduction_title': 'Privacy Policy for Play Bazaar',
      'policy_introduction_description': 'Hos Play Bazaar prioriterer vi dit privatliv og er forpligtet til at sikre sikkerheden af dine personlige oplysninger. Denne privatlivspolitik beskriver, hvordan vi håndterer, opbevarer og beskytter dine data, når du bruger vores app.',
      'policy_info_collection_title': 'Information Indsamling og Opbevaring',
      'policy_info_collection_description': 'Når du bruger Play Bazaar-appen, kan vi indsamle visse personlige oplysninger, herunder men ikke begrænset til dit navn, e-mailadresse og andre relevante oplysninger, der er nødvendige for kontooprettelse og app-funktionalitet. Alle indsamlede oplysninger opbevares sikkert i vores database, som er hostet på Firestore, en cloud-lagringstjeneste ejet og drevet af Google.',
      'policy_data_security_and_thirdparty_title' : 'Databeskyttelse og Tredjepartsadgang',
      'policy_data_security_and_thirdparty_description_part1': 'Vi deler, sælger eller distribuerer ikke dine personlige oplysninger til tredjepartsvirksomheder. Dine data anvendes udelukkende til at give dig tjenester gennem Play Bazaar-appen.',
      'policy_data_security_and_thirdparty_description_part2': 'Selvom dine data opbevares i Firestore, som tilhører Google, giver dette ikke Google nogen rettigheder til at bruge dine personlige oplysninger til formål, der ikke er relateret til vores app. Google er ansvarlig for at opretholde sikkerheden af deres cloud-tjenester, og vi sikrer, at dine oplysninger er beskyttet i henhold til Googles strenge sikkerhedsforanstaltninger.',
      'policy_agreement_title' :  'Aftale om Politik',
      'policy_agreement_description' : 'Ved at bruge Play Bazaar-appen anerkender og accepterer du denne privatlivspolitik. Vi opfordrer dig til at gennemgå denne politik regelmæssigt, da fortsat brug af appen indikerer din accept af eventuelle ændringer eller opdateringer.',
      'policy_updates_title': 'Politikopdateringer',
      'policy_updates_description' : 'Vi forbeholder os retten til at opdatere eller ændre denne privatlivspolitik til enhver tid. Eventuelle ændringer vil blive reflekteret på denne side, og din fortsatte brug af appen udgør din accept af sådanne ændringer.',

      // contact us
      'contact_us_title' : 'Kontakt os',
      'contact_us_description' : 'Hvis du har spørgsmål eller bekymringer vedrørende denne privatlivspolitik, bedes du kontakte os på kh.techn@gmail.com',

      // Long message
      'empty_quizz_message' : 'Dette spil mangler i øjeblikket ord, og vi har brug for din hjælp. Gå venligst tilbage til den forrige side og tryk på knappen \'Indsend Spørgsmål\' nederst på siden for at sende os de ord, du gerne vil have tilføjet til spillet. Tak for din venlighed og indsats.',
      'email_verification_intro' : 'Velkommen til Play Bazaar! En e-mailbekræftelse er sendt til din e-mail. Bekræft venligst din e-mail for at fuldføre processen. Vi verificerer hver medlem i Play Bazaar for at sikre, at vores platform forbliver et sikkert sted, hvor hver bruger er en reel person.'
    }
  };

}