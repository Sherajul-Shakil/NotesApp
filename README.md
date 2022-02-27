# Notes app using firebase and BLOC in domain driven design.

Runnig projecrt.

# The project we will build

- Real-time Firestore data Streams
- Extensive data validation for a rich user experience
- Google & email + password authentication
- Reorderable todo lists and much more

## Command: flutter pub run build_runner watch --delete-conflicting-outputs

# Key architectural layers present in a DDD Flutter app(T1)

<img src="./assets/images/ddd_structure.png" width="500" title="hover text">

>There are a few things that I couldn't fit on the diagram. Namely:

- Arrows represent the flow of data. This can be either uni-directional or bi-directional.

- The domain layer is completely independent of all the other layers. Just pure business logic & data.


# note:
- Notice that in addition to holding and carrying around data, Entities and validated ValueObjects also contain logic. This ranges from data validation and helpers to complex computations.

- Also take note of how Exceptions are put into the regular flow of data as Failures. The only place for try and catch statements are Repositories. This will make it impossible not to handle exceptions, which is a very good thing.

# Architectural Layers

# Presentation layer:
This layer is all Widgets 💙 and also the state of the Widgets. we're going to use BLoC in this series. BLoCs are separated into 3 core components:

- States - Their sole purpose is to deliver values (variables) to the widgets.

- Events - Equivalent to methods inside a ChangeNotifier. These trigger logic inside the BLoC and can optionally carry some raw data (e.g. String from a TextField) to the BLoC.

- BLoC - NOT A PART OF THE PRESENTATION LAYER!!! But it executes logic based on the incoming events and then it outputs states.

>note: A rule of thumb is that whenever some logic operates with data that is later on sent to a server or persisted in a local database, that logic has nothing to do in the presentation layer.

# Application layer: 

>This layer is away from all of the outside interfaces of an app. You aren't going to find any UI code, network code, or database code here. Application layer has only one job - orchestrating all of the other layers. No matter where the data originates (user input, real-time Firestore Stream, device location), its first destination is going to be the application layer.

>The role of the application layer is to decide "what to do next" with the data. It doesn't perform any complex business logic, instead, it mostly just makes sure that the user input is validated (by calling things in the domain layer) or it manages subscriptions to infrastructure data Streams (not directly, but by utilizing the dependency inversion principle, more on that later).

# Domain layer:

>The domain layer is the pristine center of an app. It is fully self contained and it doesn't depend on any other layers. Domain is not concerned with anything but doing its own job well.

>This is the part of an app which doesn't care if you switch from Firebase to a REST API or if you change your mind and you migrate from the Hive database to Moor. Because domain doesn't depend on anything external, changes to such implementation details don't affect it. On the other hand, all the other layers do depend on domain.

>So, what exactly goes on inside the domain layer? This is where your business logic lives, which is not Flutter/server/device dependent goes into domain. This includes:

- Validating data and keeping it valid with ValueObjects. For example, instead of using a plain String for the body of a Note, we're going to have a separate class called NoteBody. It will encapsulate a String value and make sure that it's no more than 1000 characters long and that it's not empty.

- Transforming data (e.g. make any color fully opaque).

- Grouping and uniquely identifying data that belongs together through Entity classes (e.g. User or Note entities)

- Performing complex business logic - this is not necessarily always the case in client Flutter apps, since you should leave complex logic to the server. Although, if you're building a truly serverless 😉 app, this is where you'd put that logic.

>The domain layer is the core of you app. Changes in the other layers don't affect it. However, changes to the domain affect every other layer. This makes sense - you're probably not changing the business logic on a daily basis.

>In addition to all this, the domain layer is also the home of Failures. Handling exceptions is a 💩 experience. 

>We want to mitigate this pain with union types! Instead of using the return keyword for "correct" data and the throw keyword when something goes wrong, we're going to have Failure unions. This will also ensure that we'll know about a method's possible failures without checking the documentation. Again, we're going to get to the details in the next parts.


# Infrastructure layer:

>Much like presentation, this layer is also at the boundary of our app. Although, of course, it's at the "opposite end" and instead of dealing with the user input and visual output, it deals with APIs, Firebase libraries, databases and device sensors.

>The infrastructure layer is composed of two parts - low-level data sources and high level repositories. Additionally, this layer holds data transfer objects (DTOs). Let's break it down!

>DTOs are classes whose sole purpose is to convert data between entities and value objects from the domain layer and the plain data of the outside world. As you know, only dumb data like String or int can be stored inside Firestore but we don't want this kind of unvalidated data throughout our app. That's precisely why we'll use ValueObjects described above everywhere, except for the infractructure layer. DTOs can also be serialized and deserialized.

>Data sources operate at the lowest level. Remote data sources fit JSON response strings gotten from a server into DTOs, and also perform server requests with DTOs converted to JSON. Similarly, local data sources fetch data from a local database or from the device sensors.

>Repositories perform an important task of being the boundary between the domain and application layers and the ugly outside world. It's their job to take DTOs and unruly Exceptions from data sources as their input, and return nice Either<Failure, Entity> as their output. 

## End of tutorial 1.

# Authentication Value Objects(T2)

# Email & password:
>How can we sign in using email and password?  The usual way would be to have a sign in form that would validate the inputted Strings. You know, email addresses must have the '@' sign and passwords must be at least six characters long. We would then pass these Strings to the authentication service, in our case, Firebase Auth.

# Validating at instantiation
>You are probably used to validating Strings in a TextFormField.We will take this principle and take it to a whole another level. You see, not all validation is equal. We're about to perform the safest validation of them all - we're going to make illegal states unrepresentable. In other words, we will make it impossible for a class like EmailAddress to hold an invalid value not just while it's in the TextFormField but throughout its whole lifespan.

# Either a failure or a value
>Our current troubles stem from the fact that the EmailAddress class holds only a single field of type String. What if, instead of throwing an InvalidEmailException, we would instead somehow store it inside the class?This will allow us to not litter our codebase with try and catch statements at the time of instantiation. 

>What if we joined the value and failure fields into one by using a union type? And not just any sort of a union - we're going to use Either.

>Note: Either is a union type from the dartz package specifically suited to handle what we call "failures". It is a union of two values, commonly called Left and Right. The left side holds Failures and the right side holds the correct values, for example, Strings.

>So, we're going to use dartz for Either but what about the regular unions? The best option is to use the freezed package. Let's add them to pubspec.yaml and since freezed uses code generation, we'll also add a bunch of other dependencies.

