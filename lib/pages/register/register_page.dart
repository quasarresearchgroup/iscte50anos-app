import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/registration_form_result.dart';
import 'package:iscte_spots/pages/register/acount_register_widget.dart';
import 'package:iscte_spots/pages/register/school_register_widget.dart';
import 'package:logger/logger.dart';

import 'acount_register_widget.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);
  final Logger _logger = Logger();
  final _accountFormkey = GlobalKey<FormState>();
  final _schoolFormkey = GlobalKey<FormState>();

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int _curentStep = 0;
  bool get isFirstStep => _curentStep == 0;
  bool get isSecondStep => _curentStep == 1;
  bool get isLastStep => _curentStep == getSteps().length - 1;

  bool _isCompleted = false;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();

  final ValueNotifier<String> chosenaffiliationType = ValueNotifier("-");
  final ValueNotifier<String> chosenAffiliationName = ValueNotifier("-");

  @override
  void dispose() {
    super.dispose();
    chosenaffiliationType.dispose();
    chosenAffiliationName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isFirstStep || _isCompleted) {
          return true;
        } else {
          setState(() {
            _curentStep--;
          });
          return false;
        }
      },
      child: Theme(
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
                    final bool isLastStep =
                        _curentStep == getSteps().length - 1;
                    final bool isFirst = _curentStep == 0;

                    return Container(
                      margin: const EdgeInsets.only(top: 30),
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
                          isFirst
                              ? Container()
                              : Expanded(
                                  child: ElevatedButton(
                                    child: const Text("BACK"),
                                    onPressed: _onStepCancel,
                                  ),
                                ),
                        ],
                      ),
                    );
                  },
                ),
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
    if (isLastStep) {
      widget._logger.i("completed steps");
      setState(() {
        _isCompleted = true;
      });
    } else if (isFirstStep) {
      if (widget._accountFormkey.currentState!.validate()) {
        setState(() {
          _curentStep++;
        });
      }
    } else if (isSecondStep) {
      if (widget._schoolFormkey.currentState!.validate()) {
        setState(() {
          _curentStep++;
        });
      }
    }
  }

  List<Step> getSteps() => [
        Step(
          state: _curentStep >= 1 ? StepState.complete : StepState.indexed,
          isActive: _curentStep >= 0,
          title: const Text("Account"),
          content: AccountRegisterForm(
            formKey: widget._accountFormkey,
            userNameController: userNameController,
            nameController: nameController,
            lastNameController: lastNameController,
            emailController: emailController,
            passwordController: passwordController,
            passwordConfirmationController: passwordConfirmationController,
          ),
        ),
        Step(
          state: _curentStep >= 2 ? StepState.complete : StepState.indexed,
          isActive: _curentStep >= 1,
          title: const Text("School"),
          content: SchoolRegisterForm(
            formKey: widget._schoolFormkey,
            chosenAffiliationType: chosenaffiliationType,
            chosenAffiliationName: chosenAffiliationName,
          ),
        ),
        Step(
          state: _curentStep >= 3 ? StepState.complete : StepState.indexed,
          isActive: _curentStep >= 2,
          title: const Text("Complete"),
          content: CompleteForm(
              data: RegistrationFormResult(
            username: userNameController.text,
            name: nameController.text,
            lastName: lastNameController.text,
            email: emailController.text,
            password: passwordController.text,
            passwordConfirmation: passwordConfirmationController.text,
            affiliationType: chosenaffiliationType.value,
            affiliationName: chosenAffiliationName.value,
          )),
        )
      ];
}

class CompleteForm extends StatelessWidget {
  const CompleteForm({Key? key, required this.data}) : super(key: key);
  final RegistrationFormResult data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data
          .toMap()
          .entries
          .map(
            (MapEntry<String, dynamic> e) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(e.key)),
                Flexible(
                  flex: 2,
                  child: Text(
                    e.value,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
