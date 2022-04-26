import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/pages/auth/register/registration_error.dart';
import 'package:iscte_spots/services/auth/registration_service.dart';
import 'package:iscte_spots/widgets/util/iscte_theme.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class SchoolRegisterForm extends StatefulWidget {
  SchoolRegisterForm({
    Key? key,
    required this.chosenAffiliationType,
    required this.chosenAffiliationName,
    required this.formKey,
    required this.errorCode,
  }) : super(key: key);
  final Logger _logger = Logger();
  ValueNotifier<String> chosenAffiliationType;
  ValueNotifier<String> chosenAffiliationName;
  final GlobalKey<FormState> formKey;
  final RegistrationError errorCode;

  @override
  State<SchoolRegisterForm> createState() => _SchoolRegisterFormState();
}

class _SchoolRegisterFormState extends State<SchoolRegisterForm> {
  var autovalidateMode2 = AutovalidateMode.always;

  Future<Map<String, List<String>>> schoolsAfilitation =
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
                        snapshot.data as Map<String, List<String>>),
                  ]),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const LoadingWidget();
        }
      },
    );
  }

  InputDecoration buildInputDecoration({required String hint}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.only(left: 25, right: 25),
      border: UnderlineInputBorder(
          //border: OutlineInputBorder(
          borderRadius: BorderRadius.all(IscteTheme.appbarRadius)),
      hintText: hint,
    );
  }

  List<Widget> generateFormFields(
      Map<String, List<String>> schoolsAfilitation) {
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
        (schoolsAfilitation[widget.chosenAffiliationType.value] as List<String>)
            .map((String e) {
      return DropdownMenuItem<String>(
        value: e,
        child: Text(e,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13)),
      );
    }).toList();

    return [
      const Text("District"),
      DropdownButtonFormField<String>(
        menuMaxHeight: MediaQuery.of(context).size.height / 2,
        autovalidateMode: autovalidateMode2,
        isExpanded: true,
        value: widget.chosenAffiliationType.value,
        hint: const Text("District"),
        items: districtList,
        validator: (String? value) {
          if (widget.errorCode == RegistrationError.invalidAffiliation) {
            return 'Invalid District';
          } else if (value == "-") {
            return 'Please select a District';
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
      const Text("School"),
      DropdownButtonFormField<String>(
        menuMaxHeight: MediaQuery.of(context).size.height / 2,
        autovalidateMode: autovalidateMode2,
        isExpanded: true,
        value: widget.chosenAffiliationName.value,
        hint: const Text("School"),
        items: schoolsList,
        validator: (String? value) {
          if (widget.errorCode == RegistrationError.invalidAffiliation) {
            return 'Invalid School';
          } else if (value == "-") {
            return 'Please select a School';
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
