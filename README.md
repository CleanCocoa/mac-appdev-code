Exploring Mac App Development Strategies
========================================

Example project code for the book "[Exploring Mac App Development Strategies](http://leanpub.com/develop-mac-apps-clean-architecture-swift)". Part of the [Clean Cocoa Project](http://cleancocoa.com/).

## The App

There are 2 app targets in this project:

1. `DDDViewDataExample` is the original application which I develop in the book.
2. `CoreDataOnly` is the result of the 4th part of the book, where I remove the separation of Core Data objects and Domain Model entities.

_Note:_ This repository contains two other branches for historic reason: `core-data-only` and `core-data-ui`. They exist to show how the changes were applied.

The application itself won't be very useful; it's just the result of what I teach in the book and not a piece of software you want to use in your day-to-day life. So the real star is the code and its organization.

### Project Groups

These are the project groups that correspond to layers in the application architecture:

* **Infrastructure** hosts the database access.
* **Domain** is where the business logic and the entities reside; it's supposed to be relatively independent from the actual app, but the `CoreDataOnly` example deviates from that.
* **Application** is glue-code that makes the app run. It's where the `AppDelegate` lives and other orchestrating service objects do their job. The real meat is pushed into Domain and Infrastructure.
* **User Interface** is everything AppKit-related, with Nibs and view controllers and all.

## License

Copyright (c) 2014--2016 Christian Tietze.

The code is distributed under The MIT License (MIT). See the `LICENSE` file for details.

