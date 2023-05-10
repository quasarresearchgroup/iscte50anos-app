import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iscte_spots/pages/auth/register/registration_error.dart';
import 'package:iscte_spots/services/auth/registration_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_loading_widget.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';

class SchoolRegisterForm extends StatefulWidget {
  const SchoolRegisterForm({
    Key? key,
    required this.chosenAffiliationType,
    required this.chosenAffiliationName,
    required this.formKey,
    required this.errorCode,
  }) : super(key: key);
  final ValueNotifier<String> chosenAffiliationType;
  final ValueNotifier<String> chosenAffiliationName;
  final GlobalKey<FormState> formKey;
  final RegistrationError errorCode;

  @override
  State<SchoolRegisterForm> createState() => _SchoolRegisterFormState();
}

class _SchoolRegisterFormState extends State<SchoolRegisterForm> {
  var autovalidateMode2 = AutovalidateMode.always;

  Future<Map<String, dynamic>> schoolsAfilitation =
      RegistrationService.getSchoolAffiliations();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: schoolsAfilitation,
      builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
        if (snapshot.hasData) {
          return Form(
            key: widget.formKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...generateFormFields(
                        snapshot.data as Map<String, dynamic>),
                  ]),
            ),
          );
        } else if (snapshot.hasError) {
          LoggerService.instance.error(snapshot.error);
          return Column(
            children: [
              RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)!
                      .registrationSchoolLoadingError,
                ),
              ),
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.errorTouchToRefresh,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                onPressed: () {
                  LoggerService.instance.debug("refreshing schools");
                  setState(() {
                    schoolsAfilitation =
                        RegistrationService.getSchoolAffiliations();
                  });
                },
              )
            ],
          );
        } else {
          return const DynamicLoadingWidget();
        }
      },
    );
  }

  InputDecoration buildInputDecoration({required String hint}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.only(left: 25, right: 25),
      border: const UnderlineInputBorder(
          //border: OutlineInputBorder(
          borderRadius: BorderRadius.all(IscteTheme.appbarRadius)),
      hintText: hint,
    );
  }

  List<Widget> generateFormFields(Map<String, dynamic> schoolsAfilitation) {
    List<DropdownMenuItem<String>> districtList =
        schoolsAfilitation.keys.toList().map((String e) {
      return DropdownMenuItem<String>(
        value: e,
        child: Text(e,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13)),
      );
    }).toList();

    List<DropdownMenuItem<String>> schoolsList =
        (schoolsAfilitation[widget.chosenAffiliationType.value]
                as List<dynamic>)
            .map((dynamic e) {
      return DropdownMenuItem<String>(
        value: e,
        child: Text(e,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13)),
      );
    }).toList();

    return [
      Text(AppLocalizations.of(context)!.registrationDistrictStep),
      DropdownButtonFormField<String>(
        menuMaxHeight: MediaQuery.of(context).size.height / 2,
        autovalidateMode: autovalidateMode2,
        isExpanded: true,
        value: widget.chosenAffiliationType.value,
        hint: Text(AppLocalizations.of(context)!.registrationDistrictStep),
        items: districtList,
        validator: (String? value) {
          if (widget.errorCode == RegistrationError.invalidAffiliation) {
            return AppLocalizations.of(context)!
                .registrationDistrictInvalidError;
          } else if (value == "-") {
            return AppLocalizations.of(context)!
                .registrationDistrictNotSelectedError;
          }
          return null;
        },
        onChanged: (String? any) {
          setState(
            () {
              widget.chosenAffiliationType.value = any!;
              widget.chosenAffiliationName.value = "-";
            },
          );
        },
      ),
      const SizedBox(height: 10),
      Text(AppLocalizations.of(context)!.registrationSchoolStep),
      DropdownButtonFormField<String>(
        menuMaxHeight: MediaQuery.of(context).size.height / 2,
        autovalidateMode: autovalidateMode2,
        isExpanded: true,
        value: widget.chosenAffiliationName.value,
        hint: Text(AppLocalizations.of(context)!.registrationSchoolStep),
        items: schoolsList,
        validator: (String? value) {
          if (widget.errorCode == RegistrationError.invalidAffiliation) {
            return AppLocalizations.of(context)!.registrationSchoolInvalidError;
          } else if (value == "-") {
            return AppLocalizations.of(context)!
                .registrationSchoolNotSelectedError;
          }
          return null;
        },
        onChanged: (String? any) {
          setState(
            () {
              widget.chosenAffiliationName.value = any!;
            },
          );
        },
      ),
    ];
  }
}
