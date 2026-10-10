**Milestones**

DaleelPlus — Sprint Plan & User Stories

| **Project Name** | Daleel+ |
| --- | --- |
| **Prepared By** | AlShimaa AlNajjar<br>Zyad AlAstal<br>Mohanned AlHalabi<br>Mohammed AlHalabi<br>Raji Madi |
| **Supervisor** | Eng.Yaseen Zaqut |
| **Organization / University** | Ajyal |
| **Date** | ‏09‏/10‏/2026 |
| **Version** | Version 1.0 |

Version 1.0 | 2026

# Platform Description

Daleel+ is a mobile application designed to help individuals discover and evaluate organized services and opportunities through a centralized platform. The application brings together educational and training services, libraries and printing services, job and training opportunities, and private tutors in one place, allowing users to search, filter, compare, review, and access relevant information based on their needs and selected location. Service and opportunity providers can manage their own listings according to their provider type and permissions, while the SuperAdmin manages platform data, accounts, categories, and reported content. By organizing scattered information into a structured and accessible platform, Daleel+ simplifies the process of discovering relevant services and opportunities and helps users make more informed decisions.

# Milestones Overview

| **Milestone ID** | **Milestone** | **Expected Outcome** | **Target Date** | **Related Sprints** |
| --- | --- | --- | --- | --- |
| **M1** | Secure Access & User Profile | Users and service / opportunity providers can register using supported authentication methods, manage their profiles and preferences, select the appropriate account or provider type, and access only the features permitted by their assigned role and provider type. | 16 October 2026 | Sprint 1 |
| **M2** | Service & Opportunity Management | Providers can create, view, update, and delete their own service and opportunity listings with the required provider-specific information, while users can access the available categories and listings. | 23 October 2026 | Sprint 2 |
| **M3** | Discovery & Evaluation | Users can search and filter services and opportunities, manually select locations, view detailed information, compare eligible listings, submit and view ratings and reviews, and access available contact options.. | 30 October 2026 | Sprint 3 |
| **M4** | Notifications, Administration & MVP Completion | Users receive basic notifications and can access previously viewed information offline, while the SuperAdmin can manage accounts, categories, and reported content. Final integration, access control, testing, and MVP completion are finalized. | 6 November 2026 | Sprint 4 |

# Continuous Verification Across Sprints

Testing is not a separate final sprint. Each user story is designed, implemented, tested, corrected, and retested within the sprint in which it is delivered.

- A story is complete only after its acceptance criteria and relevant non-functional requirements pass.

- Functional, UI, API, security, privacy, access-control, loading, error, empty-state, offline, and edge-case checks are executed continuously as applicable.

- Defects are recorded, assigned, fixed, and retested within the same sprint.

- Final integration, deployment, and demonstration preparation are completed as Sprint 4 release activities.

- Each user story references one primary functional requirement; detailed acceptance behavior is kept in the story rather than duplicated across multiple FR mappings.

# Sprint 1 — Authentication & User Access – 2 Weeks

**Sprint Goal: Deliver secure, role-aware access across mobile and web, including organization and user Sprint Goal: Deliver the account and access foundation for Daleel+, including user and provider registration, supported authentication methods, account and provider type selection, authentication and access control, account management, user profiles, interests, and preferred location. This sprint establishes the identity, authorization, and preference data required by the discovery and provider-management features delivered in later sprints.**

### US-01 — Account Registration

**Sprint:** Sprint 1

**Related Functional Requirement:** FR-001

**User Story:**

As a new user,
I want to create a Daleel+ account using Google Sign-In or email and password,
so that I can access the application and its available features.

#### Acceptance Criteria

- The system provides Google Sign-In and email-and-password registration as available account creation methods.

- A registration attempt using a supported authentication method creates an account when the required information is valid.

- The system does not create an account when the registration attempt fails validation or authentication.

- Newly registered accounts are associated with the account type selected during registration.

#### Scenarios

- [Google Registration]: User: Selects Google Sign-In and authenticates successfully • System: Creates the Daleel+ account and continues the registration process.

- [Email Registration]: User: Selects email registration and provides the required information • System: Validates the information and creates the account.

- [Registration Failure]: User: Attempts to register with invalid or incomplete information • System: Rejects the registration and displays the relevant validation message.

## US-02 — Account Type Selection

**Sprint:** Sprint 1
**Related Functional Requirement:** FR-002

**User Story:**
As a new user,
I want to select my account type during registration,
so that Daleel+ can provide the appropriate registration and profile information for my account.

**Acceptance Criteria**

- The system requires an account type to be selected during registration.

- The available user account types include University Student, Graduate, and Other Individual.

- The system provides provider account registration with selection of the applicable provider type.

- The registration and profile fields displayed by the system correspond to the selected account type or provider type.

**Scenarios**

- **[User Account Type]:** User: Selects University Student • System: Displays the applicable registration and profile fields.

- **[Graduate Account]:** User: Selects Graduate • System: Displays the fields applicable to the Graduate account type.

