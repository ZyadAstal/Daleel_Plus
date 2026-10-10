**PRODUCT REQUIREMENT DOCUMENT**

**Daleel+ PLATFORM**

Your Guide to What’s Next.

MVP Version: 1.0

Prepared By:  Daleel+ Team

Last update: 8 October 2026

Status:  Approved & Updated

# 1.  Project Overview

Daleel+ is a mobile application designed to provide a centralized platform for discovering educational, training, library, printing, job, and training opportunities. The application allows users to explore available services and opportunities through organized categories and provides features for searching, filtering, viewing details, comparing options, and interacting with relevant service or opportunity providers.

The system is intended to serve university students, recent graduates, and individuals seeking educational and professional opportunities. Khatwa aims to provide an organized and accessible digital platform that helps users explore relevant options according to their needs.

# 2.  MVP Objectives

The first version delivers a core workflow that enables users to:

- **Create and manage accounts** through registration, secure login, authentication, and basic profile management.

- **Explore services and opportunities** organized into the platform’s main categories: Education and Courses, Libraries and Printing, Jobs and Training Opportunities, and Private Tutors.

- **Search and filter available services and opportunities** using keywords and relevant criteria such as category, location, type, and other applicable attributes.

- **View detailed information** about available services, opportunities, and private tutors, including relevant descriptions, locations, contact information, and applicable details.

- **Compare eligible services and opportunities** based on their available information.

- **Submit and view ratings and reviews** for eligible services to support evaluation based on previous user experiences.

- **Access relevant contact options** for service providers, opportunity providers, and private tutors where applicable.

- **Select locations manually** when searching or filtering without relying on automatic GPS-based location detection.

- **Receive basic notifications** about important updates and events related to services, opportunities, and account activities.

- **Access previously viewed information offline**, while requiring an internet connection to retrieve newly added or updated data.

- **Manage platform data centrally**, including users, services, opportunities, ratings, and related system data.

- **Apply authentication and role-based access control** to protect system operations and resources.

# 3.  User Roles

The MVP supports three main roles. The first role administers the platform, the second role discovers and interacts with available services and opportunities, and the third role provides and manages platform listings according to the assigned provider type.

**SuperAdmin**

**Responsibility:** Platform-wide administration and system management.

- Complete platform oversight and administrative control.

- Manage users and provider accounts.

- Manage the platform’s main categories and provider types.

- Review, approve, edit, and remove service and opportunity listings.

- Manage ratings, reviews, and reported content.

- Manage platform data and system settings.

- Apply role-based access control and manage permissions.

**User (Students)**

**Responsibility:** Discovering, evaluating, and managing relevant services and opportunities.

- Create an account and manage their personal profile.

- Browse available services and opportunities across the platform categories.

- Search and filter services and opportunities using relevant criteria.

- View detailed information about available services, opportunities, and private tutors.

- Compare eligible services and opportunities.

- Submit and view ratings and reviews for eligible services.

- Access available contact options where applicable.

- Select locations manually when searching or filtering.

- Receive basic notifications related to relevant platform activities.

- Access previously viewed information when an internet connection is unavailable.

**Service / Opportunity Provider**

**Responsibility:** Creating and maintaining service or opportunity listings according to the assigned provider type.

- Authenticate and access the provider workspace.

- Create and manage service or opportunity listings according to the assigned provider type.

- Add and maintain relevant information, including name, category, location, description, contact information, and applicable details.

- Edit and update their submitted listings when permitted.

- View the status of their submitted listings.

- Manage listing information according to the permissions associated with their provider type.

**Provider Types:**

- **Education and Courses Provider:** Manages educational services and course-related opportunities.

- **Library and Printing Provider:** Manages library and printing services.

- **Jobs and Training Provider:** Manages job and training opportunities.

- **Private Tutor:** Manages tutoring services and related information.

# 4.  MVP Features

### 4.1 User Authentication & RBAC

Account authentication and access control:

- Google Sign-In or email and password authentication.

- Account registration with account type selection and type-specific registration fields.

- Support for User account types: University Student, Graduate, and Other Individual.

- Support for Provider accounts with the applicable provider type.

- Secure login and logout.

- Password management.

- Role-based access control according to the assigned account type and provider type.

- Restriction of protected features and administrative functions to authorized accounts.

#### 4.1.1 Registration & Account Types

A self-service registration flow allows users and providers to create Daleel+ accounts:

- Users select an applicable account type during registration.

- User account types include University Student, Graduate, and Other Individual.

- Providers select the applicable provider type.

- Google registration retrieves available basic account information and requires completion of the remaining Daleel+ profile information.

- Email registration requires the required account information, including name, email address, phone number with country code, password, and password confirmation.

- The system displays registration and profile fields according to the selected account type or provider type.

#### 4.1.2 Profile & Preferences

Profile management and preference configuration:

