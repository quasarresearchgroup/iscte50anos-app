import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/services/registration_service.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

import '../widgets/util/iscte_theme.dart';

class SchoolRegisterForm extends StatefulWidget {
  SchoolRegisterForm({
    Key? key,
    required this.districtController,
    required this.schoolController,
  }) : super(key: key);
  final Logger _logger = Logger();
  final TextEditingController districtController;
  final TextEditingController schoolController;

  @override
  State<SchoolRegisterForm> createState() => _SchoolRegisterFormState();
}

class _SchoolRegisterFormState extends State<SchoolRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  Future<Map<String, List<String>>> schoolsAfilitation =
      RegistrationService.getSchoolAffiliations();

  String chosenDistrict = "-";
  String chosenSchool = "-";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: schoolsAfilitation,
      builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
        if (snapshot.hasData) {
          return Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...generateFormFields(
                      snapshot.data as Map<String, List<String>>),
                ]),
          );
        } else if (snapshot.hasError) {
          return Container(
            child: Text(snapshot.error.toString()),
          );
        } else {
          return LoadingWidget();
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
        (schoolsAfilitation[chosenDistrict] as List<String>).map((String e) {
      return DropdownMenuItem<String>(
        value: e,
        child: Text(e,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13)),
      );
    }).toList();

    return [
      Padding(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: DropdownButtonFormField<String>(
          value: chosenDistrict,
          hint: Text("district"),
          items: districtList,
          onChanged: (String? any) {
            setState(
              () {
                chosenDistrict = any!;
                chosenSchool = "-";
              },
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: DropdownButtonFormField<String>(
          value: chosenSchool,
          hint: Text("school"),
          items: schoolsList,
          onChanged: (String? any) {
            setState(
              () {
                chosenSchool = any!;
              },
            );
          },
        ),
      ),
    ];
  }
}