- **[Provider Account]:** User: Selects Provider and chooses a provider type • System: Displays the fields applicable to the selected provider type.

- **[Missing Account Type]:** User: Attempts to continue registration without selecting an account type • System: Prevents continuation and requests an account type selection.

## US-03 — Google Account Information

**Sprint:** Sprint 1
**Related Functional Requirement:** FR-003

**User Story:**
As a user registering with Google,
I want Daleel+ to use the basic information available from my Google account,
so that I do not have to enter information that is already available.

**Acceptance Criteria**

- The system retrieves the available basic account information from the authenticated Google account.

- Retrieved Google account information is associated with the new Daleel+ account.

- The system requires the user to complete any additional Daleel+ profile information required for the selected account type.

- The system does not consider registration complete while required additional profile information remains incomplete.

**Scenarios**

- **[Main Scenario]:** User: Authenticates successfully through Google • System: Retrieves the available basic account information and displays the remaining required Daleel+ profile fields.

- **[Additional Information]:** User: Completes the required Daleel+ information • System: Completes the registration process for the selected account type.

- **[Incomplete Profile]:** User: Leaves required additional information incomplete • System: Prevents completion of registration until the required information is provided.

## US-04 — Email Registration Information

**Sprint:** Sprint 1
**Related Functional Requirement:** FR-004

**User Story:**
As a user registering with email and password,
I want to provide the required account information,
so that I can create and secure my Daleel+ account.

**Acceptance Criteria**

- The system requires the user's name, email address, phone number with country code, password, and password confirmation.

- The system validates that the required registration fields are provided before creating the account.

- The system verifies that the password confirmation matches the password.

- The system does not create the account when required information is missing or invalid.

**Scenarios**

- **[Main Scenario]:** User: Enters a valid name, email, phone number with country code, password, and matching confirmation • System: Validates the information and proceeds with account creation.

- **[Password Mismatch]:** User: Enters different password and confirmation values • System: Rejects the registration and displays a validation message.

- **[Missing Required Information]:** User: Leaves one or more required fields empty • System: Prevents registration and identifies the required information.

## US-05 — Provider Type Management

**Sprint:** Sprint 1
**Related Functional Requirement:** FR-005

**User Story:**
As a service or opportunity provider,
I want to select the provider type applicable to my account,
so that I can access the management functions and information fields relevant to the services or opportunities I provide.

**Acceptance Criteria**

- The system supports Private Tutor / Trainer, Library / Printing Provider, Education / Course Provider, and Job / Training Provider types.

- A provider can select an applicable provider type during registration.

- The system associates the selected provider type with the provider account.

- The system uses the assigned provider type to determine the applicable management functions and information fields.

**Scenarios**

- **[Private Tutor]:** User: Selects Private Tutor / Trainer • System: Associates the provider type with the account and provides the applicable functions and fields.

- **[Library Provider]:** User: Selects Library / Printing Provider • System: assigns the selected provider type and applies its applicable functions.

- **[Course Provider]:** User: Selects Education / Course Provider • System: assigns the selected provider type and applies its applicable functions.

- **[Job Provider]:** User: Selects Job / Training Provider • System: assigns the selected provider type and applies its applicable functions.

## US-06 — User Authentication

**Sprint:** Sprint 1
**Related Functional Requirement:** FR-006

**User Story:**
As a registered user,
I want the system to authenticate my account securely,
so that I can access protected Daleel+ features only when my identity is valid.

**Acceptance Criteria**

- The system authenticates registered users using the authentication method associated with their account.

- Successfully authenticated users can access protected features permitted for their account.

- Requests to protected features without valid authentication are denied.

- Invalid authentication attempts do not provide access to protected features.

**Scenarios**

- **[Main Scenario]:** User: Provides valid authentication credentials • System: Authenticates the account and grants access to permitted protected features.

- **[Invalid Authentication]:** User: Provides invalid authentication information • System: Rejects the authentication attempt and does not grant protected access.

- **[Unauthenticated Access]:** User: Attempts to access a protected feature without authentication • System: Denies access and requires authentication.

## US-07 — Account Management and Logout

**Sprint:** Sprint 1
**Related Functional Requirement:** FR-007

**User Story:**
As an authenticated user,
I want to securely manage my account and log out,
so that I can maintain my account information and protect access to my account.

**Acceptance Criteria**

- Authenticated users can securely log out of their accounts.

- The system prevents access to protected features after a successful logout.

- Users can change their password when password management is applicable to their account.

- Users can manage account information that they are permitted to modify.

**Scenarios**

- **[Logout]:** User: Selects Log Out • System: Ends the authenticated session and prevents access to protected features until the user authenticates again.

- **[Password Change]:** User: Requests a password change and provides the required information • System: validates the request and updates the password when valid.

- **[Permitted Account Update]:** User: Updates permitted account information • System: validates and saves the updated information.

## US-08 — Role and Provider-Based Access Control

**Sprint:** Sprint 1
**Related Functional Requirement:** FR-008