~~~dart
pubspec.yaml

dependencies:
  flutter:
    sdk: flutter
  dartz: ^0.9.0-dev.6
  freezed_annotation: ^0.7.1

dev_dependencies:
  build_runner:
  freezed: ^0.9.2
~~~

# ValueFailure union
>We'll group all failures from validated value objects into one such union - ValueFailure. Since this is something common across features, we'll create the failures.dart file inside the domain/core folder. While we're at it, let's also create a "short password" failure.

## domain/core/failures.dart
~~~dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'failures.freezed.dart';

@freezed
abstract class ValueFailure<T> with _$ValueFailure<T> {
  const factory ValueFailure.invalidEmail({
    required T failedValue,
  }) = InvalidEmail<T>;

  const factory ValueFailure.shortPassword({
    required T failedValue,
  }) = ShortPassword<T>;
}
~~~
>We made the class generic because we will also validate values other than  Strings later on in this series.

>The value which can be held inside an EmailAddress will no longer be just a String. Instead, it will be Either<ValueFailure<String>, String>. The same will also be the return type of the validateEmailAddress function. Then, instead of throwing an exception, we're going to return the left side of Either.

>Password: EmailAddress is implemented and it contains a lot of boilerplate code for toString, ==, and hashCode overrides. We surely don't want to duplicate all of this into a Password class. This is a perfect opportunity to create a super class.

# Abstract ValueObject
>This abstract class will extend specific value objects across multiple features. We're going to create it under domain/core. All it does is just extracting boilerplate into one place. Of course, we heavily rely on generics to allow the value to be of any type.

## domain/core/value_objects.dart
~~~dart
@immutable
abstract class ValueObject<T> {
  const ValueObject();
  Either<ValueFailure<T>, T> get value;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is ValueObject<T> && o.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Value($value)';
}
~~~

>We can now extend this class from EmailAddress and Password. 

## domain/auth/value_objects.dart
~~~dart
class EmailAddress extends ValueObject<String> {
  factory EmailAddress({String? email}) {
    return EmailAddress._(validateEmailAddress(email: email!.trim()));
  }
  const EmailAddress._(this.value);
  @override
  final Either<ValueFailure<String>, String> value;
}

class Password extends ValueObject<String> {
  factory Password({String? password}) {
    return Password._(validatePassword(password: password!.trim()));
  }
  const Password._(this.value);
  @override
  final Either<ValueFailure<String>, String> value;
}
~~~

## End of Readme 2.

# Domain abstraction(T3)
> the application layer cannot depend on classes from the infrastructure layer.

>Which actions do we need to perform on the authentication backend? There are three things, which we will translate into methods:

- Register with email and password
- Sign in with email and password
- Sign in with Google

>Let us, therefore, create i_auth_facade.dart under domain/auth. Its methods will take in EmailAddress and Password value objects

>Note: Facade is a design pattern for connecting two or more classes with weird interfaces into just one simplified interface. In our case, it will connect FirebaseAuth and GoogleSignIn.

## domain/auth/i_auth_facade.dart
~~~dart
abstract class IAuthFacade {
  Future<Option<AsUser>> getSignedInUser();
  Future<Either<AuthFailure, Unit>> registerWithEmailAndPassword({
    required EmailAddress emailAddress,
    required Password password,
  });

  Future<Either<AuthFailure, Unit>> signInWithEmailAndPassword({
    required EmailAddress emailAddress,
    required Password password,
  });
  Future<Either<AuthFailure, Unit>> signInWithGoogle();
}
~~~

# AuthFailure:
>Let's think about the possible failures which can occur during authentication. 

- User "taps out" of the 3rd party sign-in flow (Google in our case)
- There is an error on the auth server
- User wants to register with an email which is already in use
- User enters an invalid combination of email and password

>Let's create this union inside domain/auth/auth_failure.dart.

## domain/auth/auth_failure.dart:
~~~dart
@freezed
abstract class AuthFailure with _$AuthFailure {
  const factory AuthFailure.cancelledByUser() = CancelledByUser;
  const factory AuthFailure.serverError() = ServerError;
  const factory AuthFailure.emailAlreadyUsed() = EmailAlreadyUsed;
  const factory AuthFailure.invalidEmailandPasswordCombination() =
      InvalidEmailandPasswordCombination;
}
~~~

>It's much better to use our trusted friend called Either where we pass around failures inside the Left side of it. But what are we going to put into the Right side? Can we create something like Either<AuthFailure, void>?

>There is much to be said about Unit but for our purposes, we can think of it as of a functional equivalent to Dart's dumb void keyword.

>we've discovered the Unit type which allows us to return "nothing" inside the Either union.

# Bloc overview(4)
>As shown on the diagram, a BLoC receives events from the UI which contain raw data and outputs states which contain validated data, among other things. Let's now create the classes for the SignInFormBloc.

~~~dart
pubspec.yaml

dependencies:
  ...
  flutter_bloc: ^3.2.0
~~~

>Create new directories so that the path application/auth/sign_in_form exists. Using the extensions mentioned above, create a a Bloc with the name "sign_in_form".

>It's important to remember that events and states are a part of the presentation layer.

# Events:
>What possible events can occur in the UI of the sign-in form? Apart from the different sign-in buttons being pressed, there are also two other events which are usually handled directly in the UI unless you're following DDD - email and password input changes. Expressed as a union, the events will look like:

## application/auth/sign_in_form/sign_in_form_event.dart
~~~dart
@freezed
class SignInFormEvent with _$SignInFormEvent {
  const factory SignInFormEvent.emailChanged(String email) = EmailChanged;
  const factory SignInFormEvent.passwordChanged(String password) =
      PasswrodChanged;

  const factory SignInFormEvent.registerWithEmailAndPasswordPressed() =
      RegisterWithEmailAndPasswordPressed;
  const factory SignInFormEvent.signInWithEmailAndPasswordPressed() =
      SignInWithEmailAndPasswordPressed;
  const factory SignInFormEvent.signInWithGooglePressed() =
      SignInWithGooglePressed;
}
~~~

# state:

>BLoC usually outputs multiple subclasses (or union cases) of state. What do we need to communicate back to the UI of the sign-in form?

- Validated values: We surely want to pass back the validated EmailAddress and Password value objects to be able to show error messages in the TextFormFields.

- Auth progress: Showing a progress indicator is a no-brainer, so we have to also pass back a bool isSubmitting.

