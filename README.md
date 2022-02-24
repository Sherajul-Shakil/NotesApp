# Notes app using firebase and BLOC in domain driven design.

Runnig projecrt.

# The project we will build

- Real-time Firestore data Streams
- Extensive data validation for a rich user experience
- Google & email + password authentication
- Reorderable todo lists and much more

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

















- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)