**User Story:**
As a Daleel+ user,
I want access to features and data based on my assigned account type and provider type,
so that I can use only the functions permitted for my account.

**Acceptance Criteria**

- The system identifies the user's assigned account type or provider type when evaluating access.

- Users can access only features permitted for their assigned account type or provider type.

- A provider cannot access management functions that are not permitted for the assigned provider type.

- Requests for features or data outside the user's permitted access are denied.

**Scenarios**

- **[Main Scenario]:** User: Authenticated user opens an allowed feature • System: Grants access according to the user's assigned account or provider type.

- **[Restricted Feature]:** User: Attempts to access a feature outside the permitted account type • System: Denies the request.

- **[Provider Type Restriction]:** User: A provider attempts to access a function unavailable to the assigned provider type • System: Denies access.

## US-09 — User Profile Management

**Sprint:** Sprint 1
**Related Functional Requirement:** FR-009

**User Story:**
As an authenticated user,
I want to create and manage my profile information,
so that Daleel+ can maintain the information relevant to my account and preferences.

**Acceptance Criteria**

- The system allows users to create and manage their profiles.

- The profile supports the user's name, user type, university, specialization, preferred location, and other applicable profile information.

- Profile fields displayed or required correspond to the applicable account type where relevant.

- The system saves valid profile information and makes it available to authorized application features.

**Scenarios**

- **[Main Scenario]:** User: Completes the applicable profile information • System: Validates and saves the profile.

- **[Profile Information Update]:** User: Changes permitted profile information • System: Saves the updated information.

- **[Incomplete Required Information]:** User: Attempts to save required profile information without completing mandatory fields • System: Prevents the save and identifies the missing information.

## US-10 — Areas of Interest

**Sprint:** Sprint 1
**Related Functional Requirement:** FR-010

**User Story:**
As a user,
I want to select multiple areas of interest,
so that Daleel+ can understand the types of services and opportunities relevant to me.

**Acceptance Criteria**

- The system provides predefined categories or subjects from which users can select interests.

- Users can select multiple areas of interest.

- Users can update their selected interests after the initial selection.

- The system stores the selected interests as part of the user's preferences.

**Scenarios**

- **[Main Scenario]:** User: Selects multiple areas of interest • System: Saves all selected interests to the user's preferences.

- **[Update Interests]:** User: Adds or removes selected interests • System: Updates the stored interests accordingly.

- **[No Selection]:** User: Continues without selecting an interest where selection is not mandatory • System: Allows continuation without creating invalid interest data.

## US-11 — Relevant Services and Opportunities

**Sprint:** Sprint 1
**Related Functional Requirement:** FR-011

**User Story:**
As a user,
I want Daleel+ to use my selected interests and preferred location when presenting services and opportunities,
so that the available information is relevant to my needs.

**Acceptance Criteria**

- The system uses the user's stored areas of interest when determining relevant services and opportunities.

- The system uses the user's preferred location when determining relevant services and opportunities.

- Relevant services and opportunities are presented within the applicable sections of the application.

- Updating the user's interests or preferred location affects the information presented according to the updated preferences.

**Scenarios**

- **[Main Scenario]:** User: Has selected interests and a preferred location • System: Presents applicable services and opportunities based on the stored preferences.

- **[Interest Update]:** User: Changes their selected interests • System: Uses the updated interests when presenting relevant information.

- **[Location Update]:** User: Changes their preferred location • System: Uses the updated location when presenting relevant information.

## US-12 — Profile and Preference Updates

**Sprint:** Sprint 1
**Related Functional Requirement:** FR-012

**User Story:**
As an authenticated user,
I want to update my profile information, interests, and preferred location after registration,
so that my Daleel+ information remains current.

**Acceptance Criteria**

- The system allows authenticated users to update their permitted profile information after registration.

- The system allows users to update their selected areas of interest after registration.

- The system allows users to update their preferred location after registration.

- Updated information is saved and used by applicable system features.

**Scenarios**

- **[Profile Update]:** User: Changes their profile information after registration • System: Validates and saves the updated information.

- **[Interest Update]:** User: Modifies their selected interests • System: Stores the new interest selections.

- **[Location Update]:** User: Changes their preferred location • System: Stores the new location and uses it for applicable features.

- **[Invalid Update]:** User: Submits invalid or incomplete information for a required field • System: Rejects the update and displays the relevant validation message.

# Sprint 2 — Service & Opportunity Management & Search – 1 Week

**Sprint Goal: Deliver the core provider listing workflow and discovery foundation for Daleel+, including provider-specific service and opportunity management, required listing information, job and training opportunity details, ownership protection, keyword search, filtering, and category-based browsing results.**

## US-13 — Provider Listing Management

**Sprint:** Sprint 2
**Related Functional Requirement:** FR-013

**User Story:**
As a service or opportunity provider,
I want to create and manage my own service or opportunity records,
so that I can keep the information I provide on Daleel+ up to date.

**Acceptance Criteria**

- Authorized providers can create their own service or opportunity records.

- Providers can view their own submitted records.