- Success or error backend response:To show an error Snackbar when something goes wrong in the backend, we will need to pass back the Either<AuthFailure, Unit> returned from the IAuthFacade. We're going to call it authFailureOrSuccess and you can think of it as of the auth backend "response".

>However, there will initially be no response until the user presses a button. We could just initially assign null to the authFailureOrSuccess field but you know that this sucks.

>A much better option would be to use an Option 🙃. Much like Either, it's a union of two values - Some and None. It's a sort of a non-nullable type where null gets replaced by the None union case. Only the Some union case holds a value which will be the Either<AuthFailure, Unit>.

- Whether or not to show input error messages: Lastly, we want to show the input validation error messages under the TextFormFields only after the first press of a sign-in/register button. This will be communicated back to the UI inside a bool showErrorMessages.

## application/auth/sign_in_form/sign_in_form_state.dart
~~~dart
@freezed
class SignInFormState with _$SignInFormState {
  const factory SignInFormState({
    required EmailAddress emailAddress,
    required Password password,
    required bool isSubmitting,
    required AutovalidateMode showErrorMessages,
    required Option<Either<AuthFailure, Unit>> authFailureOrSuccessOption,
  }) = _SignInFormState;

  factory SignInFormState.initial() => SignInFormState(
        emailAddress: EmailAddress(email: ''),
        password: Password(password: ''),
        isSubmitting: false,
        showErrorMessages: AutovalidateMode.disabled,
        authFailureOrSuccessOption: none(),
      );
}
~~~

# bloc
>While events and the state data class can be viewed as View Models which live in the presentation layer, the SignInFormBloc class itself performs application logic, i.e. orchestrating the other layers to work together.

>This is where the raw Strings turn into validated ValueObjects and where the IAuthFacade's methods are called. The logic performed here is focused on transforming incoming events into states.

## application/auth/sign_in_form/sign_in_form_bloc.dart
~~~dart
part 'sign_in_form_event.dart';
part 'sign_in_form_state.dart';

part 'sign_in_form_bloc.freezed.dart';

class SignInFormBloc extends Bloc<SignInFormEvent, SignInFormState> {
  final IAuthFacade _authFacade;

  SignInFormBloc(this._authFacade);

  @override
  SignInFormState get initialState => SignInFormState.initial();

  @override
  Stream<SignInFormState> mapEventToState(
    SignInFormEvent event,
  ) async* {
    // TODO: Implement
  }
}
~~~
## End of T4

# Bloc Logic:
>The logic performed inside BLoCs is focused on transforming incoming events into states. For example, a raw String will come in from the UI and a validated EmailAddress will come out.

## Field updates:
>The simplest events to implement are those which simply receive unvalidated raw data from the UI and transform it into validated ValueObjects.

>Reset the previous error cause we don't need previous error. 
~~~dart
on<EmailChanged>((event, emit) async {
      emit(state.copyWith(
        emailAddress: EmailAddress(email: event.email),
        authFailureOrSuccessOption: none(), //resetting the previous response
      ));
    });
    on<PasswrodChanged>((event, emit) async {
      emit(state.copyWith(
        password: Password(password: event.password),
        authFailureOrSuccessOption: none(), //resetting the previous response
      ));
    });
~~~
>We have to reset the authFailureOrSuccessOption field whenever we emit a new state. This field holds a "response" from the previous call to sign in/register using IAuthFacade. Surely, when the email address changes, it's not correct to associate the old "auth response" with the updated email address.

# Sign in with Google:
>We're finally going to call a method on the IAuthFacade from this event handler. First, we'll indicate that the form is in the process of being submitted and once the signInWithGoogle method had a chance to run, we'll yield a state containing either a failure (AuthFailure) or success (Unit).
~~~dart
    on<SignInWithGooglePressed>((event, emit) async {
      emit(state.copyWith(
        isSubmitting: true,
        authFailureOrSuccessOption: none(), //resetting the previous response
      ));
      final failureOrSuccess = await _authFacade.signInWithGoogle();
      emit(state.copyWith(
        isSubmitting: false,
        authFailureOrSuccessOption:
            some(failureOrSuccess), //adding the response
      ));
    });
~~~

# Register & sign in with email and password:
>These last two event handlers contain the largest amount of code. It's still simple though and the logic can be broken down into a couple of steps. Let's focus on the registration at first.

- Check if the entered EmailAddress and Password are valid.

- If valid, register using IAuthFacade and yield Some<Right<Unit>> in the authFailureOrSuccessOption state field.

- If invalid, indicate to start showing error messages and keep the authFailureOrSuccessOption set to None.

>We know that ValueObjects have a value property which is of type Either. Therefore, to check if the inputted email address is valid, we can simply call myEmailAddress.value.isRight(). Wouldn't it be more expressive though to call myEmailAddress.isValid()? Let's create such a method in the ValueObject super class:

~~~dart
@immutable
abstract class ValueObject<T> {
  const ValueObject();
  Either<ValueFailure<T>, T> get value;

  bool isValid() => value.isRight();
}
~~~

>With this, we can go ahead and implement the sign in event handler.
~~~dart
  Future<void> _registerWithEmailAndPassword(
    RegisterWithEmailAndPasswordPressed event,
    Emitter<SignInFormState> emit,
  ) async {
    Either<AuthFailure, Unit>? failureOrSuccess;

    final isEmailValid = state.emailAddress.isValid();
    final isPasswordValid = state.password.isValid();

    if (isEmailValid && isPasswordValid) {
      emit(state.copyWith(
        isSubmitting: true,
        authFailureOrSuccessOption: none(),
      ));
      failureOrSuccess = await _authFacade.registerWithEmailAndPassword(
        emailAddress: state.emailAddress,
        password: state.password,
      );
    } else {
      //failureOrSuccess = none() as Either<AuthFailure, Unit>?;
    }
    emit(state.copyWith(
      isSubmitting: false,
      showErrorMessages: AutovalidateMode.always,
      authFailureOrSuccessOption:
          optionOf(failureOrSuccess), //if null then none
      //if some then some (handy use of ternary));
    ));
  }
~~~

