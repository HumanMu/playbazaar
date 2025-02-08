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
      'quiz': 'Quiz',
      'hangman': 'Hangman',
      'games_list': 'Games list',
      'wall_blaster': 'Wall Blaster',
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
      'with_options': 'With options',
      'without_options': 'Without options',
      'show_result': 'Show result',
      'show_the_answer': 'Show the answer',
      'see_result_first': 'See the result first, please.',
      'end_of_family_game': 'That was the end of the quiz. Play Bazaar hopes you had fun. Press the button below to return to the game list.',
      'you_won_conguratulation': 'You won! Congratulations!',
      'you_lost_word_was': 'You lost! The word was:',
      'incorrect_guess': 'Incorrect guess:',
      'hangman_play_settings': 'Hangman Play Settings',
      'share_hangman_play_code': 'Share the code with those you want to join the game',
      'deactive_other_options': 'Deactivate other options',
      'deactive_play_with_friends': 'Do you want to play alone? If so, please deactivate the two options above to continue the game',
      'add_player': 'Add Player',
      'compete_offline': 'Compete with friends - offline',
      'compete_online': 'Compete with friends - online',
      'give_players_name': 'Type each player\'s name and tap "+"',
      'this_generating_code': 'This will generate a code to share with friends to join',
      'play_solo': 'Play Solo',
      'play_solo_description': 'If you want to play by yourself, choose this option',
      'players_name_here': 'Add players name here...',
      'zero_player_error': 'Please add at least one player or deactivate the multiplayer options',
      'pick_difficulty': 'Pick Difficulty',
      'add_words': 'Adding Words',
      'add_words_label': 'Add words and do not use any special characters or any space',
      'add_words_hint': 'Add a hint',
      'guess_a_word': 'Guess a word',
      'guess_a_word_description': 'The word should not contain any extra spacing, violate writing rules, or include special characters',
      'player_turn': 'Turn of ',
      'waiting_room': 'Waiting Room',
      'game_code': 'Game Code',
      'game_code_hint': 'Your code here ...',
      'waiting_start': 'Waiting for host to start...',
      'host': 'Host',
      'first_letter': 'Start with letter: ',
      'join_hangman_with_code': 'Join with code',
      'join_hangman_with_code_description': 'If you have a code to join others, pick this one',
      'waiting_participants': 'Waiting for participants...',
      'msg_game_destruction_succed': 'The game has been successfully destroyed.',
      'msg_game_not_found': 'Failed to find a game with the given code.',
      'msg_game_creator_deleted': 'Game not found, the creator might have deleted the game.',
      'game_hint_has_changed': 'The game hint has been changed',
      'wordconnector': 'Word Connector',
      'word_connector_settings': 'Word Connector Settings',
      'remember_game_level': 'Select the game level and then press "Start" to begin.',
      'add_letters': 'Add Letters',
      'add_letters_label': 'Add letters and separate with a comma',
      'score': 'Score',
      'level': 'Level',
      'your_level': 'Your level',
      'reset_your_level': 'By pressing the button below, your game level will reset to the beginning, like day one.',
      'round_result': 'Scored in this round: %1 points\ndo you want to play more games?',


      //Personal information
      'aboutme' : 'About me ',
      'name': 'Name  ',
      'lastname' : 'Lastname',
      'email' : 'Email  ',
      'points': 'Points  ',
      'me' : 'I am  ',
      'password': 'Password',
      're_password' : 'Re-enter your password',
      'enter_your_password': 'Enter your password',
      'optional' : ' \\(optional)',
      'status' : 'Status  ',
      'online' : 'Online',
      'offline' : 'Offline',

      // group
      'private': 'Private',
      'public' : 'Public',
      'groups': 'Groups',
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
      'language' : 'Language',
      'language1': 'Language',
      'choose_language' : 'Choose language',
      'pick_a_language': 'First pick a language',
      'account': 'Account',
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
      'search_in_friends': 'Search within friends...',
      'msg_friend_not_found': 'Could not find a friend with that name',
      'search_groups' : 'Search for groups ...',
      'search' : 'Search',
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
      'sounds': 'Sounds',
      'say_hi': 'Say hi to',
      'guide': 'Guide',
      'danger_zone': 'Danger Zone',
      'write_here': 'Write here...',
      'copy': 'Copy',
      'copied_to_clipboard': 'Code copied to clipboard: ',
      'current_data': 'Current Data',
      'words': 'Words',
      'letters': 'Letters',
      'empty_field': 'The field is empty',
      'word_already_exist': 'The word already exists',
      'nothing_to_save': 'Nothing new to save',
      'max_level_100': 'The level must be less than 100 and greater than 0',
      'yes': 'Yes',
      'no': 'No',


      // friends
      'friends' : 'Friends',
      'empty_friend_list': 'You don’t have any friends yet',
      'friend_request': 'Friend request',
      'friends_messages': 'Message from friends',



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
      'btn_ok': 'Ok',
      'btn_delete_account': 'Delete Account',
      'btn_new_game': 'New Game',
      'btn_start': 'Start',
      'btn_send_words': 'Send us words',
      'btn_leave': 'Leave',
      'btn_add': 'Add',
      'btn_update': 'Update',
      'btn_reset': 'Reset',


      // Settings
      'settings': 'Settings',


      // Notifcation
      'notification': 'Notification',
      'notifications': 'Notifications',
      'question_added' : 'Your question added successfully',
      'question_added_to_quiz': 'Question added successfully',
      'quetion_added_title': 'Successful',
      'fill_all_input' : 'All fields related to the questions and answers must be filled out',
      'fill_all_input_title': 'Sending Question',



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
      'restart_app_fail': 'Due to an unexpected error, please close the app and restart it',
      'members_notfound' : 'Could not find any members',
      'name_is_required' : 'Name is required',
      'approved_friend_request': 'Added to the list of your friend',
      'declined_friend_request' : 'Declined friend request',
      'received_friend_request_body': 'You have received a friend request from',
      'received_friend_request_title': 'New friend request',
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
      'delete_account_guidance': 'Deleting your account will permanently remove all your data and take immediate effect. This action is irreversible. If you wish to return in the future, you will need to create a new account.',
      'delete_account_warning': 'Are you sure you want to permanently delete your account?',
      'delete_account_reauth_description': 'To proceed with account deletion, please enter your current password. If you have forgotten your password, please log out and click on the "Forgot my password" link on the login page to reset it.',
      'account_deletion_succed': 'Your account has been successfully deleted.',
      'change_path' : 'Change the path below',
      'error_while_sending_message': 'Could not send your message. Please try again!',
      'allowed_message_length_1000' : 'Please limit your message to under 1000 characters.',
      'allowed_message_length_300' : 'Please limit your message to under 300 characters.',
      'current_message_length' : 'Current message length',
      'reached_start_of_conversation': 'You’ve reached the start of the conversation',
      'auto_destractor_message': 'Messages will be automatically deleted after 5 days',
      'chat_creation_failed': 'Chat creation failed',
      'failed_to_accept_friend_request': 'Failed to accept friend request',
      'adding_word_succed': 'Adding new words succeeded',



      //  Policy
      'policy_title': 'Policy',
      'policy_introduction_title': 'Privacy Policy for Play Bazaar',
      'policy_introduction_description': 'At Play Bazaar, we prioritize your privacy and are committed to ensuring the security of your personal information. This privacy policy outlines how we handle, store, and protect your data when you use our app.',

      'policy_info_collection_title': 'Information Collection and Storage',
      'policy_info_collection_description': 'When using the Play Bazaar app, we may collect certain personal information, including but not limited to your name, email address, and other relevant information necessary for account creation and app functionality. All collected information is securely stored in our database, which is hosted on Firestore, a cloud storage service owned and operated by Google.',

      'policy_data_security_and_thirdparty_title' : 'Data Security and Third-Party Access',
      'policy_data_security_and_thirdparty_description_part1': 'We do not share, sell, or distribute your personal information with any third parties. Your information is used only to provide services through the PlayBazaar app. Your data is stored on Firebase servers in Frankfurt, Germany.',
      'policy_data_security_and_thirdparty_description_part2': 'While your data is stored on Firestore, owned by Google, this does not grant Google any rights to use your personal information for purposes unrelated to our app. Google is responsible for maintaining the security of its cloud services, and we ensure that your information is protected in accordance with Google’s strict security measures.',


      'policy_forbidden_usage_title': 'Terms of Use',
      'policy_forbidden_usage_description': '''At Play Bazaar, we strive to provide our users with the best possible experience by fostering a safe, respectful, and enjoyable community. To maintain this standard, we have implemented specific rules for the use of groups and private messaging. 
        It is strictly prohibited to engage in hate speech, discrimination, harassment, or share explicit or offensive content. Discussions involving racism, sexism, or other sensitive topics are not allowed and may result in consequences such as temporary or permanent restrictions on group participation or private messaging. 
        By using these features, you agree to follow these guidelines and contribute to a positive and respectful environment for everyone.''',


      'policy_agreement_title' :  'Policy Agreement',
      'policy_agreement_description' : 'By using the Play Bazaar app, you acknowledge and accept this privacy policy. We encourage you to review this policy regularly, as continued use of the app indicates your acceptance of any changes or updates.',

      'policy_updates_title': 'Policy Updates',
      'policy_updates_description' : 'We reserve the right to update or modify this privacy policy at any time. Any changes will be reflected on this page, and your continued use of the app constitutes your acceptance of such changes.',


      // contact us
      'contact_us_title' : 'Contact Us',
      'contact_us_description' : 'If you have any questions or concerns regarding this privacy policy, please contact us at kh.techn@gmail.com',

      // Long message
      'empty_quizz_message' : 'This game currently lacks words, and we need your help. Please return to the previous page and press the \'Submit Questions\' button at the bottom of the page to send us the words you would like added to the game. Thank you for your kindness and effort.',
      'email_verification_intro' : 'Welcome to Play Bazaar! A verification email has been sent to your email. Please confirm your email to complete the process. We verify every member at Play Bazaar to ensure our platform remains a safe place where every user is a real person.',

      'quiz_play_guide': '''Word games will either take you directly to the game page or ask you to choose whether you want to play with options or without options. Below are the explanations for both conditions:

      ** With Options **  
      If you choose "with options", each question will have four options, and you must select one to move to the next question. After 10 questions, the results and your total score will be displayed.  
      1. Each correct answer gives 3 points  
      2. Each incorrect answer gives 1 negative point  
      
      ** Without Options **  
      If you’re sitting with friends and need some entertainment, this option is for you. The question will be displayed for everyone to share their opinions. Once everyone has given their response, press the "Show Answer" button to reveal the correct answer. Scoring is up to you in this option.''',


      'notification_permission_description': '''Please grant us permission to notify you when you receive private messages from friends, friend requests, or exclusive deals from Play Bazaar. You can always revoke or deny permissions for specific services to send you notifications via the settings.''',

      // Hangman
      'hangman_settings_title': 'Hangman Game Settings',
      'hangman_settings_description': '''
        In this section, users can choose the type of game. The available options are:
        
        Solo Play:
        In this mode, the system automatically selects a word from the database, and the user has to guess it.
        
        Offline with Friends:
        Users need to enter the names of players and press the "+" button to add them to the list.
        After entering all names, press the "Start" button to begin the game.
        The system will select one player at a time to choose a word, and the other players have to guess the word.
        
        Online with Friends:
        If the user enables "Online", the system generates a code that should be sent to friends.
        Friends can join the game by entering the code in the "Join with Code" section.
        The game creator starts the game, and the goal is for everyone to guess the word as quickly as possible.
      '''.split('\n') // Split the string by lines
        .map((line) => line.trim()) // Remove leading and trailing spaces from each line
        .join('\n') // Rejoin the lines into a string
        .trim(), // Remove any extra spaces from the start and end of the entire string

      'play_rules_title': 'Play Rules',
      'play_rules_description': '''
        The rule is easy: you should try to find the hidden word. You have 2 hints:
        
        1. The first hint shows the category of the hidden word.
        2. The second hint shows the first letter of the word.
        
        You have 6 chances to make mistakes. For each mistake, a part of your body will be drawn on the gallows. You must guess the word before your full body is hanged.
        
        Hints:
        If you have no idea about the word, think about the category and which letters are commonly used in that category. Try pressing a letter that is often used.
      '''.split('\n') // Split the string by lines
          .map((line) => line.trim()) // Remove leading and trailing spaces from each line
          .join('\n') // Rejoin the lines into a string
          .trim(), // Remove any extra spaces from the start and end of the entire string


      // Word connector
        'word_connector_play_rules': 'When you start the game, a list of hidden words will appear at the top of the screen. The length of each word is determined by the number of boxes in the row. At the bottom of the screen, you’ll see the available letters to use for finding the hidden words. You must discover all the hidden words to proceed to the next words. Don’t forget to select a level before starting the game.',

    }
  };

}