- Providers can update their own service or opportunity records according to their permissions.

- Providers can delete their own service or opportunity records according to their permissions.

- The system applies the management permissions associated with the provider's assigned provider type.

**Scenarios**

- **[Main Scenario]:** User: Provider creates a new service or opportunity record • System: Validates the permitted information and saves the provider's record.

- **[View Own Listing]:** User: Provider opens one of their existing records • System: Displays the record and its stored information.

- **[Update Listing]:** User: Provider edits one of their own records • System: Validates and saves the updated information.

- **[Delete Listing]:** User: Provider deletes one of their own records • System: Removes the record according to the provider's permissions.

## US-14 — Provider-Specific Listing Management

**Sprint:** Sprint 2
**Related Functional Requirement:** FR-014

**User Story:**
As a service or opportunity provider,
I want the system to provide fields and management functions appropriate to my provider type,
so that I can manage information relevant to the service or opportunity I provide.

**Acceptance Criteria**

- The system provides applicable information fields for Private Tutors / Trainers.

- The system provides applicable information fields for Library / Printing Providers.

- The system provides applicable information fields for Education / Course Providers.

- The system provides applicable information fields for Job / Training Providers.

- Management functions available to a provider correspond to the assigned provider type.

**Scenarios**

- **[Private Tutor]:** User: Private Tutor / Trainer creates or edits a listing • System: Displays and manages the fields applicable to the provider type.

- **[Library Provider]:** User: Library / Printing Provider manages a listing • System: Provides the applicable library and printing information fields.

- **[Course Provider]:** User: Education / Course Provider manages a listing • System: Provides the applicable education and course information fields.

- **[Job Provider]:** User: Job / Training Provider manages a listing • System: Provides the applicable job and training information fields.

## US-15 — Required Listing Information

**Sprint:** Sprint 2
**Related Functional Requirement:** FR-015

**User Story:**
As a service or opportunity provider,
I want the system to require the necessary listing information,
so that users can access complete and useful information about available services and opportunities.

**Acceptance Criteria**

- The system requires applicable listing information before a service or opportunity can be saved or published.

- Required information includes the name or title, category, location, description, and contact information where applicable.

- The system requires additional information applicable to the selected provider or listing type.

- The system prevents a record from being saved or published when required information is missing or invalid.

**Scenarios**

- **[Main Scenario]:** User: Provider enters all required listing information • System: Validates the information and allows the record to be saved or published.

- **[Missing Required Field]:** User: Provider submits a listing with a required field missing • System: Prevents the save or publication and identifies the missing information.

- **[Type-Specific Information]:** User: Provider submits a listing without required type-specific information • System: Prevents the record from being saved or published until the required information is provided.

## US-16 — Job and Training Opportunity Management

**Sprint:** Sprint 2
**Related Functional Requirement:** FR-016

**User Story:**
As a Job / Training Provider,
I want to manage the requirements, deadlines, and status of my opportunities,
so that users can understand the conditions and current availability of each opportunity.

**Acceptance Criteria**

- Job / Training Providers can add and manage opportunity requirements.

- Job / Training Providers can add and manage opportunity deadlines.

- Job / Training Providers can manage the status of their opportunities.

- The system stores the opportunity-specific information as part of the applicable opportunity record.

**Scenarios**

- **[Main Scenario]:** User: Job / Training Provider creates an opportunity with requirements, deadline, and status • System: Validates and stores the opportunity information.

- **[Update Opportunity]:** User: Provider changes the requirements or deadline • System: Updates the stored opportunity information.

- **[Status Update]:** User: Provider changes the opportunity status • System: Saves the new status for the opportunity.

- **[Missing Opportunity Information]:** User: Provider attempts to save an opportunity without required opportunity-specific information • System: Prevents the save and identifies the missing information.

## US-17 — Provider Listing Ownership

**Sprint:** Sprint 2
**Related Functional Requirement:** FR-017

**User Story:**
As a service or opportunity provider,
I want my listings to be protected from modification by other providers,
so that only the authorized owner can manage their records.

**Acceptance Criteria**

- Each provider can modify only services or opportunities belonging to that provider.

- A provider cannot update a listing belonging to another provider.

- A provider cannot delete a listing belonging to another provider.

- Unauthorized modification or deletion requests are denied.

**Scenarios**

- **[Main Scenario]:** User: Provider opens their own listing for editing • System: Allows the permitted modification.

- **[Unauthorized Update]:** User: Provider attempts to update another provider's listing • System: Denies the request.

- **[Unauthorized Delete]:** User: Provider attempts to delete another provider's listing • System: Denies the request.

## US-18 — Keyword Search

**Sprint:** Sprint 2
**Related Functional Requirement:** FR-018

**User Story:**
As a user,
I want to search for services and opportunities using keywords,
so that I can quickly find relevant listings.

**Acceptance Criteria**

- The system provides a keyword search for available services and opportunities.

- The system processes the entered keyword against the available searchable information.

- Search results contain listings relevant to the entered keyword according to the system's search rules.

