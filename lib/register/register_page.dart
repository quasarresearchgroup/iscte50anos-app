import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/register/acount_register_widget.dart';
import 'package:iscte_spots/register/school_register_widget.dart';
import 'package:logger/logger.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);
  final Logger _logger = Logger();
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _curentStep = 0;
  bool _isCompleted = false;
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final districtController = TextEditingController();
  final schoolController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: Theme.of(context).appBarTheme.copyWith(
              shape: const ContinuousRectangleBorder(),
            ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
        ),
        //body: Padding(padding: EdgeInsets.all(8), child: RegisterForm()),
        body: _isCompleted
            ? const Center(
                child: FlutterLogo(
                  size: 300,
                  textColor: Colors.blue,
                  style: FlutterLogoStyle.stacked,
                ),
              )
            : Stepper(
                type: StepperType.vertical,
                steps: getSteps(),
                currentStep: _curentStep,
                onStepContinue: _onStepContinue,
                onStepCancel: _onStepCancel,
                controlsBuilder:
                    (BuildContext context, ControlsDetails details) {
                  final bool isLastStep = _curentStep == getSteps().length - 1;

                  return Container(
                    margin: EdgeInsets.only(top: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            child: Text(
                              isLastStep ? "CONFIRM" : "NEXT",
                            ),
                            onPressed: _onStepContinue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            child: Text(
                              "BACK",
                            ),
                            onPressed: _onStepCancel,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _onStepCancel() {
    if (_curentStep > 0) {
      setState(() => _curentStep--);
    }
  }

  void _onStepContinue() {
    final bool isLastStep = _curentStep == getSteps().length - 1;
    if (isLastStep) {
      widget._logger.i("completed steps");
      setState(() {
        _isCompleted = true;
      });
    } else {
      setState(() {
        _curentStep++;
      });
    }
  }

  List<Step> getSteps() => [
        Step(
          state: _curentStep >= 1 ? StepState.complete : StepState.indexed,
          isActive: _curentStep >= 0,
          title: const Text("Account"),
          content: AccountRegisterForm(
            nameController: nameController,
            lastNameController: lastNameController,
            emailController: emailController,
            passwordController: passwordController,
          ),
        ),
        Step(
          state: _curentStep >= 2 ? StepState.complete : StepState.indexed,
          isActive: _curentStep >= 1,
          title: const Text("School"),
          content: SchoolRegisterForm(
            districtController: districtController,
            schoolController: schoolController,
          ),
        ),
        Step(
          state: _curentStep >= 3 ? StepState.complete : StepState.indexed,
          isActive: _curentStep >= 2,
          title: const Text("Complete"),
          content: CompleteForm(data: {
            "name": nameController.text,
            "lastName": lastNameController.text,
            "email": emailController.text,
            "password": passwordController.text,
            "district": districtController.text,
            "school": schoolController.text,
          }),
        )
      ];
}

class CompleteForm extends StatelessWidget {
  CompleteForm({Key? key, required this.data}) : super(key: key);
  Map data;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(data.toString()),
    );
  }
}