- Users can create and manage their profiles, including name, user type, university, specialization, preferred location, and other applicable information.

- Users can select multiple areas of interest from predefined categories or subjects.

- Users can update their profile information, interests, and preferred location after registration.

- The selected interests and preferred location are used to present relevant services and opportunities within applicable sections of the application.

### 4.2 Service & Opportunity Categories

Organization of available services and opportunities:

- Education and Courses.

- Libraries and Printing.

- Jobs and Training Opportunities.

- Private Tutors.

- Provider-specific management functions and information fields are applied according to the selected provider type.

### 4.3 Service & Opportunity Management

Content management for authorized providers:

- Providers can create, view, update, and delete their own service or opportunity records according to their provider type and permissions.

- Providers enter applicable information such as name or title, category, location, description, contact information, and type-specific details.

- Job / Training Providers can manage requirements, deadlines, and opportunity status.

- Providers cannot modify or delete records belonging to other providers.

### 4.4 Search & Filtering

Discovery of available services and opportunities:

- Users can search using keywords.

- Users can filter results according to category, location, type, and other applicable criteria.

- Search and browsing results reflect the selected category, keywords, and filter criteria.

- Users can manually select an area or location without relying on automatic GPS detection.

### 4.5 Service & Opportunity Details

Detailed presentation of available listings:

- Users can view detailed information about selected services, opportunities, and private tutors.

- Details include applicable descriptions, categories, locations, contact information, and other relevant information.

- The current status of applicable opportunities is displayed.

- Opportunities that are no longer available or have ended are identified.

### 4.6 Comparison

Structured comparison of eligible listings:

- Users can select eligible services and opportunities for comparison.

- Selected records are displayed in a structured comparison view based on their available information.

### 4.7 Ratings & Reviews

User evaluation of eligible services:

- Eligible authenticated users can submit ratings and reviews according to the defined rating rules.

- Users can view ratings and reviews associated with eligible services.

- Users can manage their own submitted ratings and reviews.

- Users cannot modify or delete reviews submitted by other users.

### 4.8 Contact Options

Provider contact access:

- Users can access applicable contact options for service providers, opportunity providers, and private tutors.

- Contact options are based on the contact information made available by each provider.

### 4.9 Notification Management

Basic in-app notification system:

- Authenticated users can access a notification center.

- Notifications cover important updates related to accounts, services, opportunities, ratings, and other applicable system activities.

- Users can identify read and unread notifications.

- Users can access the information associated with applicable notifications.

### 4.10 Offline Data Access

Access to previously viewed information during connectivity loss:

- Users can view previously accessed and locally stored information when an internet connection is unavailable.

- Newly added or updated services and opportunities require an active internet connection to be retrieved.

- The system indicates when displayed information may not reflect the latest available data because it was accessed while offline.

### 4.11 Administration & Access Control

Platform-wide administration:

- The System Administrator can view, update, activate, restrict, and remove user and provider accounts according to administrative permissions.

- The System Administrator can manage service and opportunity categories.

- The System Administrator can manage required system configuration data.

- The System Administrator can review and manage inappropriate or reported services, opportunities, ratings, and reviews.

- Users and providers cannot access administrative functions or data outside their assigned permissions.

# 5.  Features Not Included in the MVP

The following features and services are excluded from the MVP release of Daleel+:

- **Technology and Maintenance Services:** Technology support, device maintenance, computer and mobile repair, and other technical maintenance services.

- **Scholarships and Additional Opportunities:** Scholarships, educational grants, competitions, and other opportunity types beyond the defined job and training opportunities.

- **GPS-Based Location Detection:** Automatic location detection or tracking using GPS.

- **Integrated Maps and Distance Calculation:** Map-based navigation, distance calculation, and route guidance between users and available services or opportunities.

- **Online Payment Integration:** Online payments, payment gateways, and financial transactions through the application.

- **In-App Chat and Real-Time Messaging:** Direct messaging, live chat, and real-time communication between users and service or opportunity providers.

- **Advanced Notification Systems:** Scheduled notifications, advanced notification customization, and other notification capabilities beyond the basic in-app notification system.

- **Advanced Artificial Intelligence Features:** AI-based personalized recommendations, intelligent matching, predictive analysis, and other advanced AI capabilities.

- **Advanced Provider and Administrative Dashboards:** Advanced analytics, reporting, monitoring, and management dashboards beyond the basic administrative functions required for the MVP.

- **Provider Subscription and Monetization:** Paid subscriptions, commissions, advertising management, and other provider monetization features.

- **Advanced Offline Synchronization:** Real-time synchronization, conflict resolution, and automatic synchronization of newly updated data while the application is offline.

- **iOS Support:** Development and release for iOS devices. The initial release is limited to the Android platform.

- **Third-Party Booking System Integration:** Integration with external booking, reservation, or appointment-management systems.