- The system allows users to perform a search without manually browsing every available listing.

**Scenarios**

- **[Main Scenario]:** User: Enters a keyword and submits the search • System: Displays relevant available services and opportunities matching the search.

- **[No Matching Results]:** User: Searches for a keyword with no matching listings • System: Displays an appropriate empty-result state.

- **[Updated Search]:** User: Changes the entered keyword • System: Displays results according to the updated search term.

## US-19 — Service and Opportunity Filtering

**Sprint:** Sprint 2
**Related Functional Requirement:** FR-019

**User Story:**
As a user,
I want to filter services and opportunities using relevant criteria,
so that I can narrow the available results according to my needs.

**Acceptance Criteria**

- The system allows users to filter available services and opportunities.

- Applicable filtering criteria include category, location, type, and other relevant attributes supported by the listing.

- Users can apply the available filtering criteria to the displayed listings.

- The system updates the available results according to the selected filters.

**Scenarios**

- **[Main Scenario]:** User: Selects a category and location filter • System: Displays listings matching the selected criteria.

- **[Multiple Filters]:** User: Applies more than one filter • System: Displays results satisfying the applicable selected criteria.

- **[Clear Filters]:** User: Removes the selected filters • System: Restores the corresponding broader set of available results.

## US-20 — Search and Browsing Results

**Sprint:** Sprint 2
**Related Functional Requirement:** FR-020

**User Story:**
As a user,
I want search and browsing results to reflect my selected category, keywords, and filters,
so that I can see listings that match what I am looking for.

**Acceptance Criteria**

- The system displays results according to the selected category when browsing by category.

- The system applies entered search keywords to the displayed results.

- The system applies selected filter criteria to the displayed results.

- The displayed results reflect the combination of applicable category, search, and filter selections.

**Scenarios**

- **[Category Browsing]:** User: Selects a category • System: Displays services and opportunities belonging to the selected category.

- **[Category and Keyword]:** User: Selects a category and enters a keyword • System: Displays results matching the applicable category and keyword.

- **[Combined Criteria]:** User: Selects a category, keyword, and filters • System: Displays results according to the combined criteria.

- **[No Matching Results]:** User: Applies criteria for which no listings are available • System: Displays an appropriate empty-result state.

### .

# Sprint 3 — Discovery, Evaluation & Contact – 1 Week

**Sprint Goal: Deliver the service and opportunity discovery experience for Daleel+, enabling users to view detailed listing information and opportunity status, compare eligible listings, submit and manage ratings and reviews, access available contact options, and manually select locations when searching or filtering. This sprint builds on the provider listing and search capabilities delivered in Sprint 2.**

## US-21 — Service and Opportunity Details

**Sprint:** Sprint 3
**Related Functional Requirement:** FR-021

**User Story:**
As a user,
I want to view detailed information about a selected service, opportunity, or private tutor,
so that I can evaluate the available information before deciding how to proceed.

**Acceptance Criteria**

- The system allows users to open and view a selected service, opportunity, or private tutor listing.

- The details view displays applicable descriptions, categories, locations, and contact information.

- The system displays other relevant details available for the selected listing type.

- The displayed information corresponds to the selected listing.

**Scenarios**

- **[Main Scenario]:** User: Selects a service or opportunity from the results • System: Displays the detailed information associated with the selected listing.

- **[Private Tutor Details]:** User: Opens a private tutor listing • System: Displays the applicable tutor information and available contact details.

- **[Listing Details]:** User: Opens a listing with type-specific information • System: Displays the relevant details applicable to that listing type.

## US-22 — Opportunity Status Display

**Sprint:** Sprint 3
**Related Functional Requirement:** FR-022

**User Story:**
As a user,
I want to see the current status of an opportunity,
so that I can identify opportunities that are still available and those that have ended or are no longer available.

**Acceptance Criteria**

- The system displays the current status for opportunities whose status is applicable.

- The system identifies opportunities that are no longer available or have ended.

- The displayed status corresponds to the status recorded for the opportunity.

- Opportunity status is visible when users view the applicable opportunity information.

**Scenarios**

- **[Available Opportunity]:** User: Opens an opportunity that is still available • System: Displays its current status.

- **[Ended Opportunity]:** User: Opens an opportunity marked as ended • System: Identifies the opportunity as ended.

- **[Unavailable Opportunity]:** User: Views an opportunity marked as no longer available • System: Clearly displays its unavailable status.

## US-23 — Service and Opportunity Comparison

**Sprint:** Sprint 3
**Related Functional Requirement:** FR-023

**User Story:**
As a user,
I want to select and compare eligible services and opportunities in a structured view,
so that I can evaluate their available information side by side.

**Acceptance Criteria**

- The system allows users to select eligible services and opportunities for comparison.

- The system presents the selected listings in a structured comparison view.

- The comparison displays the available information relevant to each selected listing.

- The system does not present unavailable information as if it were known for a listing.

**Scenarios**

- **[Main Scenario]:** User: Selects eligible listings for comparison • System: Displays their available information in a structured comparison view.

