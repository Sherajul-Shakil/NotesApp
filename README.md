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

This is the part of an app which doesn't care if you switch from Firebase to a REST API or if you change your mind and you migrate from the Hive database to Moor. Because domain doesn't depend on anything external, changes to such implementation details don't affect it. On the other hand, all the other layers do depend on domain.

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



~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~
~~~dart

~~~




- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)


