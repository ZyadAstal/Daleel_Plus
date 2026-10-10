**SOFTWARE REQUIREMENTS**
**SPECIFICATION**

## CHAPTER 1 — INTRODUCTION**
**CHAPTER 2 — SYSTEM SPECIFICATIONS

| **Project Name** | Daleel+ |
| --- | --- |
| **Prepared By** | AlShimaa AlNajjar<br>Zyad AlAstal<br>Mohanned AlHalabi<br>Mohammed AlHalabi<br>Raji Mady |
| **Supervisor** | Eng.Yaseen Zaqout |
| **Organization / University** | Ajyal |
| **Date** | ‏07‏/10‏/2026 |
| **Version** | Version 1.1 |

# TABLE OF CONTENTS

## CHAPTER 1 — INTRODUCTION

1.1 Introduction

1.2 Problem Statement

1.3 Project Objectives

1.3.1 Main Objective

1.3.2 Specific Objectives

1.4 Project Limitations

1.5 Project Scope

1.5.1 In Scope

1.5.2 Out of Scope

1.6 Project Stages

1.7 Tools and Equipment

1.7.1 Hardware

1.7.2 Software Tools

1.8 Frontend Framework Overview

1.8.1 Reasons for Selection

1.8.2 Frontend Responsibilities

1.8.3 Frontend Architecture

1.9 Backend Framework Overview

1.9.1 Reasons for Selection

1.9.2 Backend Responsibilities

1.9.3 Backend Architecture

## CHAPTER 2 — SYSTEM SPECIFICATIONS

2.1 Stakeholder List

2.1.1 Primary Stakeholders

2.1.2 Secondary Stakeholders

2.1.3 Tertiary Stakeholders

2.2 Functional Requirements

2.2.1 Authentication and Account Management

2.2.2 User Profile and Preferences

2.2.3 Service and Opportunity Management

2.2.4 Search and Filtering

2.2.5 Service and Opportunity Details

2.2.6 Comparison

2.2.7 Ratings and Reviews

2.2.8 Contact Options

2.2.9 Manual Location Selection

2.2.10 Notification Management

2.2.11 Offline Data Access

2.2.12 Administration and Access Control

2.3 Non-Functional Requirements

2.3.1 Performance

2.3.2 Security

2.3.3 Usability

2.3.4 Reliability

2.3.5 Availability

2.3.6 Scalability

2.3.7 Maintainability

2.3.8 Portability

2.3.9 Compatibility

2.3.10 Data Integrity and Backup

2.3.11 Accessibility and Localization

2.3.12 Privacy and Data Protection

***CHAPTER 1***

# INTRODUCTION

## 1.1 Introduction

Daleel+ ***is a mobile application designed to provide a centralized platform for discovering educational, training, library, printing, job, and training opportunities. The application allows users to explore available services and opportunities through organized categories and provides features for searching, filtering, viewing details, comparing options, and interacting with relevant service or opportunity providers.***

***The system is intended to serve university students, recent graduates, and individuals seeking educational and professional opportunities. Khatwa aims to provide an organized and accessible digital platform that helps users explore relevant options according to their needs.***

## 1.2 Problem Statement

Currently, university students, recent graduates, and individuals seeking educational and professional opportunities face difficulties in finding reliable and relevant information about educational and training services, libraries and printing services, jobs, and training opportunities. The current process depends on searching through disconnected sources such as social media platforms, messaging groups, and individual service providers, which makes information difficult to find, compare, and verify.

This process may also result in scattered information, outdated opportunities or service details, and additional time and effort spent searching across multiple sources. Therefore, a centralized system is required to organize relevant services and opportunities in one platform and provide users with a more structured way to search, filter, compare, and access the information they need.

## 1.3 Project Objectives

### 1.3.1 Main Objective

***The main objective of the project is to develop a mobile application that helps university students, recent graduates, and individuals seeking educational and professional opportunities to discover and access relevant services and opportunities by providing organized categories, search, filtering, detailed information, comparison, and communication or booking options.***

### 1.3.2 Specific Objectives

- ***Provide an easy-to-use mobile interface for university students, recent graduates, and individuals seeking educational and professional opportunities, achieving a user satisfaction rate of at least 80% during usability testing.***

- ***Organize educational and training services, libraries and printing services, and job and training opportunities into structured categories, reducing the effort required to find relevant information compared with searching across multiple disconnected sources.***