- **[Different Listing Details]:** User: Compares listings with different available information • System: Presents the information available for each listing without inventing missing details.

- **[Comparison Selection]:** User: Changes the listings selected for comparison • System: Updates the comparison view to reflect the current selection.

## US-24 — Submit Ratings and Reviews

**Sprint:** Sprint 3
**Related Functional Requirement:** FR-024

**User Story:**
As an eligible authenticated user,
I want to submit a rating and review for a supported service,
so that I can share my experience with other users.

**Acceptance Criteria**

- Only authenticated users who meet the defined eligibility rules can submit ratings and reviews for supported services.

- The system validates rating and review submissions according to the defined rating rules.

- Valid submissions are associated with the relevant service and submitting user.

- Invalid or ineligible submissions are rejected.

**Scenarios**

- **[Main Scenario]:** User: An eligible authenticated user submits a valid rating and review for a supported service • System: Validates and records the submission.

- **[Unauthenticated Submission]:** User: Attempts to submit a rating or review without authentication • System: Rejects the submission.

- **[Ineligible Submission]:** User: Attempts to review a service for which they do not meet the eligibility rules • System: Rejects the submission.

- **[Invalid Rating]:** User: Submits a rating that violates the defined rating rules • System: Rejects the submission and identifies the validation issue.

## US-25 — View Ratings and Reviews

**Sprint:** Sprint 3
**Related Functional Requirement:** FR-025

**User Story:**
As a user,
I want to view ratings and reviews associated with eligible services,
so that I can consider other users' experiences when evaluating a service.

**Acceptance Criteria**

- The system displays ratings and reviews associated with eligible services.

- Ratings and reviews are shown in the context of the relevant service.

- The system displays the available rating and review information without associating it with the wrong service.

- When a service has no ratings or reviews, the system displays an appropriate empty state.

**Scenarios**

- **[Main Scenario]:** User: Opens a service with existing ratings and reviews • System: Displays the ratings and reviews associated with that service.

- **[No Reviews]:** User: Opens a service without ratings or reviews • System: Displays an appropriate message indicating that no reviews are available.

- **[Different Service]:** User: Opens another service • System: Displays the ratings and reviews associated with the newly selected service.

## US-26 — Manage Own Ratings and Reviews

**Sprint:** Sprint 3
**Related Functional Requirement:** FR-026

**User Story:**
As a user who has submitted a rating or review,
I want to manage my own submissions,
so that I can maintain or correct the feedback I have provided.

**Acceptance Criteria**

- Users can manage their own submitted ratings and reviews according to the supported management operations.

- The system identifies the owner of each rating and review before allowing a modification or deletion.

- Users cannot modify ratings or reviews submitted by other users.

- Users cannot delete ratings or reviews submitted by other users.

- Unauthorized modification and deletion requests are denied.

**Scenarios**

- **[Manage Own Review]:** User: Updates or deletes their own review using an available operation • System: Verifies ownership and performs the permitted operation.

- **[Unauthorized Modification]:** User: Attempts to modify another user's review • System: Denies the request.

- **[Unauthorized Deletion]:** User: Attempts to delete another user's review • System: Denies the request.

## US-27 — Provider Contact Options

**Sprint:** Sprint 3
**Related Functional Requirement:** FR-027

**User Story:**
As a user,
I want to access the available contact options for service providers, opportunity providers, and private tutors,
so that I can contact the relevant provider using the information they have made available.

**Acceptance Criteria**

- The system provides applicable contact options for service providers, opportunity providers, and private tutors.

- Contact options are based on the contact information made available by the relevant provider.

- The system associates displayed contact information with the correct listing or provider.

- The system does not display unavailable contact details as though they were provided.

**Scenarios**

- **[Main Scenario]:** User: Opens a listing with available contact information • System: Displays the applicable contact options.

- **[Private Tutor Contact]:** User: Views a private tutor listing • System: Displays the contact options made available by the tutor.

- **[No Contact Information]:** User: Opens a listing without available contact information • System: Does not display nonexistent contact details.

## US-28 — Manual Location Selection

**Sprint:** Sprint 3
**Related Functional Requirement:** FR-028

**User Story:**
As a user,
I want to manually select an area or location when searching or filtering services and opportunities,
so that I can find listings relevant to the location I choose without requiring automatic GPS detection.

**Acceptance Criteria**

- The system allows users to select an area or location manually when searching or filtering.

- The selected location is used as a search or filtering criterion for services and opportunities.

- The system displays results according to the selected location and any other applicable search criteria.

- The system does not automatically detect the user's location through GPS for this functionality.

**Scenarios**

- **[Main Scenario]:** User: Selects a location manually and applies the location criterion • System: Displays listings matching the selected location.

- **[Change Location]:** User: Selects a different location • System: Updates the results according to the newly selected location.

- **[Location with Other Filters]:** User: Selects a location and another applicable filter • System: Displays results matching the combined criteria.

