
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_courses.dart';


class CoursesAdminScreen extends StatefulWidget {
  const CoursesAdminScreen({super.key});

  @override
  State<CoursesAdminScreen> createState() =>
      _CoursesAdminScreenState();
}

class _CoursesAdminScreenState
    extends State<CoursesAdminScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  bool uploading = false;
  String status = 'جاهز';
  String? errorMessage;

  Future<int> getCoursesCount() async {
    final result = await db.collection('Courses').count().get();
    return result.count ?? 0;
  }

  Future<void> addCourses() async {
    if (uploading) return;

    setState(() {
      uploading = true;
      status = 'جارٍ إضافة الدورات...';
      errorMessage = null;
    });

    try {
      await SeedCourses.add20Courses();

      if (!mounted) return;

      setState(() {
        status = 'اكتملت عملية الإضافة بنجاح';
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        status = 'فشلت عملية الإضافة';
        errorMessage = '${e.code}: ${e.message ?? ''}';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        status = 'حدث خطأ';
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الدورات'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: db.collection('Courses').snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.school,
                          size: 42,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        const Text('إجمالي الدورات المخزنة'),
                        const SizedBox(height: 8),
                        if (snapshot.hasError)
                          const Text('تعذر جلب عدد الدورات')
                        else
                          Text(
                            snapshot.connectionState ==
                                ConnectionState.waiting
                                ? '...'
                                : '${docs.length}',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const Text('دورة'),
                        TextButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.refresh),
                          label: const Text('تحديث الواجهة'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'إضافة بيانات تجريبية',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'إضافة 20 دورة باستخدام الدالة المجهزة.',
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: SeedCourses.add20Courses,
                          icon: uploading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.cloud_upload),
                          label: Text(
                            uploading
                                ? 'جارٍ الرفع...'
                                : 'إضافة 20 دورة',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('الحالة: $status'),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 8),
                          SelectableText(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'الدورات المسجلة (${docs.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (snapshot.hasError)
                  const Text('تعذر تحميل الدورات. تحقق من الاتصال والصلاحيات.')
                else if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                    docs.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (docs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('لا توجد دورات مسجلة حتى الآن'),
                      ),
                    )
                  else
                    ...docs.map((doc) {
                      final data = doc.data();

                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.menu_book),
                          ),
                          title: Text(
                            data['title']?.toString() ?? 'دورة بلا عنوان',
                          ),
                          subtitle: Text(
                            '${data['category_subtag'] ?? 'غير مصنف'}'
                                ' · ${data['target_level'] ?? 'غير محدد'}',
                          ),
                          trailing: const Icon(Icons.chevron_left),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              showDragHandle: true,
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: ListView(
                                    children: [
                                      Text(
                                        data['title']?.toString() ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      const SizedBox(height: 12),
                                      ...data.entries.map(
                                            (entry) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          child: Text(
                                            '${entry.key}: '
                                                '${entry.value ?? 'غير متوفر'}',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    }),
              ],
            );
          },
        ),
      ),
    );
  }
}