- ***Enable users to search for relevant services and opportunities using keywords and selected criteria, allowing users to find relevant results within an average of 2 minutes during usability testing.***

- ***Provide filtering and comparison features that allow users to evaluate and compare available services and opportunities according to relevant criteria.***

- ***Store and manage user, service, opportunity, and rating data securely according to the project's defined security requirements.***

- ***Allow at least 90% of the target users participating in usability testing to access and explore relevant services and opportunities successfully through the supported mobile platform.***

- ***Provide users with detailed and organized information about available services and opportunities, including relevant contact or booking options where applicable.***

- ***Enable users to submit and view ratings and reviews for eligible services, supporting users in evaluating available options based on previous user experiences.***

## 1.4 Project Limitations

***The project may face the following limitations:***

- ***Limited Development Time: The application must be developed and tested within the available training period, which limits the implementation of additional features beyond the defined MVP.***

- ***Limited Availability of Real Data: The availability of accurate and up-to-date information about services, libraries, printing providers, jobs, and training opportunities may be limited during the development and testing phases.***

- ***Data Freshness During Offline Use: Users can access previously viewed information when an internet connection is unavailable. However, newly added or updated services and opportunities cannot be retrieved until the application reconnects to the internet.***

- ***Limited Platform Support: The initial version of Khatwa focuses on Android devices, which may limit its availability and testing on other mobile platforms such as iOS.***

- ***Limited External Service Integration: The MVP may have limited integration with external services such as payment gateways or third-party booking systems.***

- ***Data Accuracy Limitation: The accuracy and reliability of displayed services and opportunities depend on the correctness and update frequency of the information provided to the system.***

- ***Limited Testing Devices: The team may have access to a limited number of physical devices, which can restrict testing across different screen sizes, hardware specifications, and operating system versions.***

## 1.5 Project Scope

The scope of Daleel+ defines the operational boundaries and functional capabilities included in the first release (MVP). The application provides a centralized platform for discovering and exploring educational and training services, libraries and printing services, jobs and training opportunities, and private tutors through organized categories, search, filtering, comparison, ratings, and relevant contact options.

### 1.5.1 In Scope

To achieve the project objectives, the following features are included in the MVP release:

- **User Profiles & Authentication:** User registration, secure login, authentication, and basic profile management.

- **Service and Opportunity Categories:** Organizing the platform into four main categories: Education and Courses, Libraries and Printing, Jobs and Training Opportunities, and Private Tutors.

- **Service & Opportunity Management:** Adding, viewing, editing, and deleting service and opportunity records according to defined user permissions, including relevant information such as name, category, location, description, contact information, and applicable details.

- **Search & Filtering:** Allowing users to search for services and opportunities using keywords and filter results according to relevant criteria such as category, location, type, and other applicable attributes.

- **Detailed Information:** Providing users with organized and detailed information about available services, opportunities, and private tutors.

- **Comparison:** Allowing users to select and compare eligible services and opportunities based on their available information.

- **Ratings & Reviews:** Allowing users to submit and view ratings and reviews for eligible services, supporting evaluation based on previous user experiences.

- **Contact Options:** Providing relevant contact options for service providers, opportunity providers, and private tutors where applicable.

- **Manual Location Selection:** Allowing users to select an area or location manually when searching or filtering, without relying on automatic GPS-based location detection.

- **Basic Notification System:** Providing users with basic notifications about important updates and events related to services, opportunities, and activities associated with their accounts.

- **Centralized Data Storage:** Storing and managing user, service, opportunity, rating, and related system data in a centralized database.

- **Access Control:** Applying authentication and role-based permissions to control access to system operations and protected resources.

- **Offline Data Access:** Allowing users to view previously accessed information when an internet connection is unavailable, while requiring an internet connection to retrieve newly added or updated data.

### 1.5.2 Out of Scope

The following features and services are excluded from the MVP release of Daleel+:

- **Technology and Maintenance Services:** Services related to technology support, device maintenance, computer and mobile repair, and other technical maintenance services.

- **Scholarships and Additional Opportunities:** Scholarships, educational grants, competitions, and other types of opportunities beyond the defined job and training opportunities.

- **GPS-Based Location Detection:** Automatic location detection and tracking using GPS.

- **Integrated Maps and Distance Calculation:** Map-based navigation, distance calculation, and route guidance between users and available services or opportunities.