- **[No Matching Location Results]:** User: Selects a location with no matching listings • System: Displays an appropriate empty-result state.

# Sprint 4 — Notifications, Administration & MVP Completion – 1 Week

### Sprint Goal: Complete the remaining core capabilities of Daleel+, including in-app notification management, offline access to previously accessed information, administrative management of user and provider accounts, category and system configuration management, reported-content moderation, and enforcement of administrative access restrictions. This sprint also focuses on final integration, verification, defect correction, and preparation of the MVP demonstration and release.

## US-29 — In-App Notification Center

**Sprint:** Sprint 4
**Related Functional Requirement:** FR-029

**User Story:**
As an authenticated user,
I want to access a notification center containing important updates related to my account and platform activities,
so that I can stay informed about relevant changes and events.

**Acceptance Criteria**

- The system provides an in-app notification center for authenticated users.

- The notification center displays important updates related to accounts, services, opportunities, ratings, and other applicable system activities.

- Notifications are associated with the relevant user and activity.

- Unauthenticated users cannot access the protected notification center.

**Scenarios**

- **[Main Scenario]:** User: An authenticated user opens the notification center • System: Displays the notifications available for that user.

- **[Account Update]:** User: Opens the notification center after an applicable account-related update • System: Displays the relevant notification when generated.

- **[Service or Opportunity Update]:** User: Opens the notification center containing an applicable service or opportunity notification • System: Displays the notification and its associated information.

- **[Unauthenticated Access]:** User: Attempts to access the notification center without authentication • System: Denies access.

## US-30 — Notification Read Status and Navigation

**Sprint:** Sprint 4
**Related Functional Requirement:** FR-030

**User Story:**
As an authenticated user,
I want to distinguish read notifications from unread notifications and access their associated information,
so that I can keep track of updates and navigate to relevant details.

**Acceptance Criteria**

- The system distinguishes read notifications from unread notifications.

- The notification center displays the read or unread status of each applicable notification.

- Users can access the information associated with a notification where applicable.

- The system maintains the correct association between a notification and its related information.

**Scenarios**

- **[Main Scenario]:** User: Opens the notification center • System: Displays notifications with their corresponding read or unread status.

- **[Read Notification]:** User: Opens a notification • System: Provides access to its associated information and reflects its read status according to the implemented notification behavior.

- **[Unread Notification]:** User: Views an unread notification • System: Identifies it as unread until its read status changes.

- **[Associated Information]:** User: Selects a notification related to a service or opportunity • System: Provides access to the relevant associated information where available.

## US-31 — Offline Access to Previously Accessed Information

**Sprint:** Sprint 4
**Related Functional Requirement:** FR-031

**User Story:**
As a user,
I want to view previously accessed and locally stored information when I lose my internet connection,
so that I can continue accessing available information while offline.

**Acceptance Criteria**

- The system stores previously accessed information locally where supported by the application.

- Users can view previously accessed and locally stored information when an internet connection is unavailable.

- The system requires an active internet connection to retrieve newly added or updated services and opportunities.

- Information that has not been stored locally and requires an internet connection is not presented as newly retrieved offline data.

**Scenarios**

- **[Main Scenario]:** User: Opens previously accessed information while connected to the internet, then loses connectivity • System: Allows the locally stored information to be viewed offline.

- **[Offline Access]:** User: Opens previously stored service or opportunity information without an internet connection • System: Displays the available locally stored information.

- **[New Information While Offline]:** User: Attempts to retrieve newly added information while offline • System: Indicates that an internet connection is required to retrieve the new information.

- **[Updated Information While Offline]:** User: Attempts to retrieve updated service or opportunity information while offline • System: Cannot retrieve the latest version until connectivity is restored.

## US-32 — Offline Data Freshness Indicator

**Sprint:** Sprint 4
**Related Functional Requirement:** FR-032

**User Story:**
As a user viewing information offline,
I want to know when the displayed information may be outdated,
so that I can understand that it might not reflect the latest available data.

**Acceptance Criteria**

- The system indicates when displayed information may not reflect the latest available data because it was accessed while offline.

- The indicator is presented alongside or within the relevant offline information view.

- The system does not imply that locally stored information is current when its latest status cannot be verified.

**Scenarios**

- **[Main Scenario]:** User: Opens locally stored information while offline • System: Indicates that the displayed information may not reflect the latest available data.

- **[Potentially Outdated Opportunity]:** User: Views a previously accessed opportunity while offline • System: Shows the offline data freshness indication.

- **[Connectivity Restored]:** User: Reconnects to the internet • System: Allows the application to retrieve updated information when requested or through the implemented refresh behavior.

## US-33 — User and Provider Account Administration

**Sprint:** Sprint 4
**Related Functional Requirement:** FR-033

**User Story:**
As a SuperAdmin,
I want to manage user and provider accounts,
so that I can administer platform accounts according to my permissions.

**Acceptance Criteria**

- The system allows the SuperAdmin to view user and provider accounts.

- The system allows the SuperAdmin to update account information according to administrative permissions.

