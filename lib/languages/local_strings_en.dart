import 'package:get/get.dart';

class LocalStringsEn extends Translations {

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      //appName
      'app_name' : 'Play Bazaar',
      'notification_title' : 'Play Bazaar',


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
      'question_is_answered' : 'You have already provided an answer to this question',
      'pick_an_answer' : 'Please select an answer before proceeding',
      'points_earned': 'Earned points',
      'you_can_do_better': 'Aim higher next time',
      'not_bad': 'Good effort, keep improving',
      'well_done': 'Well done!',
      'excellent': 'Excellent!',
      'correct' : 'Correct',


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
      'status' : 'Status  ',
      'online' : 'Online',
      'offline' : 'Offline',

      // group
      'private': 'Private',
      'public' : 'Public',
      'group_password_hint' : 'Enter the group password',
      'creating_group_title': 'Creating group',
      'creating_group_description': 'Select the group details',
      'group_password_title' : 'Private group',
      'enter_group_password_label' : 'Enter group ',
      'enter_group_password' : 'This is a private group',
      'group_name_hint' : 'Choose a group name ...',
      'group_admin': 'Admin',
      'about_this_group' : 'About this group',
      'group': 'Group: ',
      'group_created' : 'Group created succesfully',
      'leaving' : 'Leaving',
      'number_of_members': 'Number of members',
      'group_names_valid_size' : 'The group name must not be empty or exceed 25 characters',
      'group_name_unvalid_characters' : 'The group name must not contain the character \'_\'',
      'private_group_is_selected' : 'You have selected a private group, and a private group must have a password of at least 4 characters',
      'you_became_a_member': 'You have become a member',
      'already_member': 'Already a member',
      'not_group_member': 'You are not a member of this group',
      'group_not_found': 'The group could not be found',


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
      'delete_friendship': 'Delete friendship with',
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
      'request_cancelled': 'Request cancelled',
      'request_sent': 'Request has been sent',
      'search_not_found': 'Could not find any data matching that search parameter',
      'details': 'Details',
      'select' : 'Select',


      // friends
      'friends' : 'Friends',
      'empty_friend_list': 'You don’t have any friends yet',

      // Buttons
      'btn_chats' : 'Messages',
      'btn_home': 'Home',
      'btn_cancel': 'Cancel',
      'btn_create': 'Create',
      'btn_login' : 'Login',
      'btn_membership_request' : 'Request Membership',
      'btn_accept' : 'Accept',
      'btn_leaving_group': 'Leaving group',
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
      'btn_sounds': 'Button sounds',
      'btn_awaiting_response': 'Awaiting response',
      'btn_approve_request': 'Approve request',
      'btn_cancel_request': 'Cancel request',
      'btn_request_friendship' : 'Add friend',
      'btn_restart': 'Restart',


      // Settings
      'settings': 'Settings',

