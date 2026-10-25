# Authentication integration

This branch ports the working Firebase registration/login flow into the team's
feature structure. It keeps the existing Firebase project, native application
identifiers, Cairo fonts, theme and provider/status features.

## Entry point and ownership

`main.dart` registers `AuthRepository` and opens `AuthGate`.

- `presentation/features/auth`: login, registration, Google password setup,
  verification link, recovery, consent screens and GetX state.
- `presentation/features/onboarding`: welcome and the three introduction pages.
- `presentation/features/profile`: account summary and editing entry point.
- `data/models/user_profile.dart`: typed profile with `fromJson` / `toJson`.
- `data/repositories/auth_repository.dart`: shared authentication contract and
  Firebase implementation. No direct Firebase calls in the feature screens or
  controllers.
- `data/repositories/profile_repository.dart`: reads/writes `users/{uid}`.
- `data/repositories/session_preferences.dart`: introduction completion and the
  optional remembered email. Passwords and tokens are never stored here.

Screens use `Get.to`, `Get.off`, `Get.offAll` and `Get.back`; there are no named
routes. Controllers are scoped to their screens and close their timers,
subscriptions and text controllers on disposal.

## Behavior

- The welcome/introduction flow appears until first completion or skipping.
- Firebase sessions persist on Android and web until explicit sign-out.
- Remember me saves only the email after successful authentication. It pre-fills
  the next login after sign-out and never fills a password. A successful login
  without this option clears the saved email.
- Email registration creates a Firebase Auth account, then the user profile.
  Unverified accounts stay at verification. Firebase emails contain a link, not
  a numeric OTP. The screen checks every five seconds while active and on resume.
- Google authentication uses Firebase credentials. A Google account without a
  password completes its profile and links a password to the same Firebase uid.
- Recovery sends Firebase's email reset link. SMS recovery and Apple login
  remain unavailable; the interface does not pretend they work.
- Phone entry supports +970 and +972, defaults to +970, and requires nine digits
  after the prefix.

## Shared design

The repository currently stores its design system in `presentation/shared`,
despite the README tree mentioning `core`. This integration uses those existing
`AppColors`, `AppSizes`, `AppTextStyles`, `AppTheme` and `AppPrimaryButton`.

`AppTextField`, `AppTopBar` and `AppSectionHeader` listed in README are absent in
this checkout. The registration field stays within `auth/widgets` until the team
provides the shared field API. Auth presentation helpers are reused by onboarding
and profile without copying them into those features.

One existing shared file changes: `AppPrimaryButton` wraps its label in Flexible
so long Arabic labels fit narrow screens. The constructor and visual design are
unchanged. Review this small shared change with the team before merging.

## Firestore contract and provider integration

`users/{uid}` stores identity/profile data: `uid`, `email`, `name`, `phone`,
`countryCode`, `accountType`, `providerType`, `university`, `specialization`,
`interests`, `field`, `location`, `portfolio`, and server `updatedAt`.

`accountType` is `individual` or `provider`. Provider types are `education`,
`opportunities`, `printing`, and `privateTutor`.

The providers feature independently reads business data from
`serviceProviders/{uid}`. Authentication does not create business records,
grant verification/administrative roles, or write that feature's fields. The
post-login landing page is the account/profile screen. Agree on business record
creation and destination routing with the provider/discovery owners before
connecting their dashboards. Existing provider screens/controllers are untouched.

Existing server rules must enforce ownership, input validation, and verified
email access where appropriate. This branch does not deploy or replace project
rules because that could break other features' collections.

## Native setup

The checked-in `firebase_options.dart` remains the source for the team's Android,
iOS and web app registrations. Do not copy the standalone app's native config:
its package ids and Firebase app ids differ.

Matching Android and iOS SDK configuration files were downloaded locally from
the existing Firebase app registrations. They remain ignored by Git; CI already
supplies Android configuration through its secret. This Windows machine's debug
SHA-1 and SHA-256 were registered for the team's Android app. Other developers
and release/CI builds must register their own signing-key fingerprints.

`ios/Runner/Info.plist` now includes the matching Google client/server IDs and
reversed-client-id callback scheme. Validate iOS with Xcode on macOS; it cannot
be built on this Windows host. Neither mobile Google login nor a production
login is exercised by the mock test suite.

On Windows, if `flutter pub get` reports missing symlink support, enable Windows
Developer Mode and run it again. Dependencies were resolved locally and tests
can be run with `flutter test --no-pub`; this does not replace the OS setup for
normal development.

## Validation

```sh
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --web-port=8080
```

Tests under `test/auth` use `FakeAuthRepository`; they do not connect to production
Firebase or create real users. The profile model serialization and repository
token refresh are tested separately. Consent text is marked as a draft for the
team's review. No Firebase server settings or deployed data are changed by tests.
