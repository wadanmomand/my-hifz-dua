import 'package:flutter/widgets.dart';

/// Supported UI languages. Full trilingual EN/UR/AR with RTL (locked 2026-10-12).
enum KidsLang { en, ur, ar }

extension KidsLangX on KidsLang {
  String get code => switch (this) {
        KidsLang.en => 'en',
        KidsLang.ur => 'ur',
        KidsLang.ar => 'ar',
      };

  TextDirection get direction =>
      this == KidsLang.en ? TextDirection.ltr : TextDirection.rtl;

  String get label => switch (this) {
        KidsLang.en => 'English',
        KidsLang.ur => 'اردو',
        KidsLang.ar => 'العربية',
      };
}

/// Minimal string table. Phase 1 covers shell + engine-facing strings;
/// lesson content ships its own trilingual fields in JSON.
class KidsStrings {
  final KidsLang lang;
  const KidsStrings(this.lang);

  static const _t = <String, Map<KidsLang, String>>{
    'appName': {
      KidsLang.en: 'My Hifz Duas',
      KidsLang.ur: 'میری حفظ دعائیں',
      KidsLang.ar: 'أدعيتي المحفوظة',
    },
    'start': {
      KidsLang.en: 'Start',
      KidsLang.ur: 'شروع کریں',
      KidsLang.ar: 'ابدأ',
    },
    'continue': {
      KidsLang.en: 'Continue',
      KidsLang.ur: 'جاری رکھیں',
      KidsLang.ar: 'تابع',
    },
    'listen': {
      KidsLang.en: 'Listen',
      KidsLang.ur: 'سنیں',
      KidsLang.ar: 'استمع',
    },
    'repeatAfterMe': {
      KidsLang.en: 'Repeat after me',
      KidsLang.ur: 'میرے بعد دہرائیں',
      KidsLang.ar: 'ردد بعدي',
    },
    'wellDone': {
      KidsLang.en: 'Well done!',
      KidsLang.ur: 'شاباش!',
      KidsLang.ar: 'أحسنت!',
    },
    'tryAgain': {
      KidsLang.en: 'Try again',
      KidsLang.ur: 'دوبارہ کوشش کریں',
      KidsLang.ar: 'حاول مجددًا',
    },
    'stars': {
      KidsLang.en: 'Stars',
      KidsLang.ur: 'ستارے',
      KidsLang.ar: 'نجوم',
    },
    'settings': {
      KidsLang.en: 'Settings',
      KidsLang.ur: 'ترتیبات',
      KidsLang.ar: 'الإعدادات',
    },
    'ayahOfTheDay': {
      KidsLang.en: 'Ayah of the Day',
      KidsLang.ur: 'آج کی آیت',
      KidsLang.ar: 'آية اليوم',
    },
    'storyMap': {
      KidsLang.en: 'Story Map',
      KidsLang.ur: 'کہانی کا نقشہ',
      KidsLang.ar: 'خريطة القصة',
    },
    'tapToPlay': {
      KidsLang.en: 'Tap to play the story',
      KidsLang.ur: 'کہانی شروع کرنے کے لیے دبائیں',
      KidsLang.ar: 'اضغط لبدء القصة',
    },
    'listenStory': {
      KidsLang.en: 'Listen',
      KidsLang.ur: 'سنو',
      KidsLang.ar: 'استمع',
    },
    'nextScene': {
      KidsLang.en: 'Next',
      KidsLang.ur: 'آگے',
      KidsLang.ar: 'التالي',
    },
    'chooseYourPath': {
      KidsLang.en: 'What would YOU do?',
      KidsLang.ur: 'تم کیا کرو گے؟',
      KidsLang.ar: 'ماذا ستفعل أنت؟',
    },
    'goodChoice': {
      KidsLang.en: 'Good choice!',
      KidsLang.ur: 'اچھا انتخاب!',
      KidsLang.ar: 'اختيار جميل!',
    },
    'quizTime': {
      KidsLang.en: 'Quiz Time!',
      KidsLang.ur: 'کوئز کا وقت!',
      KidsLang.ar: 'وقت الاختبار!',
    },
    'duaTime': {
      KidsLang.en: 'Dua Time',
      KidsLang.ur: 'دعا کا وقت',
      KidsLang.ar: 'وقت الدعاء',
    },
    'moralOfStory': {
      KidsLang.en: 'Moral of the Story',
      KidsLang.ur: 'کہانی کا سبق',
      KidsLang.ar: 'عبرة القصة',
    },
    'sources': {
      KidsLang.en: 'From the books of Seerah:',
      KidsLang.ur: 'سیرت کی کتابوں سے:',
      KidsLang.ar: 'من كتب السيرة:',
    },
    'episodeComplete': {
      KidsLang.en: 'Story Complete!',
      KidsLang.ur: 'کہانی مکمل!',
      KidsLang.ar: 'اكتملت القصة!',
    },
    'locked': {
      KidsLang.en: 'Finish the previous story to unlock',
      KidsLang.ur: 'کھولنے کے لیے پچھلی کہانی مکمل کرو',
      KidsLang.ar: 'أكمل القصة السابقة لفتحها',
    },
    'xpLabel': {
      KidsLang.en: 'XP',
      KidsLang.ur: 'XP',
      KidsLang.ar: 'XP',
    },
    'duasDone': {
      KidsLang.en: 'duas learned',
      KidsLang.ur: 'duas yaad ki',
      KidsLang.ar: 'أدعية محفوظة',
    },
    'tapToHearMeaning': {
      KidsLang.en: 'Tap a card to hear its meaning.',
      KidsLang.ur: 'Meaning sunne ke liye card par tap karein.',
      KidsLang.ar: 'اضغط على البطاقة لسماع معناها.',
    },
    'markLearned': {
      KidsLang.en: 'I learned this!',
      KidsLang.ur: 'Maine yaad kar li!',
      KidsLang.ar: 'حفظت هذا!',
    },
    'learned': {
      KidsLang.en: 'Learned',
      KidsLang.ur: 'Yaad ho gayi',
      KidsLang.ar: 'محفوظ',
    },
    'playAgain': {
      KidsLang.en: 'Play Again',
      KidsLang.ur: 'Phir Khelo',
      KidsLang.ar: 'العب مجددا',
    },
    'solveToEnter': {
      KidsLang.en: 'Solve this to enter (parents only)',
      KidsLang.ur: 'Andar jane ke liye hal karein (sirf walidain)',
      KidsLang.ar: 'حل هذه المسألة للدخول (للوالدين فقط)',
    },
    'streak': {
      KidsLang.en: 'Day streak',
      KidsLang.ur: 'Lagataar din',
      KidsLang.ar: 'أيام متتالية',
    },
    'narration': {
      KidsLang.en: 'Voice instructions',
      KidsLang.ur: 'Aawaz me hidayat',
      KidsLang.ar: 'التعليمات الصوتية',
    },
    'language': {
      KidsLang.en: 'Language',
      KidsLang.ur: 'Zubaan',
      KidsLang.ar: 'اللغة',
    },
    'progressReset': {
      KidsLang.en: 'Progress has been reset.',
      KidsLang.ur: 'Progress reset ho gayi.',
      KidsLang.ar: 'تمت إعادة تعيين التقدم.',
    },
    'learnDuas': {
      KidsLang.en: 'Learn Duas',
      KidsLang.ur: 'Duaen Seekho',
      KidsLang.ar: 'تعلم الأدعية',
    },
    'matchGame': {
      KidsLang.en: 'Match Game',
      KidsLang.ur: 'Match Khelo',
      KidsLang.ar: 'لعبة المطابقة',
    },
    'easy': {
      KidsLang.en: 'Easy',
      KidsLang.ur: 'Aasan',
      KidsLang.ar: 'سهل',
    },
    'hard': {
      KidsLang.en: 'Hard',
      KidsLang.ur: 'Mushkil',
      KidsLang.ar: 'صعب',
    },
    'flipCards': {
      KidsLang.en: 'Flip the cards, match Arabic with meaning!',
      KidsLang.ur: 'Card paltain, Arabic ko meaning se milain!',
      KidsLang.ar: 'اقلب البطاقات وطابق العربية مع المعنى!',
    },
    'moves': {
      KidsLang.en: 'Moves',
      KidsLang.ur: 'Chaal',
      KidsLang.ar: 'حركات',
    },
    'pairs': {
      KidsLang.en: 'Pairs',
      KidsLang.ur: 'Jore',
      KidsLang.ar: 'أزواج',
    },
    'gameComplete': {
      KidsLang.en: 'Game Complete!',
      KidsLang.ur: 'کھیل مکمل!',
      KidsLang.ar: 'اكتملت اللعبة!',
    },
    'score': {
      KidsLang.en: 'Score',
      KidsLang.ur: 'اسکور',
      KidsLang.ar: 'النتيجة',
    },
    'roundOf': {
      KidsLang.en: 'Round',
      KidsLang.ur: 'راؤنڈ',
      KidsLang.ar: 'جولة',
    },
    'wudu': {
      KidsLang.en: 'Wudu',
      KidsLang.ur: 'وضو',
      KidsLang.ar: 'الوضوء',
    },
    'salah': {
      KidsLang.en: 'Salah',
      KidsLang.ur: 'نماز',
      KidsLang.ar: 'الصلاة',
    },
    'learn': {
      KidsLang.en: 'Learn',
      KidsLang.ur: 'سیکھو',
      KidsLang.ar: 'تعلم',
    },
    'practice': {
      KidsLang.en: 'Practice',
      KidsLang.ur: 'مشق کرو',
      KidsLang.ar: 'تدرب',
    },
    'quiz': {
      KidsLang.en: 'Quiz',
      KidsLang.ur: 'کوئز',
      KidsLang.ar: 'اختبار',
    },
    'stepOf': {
      KidsLang.en: 'Step',
      KidsLang.ur: 'مرحلہ',
      KidsLang.ar: 'خطوة',
    },
    'learnMode': {
      KidsLang.en: 'Learn',
      KidsLang.ur: 'سیکھو',
      KidsLang.ar: 'تعلم',
    },
    'practiceMode': {
      KidsLang.en: 'Practice',
      KidsLang.ur: 'مشق',
      KidsLang.ar: 'تدرب',
    },
    'whatComesNext': {
      KidsLang.en: 'What comes next?',
      KidsLang.ur: 'اگلا مرحلہ کون سا ہے؟',
      KidsLang.ar: 'ما الخطوة التالية؟',
    },
    'listenInstruction': {
      KidsLang.en: 'Listen',
      KidsLang.ur: 'سنو',
      KidsLang.ar: 'استمع',
    },
    'recitation': {
      KidsLang.en: 'Recitation',
      KidsLang.ur: 'تلاوت',
      KidsLang.ar: 'التلاوة',
    },
    'practiceComplete': {
      KidsLang.en: 'Practice Complete!',
      KidsLang.ur: 'مشق مکمل!',
      KidsLang.ar: 'اكتمل التدريب!',
    },
    'learnComplete': {
      KidsLang.en: 'Lesson Complete!',
      KidsLang.ur: 'سبق مکمل!',
      KidsLang.ar: 'اكتمل الدرس!',
    },
    'back': {
      KidsLang.en: 'Back',
      KidsLang.ur: 'پیچھے',
      KidsLang.ar: 'رجوع',
    },
    'quizComplete': {
      KidsLang.en: 'Quiz Complete!',
      KidsLang.ur: 'کوئز مکمل!',
      KidsLang.ar: 'اكتمل الاختبار!',
    },
    'questionOf': {
      KidsLang.en: 'Question',
      KidsLang.ur: 'سوال',
      KidsLang.ar: 'سؤال',
    },
    'whatAfter': {
      KidsLang.en: 'What comes right AFTER this step?',
      KidsLang.ur: 'اس مرحلے کے فوراً بعد کون سا مرحلہ آتا ہے؟',
      KidsLang.ar: 'ما الخطوة التي تأتي بعد هذه مباشرة؟',
    },
    'whatBefore': {
      KidsLang.en: 'What comes right BEFORE this step?',
      KidsLang.ur: 'اس مرحلے سے فوراً پہلے کون سا مرحلہ آتا ہے؟',
      KidsLang.ar: 'ما الخطوة التي تأتي قبل هذه مباشرة؟',
    },
    'forParents': {
      KidsLang.en: 'Parents',
      KidsLang.ur: 'والدین',
      KidsLang.ar: 'للآباء',
    },
    'parentGate': {
      KidsLang.en: 'Parents only: what is',
      KidsLang.ur: 'صرف والدین: بتائیں',
      KidsLang.ar: 'للآباء فقط: ما ناتج',
    },
    'narrationOn': {
      KidsLang.en: 'Voice Instructions',
      KidsLang.ur: 'آواز کی ہدایات',
      KidsLang.ar: 'التعليمات الصوتية',
    },
    'dailyReminder': {
      KidsLang.en: 'Daily Practice Reminder',
      KidsLang.ur: 'روزانہ مشق کی یاد دہانی',
      KidsLang.ar: 'تذكير يومي بالتدريب',
    },
    'reminderTitle': {
      KidsLang.en: 'Time to practice!',
      KidsLang.ur: 'مشق کا وقت!',
      KidsLang.ar: 'حان وقت التدريب!',
    },
    'reminderBody': {
      KidsLang.en: 'Open My Hifz Duas and practice your Wudu and Salah.',
      KidsLang.ur: 'میرا نماز ٹرینر کھولو اور وضو اور نماز کی مشق کرو۔',
      KidsLang.ar: 'افتح مدربي للصلاة وتدرب على الوضوء والصلاة.',
    },
    'storyOfTheDay': {
      KidsLang.en: 'Story of the Day',
      KidsLang.ur: 'آج کی کہانی',
      KidsLang.ar: 'قصة اليوم',
    },
    'parentDashboard': {
      KidsLang.en: 'Parent Dashboard',
      KidsLang.ur: 'والدین کا ڈیش بورڈ',
      KidsLang.ar: 'لوحة الوالدين',
    },
    'totalStars': {
      KidsLang.en: 'Total Stars',
      KidsLang.ur: 'کل ستارے',
      KidsLang.ar: 'مجموع النجوم',
    },
    'episodesDone': {
      KidsLang.en: 'Stories Completed',
      KidsLang.ur: 'مکمل کہانیاں',
      KidsLang.ar: 'القصص المكتملة',
    },
    'dayStreak': {
      KidsLang.en: 'Day Streak',
      KidsLang.ur: 'مسلسل دن',
      KidsLang.ar: 'أيام متتالية',
    },
    'resetProgress': {
      KidsLang.en: 'Reset Progress',
      KidsLang.ur: 'پیش رفت صاف کریں',
      KidsLang.ar: 'إعادة تعيين التقدم',
    },
    'confirmReset': {
      KidsLang.en: 'Delete all stars and XP? This cannot be undone.',
      KidsLang.ur: 'تمام ستارے اور XP حذف کر دیں؟ یہ واپس نہیں ہوگا۔',
      KidsLang.ar: 'حذف كل النجوم والنقاط؟ لا يمكن التراجع.',
    },
    'yes': {
      KidsLang.en: 'Yes',
      KidsLang.ur: 'جی ہاں',
      KidsLang.ar: 'نعم',
    },
    'no': {
      KidsLang.en: 'No',
      KidsLang.ur: 'نہیں',
      KidsLang.ar: 'لا',
    },
    'storyReminder': {
      KidsLang.en: 'Daily Story Reminder',
      KidsLang.ur: 'روزانہ کہانی کی یاددہانی',
      KidsLang.ar: 'تذكير يومي بالقصة',
    },
  };

  String get(String key) => _t[key]?[lang] ?? _t[key]?[KidsLang.en] ?? key;

  /// All keys must exist for all languages (checked in tests).
  @visibleForTesting
  static Map<String, Map<KidsLang, String>> get table => _t;
}
