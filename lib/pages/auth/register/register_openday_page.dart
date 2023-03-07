import 'package:flutter/material.dart';
import 'package:iscte_spots/models/auth/registration_form_result.dart';
import 'package:iscte_spots/pages/auth/register/registration_error.dart';
import 'package:iscte_spots/pages/auth/register/school_register_widget.dart';
import 'package:iscte_spots/services/auth/registration_service.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:iscte_spots/widgets/dynamic_widgets/dynamic_text_button.dart';
import 'package:iscte_spots/widgets/network/error.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:lottie/lottie.dart';

import 'acount_register_widget.dart';

class RegisterOpenDayPage extends StatefulWidget {
  RegisterOpenDayPage({
    Key? key,
    required this.changeToLogIn,
    required this.loggingComplete,
    required this.animatedSwitcherDuration,
  }) : super(key: key);

  @override
  State<RegisterOpenDayPage> createState() => _RegisterOpenDayPageState();
  void Function() changeToLogIn;
  final void Function() loggingComplete;
  final Duration animatedSwitcherDuration;
}

class _RegisterOpenDayPageState extends State<RegisterOpenDayPage>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<FormState> _accountFormkey = GlobalKey<FormState>();
  final GlobalKey<FormState> _schoolFormkey = GlobalKey<FormState>();
  int _curentStep = 0;
  bool _isLodading = false;

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

  @override
  bool get wantKeepAlive => true;

  void _onStepCancel() {
    if (_curentStep > 0) {
      setState(() => _curentStep--);
    }
  }

  void _onStepContinue() async {
    if (isFirstStep) {
      if (_accountFormkey.currentState!.validate()) {
        setState(() {
          _curentStep++;
        });
      }
    } else if (isSecondStep) {
      if (_schoolFormkey.currentState!.validate() &&
          _accountFormkey.currentState!.validate()) {
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
        /*
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
        */
        setState(() {
          _isLodading = true;
        });
        RegistrationError registrationError =
            await RegistrationService.registerNewUser(registrationFormResult);
        if (registrationError == RegistrationError.noError) {
          LoggerService.instance.info("completed registration");
          widget.loggingComplete();
        } else {
          setState(() {
            errorCode = registrationError;
          });
          if (_schoolFormkey.currentState != null) {
            _schoolFormkey.currentState!.validate();
          }
          if (_accountFormkey.currentState != null) {
            _accountFormkey.currentState!.validate();
          }
        }
        setState(() {
          _isLodading = false;
        });
      }
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
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        if (isFirstStep) {
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
        child: AnimatedSwitcher(
          duration: widget.animatedSwitcherDuration,
          child: _isLodading
              ? const LoadingWidget()
              : Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 9,
                        child: Stepper(
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
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _onStepContinue,
                                          child: Text(
                                            isLastStep ? "CONFIRM" : "NEXT",
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      isFirst
                                          ? Container()
                                          : Expanded(
                                              child: ElevatedButton(
                                                onPressed: _onStepCancel,
                                                child: const Text("BACK"),
                                              ),
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          steps: getSteps(),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Column(
                          children: [
                            const Text("Already have an account?"), //TODO
                            DynamicTextButton(
                              onPressed: widget.changeToLogIn,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.adaptive.arrow_back),
                                  const Text("Log In!") //TODO
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  List<Step> getSteps() {
    return [
      Step(
        state: _stepState(0),
        isActive: _curentStep >= 0,
        title: const Text("Account"), //TODO
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
        title: const Text("School"), //TODO
        content: SchoolRegisterForm(
          errorCode: errorCode,
          formKey: _schoolFormkey,
          chosenAffiliationType: chosenaffiliationType,
          chosenAffiliationName: chosenAffiliationName,
        ),
      ),
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
        'https://assets6.lottiefiles.com/packages/lf20_Vwcw5D.json',
        errorBuilder: (context, error, stackTrace) =>
            DynamicErrorWidget.networkError(
          context: context,
        ),
      ),
    );
  }
}
