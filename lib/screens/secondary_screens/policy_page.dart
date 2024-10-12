import 'package:flutter/material.dart';
import 'package:get/get.dart';


class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {

    Widget textTitle(String text) {
      return Container(
        margin: const EdgeInsets.only(top: 30),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    }


    Widget textDescription(String text) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("policy_title".tr,
          style: TextStyle(
            color: Colors.white
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //Introduction
            textTitle('policy_introduction_title'.tr),
            textDescription('policy_introduction_description'.tr),

            // Information collection
            textTitle('policy_info_collection_title'.tr),
            textDescription('policy_info_collection_description'.tr),

            // Security and thidsparty app
            textTitle('policy_data_security_and_thirdparty_title'.tr),
            textDescription('policy_data_security_and_thirdparty_description_part1'.tr),
            const SizedBox(height: 20),
            textDescription('policy_data_security_and_thirdparty_description_part2'.tr),

            // Agreement
            textTitle('policy_agreement_title'.tr),
            textDescription('policy_agreement_description'.tr),

            // Policy updates
            textTitle('policy_updates_title'.tr),
            textDescription('policy_updates_description'.tr),

            // Contact up
            textTitle('contact_us_title'.tr),
            textDescription('contact_us_description'.tr),

            const SizedBox(height: 100)

          ],
        ),

      ),
    );
  }
}
