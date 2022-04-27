enum RegistrationError {
  noError,
  existingUsername,
  existingEmail,
  passwordNotMatch,
  invalidAffiliation,
  invalidEmail,
  generalError,

/*  noError(0),
  existingUsername(1),
  existingEmail(2),
  passwordNotMatch(3),
  invalidAffiliation(4),
  invalidEmail(5);
*/
}

extension RegistrationErrorExtension on RegistrationError {
  //const RegistrationError(this.code);
  //final int code;
  static RegistrationError registrationErrorConstructor(int code) {
    switch (code) {
      case 0:
        return RegistrationError.noError;
      case 1:
        return RegistrationError.existingUsername;
      case 2:
        return RegistrationError.existingEmail;
      case 3:
        return RegistrationError.passwordNotMatch;
      case 4:
        return RegistrationError.invalidAffiliation;
      case 5:
        return RegistrationError.invalidEmail;
      default:
        return RegistrationError.generalError;
    }
  }

  int get code {
    switch (this) {
      case RegistrationError.noError:
        return 0;
      case RegistrationError.existingUsername:
        return 1;
      case RegistrationError.existingEmail:
        return 2;
      case RegistrationError.passwordNotMatch:
        return 3;
      case RegistrationError.invalidAffiliation:
        return 4;
      case RegistrationError.invalidEmail:
        return 5;
      case RegistrationError.generalError:
        return -1;
    }
  }
}