- **Online Payment Integration:** Online payments, payment gateways, and financial transactions through the application.

- **In-App Chat and Real-Time Messaging:** Direct messaging, live chat, and real-time communication between users and service or opportunity providers.

- **Advanced Notification Systems:** Complex notification systems, scheduled notifications, advanced notification customization, and other notification features beyond the basic notification system included in the MVP.

- **Advanced Artificial Intelligence Features:** AI-based personalized recommendations, intelligent matching, predictive analysis, and other advanced AI capabilities.

- **Advanced Provider and Administrative Dashboards:** Advanced analytics, reporting, monitoring, and management dashboards beyond the basic administrative functions required for the MVP.

- **Provider Subscription and Monetization:** Paid subscriptions, commissions, advertising management, and other monetization features for service and opportunity providers.

- **Advanced Offline Synchronization:** Real-time synchronization, conflict resolution, and automatic synchronization of newly updated data while the application is offline.

- **iOS Support:** Development and release of the application for iOS devices. The initial release is limited to the Android platform.

- **Third-Party Booking System Integration:** Integration with external booking, reservation, or appointment-management systems.

## 1.6 Project Stages

The Daleel+ project is developed following a structured Software Development Life Cycle (SDLC) consisting of the following phases:

### Stage 1: Idea Selection

Identify the project idea, target users, and central problem based on the difficulty of finding organized and reliable information about educational, training, library, printing, job, and training opportunities through scattered sources.

### Stage 2: Requirement Gathering

Gather requirements by identifying the information and services users need when searching for educational and training services, libraries and printing services, jobs, and training opportunities. The requirements are also defined by analyzing the expected user interactions, including searching, filtering, comparing, viewing details, accessing contact or booking options where applicable, and submitting or viewing ratings and reviews.

### Stage 3: Requirement Analysis

Analyze, categorize, prioritize, and validate the functional and non-functional requirements to establish the boundaries of the Minimum Viable Product (MVP) and ensure that the requirements are achievable within the available project time and resources.

### Stage 4: System Design

Analyze, categorize, prioritize, and validate the functional and non-functional requirements to establish the boundaries of the Minimum Viable Product (MVP) and ensure that the requirements are achievable within the available project time and resources.

### Stage 5: System Development

Implement the mobile application using Flutter, the main backend services using ASP.NET Core, specialized backend services using FastAPI where required, and the database using MySQL. The required APIs, authentication, search and filtering, service and opportunity management, ratings, and other defined MVP features are also implemented.

### Stage 6: System Testing

Perform unit, integration, system, usability, security, performance, and acceptance testing across the mobile application, backend services, database operations, and API integrations.

### Stage 7: System Deployment

Deploy the backend services and MySQL database on the selected hosting environment and prepare the Flutter mobile application for distribution on the supported Android platform.

### Stage 8: Maintenance and Improvement

Correct defects, monitor system operation, improve performance and usability, maintain data accuracy, and implement approved improvements based on testing results and user feedback.

## 1.7 Tools and Equipment

### 1.7.1 Hardware

| **Equipment** | **Purpose** |
| --- | --- |
| Msi GF63 / | System analysis, design, development, and documentation. |
| Mobile Device | Testing the mobile application on a physical device. |
| Cloud Server | Hosting the backend, database, and deployed services. |
| Internet Connection | Development, testing, collaboration, and deployment. |

### 1.7.2 Software Tools

| **Tool** | **Purpose** |
| --- | --- |
| Visual Studio Code | Backend development. |
| Android Studio | Flutter development. |
| Figma | User interface design and prototyping. |
| GitHub | Version control and team collaboration. |
| Postman | API testing and documentation. |
| Slack | Project planning |
| Draw.io | System and database diagrams. |
| ClickUp | Task Management |
| SQL server | Database management and data storage. |

## 1.8 Frontend Framework Overview

**Framework Name:** Flutter

**Framework Version:** 3.47.4

The frontend framework is responsible for presenting the system interface, receiving user input, applying client-side validation, communicating with backend services, and displaying system responses.

### 1.8.1 Reasons for Selection

- ***Modern and Responsive Interfaces: Flutter supports building modern and responsive mobile interfaces for different screen sizes.***

- ***Reusable Components: Flutter provides reusable widgets that help maintain consistency across the application.***

- ***Fast Development Cycle: Hot reload allows developers to quickly test and apply changes during development.***

