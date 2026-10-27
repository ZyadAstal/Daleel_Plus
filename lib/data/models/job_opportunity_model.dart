class JobOpportunityModel {
  final String id;
  final String title;
  final String companyName;
  final String salary;
  final String workMode;
  final String logoUrl;

  JobOpportunityModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.salary,
    required this.workMode,
    required this.logoUrl,
  });

  factory JobOpportunityModel.fromMap(Map<String, dynamic> map, String documentId) {
    return JobOpportunityModel(
      id: documentId,
      title: map['title'] ?? '',
      companyName: map['company_name'] ?? '',
      salary: map['stipend_salary']?.toString() ?? '',
      workMode: map['work_mode'] ?? '',
      logoUrl: map['logo_url'] ?? '[رابط_شعار_الشركة]',
    );
  }
}