>Awesome! We can now implement the signInWithEmailAndPasswordPressed event handler but it will be suspiciously simple 🧐
~~~dart
  Future<void> _loginWithEmailAndPassword(
    SignInWithEmailAndPasswordPressed event,
    Emitter<SignInFormState> emit,
  ) async {
    Either<AuthFailure, Unit>? failureOrSucces;

    final isEmailValid = state.emailAddress.isValid();
    final isPasswordValid = state.password.isValid();

    if (isEmailValid && isPasswordValid) {
      emit(state.copyWith(
        isSubmitting: true,
        authFailureOrSuccessOption: none(),
      ));
      failureOrSucces = await _authFacade.signInWithEmailAndPassword(
        emailAddress: state.emailAddress,
        password: state.password,
      );
    } else {
      //  failureOrSucces = none();
    }
    emit(state.copyWith(
      isSubmitting: false,
      showErrorMessages: AutovalidateMode.always,
      authFailureOrSuccessOption: optionOf(failureOrSucces), //if null then none
      //if some then some (handy use of ternary));
    ));
  }
~~~
## End of T5

#  Firebase Auth Setup & Facade(T6)
>so the first thing we should do here is to create a firebase project because actually up until now we did not have any firebase configuration inside our app.

# infrustructure/auth/firebase_auth_facade.dart
>Implementation of i_auth_facade.dart:

~~~dart
  @override
  Future<Either<AuthFailure, Unit>> registerWithEmailAndPassword({
    required EmailAddress emailAddress,
    required Password password,
  }) async {
    //_firebaseAuth.currentUser!()
    final emailAddressString = emailAddress.getOrCrash();
    final passwordString = password.getOrCrash();

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailAddressString,
        password: passwordString,
      );
      return right(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return left(const AuthFailure.emailAlreadyUsed());
      } else {
        return left(const AuthFailure.serverError());
      }
    }
  }
~~~

>so let's jump into register with email and password first right what we should do here is to call firebase off that create user with email and password. the problem though is that the method on firebase auth does not have the concept of our value object email address and password. it expects a string and indeed email address is just a string which is validated and the same goes for password.

>for some reason which is completely unknown there is an invalid thing held inside the email address we're going to crash the app and that's precisely what we should do because again this situation should not even happen in the first place.

~~~dart
domain/core/value_objects.dart
  T getOrCrash() {
    return value.fold(
        (l) => throw UnexpectedValueError(l), id //shorthand of (r) => r
        );
  }
~~~
~~~dart
domain/core/failures.dart
class UnexpectedValueError extends Error {
  UnexpectedValueError(this.valueFailure);
  final ValueFailure valueFailure;

  @override
  String toString() {
    const explanation = 'Encountered a ValueFailure at an unrecoverable point.';
    return Error.safeToString(
        '$explanation Terminating!!.\n failure was: $valueFailure');
  }
}
~~~

>are returning left from the catch statement but we are now returning anything from the try block so if there is no exception happening we are not gonna return anything and we need to return something so what can we do well. we can return right unit. because unit is used inside either to signify that nothing wrong happened.

~~~dart
try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: emailAddressString,
        password: passwordString,
      );
      return right(unit);
    }
~~~

## signInWithEmailAndPassword:
~~~dart
  @override
  Future<Either<AuthFailure, Unit>> signInWithEmailAndPassword({
    required EmailAddress emailAddress,
    required Password password,
  }) async {
    final emailAddressString = emailAddress.getOrCrash();
    final passwordString = password.getOrCrash();

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: emailAddressString,
        password: passwordString,
      );
      return right(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return left(const AuthFailure.invalidEmailandPasswordCombination());
      } else {
        return left(const AuthFailure.serverError());
      }
    }
  }
~~~
>why is that why do we not have separate failure for a wrong password and a separate one for user not found?why do we join them together? well the reason for that is that if we said wrong password to the user in the UI that user if he tried to be malicious could know now that the email address is actually correct and only the password is wrong and what could happen then is that the user could do a brute-force tag or just simply try to hack the account because that user which is malicious would know that oh that email address is already present on the back end I just need to find out about a password.

## signInWithGoogle:
~~~dart
  @override
  Future<Either<AuthFailure, Unit>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return left(const AuthFailure.cancelledByUser());
      }
      final googleAuthentication = await googleUser.authentication;
      final authCredential = GoogleAuthProvider.credential(
        idToken: googleAuthentication.idToken,
        accessToken: googleAuthentication.accessToken,
      );
      await _firebaseAuth.signInWithCredential(authCredential);
      return right(unit);
    } on FirebaseAuthException catch (_) {
      return left(const AuthFailure.serverError());
    }
  }
~~~
## End of T6

# Injectable & Linting(T7)
>when you look at it closely there constructors accept firebase or Google sign in and so on the problem is that we are not testing these dependencies into the classes which we have created before in any sort of way that's why we need to add dependency injection into our app and we are going to use injectable for that.
~~~dart
class FirebaseAuthFacade implements IAuthFacade {
  FirebaseAuthFacade(this._firebaseAuth, this._googleSignIn);

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
}
~~~
> let's add in injectable for dependency injection and also get it because injectable actually works with get it which is a service. locator 
~~~dart
injectable: ^1.5.3
get_it: ^7.2.0

DEV:
injectable_generator: ^1.5.3
flutter_lints: ^1.0.0
~~~

> let's immediately jump into it first up we are going to set up linting.

>that's the yeah the root folder and we are just going to add a new file which is going to be called analysis options yamo and this is where we can enable custom analyzer errors and overall configure the things which we are going to see as errors and warnings in our app.

>the way injectable works is that you have to have one file create it for example we can create it in the lib of our project just where main dart lives 
~~~dart
final GetIt getIt = GetIt.instance;

@injectableInit
void configureInjection(String env) {
  $initGetIt(getIt, environment: env);
}
~~~

>we definitely want to annotate our sign-in form block because this is expecting an I auth facade instance to be passed into it so we can annotate it with an injectable.
~~~dart
@injectable
class SignInFormBloc extends Bloc<SignInFormEvent, SignInFormState> {
  final IAuthFacade _authFacade;
}
~~~

>we should know that what we actually want is the concrete implementation of firebase of facade what we can do is simple we can go over to firebase of facade and just say that we want to make it a lazy singleton and register it as and the type under which we wanna register.
~~~dart
@LazySingleton(as: IAuthFacade)
class FirebaseAuthFacade implements IAuthFacade {
  FirebaseAuthFacade(this._firebaseAuth, this._googleSignIn);
}
~~~

>we are doing domain-driven design with this sort of a folder layout so into which folder should we put our firebase injectible module. I would say that the best place to put this module is inside the infrastructure folder under the core sub folder and we are going to create a new file firebase injectable module dot dart we're going to create an abstract class firebase injectable module abstract and we are going to mark it with add register module and which sort of third-party dependencies.