- ***Good Performance: Flutter provides good application performance through its compiled application architecture.***

- ***Strong Community and Documentation: Flutter has extensive documentation and a large developer community.***

- ***Easy API Integration: Flutter can communicate easily with backend REST APIs to retrieve and submit application data.***

- ***Android Platform Support: Flutter supports the Android platform targeted by the initial version of Khatwati.***

- ***Maintainable Project Structure: Flutter supports organizing the application into reusable and maintainable components.***

### 1.8.2 Frontend Responsibilities

- ***Display System Screens: Display the application's screens, categories, services, opportunities, and related information.***

- ***Receive and Validate User Input: Receive user input and perform client-side validation before sending requests.***

- ***Send Requests to Backend Services: Communicate with backend services through REST APIs to retrieve and submit data.***

- ***Display Returned Data and Errors: Display retrieved information, operation results, validation messages, and errors to users.***

- ***Manage Navigation: Handle navigation between the different screens and sections of the application.***

- ***Manage Application State: Manage the application state and update the interface based on user actions and backend responses.***

- ***Apply Localization and Accessibility Rules: Support the required language and apply appropriate accessibility considerations within the mobile interface.***

### 1.8.3 Frontend Architecture

The frontend will use **Clean Architecture**. Its main components include the presentation layer, domain layer, data layer, API services, models, and reusable UI components. This architecture separates the application into organized layers, making the Flutter application easier to maintain, test, and extend.

## 1.9 Backend Framework Overview

Framework Name: ASP.NET Core, FastAPI

**Framework Version:** [Version Number]

The backend frameworks implement business rules, validate requests, manage data, control access, expose system services, and integrate with external systems.

### 1.9.1 Reasons for Selection

- ***High Performance: Both frameworks provide good performance for developing and handling backend services and API requests.***

- ***Secure Service Development: Both frameworks support implementing secure backend services and applying appropriate security practices.***

- ***Database Integration: Both frameworks support integration with relational databases such as MySQL.***

- ***Authentication and Authorization Support: Both frameworks provide mechanisms for implementing authentication and authorization.***

- ***Scalable Architecture: Both frameworks support building structured backend services that can be extended as the system grows.***

- ***Structured Error Handling: Both frameworks provide mechanisms for handling validation errors, exceptions, and API responses in an organized way.***

- ***Maintainability: Both frameworks support organized code structures that make backend services easier to maintain and modify.***

- ***Third-Party Service Integration: Both frameworks can integrate with external APIs and third-party services when required.***

### 1.9.2 Backend Responsibilities

- ***Manage Accounts and Access Permissions: Manage user accounts, authentication, and access permissions according to user roles.***

- ***Process Business Rules: Apply the business rules related to services, opportunities, ratings, and other system operations.***

- ***Validate Incoming Data: Validate data received from the mobile application before processing or storing it.***

- ***Manage Database Operations: Store, retrieve, update, and manage system data in the database.***

- ***Provide REST APIs: Provide REST APIs for communication between the mobile application and backend services.***

- ***Manage Service and Opportunity Data: Manage information related to educational and training services, libraries, printing services, jobs, and training opportunities.***

- ***Manage Ratings and Reviews: Process and store user ratings and reviews according to the system rules.***

- ***Handle Errors and Exceptions: Handle backend errors and exceptions and return appropriate responses to the mobile application.***

### 1.9.3 Backend Architecture

The backend will use **Clean Architecture**. Its main components include controllers, services, repositories, data models, middleware, API routes, authentication and authorization, database access, and error handling. This architecture separates business logic from infrastructure and external dependencies, making the backend easier to maintain, test, and extend.

***CHAPTER 2***

# SYSTEM SPECIFICATIONS

## 2.1 Stakeholder List

A stakeholder is any individual, group, or organization that affects, is affected by, or has an interest in the outcome of the system. Identifying stakeholders early ensures that requirements reflect real needs and that no affected party is overlooked during design and validation.

Stakeholders of Daleel+ are classified into three levels according to their degree of interaction with the system. Identifying stakeholders early ensures that requirements reflect real needs and that no affected party is overlooked during design and validation.

### 2.1.1 Primary Stakeholders

