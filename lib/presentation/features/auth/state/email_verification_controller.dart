import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daleel_plus/data/repositories/auth_repository.dart';
import 'package:daleel_plus/presentation/features/auth/widgets/auth_widgets.dart';

class EmailVerificationController extends GetxController
    with WidgetsBindingObserver {
  void change(VoidCallback action) {
    if (isClosed) return;
    action();
    update();
  }

  Timer? timer;
  Timer? verificationTimer;
  bool checking = false;
  DateTime? resendAt;
  int remaining = 0;
  bool busy = false;
  bool sent = false;
  AuthRepository get service => Get.find<AuthRepository>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    send();
    startVerificationChecks();
  }

  void startVerificationChecks() {
    verificationTimer?.cancel();
    verificationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      check(automatic: true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      check(automatic: true);
      startVerificationChecks();
    } else {
      verificationTimer?.cancel();
    }
  }

  void startCooldown() {
    timer?.cancel();
    remaining = 45;
    resendAt = DateTime.now().add(const Duration(seconds: 45));
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) return;
      final seconds =
          (resendAt!.difference(DateTime.now()).inMilliseconds / 1000).ceil();
      change(() => remaining = seconds.clamp(0, 45));
      if (remaining == 0) timer.cancel();
    });
  }

  Future<void> send() async {
    if (busy || remaining > 0) return;
    change(() {
      busy = true;
    });
    try {
      await service.sendEmailVerification();
      if (isClosed) return;
      change(() {
        sent = true;
        startCooldown();
      });
    } catch (e) {
      if (!isClosed) AppSnackbar.show(authErrorMessage(e));
    } finally {
      if (!isClosed) change(() => busy = false);
    }
  }

  Future<void> check({bool automatic = false}) async {
    if (busy || checking) return;
    checking = true;
    if (!automatic) change(() => busy = true);
    try {
      final verified = await service.refreshEmailVerification();
      if (verified) verificationTimer?.cancel();
      if (!isClosed && !verified && !automatic) {
        AppSnackbar.show(
          'لم يتأكد البريد بعد. افتح الرابط في الرسالة ثم حاول مجددًا.',
        );
      }
    } catch (e) {
      if (!isClosed && !automatic) AppSnackbar.show(authErrorMessage(e));
    } finally {
      checking = false;
      if (!isClosed && !automatic) change(() => busy = false);
    }
  }

  Future<void> signOut() async {
    if (busy) return;
    change(() {
      busy = true;
    });
    try {
      await service.signOut();
    } catch (e) {
      if (!isClosed) AppSnackbar.show(authErrorMessage(e));
    } finally {
      if (!isClosed) change(() => busy = false);
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    verificationTimer?.cancel();
    timer?.cancel();
    super.onClose();
  }
}