>we need to register whatever is passed into firebase_auth_facade and that is firebase auth and also Google sign-in so let's start off with Google sign-in so let's jump into the firebase injectable module and we are just going to create Google sign-in get. 

>why on earth did we put this firebase injectable module into the core folder of infrastructure? why did we not put it into the auth folder of infrastructure? well the answer is that I would say that this sort of injectable modules would really have nothing else to do than to specify a few properties to get registered they should be in the core folder.
~~~dart
@module
abstract class FirebaseInjectableModule {
  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn();
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
  }
}
~~~

>In main.dart use
~~~dart
configureInjection(Environment.prod);
~~~
## End of T7


# Sign-In Form UI(T8)
## Presentation/sign_in/sign_in_page.dart
~~~dart
class SignInPage extends StatelessWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: BlocProvider(
        create: (context) => getIt<SignInFormBloc>(),
        child: const SignInForm(),
      ),
    );
  }
}
~~~
## Presentation/sign_in/widget/sign_in_form.dart
~~~dart
class SignInForm extends StatelessWidget {
  const SignInForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInFormBloc, SignInFormState>(
      listener: (context, state) {
        state.authFailureOrSuccessOption.fold(
          () {},
          (either) => either.fold(
            (l) {
              // ignore: avoid_single_cascade_in_expression_statements
              Flushbar<dynamic>(
                title: '⚠',
                message: l.map(
                  serverError: (_) => 'Server Error!',
                  emailAlreadyUsed: (_) => 'Email already in use!',
                  invalidEmailandPasswordCombination: (_) =>
                      'Invalid email and password combination',
                  cancelledByUser: (_) => 'Cancelled!',
                ),
                duration: const Duration(seconds: 3),
              ).show(context);
            },
            (r) {},
          ),
        );
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Form(
            autovalidateMode: state.showErrorMessages,
            // this is coming from the block and from the
            // block consumer respectively this will
            // allow for the immediate validation of
            // the input as soon as one character
            // changes is going to be validated and
            // possibly an error message will be shown
            // below the text form field
            child: ListView(children: [
              const Text(
                '📝',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 130),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Email',
                ),
                autocorrect: false,
                onChanged: (value) => BlocProvider.of<SignInFormBloc>(context)
                    .add(SignInFormEvent.emailChanged(value)),
                // this value will be
                // validated inside our value object
                validator: (_) => context
                    .read<SignInFormBloc>()
                    .state
                    .emailAddress
                    .value
                    .fold(
                      (l) => l.maybeMap(
                        orElse: () => null,
                        invalidEmail: (_) => 'Invalid Email',
                      ),
                      (_) => null,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      //toogleShowPassword.value = !toogleShowPassword.value;
                    },
                    icon: const Icon(Icons.visibility),
                    // toogleShowPassword.value == true
                    //     ? const Icon(Icons.visibility_off)
                    //     : const Icon(Icons.visibility),
                  ),
                ),
                obscureText: true,
                // !(!!toogleShowPassword.value),
                autocorrect: false,
                onChanged: (value) => BlocProvider.of<SignInFormBloc>(context)
                    .add(SignInFormEvent.passwordChanged(value)),
                validator: (_) =>
                    context.read<SignInFormBloc>().state.password.value.fold(
                          (l) => l.maybeMap(
                            orElse: () => null,
                            shortPassword: (_) => 'Short Password',
                          ),
                          (_) => null,
                        ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      context.read<SignInFormBloc>().add(
                            const SignInFormEvent
                                .signInWithEmailAndPasswordPressed(),
                          );
                    },
                    child: const Text('SIGN IN'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<SignInFormBloc>().add(
                            const SignInFormEvent
                                .registerWithEmailAndPasswordPressed(),
                          );
                    },
                    child: const Text('REGISTER'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<SignInFormBloc>().add(
                        const SignInFormEvent.signInWithGooglePressed(),
                      );
                },
                child: const Text('SIGN IN WITH GOOGLE'),
              ),
              if (state.isSubmitting) ...[
                const SizedBox(height: 8),
                const CupertinoActivityIndicator(),
              ],
            ]),
          ),
        );
      },
    );
  }
}
~~~
## End of T8


# Getting the Signed-In User(T9)
>To get current user we need a unique id.

## domain/auth/user.dart
~~~dart
@freezed
abstract class AsUser with _$AsUser {
  const factory AsUser({
    required UniqueId id,
  }) = _AsUser;
}
~~~

>we are not going to be generating unique IDs inside our app instead we can obtain the unique IDs directly from firebase off by this UID call which provides the user ID for the signed-in user.
## domain/auth/value_objects.dart
~~~dart
class UniqueId extends ValueObject<String> {
  @override
  factory UniqueId() {
    return UniqueId._(
      // ignore: prefer_const_constructors
      right(Uuid().v1()),
    );
  }
  const UniqueId._(this.value);
  factory UniqueId.fromUniqueString(String uniqueId) {
    return UniqueId._(right(uniqueId));
  }

  @override
  final Either<ValueFailure<String>, String> value;
}
~~~

## domain/auth/i_auth_facade.dart
~~~dart
Future<Option<AsUser>> getSignedInUser();
Future<void> signOut();
~~~

>Let's implement getSignedInUser()
## infrustructure/auth/firabse_auth_facade.dart
~~~dart
  @override
  Future<Option<AsUser>> getSignedInUser() async {
    return optionOf(_firebaseAuth.currentUser?.toDomain());
  }
~~~
>Implement toDomain()
~~~dart
extension FirebaseUserDomainX on User {
  AsUser toDomain() {
    return AsUser(id: UniqueId.fromUniqueString(uid));
  }
}
~~~

## ## infrustructure/auth/firabse_auth_facade.dart
~~~dart
  @override
  Future<void> signOut() => Future.wait([
        _googleSignIn.signOut(),
        _firebaseAuth.signOut(),
      ]);
~~~
## End of T9


# Navigation Based on Auth State(T10)
>we also need to have some sort of a general authentication or auth block which will do things like check for the authentication status and also this block will sign out the user if needed.