| **Stakeholder** | **Description** | **Interest in the System** |
| --- | --- | --- |
| User (University Students, Recent Graduates, Job Seekers, and Other Individuals) | Uses the mobile application to search, filter, view, compare, and evaluate available services and opportunities. Users can also access provider contact information and submit or view ratings and reviews where applicable. | Find relevant educational, training, library, printing, job, and other available services and opportunities through an organized platform. |
| Private Tutor / Trainer | Uses the application to create and manage their professional profile and educational or training services, including relevant subjects, areas of expertise, availability, and contact information. | Promote their educational or training services and reach users looking for private tutoring or training. |
| Library / Printing Provider | Uses the application to create and manage information about library and printing services, including available services, operating information, and contact details. . | Present available library and printing services to users and make their services easier to discover. |
| Education / Course Provider | Uses the application to create and manage educational services and courses, including course information, requirements, schedules, and relevant contact details. | Publish educational services and courses and reach users interested in learning opportunities. |
| Job / Training Provider | Uses the application to create and manage job and training opportunities, including descriptions, requirements, deadlines, and opportunity status. | Publish available jobs and training opportunities and reach suitable users. |
| System Administrator | Directly interacts with the administrative functions of the system to manage users, providers, services, opportunities, categories, ratings, and other system data according to defined permissions. | Maintain controlled access, accurate system data, and proper operation of the platform. |

### 2.1.2 Secondary Stakeholders

### 2.1.3 Tertiary Stakeholders

Tertiary stakeholders do not interact with the system but are affected by its outputs or impose external constraints upon it.

## 2.2 Functional Requirements

Functional requirements define the functions and behaviors that Daleel+ shall provide to its users and authorized system roles. The requirements are numbered sequentially according to their order in this specification.

### 2.2.1 Authentication and Account Management

- **FR-001:** The system shall allow users to create an account using Google Sign-In or email and password.

- **FR-002:** The system shall require users to select an account type during registration and display the appropriate registration and profile fields according to the selected account type. User accounts shall include University Student, Graduate, and Other Individual types, while Provider accounts shall allow selection of the applicable provider type.

- **FR-003:** When a user registers using Google Sign-In, the system shall retrieve the available basic account information from the authenticated Google account and shall require the user to complete the additional Daleel+ profile information applicable to the selected account type.

- **FR-004:** When a user registers using email and password, the system shall require the user to provide the required account information, including name, email address, phone number with country code, password, and password confirmation.

- **FR-005:** The system shall support the following provider types: Private Tutor / Trainer, Library / Printing Provider, Education / Course Provider, and Job / Training Provider, with each provider type having access to its applicable management functions and information fields.

- **FR-006:** The system shall authenticate registered users using the selected authentication method and prevent access to protected features when authentication is missing or invalid.

- **FR-007:** The system shall allow authenticated users to securely log out, change their password when applicable, and manage permitted account information.

- **FR-008:** The system shall enforce role-based access control so that each user can access only the features and data permitted for their assigned account type and provider type.

### 2.2.2 User Profile and Preferences

- **FR-009:** The system shall allow users to create and manage their profiles, including their name, user type, university, specialization, preferred location, and other applicable profile information.

- **FR-010:** The system shall allow users to select and update multiple areas of interest from predefined categories or subjects.

- **FR-011:** The system shall use the user's selected interests and preferred location to present relevant services and opportunities within applicable sections of the application.

- **FR-012:** The system shall allow users to update their profile information, interests, and preferred location after completing registration.

### 2.2.3 Service and Opportunity Management

- **FR-013:** The system shall allow authorized providers to create, view, update, and delete their own service or opportunity records according to their provider type and permissions.

- **FR-014:** The system shall provide provider-specific information fields and management functions for Private Tutors / Trainers, Library / Printing Providers, Education / Course Providers, and Job / Training Providers.

- **FR-015:** The system shall require applicable service and opportunity information, including name or title, category, location, description, contact information, and other type-specific details, before allowing a record to be saved or published.

- **FR-016:** The system shall allow Job / Training Providers to manage opportunity-specific information, including requirements, deadlines, and opportunity status.

- **FR-017:** The system shall prevent providers from modifying or deleting services or opportunities belonging to other providers.

### 2.2.4 Search and Filtering

- **FR-018:** The system shall allow users to search for available services and opportunities using keywords.

- **FR-019:** The system shall allow users to filter available services and opportunities using applicable criteria, including category, location, type, and other relevant attributes.

- **FR-020:** The system shall display search and browsing results according to the selected category, search keywords, and filter criteria.

### 2.2.5 Service and Opportunity Details

