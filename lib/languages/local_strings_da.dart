import 'package:get/get.dart';

class LocalStringsDa extends Translations {

  @override
  Map<String, Map<String, String>> get keys => {
    'dk_DK': {
      //app related
      'app_name': 'Play Bazaar',
      'notification_title': 'Play Bazaar',



      // Games
      'games': 'Spil',
      'games_list': 'Spilliste',
      'ludo_world_war': 'Ludo World War',
      'add_question_hint': 'Har du et spørgsmål, du gerne vil tilføje til et af disse spil? Tryk på knappen nedenfor!',
      'question_hint': 'Spørgsmål',
      'add_question_title': 'Send Spørgsmål',
      'pick_quiz_hint': 'Hvilket quiz skal dette tilføjes til?',
      'your_answer': 'Dit svar',
      'correct_answer': 'Korrekt svar',
      'correct_answers': 'Korrekte svar',
      'wrong_answers': 'Forkerte svar',
      'wrong_answer': 'Forkert svar',
      'more_information_add_quiz': 'Mere information. For eksempel områder, hvor det bruges...',
      'enter_your_answer_here': 'Indtast dit svar her...',
      'quiz_list': 'Quiz Liste',
      "game_result": "Spilresultater",
      'question_is_answered': 'Du har allerede givet et svar på dette spørgsmål',
      'pick_an_answer': 'Vælg et svar før du fortsætter',
      'points_earned': 'Optjente point',
      'you_can_do_better': 'Sig højere næste gang',
      'not_bad': 'God indsats, bliv ved med at forbedre dig',
      'well_done': 'Godt gået!',
      'excellent': 'Fremragende!',



      //Personal information
      'aboutme': 'Om mig ',
      'name': 'Navn ',
      'lastname': 'Efternavn',
      'email': 'E-mail ',
      'points': 'Point ',
      'me': 'Jeg er ',
      'password': 'Adgangskode',
      're_password': 'Gentag din adgangskode',
      'optional': ' \\(valgfri)',
      'status': 'Status ',
      'online': 'Online',
      'offline': 'Offline',

      // group
      'private': 'Privat',
      'public': 'Offentlig',
      'group_password_hint': 'Indtast gruppens adgangskode',
      'creating_group_title': 'Opretter gruppe',
      'creating_group_description': 'Vælg gruppens detaljer',
      'group_password_title': 'Privat gruppe',
      'enter_group_password_label': 'Indtast gruppe ',
      'enter_group_password': 'Dette er en privat gruppe',
      'group_name_hint': 'Vælg et gruppenavn ...',
      'group_admin': 'Admin',
      'about_this_group': 'Om denne gruppe',
      'group': 'Gruppe: ',
      'group_created': 'Gruppen blev oprettet succesfuldt',
      'leaving': 'Forlader',
      'number_of:members' : 'Antal medlemder',
      'group_names_valid_size' : 'Gruppenavnet må ikke være tomt eller overstige 25 tegn',
      'group_name_unvalid_characters' : 'Gruppenavnet må ikke indeholde tegnet \'_\'',
      'private_group_is_selected': 'Du har valgt en privat gruppe, og en privat gruppe skal have et kodeord på mindst 4 tegn',
      'you_became_a_member': 'Du er blevet medlem!',
      'already_member': 'Allerede medlem',
      'not_group_member': 'Du er ikke medlem af denne gruppe',
      'group_not_found': 'Kunne ikke finde gruppen',



      // Others
      'language': 'Languages',
      'farsi': 'فارسی , دری',
      'english': 'Engelsk',
      'requests': 'Anmodninger',
      'my_page': 'Min side',
      'logout': 'Log ud',
      'my_chat': 'Beskeder',
      'my_friends': 'Mine venner',
      'request_friendship': 'Venneanmodning',
      'delete_friend': 'Slet',
      'delete_friendship': 'Slet venskab med',
      'my_memberships': "Mine beskeder",
      'write_message_here': "Skriv dine beskeder her ...",
      'search_friends': 'Søg efter venner ...',
      'search_in_friends': 'Søg blandt venner...',
      'msg_friend_not_found': 'Kunne ikke finde en ven med det navn',
      'search_groups': 'Søg efter grupper ...',
      'search': 'Søg',
      'choose_language': 'Vælg dit foretrukne sprog',
      'not_have_account': 'Har du ikke en konto? ',
      'make_account_here': 'Opret din konto her ',
      'not_valid_email': 'Indtast venligst en gyldig e-mail',
      'your_message_here': 'Skriv din besked her ...',
      'do_have_account': 'Har en konto? ',
      'login_from_here': 'Log ind her',
      'reset_password': 'Nulstil adgangskode',
      'enter_your_email': 'Indtast din email',
      'send_reset_link': 'Send nulstillingslink',
      'reset_link_sent': 'Nulstillingslink er sendt! Tjek din email.',
      'forgot_password': 'Glemt adgangskode?',
      'received_requests': 'Modtagne anmodninger',
      'description': 'Beskrivelse',
      'no_description': 'Ingen beskrivelse',
      'path': 'Anmodning om at blive tilføjet til',
      'request_cancelled': 'Anmodning annulleret',
      'request_sent': 'Anmodning er sendt',
      'search_not_found': 'Kunne ikke finde nogen data med det søgeparameter',
      'details': 'Detaljer',
      'select' : 'Vælg',
      'sounds': 'Lyde',
      'say_hi': 'Sig hej til',

      // friends
      'friends': 'Venner',
      'empty_friend_list': 'Du har endnu ingen venner',
      'friend_request': 'Venneanmodning',
      'friends_messages': 'Besked fra venner',



      // Buttons
      'btn_chats': 'Beskeder',
      'btn_home': 'Hjem',
      'btn_cancel': 'Annuller',
      'btn_create': 'Opret',
      'btn_login': 'Log ind',
      'btn_membership_request': 'Anmod om medlemskab',
      'btn_accept': 'Accepter',
      'btn_leaving_group': 'Forlader gruppe',
      'btn_edit': 'Rediger',
      'btn_save': 'Gem',
      'btn_next': 'Næste spørgsmål',
      'btn_result': 'Se resultater',
      'btn_send_question': 'Send spørgsmål',
      'btn_send': 'Send',
      'btn_continue': 'Fortsæt',
      'btn_review_question': 'Gennemgå spørgsmål',
      'btn_approve': 'Godkend',
      'btn_reject': 'Afvis',
      'btn_resent': 'Send e-mail igen',
      'btn_sounds': 'Knaplyde',
      'btn_awaiting_response': 'Venter på svar',
      'btn_approve_request': 'Accepter anmodning',
      'btn_cancel_request': 'Annuller anmodning',
      'btn_request_friendship' : 'Send venneansmodning',
      'btn_restart': 'Start forfra',

      // Settings
      'settings': 'Indstillinger',


      // Notifcation - generall
      'notification': 'Notifikation',
      'notifications': 'Notifikationer',
      'question_added': 'Dit spørgsmål blev tilføjet succesfuldt',
      'question_added_to_quiz': 'Spørgsmål tilføjet succesfuldt',
      'quetion_added_title': 'Succesfuld',
      'fill_all_input': 'Alle felter relateret til spørgsmål og svar skal udfyldes',
      'fill_all_input_title': 'Send Spørgsmål',



      //Message
      'leaving_group': 'Er du sikker på, at du vil forlade gruppen?',
      'leaving_group_succed': 'Du har forladt gruppen succesfuldt',
      'group_membership_succed': 'Dit medlemskab blev godkendt',
      'leaving_group_failed' : 'Kunne ikke fjerne dig fra gruppen på grund af en fejl. Prøv venligst igen',
      'group_membership_failed' : 'Kunne ikke tilføje dig til gruppen på grund af en fejl. Prøv venligst igen',
      'not_found_title': 'Du er ikke medlem af nogen grupper!',
      'not_found_message': 'For at oprette din egen gruppe, klik på knappen nedenfor, eller søg efter en gruppe',
      'friend_notfound': 'Kunne ikke finde en bruger med det givne navn!',
      'registration_succed': 'Din konto er oprettet succesfuldt',
      'authentication_failed': 'Godkendelse mislykkedes. Prøv venligst igen',
      'unexpected_result': 'Et uventet resultat, prøv venligst igen',
      'members_notfound': 'Kunne ikke finde nogen medlemmer',
      'name_is_required': 'Navn er påkrævet',
      'approved_friend_request': 'Tilføjet til din venneliste',
      'declined_friend_request': 'Afslået venneanmodning',
      'received_friend_request_body': 'Du har modtaget en venneanmodning fra',
      'received_friend_request_title': 'Ny venneanmodning',
      'removed_from_friends': 'blev fjernet fra din venneliste',
      'something_went_wrong': 'Noget gik galt, prøv venligst igen',
      'wrong_group_password': 'Den angivne adgangskode var ugyldig',
      'email_exist': 'Den indtastede e-mail er allerede brugt. Hvis du har glemt din adgangskode, bedes du anmode om en ny!',
      'too_weak_password': 'Din adgangskode er svag. Indtast venligst en stærkere adgangskode bestående af små og store bogstaver samt tal!',
      'invalid_email_format': 'E-mail formatet er ikke korrekt',
      'different_password': 'Dine adgangskoder matcher ikke',
      'no_review_questions': 'Ingen spørgsmål at gennemgå ',
      'user_not_found': 'Ingen bruger fundet med disse legitimationsoplysninger. Kontroller venligst din e-mail og adgangskode!',
      'too_many_requests': 'For mange login-forsøg. Prøv igen senere!',
      'verification_email_sent': 'Bekræftelses-e-mail sendt!',
      'reassign_text': 'Har du indtastet din e-mail forkert? Tryk på knappen nedenfor',
      'signed_as': 'Logget ind som',
      'verify_email_counter': 'Af sikkerhedsmæssige årsager, verificer venligst din e-mail inden for 24 timer. Manglende verifikation vil resultere i permanent sletning af din konto!',
      'verify_email_title' : 'Bekræft din e-mail',
      'check_your_inbox': 'Log venligst ind på din e-mail og klik på bekræftelseslinket',
      'account_removed_not_verifying_email': 'Din konto er blevet permanent slettet på grund af manglende verifikation af din e-mailadresse.',
      'account_removed_permanantly': 'Din konto er blevet permanent slettet',
      'relogin_to_delete_your_account': 'For at slette din konto, skal du logge ind igen.',
      'didnt_made_changes': 'Du har ikke foretaget nogen ændringer, der skal gemmes',
      'your_changes_succed': 'Dine oplysninger er ændret succesfuldt',
      'account_succed_but_info_failed': 'Din konto er oprettet, men dit fornavn og efternavn kunne ikke gemmes. Tilføj dem venligst via redigeringsmuligheden',
      'change_path' : 'Ændr stien nedenfor',
      'error_while_sending_message' : 'Kunne ikke sende din besked. Prøv igen!',
      'allowed_message_length_1000' : 'Venligst begræns din besked til under 1000 tegn',
      'allowed_message_length_300' : 'Venligst begræns din besked til under 300 tegn',
      'current_message_length' : 'Nuværende beskedlængde',
      'chat_creation_failed': 'Oprettelse af chat mislykkedes',
      'failed_to_accept_friend_request': 'Kunne ikke acceptere venneanmodning',



      // Policy
      'policy_title': 'Politik',
      'policy_introduction_title': 'Privatlivspolitik for Play Bazaar',
      'policy_introduction_description': 'Hos Play Bazaar prioriterer vi dit privatliv og er forpligtet til at sikre sikkerheden af dine personlige oplysninger. Denne privatlivspolitik beskriver, hvordan vi håndterer, opbevarer og beskytter dine data, når du bruger vores app.',

      'policy_info_collection_title': 'Information Indsamling og Opbevaring',
      'policy_info_collection_description': 'Når du bruger Play Bazaar-appen, kan vi indsamle visse personlige oplysninger, herunder men ikke begrænset til dit navn, e-mailadresse og andre relevante oplysninger, der er nødvendige for kontooprettelse og app-funktionalitet. Alle indsamlede oplysninger opbevares sikkert i vores database, som er hostet på Firestore, en cloud-lagringstjeneste ejet og drevet af Google.',

      'policy_data_security_and_thirdparty_title' : 'Databeskyttelse og Tredjepartsadgang',
      'policy_data_security_and_thirdparty_description_part1': 'Vi deler, sælger eller distribuerer ikke dine personlige oplysninger med nogen tredjepart. Dine oplysninger bruges kun til at levere tjenester gennem PlayBazaar-appen. Dine data gemmes på Firebases servere i Frankfurt, Tyskland.',
      'policy_data_security_and_thirdparty_description_part2': 'Selvom dine data opbevares i Firestore, som tilhører Google, giver dette ikke Google nogen rettigheder til at bruge dine personlige oplysninger til formål, der ikke er relateret til vores app. Google er ansvarlig for at opretholde sikkerheden af deres cloud-tjenester, og vi sikrer, at dine oplysninger er beskyttet i henhold til Googles strenge sikkerhedsforanstaltninger.',

      'policy_agreement_title' :  'Aftale om Politik',
      'policy_agreement_description': 'Ved at bruge Play Bazaar-appen anerkender og accepterer du denne privatlivspolitik. Firebase-servere, der er placeret i et europæisk land, bruges til databehandling. Vi opfordrer dig til regelmæssigt at gennemgå denne politik, da fortsat brug af appen indikerer din accept af eventuelle ændringer eller opdateringer.',

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