>we can go about setting up how the events and States are going to look like. so as you know already events are four things which we want the block to accomplish this is what comes into the block and it tells the block what to do. so what is our block going to respond to or what is it going to do well it's going to check the authentication status and it's also possibly going to sign the user out when the user presses a sign out button.
## application/auth/auth_event.dart
~~~dart
@freezed
abstract class AuthEvent with _$AuthEvent {
  const factory AuthEvent.authCheckRequested() = AuthCheckRequested;
  const factory AuthEvent.signedOut() = SignedOut;
}
~~~


## application/auth/auth_state.dart
~~~dart
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;
  const factory AuthState.authenticated() = Authenticated;
  const factory AuthState.unAuthenticated() = UnAuthenticated;
}
~~~
> initial(): until we call this get signed and use your method we have no clue where or now we are signed in and that's what this initial state represents.


>Const of state that initial by the looks of it both blog is probably going to need to communicate with the firebase auth facade but because we are inside the application layer this means that we are not going to communicate directly with the infrastructure layer which holds the firebase auth facade the concrete implementation. no we are instead going to communicate with the abstract I auth façade(infrustructure/auth/firebase_auth_facade.dart).

## application/auth/auth_bloc.dart
~~~dart
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthFacade _authFacade;
  AuthBloc(this._authFacade) : super(const Initial()) {
    on<AuthCheckRequested>((event, emit) async {
      final userOption = await _authFacade.getSignedInUser();
      emit(userOption.fold(
        () => const AuthState.unAuthenticated(),
        (a) => const AuthState.authenticated(),
      ));
    });

    on<SignedOut>((event, emit) async {
      await _authFacade.signOut();
      emit(const AuthState.unAuthenticated());
    });
  }
}
~~~

>in this part we are going to add the splash page which is going to decide what to show at the beginning after the user launches the app that's where we are going to call this off check requested event from and in order to navigate to our pages we can just use the material paid route or we can use named routes and set it up all by ourselves or we can introduce another dependency which is going to make our lives so much easier. it's not a golden bullet but in this case it's precisely what is going to facilitate easier writing of the code. so I would say let's go for it it's actually quite a cool library it's called or route or auto route.

## presentation/routes/router.dart
~~~dart
@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute<dynamic>(page: SplashPage, initial: true),
    AutoRoute<dynamic>(page: SignInPage),
    // AutoRoute<dynamic>(page: NotesOverviewPage),
    // AutoRoute<dynamic>(
    //   page: NoteFormPage,
    //   fullscreenDialog: true,
    // ),
  ],
)
class $AppRouter {}
~~~

>To acces auth condition of authenticate and unauthenticate wrap the MaterialApp with MultiBlocProvider. we are actually wrapping the top level material app and by the virtue of that our block is going to be available literally everywhere.
## presentation/core/app_widget.dart
~~~dart
return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<AuthBloc>()..add(const AuthEvent.authCheckRequested()),
        ),
      ],
    )
~~~

>the block listener widget is for to observe the block and where are we going to observe the block from well certainly not from the sign-in page which is currently being the home of our material app. now we need to have a separate page which is going to be basically the decision maker about where to navigate next. if the user is signed in we're going to navigate to the home page which is going to show the user the notes but if the user is not signed in we're going to navigate to the sign-in page and all of that is going to be decided upon in the splash page. so we need to get rid of this home sign-in page of our material app and actually because we are using auto route library we are going to set up the Builder of our material app and we are going to set it to be extended navigator which comes from order out and pass in our generated router class.

## presentation/splash/splash_screen/dart
~~~dart
class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //BlocListener run after build has finished
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.map(
          initial: (_) {},
          authenticated: (_) {
            print("authenticated");
            //context.router.replace(const NotesOverviewPageRoute());
          },
          unAuthenticated: (_) =>
              context.router.replace(const SignInPageRoute()),
        );
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
~~~
>block listener is useful for doing things which basically cannot happen during build. so something like navigation is certainly something which cannot happen during built and so that's why we need to use the block listener which runs after the build has finished.
## End of T10
## 😍😍😍😍😍😍😍😍😍Authentication is finished😍😍😍😍😍😍😍😍😍

# Note Value Failures(T11)
>we are going to start off maybe unconventionally and that is by creating all of the possible failures which can occur during creating of a note or the todo.

## domain/core/failure.dart
~~~dart
  const factory ValueFailure.exceedingLength({
    required T failedValue,
    required int max,
  }) = ExceedingLength<T>;

  const factory ValueFailure.empty({
    required T failedValue,
  }) = Empty<T>;

  const factory ValueFailure.multiLine({
    required T failedValue,
  }) = MultiLine<T>;

  const factory ValueFailure.listTooLong({
    required T failedValue,
    required int max,
  }) = ListTooLong<T>;
~~~
## End of T11


# Note Value Objects(T12)
>Validate the notes failures.

## domain/core/value_validators.dart
~~~dart
Either<ValueFailure<String>, String> validateMaxStringLength(
  String? input,
  int? maxLength,
) {
  if (input!.length <= maxLength!) {
    return right(input);
  } else {
    return left(
      ValueFailure.exceedingLength(
        failedValue: input,
        max: maxLength,
      ),
    );
  }
}

Either<ValueFailure<String>, String> validateStringNotEmpty(
  String? input,
) {
  if (input!.isNotEmpty) {
    return right(input);
  } else {
    return left(ValueFailure.empty(failedValue: input));
  }
}

Either<ValueFailure<String>, String> validateSingleLine(
  String? input,
) {
  if (!input!.contains('\n')) {
    return right(input);
  } else {
    return left(ValueFailure.empty(failedValue: input));
  }
}

Either<ValueFailure<KtList<T>>, KtList<T>> validateMaxListLength<T>(
  KtList<T>? input,
  int? maxLength,
) {
  if (input!.size <= maxLength!) {
    return right(input);
  } else {
    return left(ValueFailure.listTooLong(
      failedValue: input,
      max: maxLength,
    ));
  }
}
~~~

>let's continue let's go ahead and create the value objects which are going to be needed in the notes feature. so again what do we want to have here we want to have notes body we want to have a to-do name and also note color and I hope I didn't forget about anything else. so we are going to go ahead and create a new folder under domain it's gonna be called notes and over there under this folder we are going to create a new file value_objects.dart and let's go ahead and create our value_objects.

## domain/notes/value_objects.dart
~~~dart
class NoteBody extends ValueObject<String> {
  factory NoteBody(String input) {
    return NoteBody._(
      validateMaxStringLength(
        input,
        maxLength,
      ).flatMap(validateStringNotEmpty),
      //check 1st condition and then second condition.
      //if first condition is false then skip second condition
      //kind of middlewares in express.js
    );
  }
  const NoteBody._(this.value);