# 6.  Technical Stack

| **Component** | **Technology** | **Role in Architecture** |
| --- | --- | --- |
| **Backend** | ASP.NET Core Web API | Core business logic, authentication, role-based access control, service and opportunity management, and API layer |
| **Backend Services** | FastAPI | Backend services for selected system functions and business logic, integrated with the ASP.NET Core backend |
| **Mobile** | Flutter | Cross-platform Android mobile application for users and service / opportunity providers, communicating with the backend through APIs |
| **Database** | SQL Server | Structured storage for user accounts, profiles, services, opportunities, ratings, reviews, and related system data |
| **Notifications** | Firebase Cloud Messaging (FCM) | Delivery of in-app notifications for important account, service, opportunity, and system updates |
| **Authentication** | Google Sign-In & ASP.NET Core Authentication | User registration, authentication, password management, and secure account access |

# 7.  MVP User Flows

**User (Students)**

- Create an account using Google Sign-In or email and password.

- Select the applicable user account type and complete the required profile information.

- Select areas of interest and a preferred location.

- Browse available services and opportunities across the main categories.

- Search and filter services and opportunities using keywords, category, location, type, and other applicable criteria.

- View detailed information about a selected service, opportunity, or private tutor.

- Compare eligible services and opportunities based on their available information.

- Submit and view ratings and reviews for eligible services.

- Access available contact options for service and opportunity providers.

- Receive and manage in-app notifications related to relevant account and system activities.

- View previously accessed information when an internet connection is unavailable.

**Service / Opportunity Provider**

- Create an account and select the applicable provider type.

- Complete the provider profile and required information.

- Create a service or opportunity listing with its applicable details.

- View, update, and delete their own listings according to their provider type and permissions.

- Manage provider-specific information and, for Job / Training Providers, requirements, deadlines, and opportunity status.

- View the status and available information of their submitted listings.

**SuperAdmin**

- Sign in to the administrative interface.

- Manage user and provider accounts, including activation, restriction, updating, and removal.

- Manage service and opportunity categories and required system configuration data.

- Review and manage inappropriate or reported services, opportunities, ratings, and reviews.

- Manage platform data and administrative access according to assigned permissions.

# 8.  MVP Success Criteria

The MVP is successful when:

- **SuperAdmin:** can manage user and provider accounts, manage service and opportunity categories, and review and manage reported or inappropriate platform content.

- **User:** can create an account, complete their profile and preferences, discover available services and opportunities, and access relevant information through the platform.

- **Service / Opportunity Provider:** can create and manage their own service or opportunity listings according to their assigned provider type and permissions.

- **Search & Discovery:** users can search and filter services and opportunities using keywords, categories, locations, types, and other applicable criteria.

- **Service & Opportunity Details:** users can view organized and detailed information about available services, opportunities, and private tutors, including applicable status and contact information.

- **Comparison:** users can select eligible services and opportunities and compare them using a structured view based on their available information.

- **Ratings & Reviews:** eligible users can submit and manage their own ratings and reviews, while viewing ratings and reviews associated with eligible services.

- **Location Selection:** users can manually select locations when searching or filtering without requiring GPS-based location detection.

- **Notifications:** authenticated users can access relevant in-app notifications, distinguish unread notifications, and open the information associated with applicable notifications.

- **Offline Access:** users can view previously accessed and locally stored information when offline and are clearly informed when displayed information may not reflect the latest available data.

- **Access Control:** users, providers, and the SuperAdmin can access only the features and data permitted by their assigned roles and provider types.

# 9.  Future Development

The following features may be considered for future versions of Daleel+:

- **Expanded Service Categories:** Adding additional service and opportunity categories beyond the four categories included in the MVP, such as scholarships, competitions, and technology-related services.

- **Advanced AI Features:** Introducing personalized recommendations, intelligent matching, predictive analysis, and other AI-powered capabilities.

- **Integrated Maps & Location Services:** Adding map-based navigation, automatic location detection, distance calculation, and route guidance.

- **Online Payments:** Supporting online payment gateways and financial transactions within the platform.

- **In-App Communication:** Introducing direct messaging, live chat, and real-time communication between users and service or opportunity providers.

- **Advanced Notifications:** Supporting scheduled notifications, advanced notification customization, and additional notification delivery mechanisms.

- **Advanced Provider & Administrative Dashboards:** Providing analytics, reporting, monitoring, and advanced management tools for providers and administrators.

- **Provider Monetization:** Introducing provider subscriptions, commissions, advertising, and other monetization models.

- **Advanced Offline Synchronization:** Supporting automatic synchronization, conflict resolution, and more advanced offline data management.

- **Third-Party Booking Integration:** Integrating external booking, reservation, and appointment-management systems.

- **iOS Support:** Extending the application to iOS devices in addition to the initial Android release.
