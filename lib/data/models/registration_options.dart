enum AccountType {
  universityStudent('طالب جامعي'),
  graduate('خريج'),
  otherIndividual('فرد آخر'),
  provider('مزوّد خدمة');

  const AccountType(this.label);
  final String label;
}

enum RegistrationMethod { emailPassword }

enum ProviderType {
  education('تعليم / دورات'),
  opportunities('وظائف / تدريب'),
  printing('مكتبة / طباعة'),
  privateTutor('مدرس خاص / مدرّب');

  const ProviderType(this.label);
  final String label;
}

const phoneCountryCodes = <String>['+970', '+972'];