  @override
  final Either<ValueFailure<String>, String> value;
  static const maxLength = 1000;
}

class TodoName extends ValueObject<String> {
  factory TodoName(String input) {
    return TodoName._(
      validateMaxStringLength(input, maxLength)
          .flatMap(validateStringNotEmpty)
          .flatMap(validateSingleLine),
      //(a) => pFunc(func(a));
      // instead we can write
      //  pFunc(func)
    );
  }
  const TodoName._(this.value);

  @override
  final Either<ValueFailure<String>, String> value;
  static const maxLength = 30;
}

class NoteColor extends ValueObject<Color> {
  factory NoteColor(Color input) {
    return NoteColor._(right(makeColorOpaque(input)));
  }
  const NoteColor._(this.value);

  @override
  final Either<ValueFailure<Color>, Color> value;
  static const List<Color> predefinedColors = [
    Color(0xfffafafa), // canvas
    Color(0xfffa8072), // salmon
    Color(0xfffedc56), // mustard
    Color(0xffd0f0c0), // tea
    Color(0xfffca3b7), // flamingo
    Color(0xff997950), // tortilla
    Color(0xfffffdd0), // cream
  ];
}

class ListThree<T> extends ValueObject<KtList<T>> {
  factory ListThree(KtList<T> input) {
    return ListThree._(
      validateMaxListLength(input, maxLength),
    );
  }
  const ListThree._(this.value);

  @override
  final Either<ValueFailure<KtList<T>>, KtList<T>> value;
  static const maxLength = 3;
  int get length => value.getOrElse(emptyList).size;
  bool get isFull => length == maxLength;
}

~~~

>For transparency
## domain/core/value_transformer.dart
~~~dart
Color makeColorOpaque(Color color) {
  return color.withOpacity(1);
}
~~~
## End of T12


# Note Entities(T13)
>entities are basically a group of value objects which has an identity. which is going to be given by the unique identifier. 

## domain/notes/note.dart
~~~dart
  const factory Note({
    required UniqueId id,
    required NoteBody body,
    required NoteColor color,
    required ListThree<TodoItem> todos,
  }) = _Note;
~~~

>required UniqueId id: the first one is the unique id by which each individual instance of the note class will be identified. so it will be required parameter unique id.

>required ListThree<TodoItem> todos: we can do something like this but then the problem arises that these todo's cannot be completed because this listThree of to-do name has no concept of done or undone todo. it just holds basically what is a validated string of a todo name but we need to provide a way to complete or uncomplete the given todo. that's why we are going to create yet another entity and this one is going to be called todo_item.dart.

## domain/notes/todo_item.dart
~~~dart
  const factory TodoItem({
    required UniqueId id,
    required TodoName name,
    required bool done,
  }) = _TodoItem;
~~~

>we are going to provide some helper factories and also getters or other properties which are going to allow us to write code more quickly in the future. in the future parts that is so the first thing we are going to add to our entities are empty factories because think about it. when you open up a new screen that you want to create a new note you need to have an empty note body a certain default note color will be selected and you are going to have zero to do items added to the note so that's going to be sort of the empty state.
## domain/notes/note.dart
~~~dart
  factory Note.empty() => Note(
        id: UniqueId(),
        body: NoteBody(''),
        color: NoteColor(NoteColor.predefinedColors[0]),
        todos: ListThree(emptyList()),
      );
~~~

>similar to this we also want to have an empty factory for whenever we add a new todo_item inside the note creation form in the ui. so in order to simplify the process of creating a new empty todo again we are going to have factory todo_item.empty and we're just going to instantiate a to do item.
## domain/notes/todo_item.dart
~~~dart
  factory TodoItem.empty() => TodoItem(
        id: UniqueId(),
        name: TodoName(''),
        done: false,
      );
~~~

>when i open up the app and open up the note creation form like this and i hit this check mark to basically add the note to the database we are going to get an error message under the note body saying that it cannot be empty and the same would go also for the to-do's and we cannot add more than three to-do's and so on so that's all nice but the thing is that these error messages are coming from the individual value objects for example from the note body value object, from the list 3 value object and also from the todo name value object but how can we validate the whole entity at once? if all are valid then the whole entity is valid if just one value object is invalid that means that the whole entity is also invalid.

>we just cannot even see the invalid node in our ui and technically what we could do then is create some sort of a reporting system where if we click on this invalid node in the ui it would open up some support client or for example it would send an email to the application support team with the id of the failed note. Let's implements:

## domain/notes/todo_item.dart
~~~dart
const TodoItem._(); //1st need a empty constructor
//check only name is an error or not
  Option<ValueFailure<dynamic>> get failureOption {
    return name.value.fold(some, (r) => none());
    // (f) => some(f)   shortend to some
  }
}
//return some if any error
//return none if no error
~~~

## domain/notes/note.dart
>Similar for note.dart
~~~dart
  Option<ValueFailure<dynamic>> get failureOption {
    return body.failureOrUnit //take all kinds off failure and return one type
        .andThen<Unit>(todos.failureOrUnit)
        .andThen<Unit>(
          todos
              .getOrCrash()
              .map((todoItem) => todoItem.failureOption)
              .filter((o) => o.isSome())
              .getOrElse(0, (_) => none())
              //checking atleast 1 element. if not then none if yes then it's valid
              .fold(() => right(unit), (l) => left(l as ValueFailure<String>)),
        )
        .map((r) => null)
        .fold((f) => some(f as ValueFailure<String>), (r) => none());
  }
~~~

>**andThen<Unit>(todos.failureOrUnit)**: just like flat map if the first validated value is invalid so it's left then the whole chain will be basically just short circuited it will be skipped and the whole entity will be thus immediately evaluated as invalid. so inside this andthen we want to provide the next thing which should be validated.

## domain/core/value_objects/dart
~~~dart
  Either<ValueFailure<dynamic>, Unit> get failureOrUnit {
    return value.fold(
      (l) => Left(l),
      (r) => const Right(unit),
    );
  }
~~~
>just like that we have gotten rid of all of the things which prevent us from using different value objects in one validation chain so now we can go ahead into the note.dart and instead of saying body.value we are going to say body dot failure or unit.

>**filter((o) => o.isSome())** : so we are going to filter by a predicate which will say that the failure option o is sum. so what this is going to do is that we're going to have only the failed to do items in this kt list returned by the filter method.