- **FR-021:** The system shall allow users to view detailed information about selected services, opportunities, and private tutors, including applicable descriptions, categories, locations, contact information, and other relevant details.

- **FR-022:** The system shall display the current status of applicable opportunities and identify opportunities that are no longer available or have ended.

### 2.2.6 Comparison

- **FR-023:** The system shall allow users to select eligible services and opportunities and compare them in a structured view based on their available information.

### 2.2.7 Ratings and Reviews

- **FR-024:** The system shall allow eligible authenticated users to submit ratings and reviews for supported services according to the defined rating rules.

- **FR-025:** The system shall allow users to view ratings and reviews associated with eligible services.

- **FR-026:** The system shall allow users to manage their own submitted ratings and reviews and prevent them from modifying or deleting reviews belonging to other users.

### 2.2.8 Contact Options

- **FR-027:** The system shall provide users with applicable contact options for service providers, opportunity providers, and private tutors using the contact information made available by each provider.

### 2.2.9 Manual Location Selection

- **FR-028:** The system shall allow users to manually select an area or location when searching or filtering services and opportunities and shall use the selected location as a search or filtering criterion without automatically detecting the user's location through GPS.

### 2.2.10 Notification Management

- **FR-029:** The system shall provide authenticated users with an in-app notification center that displays important updates related to their accounts, services, opportunities, ratings, and other applicable system activities.

- **FR-030:** The system shall allow users to identify read and unread notifications and access the information associated with applicable notifications.

### 2.2.11 Offline Data Access

- **FR-031:** The system shall allow users to view previously accessed and locally stored information when an internet connection is unavailable, while requiring an active internet connection to retrieve newly added or updated services and opportunities.

- **FR-032:** The system shall indicate when displayed information may not reflect the latest available data because it was accessed while offline.

### 2.2.12 Administration and Access Control

- **FR-033:** The system shall allow the System Administrator to manage user and provider accounts, including viewing, updating, activating, restricting, or removing accounts according to administrative permissions.

- **FR-034:** The system shall allow the System Administrator to manage service and opportunity categories and other required system configuration data.

- **FR-035:** The system shall allow the System Administrator to review and manage inappropriate or reported services, opportunities, ratings, and reviews according to defined system rules.

- **FR-036:** The system shall prevent users and providers from accessing administrative functions or data outside their assigned permissions.

## 2.3 Non-Functional Requirements

Non-functional requirements define the quality attributes, constraints, and operational characteristics that Daleel+ shall satisfy in addition to its functional capabilities. The requirements are numbered sequentially according to their order within the quality categories below.

### 2.3.1 Performance

The system should remain responsive during normal use and provide reasonable response times for common user operations.

- **NFR-01:** The system shall complete authentication requests and return a response within 3 seconds under normal network conditions.

- **NFR-02:** The system shall load the main application screens and commonly requested service or opportunity information within 3 seconds under normal network conditions.

- **NFR-03:** The system shall return search and filtering results within 3 seconds under normal network conditions for typical data volumes.

- **NFR-04:** The system shall process user requests without blocking the mobile application's interface during operations that require extended processing.

### 2.3.2 Security

The system handles user accounts, contact information, provider information, ratings, and other personal data and shall protect this information from unauthorized access.

- **NFR-05:** The system shall store user passwords using a secure one-way cryptographic hashing algorithm.

- **NFR-06:** The system shall transmit all client-server communication over HTTPS.

- **NFR-07:** The system shall require authentication for access to protected resources and shall validate the authenticated user's permissions before performing protected operations.

- **NFR-08:** The system shall prevent users and providers from accessing or modifying data that belongs to other users or providers unless explicitly authorized by their assigned permissions.

- **NFR-09:** The system shall securely manage authentication credentials and authentication tokens and shall not expose them through application interfaces or logs.

### 2.3.3 Usability

Daleel+ is intended for users with different levels of technical experience and should provide a simple and understandable mobile interface.

- **NFR-10:** The system shall allow a new user to complete the registration process without requiring prior technical training.

- **NFR-11:** The system shall provide clear and understandable messages for validation errors, failed operations, and other user-facing system errors.

- **NFR-12:** The system shall maintain consistent navigation, terminology, layouts, and interaction patterns throughout the mobile application.

- **NFR-13:** The system shall present search, filtering, comparison, service details, and provider management functions in a clear and understandable manner appropriate to the user's role.

