import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iscte_spots/models/auth/registration_form_result.dart';
import 'package:iscte_spots/pages/auth/register/registration_error.dart';
import 'package:iscte_spots/pages/auth/register/school_register_widget.dart';
import 'package:iscte_spots/services/registration_service.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

import 'acount_register_widget.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);
  final Logger _logger = Logger();

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _accountFormkey = GlobalKey<FormState>();
  final _schoolFormkey = GlobalKey<FormState>();
  int _curentStep = 0;
  bool _isLodading = false;
  bool _isCompleted = false;

  RegistrationError errorCode = RegistrationError.noError;
  bool get isFirstStep => _curentStep == 0;
  bool get isSecondStep => _curentStep == 1;
  bool get isLastStep => _curentStep == getSteps().length - 1;

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

  void _onStepCancel() {
    if (_curentStep > 0) {
      setState(() => _curentStep--);
    }
  }

  void _onStepContinue() async {
    if (isFirstStep) {
      // if (widget._accountFormkey.currentState!.validate()) {
      setState(() {
        _curentStep++;
      });
      // }
    } else if (isSecondStep) {
      //if (widget._schoolFormkey.currentState!.validate()) {
      /*
        var registrationFormResult = RegistrationFormResult(
          username: userNameController.text,
          firstName: nameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          password: passwordController.text,
          passwordConfirmation: passwordConfirmationController.text,
          affiliationType: chosenaffiliationType.value,
          affiliationName: chosenAffiliationName.value,
        );
        */
      var registrationFormResult = RegistrationFormResult(
        username: "test",
        firstName: "test",
        lastName: "test",
        email: "test@gmail.com",
        password: "test",
        passwordConfirmation: "test",
        affiliationType: "Alenquer",
        affiliationName: "Escola Secundária Damião de Goes",
      );
      setState(() {
        _isLodading = true;
      });
      RegistrationError registrationError =
          await RegistrationService.registerNewUser(registrationFormResult);
      setState(() {
        _isLodading = false;
      });
      if (registrationError != RegistrationError.noError) {
        setState(() {
          errorCode = registrationError;
        });
        //_schoolFormkey.currentState!.validate();
        //_accountFormkey.currentState!.validate();
      } else {
        setState(() {
          widget._logger.i("completed registration");
          _isCompleted = true;
        });
      }
      //}
    }
  }

  StepState _stepState(int step) {
    if (step == 0 &&
        (errorCode == RegistrationError.passwordNotMatch ||
            errorCode == RegistrationError.existingEmail ||
            errorCode == RegistrationError.existingUsername ||
            errorCode == RegistrationError.invalidEmail)) {
      return StepState.error;
    } else if (step == 1 && errorCode == RegistrationError.invalidAffiliation) {
      return StepState.error;
    } else if (_curentStep == step) {
      return StepState.editing;
    } else {
      if (_curentStep > step) {
        return StepState.complete;
      } else {
        return StepState.indexed;
      }
    }
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
          body: _isLodading
              ? const LoadingWidget()
              : _isCompleted
                  ? CompleteForm()
                  : Stepper(
                      type: StepperType.vertical,
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
                      steps: getSteps(),
                    ),
        ),
      ),
    );
  }

  List<Step> getSteps() {
    var registrationFormResult = RegistrationFormResult(
      username: userNameController.text,
      firstName: nameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      password: passwordController.text,
      passwordConfirmation: passwordConfirmationController.text,
      affiliationType: chosenaffiliationType.value,
      affiliationName: chosenAffiliationName.value,
    );
    return [
      Step(
        state: _stepState(0),
        isActive: _curentStep >= 0,
        title: const Text("Account"),
        content: AccountRegisterForm(
          errorCode: errorCode,
          formKey: _accountFormkey,
          userNameController: userNameController,
          nameController: nameController,
          lastNameController: lastNameController,
          emailController: emailController,
          passwordController: passwordController,
          passwordConfirmationController: passwordConfirmationController,
        ),
      ),
      Step(
        state: _stepState(1),
        isActive: _curentStep >= 1,
        title: const Text("School"),
        content: SchoolRegisterForm(
          errorCode: errorCode,
          formKey: _schoolFormkey,
          chosenAffiliationType: chosenaffiliationType,
          chosenAffiliationName: chosenAffiliationName,
        ),
      ),
/*
      Step(
        state: _stepState(2),
        isActive: _curentStep >= 2,
        title: const Text("Complete"),
        content: CompleteForm(data: registrationFormResult),
      )
*/
    ];
  }
}

class CompleteForm extends StatelessWidget {
  const CompleteForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Lottie.network(
          'https://assets6.lottiefiles.com/packages/lf20_Vwcw5D.json'),
    );
  }
}