- The system allows the SuperAdmin to activate or restrict accounts.

- The system allows the SuperAdmin to remove accounts according to administrative permissions.

- Each administrative operation is applied to the intended account.

**Scenarios**

- **[View Accounts]:** User: SuperAdmin opens account management • System: Displays the available user and provider account information.

- **[Update Account]:** User: SuperAdmin updates an account • System: Validates and saves the permitted changes.

- **[Activate Account]:** User: SuperAdmin activates an account • System: Updates the account's activation state.

- **[Restrict Account]:** User: SuperAdmin restricts an account • System: Applies the restriction according to the system's account-management rules.

- **[Remove Account]:** User: SuperAdmin requests account removal • System: Performs the permitted removal operation.

## US-34 — Category and System Configuration Management

**Sprint:** Sprint 4
**Related Functional Requirement:** FR-034

**User Story:**
As a SuperAdmin,
I want to manage service and opportunity categories and required system configuration data,
so that Daleel+ maintains an organized and appropriately configured platform.

**Acceptance Criteria**

- The system allows the SuperAdmin to manage service categories.

- The system allows the SuperAdmin to manage opportunity categories.

- The system allows the SuperAdmin to manage other required system configuration data within the defined administrative scope.

- Changes to categories and configuration data are reflected in applicable system functions.

**Scenarios**

- **[Main Scenario]:** User: SuperAdmin opens category management • System: Displays the available service and opportunity categories.

- **[Category Update]:** User: SuperAdmin updates a category • System: Saves the change and applies it to the relevant category-dependent functions.

- **[Configuration Update]:** User: SuperAdmin updates permitted system configuration data • System: Validates and saves the changes.

## US-35 — Reported and Inappropriate Content Management

**Sprint:** Sprint 4
**Related Functional Requirement:** FR-035

**User Story:**
As a SuperAdmin,
I want to review and manage inappropriate or reported services, opportunities, ratings, and reviews,
so that I can handle content that violates the defined system rules.

**Acceptance Criteria**

- The system allows the SuperAdmin to review inappropriate or reported services.

- The system allows the SuperAdmin to review inappropriate or reported opportunities.

- The system allows the SuperAdmin to review inappropriate or reported ratings and reviews.

- The system provides applicable management actions according to the defined system rules.

- Content management actions are applied to the intended service, opportunity, rating, or review.

**Scenarios**

- **[Reported Service]:** User: SuperAdmin opens a reported service • System: Displays the relevant content for review and provides applicable management actions.

- **[Reported Opportunity]:** User: SuperAdmin reviews a reported opportunity • System: Displays the opportunity information and applicable management actions.

- **[Reported Review]:** User: SuperAdmin reviews an inappropriate or reported rating or review • System: Provides the available management actions according to the defined rules.

- **[Management Action]:** User: SuperAdmin applies an authorized action to reviewed content • System: Executes the applicable action on the selected content.

## US-36 — Administrative Access Protection

**Sprint:** Sprint 4
**Related Functional Requirement:** FR-036

**User Story:**
As a platform administrator,
I want administrative functions and data to be restricted to authorized accounts,
so that users and providers cannot access administrative capabilities outside their assigned permissions.

**Acceptance Criteria**

- The system restricts administrative functions and data according to assigned permissions.

- Users cannot access administrative functions they are not authorized to use.

- Providers cannot access administrative functions they are not authorized to use.

- Unauthorized requests to protected administrative operations or data are denied.

- Access restrictions are enforced when protected operations are requested, not only by hiding administrative interface elements.

**Scenarios**

- **[Authorized Administration]:** User: SuperAdmin accesses an administrative function permitted by their permissions • System: Grants access.

- **[User Attempts Administrative Access]:** User: A regular user attempts to access an administrative operation • System: Denies access.

- **[Provider Attempts Administrative Access]:** User: A provider attempts to access protected administrative data • System: Denies access.

- **[Direct Unauthorized Request]:** User: An unauthorized account directly requests a protected administrative resource • System: Rejects the request without exposing the protected data.

**Sprint 4 — Final Integration, Verification & Release**

The following activities complete the MVP release and are not separate functional requirements.

**Integration Activities**

- Integrate the Flutter application with the relevant ASP.NET Core Web API and FastAPI endpoints.

- Verify that the backend components and SQL Server database support the implemented workflows.

- Verify that authentication and access-control rules are consistently enforced across the application and APIs.

- Verify the main user, provider, and SuperAdmin workflows across the completed sprints.

**Final Verification Activities**

- Execute functional, UI, API, security, access-control, loading, error, empty-state, and offline checks as applicable.

- Verify that the implemented features satisfy their acceptance criteria and related functional requirements.

- Record, correct, and retest identified defects.

- Verify that previously completed workflows continue to operate after integration and defect correction.

**Release Readiness**

- Confirm that the four sprints' implemented features operate together as the Daleel+ MVP.

- Complete deployment preparation and demonstration readiness.

- Document any known limitations or incomplete items rather than treating unimplemented functionality as complete.