      //Message
      'leaving_group': 'Are you sure about leaving the group?',
      'leaving_group_succed' : 'You left the group succesfully',
      'group_membership_succed' : 'Your membershipt approved',
      'leaving_group_failed' : 'Unable to remove you from the group due to an error. Please try again',
      'group_membership_failed' : 'Unable to add you to the group due to an error. Please try again',
      'not_found_title': 'Your are not a member of any group!',
      'not_found_message': 'For creating your own group, click the button bellow, or search for a group',
      'friend_notfound': 'Could not find a user with the given name!',
      'registration_succed': 'Your account has been created succesfully',
      'authentication_failed' : 'Authentication failed. Please try again',
      'unexpected_result' : 'An unexpected result, try again please',
      'members_notfound' : 'Could not find any members',
      'name_is_required' : 'Name is required',
      'approved_friend_request': 'Added to the list of your friend',
      'declined_friend_request' : 'Declined friend request',
      'removed_from_friends' : 'was removed from your friends list',
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
      'reassign_text': 'Did you enter your email incorrectly? Click the button below',
      'signed_as' : 'Signed as',
      'verify_email_counter' : 'For security reasons, please verify your email within 24 hours. Failure to do so will result in the permanent deletion of your account!',
      'verify_email_title' : 'Verify your email',
      'check_your_inbox' : 'Please log into your email and click on the verification link',
      'account_removed_not_verifying_email': 'Your account has been permanently deleted due to the failure to verify your email address.',
      'account_removed_permanantly' : 'Your account has been permanently deleted',
      'relogin_to_delete_your_account' : 'To delete your account, please reauthenticate by signing in again.',
      'didnt_made_changes' : 'You have not made any changes to be saved',
      'your_changes_succed' : 'Your information has been changed successfully',
      'account_succed_but_info_failed': 'Your account has been created, but your first and last name could not be saved. Please add them through the edit option',
      'change_path' : 'Change the path below',
      'error_while_sending_message': 'Could not send your message. Please try again!',
      'allowed_message_length_1000' : 'Please limit your message to under 1000 characters.',
      'allowed_message_length_300' : 'Please limit your message to under 300 characters.',
      'current_message_length' : 'Current message length',




      // Notifcation
      'question_added' : 'Your question added successfully',
      'question_added_to_quiz': 'Question added successfully',
      'quetion_added_title': 'Successful',
      'fill_all_input' : 'All fields related to the questions and answers must be filled out',
      'fill_all_input_title': 'Sending Question',


      //  Policy
      'policy_title': 'Policy',
      'policy_introduction_title': 'Privacy Policy for Play Bazaar',
      'policy_introduction_description': 'At Play Bazaar, we prioritize your privacy and are committed to ensuring the security of your personal information. This privacy policy outlines how we handle, store, and protect your data when you use our app.',

      'policy_info_collection_title': 'Information Collection and Storage',
      'policy_info_collection_description': 'When using the Play Bazaar app, we may collect certain personal information, including but not limited to your name, email address, and other relevant information necessary for account creation and app functionality. All collected information is securely stored in our database, which is hosted on Firestore, a cloud storage service owned and operated by Google.',

      'policy_data_security_and_thirdparty_title' : 'Data Security and Third-Party Access',
      'policy_data_security_and_thirdparty_description_part1': 'We do not share, sell, or distribute your personal information with any third parties. Your information is used only to provide services through the PlayBazaar app. Your data is stored on Firebase servers in Frankfurt, Germany.',
      'policy_data_security_and_thirdparty_description_part2': 'While your data is stored on Firestore, owned by Google, this does not grant Google any rights to use your personal information for purposes unrelated to our app. Google is responsible for maintaining the security of its cloud services, and we ensure that your information is protected in accordance with Google’s strict security measures.',

      'policy_agreement_title' :  'Policy Agreement',
      'policy_agreement_description' : 'By using the Play Bazaar app, you acknowledge and accept this privacy policy. We encourage you to review this policy regularly, as continued use of the app indicates your acceptance of any changes or updates.',

      'policy_updates_title': 'Policy Updates',
      'policy_updates_description' : 'We reserve the right to update or modify this privacy policy at any time. Any changes will be reflected on this page, and your continued use of the app constitutes your acceptance of such changes.',

      // contact us
      'contact_us_title' : 'Contact Us',
      'contact_us_description' : 'If you have any questions or concerns regarding this privacy policy, please contact us at kh.techn@gmail.com',

      // Long message
      'empty_quizz_message' : 'This game currently lacks words, and we need your help. Please return to the previous page and press the \'Submit Questions\' button at the bottom of the page to send us the words you would like added to the game. Thank you for your kindness and effort.',
      'email_verification_intro' : 'Welcome to Play Bazaar! A verification email has been sent to your email. Please confirm your email to complete the process. We verify every member at Play Bazaar to ensure our platform remains a safe place where every user is a real person.'
    }
  };

}