### 2.3.4 Reliability

The system shall preserve user data and maintain consistent behavior when operations fail or network connectivity is interrupted.

- **NFR-14:** The system shall prevent incomplete or invalid service, opportunity, user, and provider records from being stored as valid records.

- **NFR-15:** The system shall preserve successfully saved user, service, opportunity, rating, and review data when a subsequent operation fails.

- **NFR-16:** The system shall handle temporary network failures without corrupting or unintentionally deleting locally stored offline data.

- **NFR-17:** The system shall provide a clear indication when an operation has failed and shall allow the user to retry the operation when applicable.

### 2.3.5 Availability

The system should remain available for users during the defined evaluation and demonstration period.

- **NFR-18:** The system shall achieve at least 95% availability during the project evaluation period, excluding planned maintenance.

- **NFR-19:** The mobile application shall allow users to access previously stored offline information when the backend service is temporarily unavailable, where such information exists locally on the device.

### 2.3.6 Scalability

The system architecture should support an increase in users, services, opportunities, and stored data without requiring major structural changes.

- **NFR-20:** The system shall support at least 50 concurrent authenticated users during the project evaluation without significant degradation of normal response times.

- **NFR-21:** The system shall use a structured backend architecture that allows additional services, categories, provider types, and system functions to be added without requiring major changes to existing components.

### 2.3.7 Maintainability

The system shall use a clear and consistent structure to support maintenance and future development by the project team.

- **NFR-22:** The mobile application and backend services shall follow the defined Clean Architecture structure and maintain a clear separation of presentation, business logic, and data access responsibilities.

- **NFR-23:** The system shall follow consistent naming conventions, coding standards, and project structure across its components.

- **NFR-24:** The backend shall provide documented REST APIs with consistent request, response, validation, and error-handling structures.

- **NFR-25:** The system shall maintain documentation for the main system components, database structure, APIs, and deployment configuration required for future maintenance.

### 2.3.8 Portability

The initial release of Daleel+ is intended for Android mobile devices.

- **NFR-26:** The mobile application shall operate on supported Android devices within the minimum Android version defined for the project.

- **NFR-27:** The backend services shall be deployable on a standard server or cloud hosting environment that supports the required runtime and database services.

### 2.3.9 Compatibility

The system components shall communicate through standardized interfaces and maintain compatibility between the mobile application, backend services, and database.

- **NFR-28:** The system shall exchange structured client-server data using JSON over REST APIs.

- **NFR-29:** The system shall use consistent data types, field names, date formats, and response structures across backend APIs.

- **NFR-30:** The mobile application shall remain compatible with the supported Android devices and operating system versions defined for the initial release.

### 2.3.10 Data Integrity and Backup

The system shall maintain the consistency and availability of stored user, service, opportunity, rating, review, and system data.

- **NFR-31:** The system shall maintain referential integrity between related users, providers, services, opportunities, ratings, reviews, notifications, and other related records.

- **NFR-32:** The system shall validate data before storing or updating records to prevent inconsistent or invalid information from being persisted.

- **NFR-33:** The system shall perform scheduled database backups at least once per day during the active deployment period.

- **NFR-34:** The system shall provide a mechanism for restoring the database from an available backup in the event of data loss or system failure.

### 2.3.11 Accessibility and Localization

The primary interface language of Daleel+ is Arabic and the application shall support appropriate Arabic presentation and usability.

- **NFR-35:** The system shall present Arabic content using a right-to-left layout throughout the mobile application.

- **NFR-36:** The system shall correctly display mixed Arabic and Latin text, including names, email addresses, phone numbers, and technical terms.

- **NFR-37:** The interface shall maintain sufficient text and background contrast to ensure that displayed information remains readable.

- **NFR-38:** The interface shall prevent essential labels, buttons, and system messages from being truncated on supported device screen sizes.

### 2.3.12 Privacy and Data Protection

The system shall protect personal information and restrict its use according to the user's role and the purpose for which the information is collected.

- **NFR-39:** The system shall collect and store only the personal information required for account management and the defined Daleel+ functionality.

- **NFR-40:** The system shall restrict access to personal and provider information according to the user's assigned permissions.

- **NFR-41:** The system shall not expose users' private account information, authentication credentials, or other protected data to unauthorized users.

- **NFR-42:** The system shall provide users with appropriate control over the personal profile information that they are permitted to view and update.

*End of Chapters 1 and 2*
