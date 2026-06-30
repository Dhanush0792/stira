# TESTING

## Frameworks
- `flutter_test`: The standard testing framework for Flutter applications used primarily for unit and widget testing.

## Strategy
- The separation of pure logic (in `lib/core/` and engines) from the UI components allows for robust unit testing of the business logic independently of Riverpod or Flutter rendering.
- State notifiers and services can be tested with mocked dependencies.