>**getOrElse(0, (_) => none())**: we want to say get or else on the index of zero and if we cannot get this zero index meaning that there is no element present then we're going to return none okay so what are we doing here with this get or else well if we cannot get the zeroth item from this filtered list which should contain only the failed todo items that means that there are no failed to do items present which in its logical conclusion means that all of the to do items are valid.

>**fold(() => right(unit), (l) => left(l as ValueFailure<String>))**: well we can again use our trusty fold method and if the none value arrives that means that our whole list of to-do items holds only valid to do items. so we are going to return right unit. why write unit? well because our failure or units have the right value being a unit that's why we return right unit and in another case that is when at least one element inside the list of to-do items is invalid we are going to return that value failure so left and let's rename the a parameter to f so left f.
## End of T13


# Data Transfer Objects(T14)
>now comes the time to create the interface of the I node repository or of the node repository which will live in the domain layer it's going to be completely independent of firebase or whatever else you are using to store data.

>then the implementation of the repository which we are about to define an interface of is going to be in the infrastructure layer.

>we are not going to use a future to watch notes but instead we are going to use a stream. streams are asynchronous beings which operate over time. we can listen to streams and they are going to deliver us new results over time in this case whenever the notes are updated on firestore we're going to get new results from this watch notes method.
## domain/notes/i_note_repository.dart
~~~dart
abstract class INoteRepository {
  //watch notes
  Stream<Either<NoteFailure, KtList<Note>>> watchAll();
  //watch uncompleted notes
  Stream<Either<NoteFailure, KtList<Note>>> watchUncompleted();
  //CUD
  //CUD doesn't have return type. Instead void use Unit
  Future<Either<NoteFailure, Unit>> create(Note note);
  Future<Either<NoteFailure, Unit>> update(Note note);
  Future<Either<NoteFailure, Unit>> delete(Note note);
}
~~~

>To handle failure:
## domain/notes/note_failure.dart
~~~dart
@freezed
abstract class NoteFailure with _$NoteFailure {
  const factory NoteFailure.unexpected() = _Unexpected;
  const factory NoteFailure.insufficientPermission() = _InsufficientPermission;
  const factory NoteFailure.unableToUpdate() = _UnableToUpdate;
}
~~~

>the nodes domain layer all done and we can now move over to the next layer which is going to be the infrastructure layer. 

>this file will hold both the to-do item data transfer object and also the note data transfer objects.

## infrustructure/notes/note_dtos.dart
~~~dart
@freezed
abstract class TodoItemDto implements _$TodoItemDto {
  const factory TodoItemDto({
    required String? id,
    required String? name,
    required bool? done,
  }) = _TodoItemDto;

  factory TodoItemDto.fromJson(Map<String, dynamic> json) =>
      _$TodoItemDtoFromJson(json);

  factory TodoItemDto.fromDomain(TodoItem todoItem) {
    return TodoItemDto(
        id: todoItem.id.getOrCrash(),
        name: todoItem.name.getOrCrash(),
        done: todoItem.done);
  }

  const TodoItemDto._();
  TodoItem toDomain() {
    return TodoItem(
      id: UniqueId.fromUniqueString(id!),
      name: TodoName(name!),
      done: done!,
    );
  }
}
~~~
>we want to keep our domain layer completely independent from outside influence all of the mapping is going to happen here inside the DTO and nothing will go into the entity. so here we want to define both the from domain factory so let's do it right now. factory to-do item DTO from domain and just like it says in the name we are going to use this factory to construct the data transfer object from an entity which is present inside the domain layer.

>**TodoItem toDomain():** whenever we receive a to-do item from fire store or from some other source of data we are going to receive it as simple data as string and boolean and then the other layers of our app are going to want to communicate in terms of to-do item entity not to-do item DTO and this conversion from DTO to domain entity is going to happen inside - domain method which is going to return todo item. 

>Let's create NoteDto:

~~~dart
@freezed
abstract class NoteDto implements _$NoteDto {
  const factory NoteDto({
    @JsonKey(ignore: true) String? id,
    @required String? body,
    @required int? color,
    @required List<TodoItemDto?>? todos,
    @ServerTimeStampConverter() required FieldValue? serverTimeStamp,
  }) = _NoteDto;

  factory NoteDto.fromDomain(Note note) {
    return NoteDto(
      id: note.id.getOrCrash(),
      body: note.body.getOrCrash(),
      color: note.color.getOrCrash().value,
      todos: note.todos
          .getOrCrash()
          .map(
            (todoItem) => TodoItemDto.fromDomain(todoItem),
          )
          .asList(),
      serverTimeStamp: FieldValue.serverTimestamp(),
    );
  }

  factory NoteDto.fromFirestore(DocumentSnapshot doc) {
    final data = Map<String, dynamic>.from(doc.data()! as Map<String, dynamic>);
    return NoteDto.fromJson(data).copyWith(id: doc.id);
  }

  factory NoteDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDtoFromJson(json);

  const NoteDto._();
  Note toDomain() {
    return Note(
      id: UniqueId.fromUniqueString(id!),
      body: NoteBody(body!),
      color: NoteColor(Color(color!)),
      todos: ListThree(todos!.map((dto) => dto!.toDomain()).toImmutableList()),
    );
  }
}
~~~

>**@JsonKey(ignore: true) String? id:** we do not want to store the ID along with all of the other fields. we are going to make it be ignored by the JSON conversion. so we are going to annotate this ID with a JSON key and we are going to say that ignore is true and now when we provide a from JSON factory.

>**todos: ListThree(todos!.map((dto) => dto!.toDomain()).toImmutableList()):** we have to do is which are going to be a list three to duce that map and we want to map our to-do item data transfer objects into entities so this DT o is of type to-do item detail and we want to call to domain on the hat which is the function we have implemented a while ago in this part so now that we have entity representations of our to-do item details now we want to convert this simple list or the simple iterable writer into a katie list which our list three value object expects so we are going to say something like two immutable list which is an extension provided by the katie dart package.

>**factory NoteDto.fromFirestore(DocumentSnapshot doc):**in addition to from json this note DTO which is going to be stored inside fire store will also greatly benefit from having a from fire store method. it will be very similar to from json. it's actually going to use from json but it will know about one more thing about the ID of the firestore document and again ID of a fire store document is not something we are going to have inside this map string dynamic json coming from fire store that's because ID is not a part of the data and itself it's just a separate identifier.
## End of T14
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~





- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)


