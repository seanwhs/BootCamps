# Part 3 – Business Modeling & Process Improvement

## Module 8: Data Analysis & Information Modeling

---

### Learning Objectives

By the end of this module, you will be able to:

- Define data modeling and its importance in business analysis
- Create Entity Relationship Diagrams (ERDs) using standard notation
- Understand and apply normalization principles
- Build data dictionaries and glossaries
- Design Data Flow Diagrams (DFDs)
- Create CRUD matrices to map data interactions
- Understand reference data, master data, and metadata concepts

---

## 8.1 Core Concepts: Data Modeling

### What is Data Modeling?

**Data modeling** is the process of creating a visual representation of the information requirements of an organization and the relationships between data elements.

**Analogy:** Think of data modeling as creating the blueprint for a library. You need to know what books you'll have (entities), how they're organized (relationships), and how to find them (keys). Without a well-designed system, the library is chaos.

### Why Data Modeling Matters

1. **Data Quality:** Ensures data is accurate and consistent
2. **Integration:** Maps how systems share data
3. **Efficiency:** Optimizes data structures for performance
4. **Communication:** Common understanding of data requirements
5. **Compliance:** Supports data governance and privacy
6. **Development:** Provides blueprint for database design

### The Data Modeling Process

```
1. UNDERSTAND BUSINESS REQUIREMENTS
   ↓
   What data does the business need?

2. IDENTIFY ENTITIES
   ↓
   What are the key objects?

3. DEFINE ATTRIBUTES
   ↓
   What characteristics does each entity have?

4. IDENTIFY RELATIONSHIPS
   ↓
   How are entities connected?

5. DEFINE KEYS
   ↓
   How do we identify each instance?

6. NORMALIZE
   ↓
   How do we eliminate redundancy?

7. VALIDATE
   ↓
   Does it meet business needs?

8. IMPLEMENT
   ↓
   Build the database/schema
```

---

## 8.2 Entity Relationship Diagrams (ERDs)

### ERD Fundamentals

**Entity Relationship Diagrams** show entities (things of interest) and their relationships.

**Core Components:**

| Component | Symbol | Description | Example |
|-----------|--------|-------------|---------|
| **Entity** | Rectangle | A thing of interest | Patient, Provider, Appointment |
| **Attribute** | Oval (sometimes listed) | Characteristics of an entity | Patient Name, Date of Birth |
| **Relationship** | Diamond or line | Connection between entities | "Schedules" between Patient and Appointment |
| **Primary Key** | Underlined | Unique identifier | Patient ID |
| **Foreign Key** | [PK name] in another table | Link to another entity | Patient ID in Appointment |

### ERD Notation Types

**1. Chen Notation**

```
┌──────────────┐
│   Patient    │          ┌──────────────┐
│              │          │  Appointment │
│  *PatientID  │─────────│  *ApptID     │
│   FirstName  │          │   Date       │
│   LastName   │          │   Time       │
│   DOB        │          │   Status     │
└──────────────┘          └──────────────┘
        │                         │
        │                    ┌────┴────┐
        │                    │         │
        └────────────────────┘         │
               │                        │
          ┌────┴────┐               ┌──┴────┐
          │         │               │       │
      ┌───▼───┐ ┌───▼───┐      ┌───▼───┐ ┌───▼───┐
      │       │ │       │      │       │ │       │
      └───────┘ └───────┘      └───────┘ └───────┘
```

**2. Crow's Foot Notation (Most Common)**

```
┌──────────────────┐     ═══<│┌──────────────────┐
│     Patient      │          │    Appointment   │
│──────────────────│          │──────────────────│
│ PK  PatientID    │──────────│ PK  ApptID       │
│     FirstName    │          │ FK  PatientID    │
│     LastName     │          │     Date         │
│     DOB          │          │     Time         │
└──────────────────┘          └──────────────────┘
```

**Relationship Cardinality:**

| Symbol | Meaning | Example |
|--------|---------|---------|
| `|───|` | Exactly one | Each Patient has one Primary Care Provider |
| `o───|` | Zero or one | Patient may have one Emergency Contact |
| `|───<` | One or many | One Patient has many Appointments |
| `o───<` | Zero or many | One Provider may have zero or many Patients |

### Complete MediConnect ERD

**Entities:**

1. **Patient** - Individuals receiving care
2. **Provider** - Clinicians providing care
3. **Appointment** - Scheduled encounters
4. **MedicalRecord** - Clinical documentation
5. **Prescription** - Medications ordered
6. **LabResult** - Laboratory test results
7. **Claim** - Billing claims
8. **Insurance** - Patient insurance information

**MediConnect ERD:**

```
┌───────────────────────────┐
│         Patient           │
│───────────────────────────│
│ PK   PatientID            │
│      FirstName            │
│      LastName             │
│      DateOfBirth          │
│      Gender               │
│      Phone                │
│      Email                │
│      Address              │
│      EmergencyContact     │
└──────────┬────────────────┘
           │
           │ 1
           │
           │ m
┌──────────▼────────────────┐
│       Appointment         │
│───────────────────────────│
│ PK   AppointmentID        │
│ FK   PatientID            │
│ FK   ProviderID           │
│      Date                 │
│      Time                 │
│      Status               │
│      Type                 │
│      Notes                │
└──────────┬────────────────┘
           │
           │ 1
           │
           │ 1
┌──────────▼────────────────┐
│       MedicalRecord       │
│───────────────────────────│
│ PK   RecordID             │
│ FK   AppointmentID        │
│ FK   PatientID            │
│      Date                 │
│      Diagnosis            │
│      Treatment            │
│      Notes                │
└──────────┬────────────────┘
           │
           │ 1
           │
           │ m
┌──────────▼────────────────┐
│       Prescription        │
│───────────────────────────│
│ PK   PrescriptionID       │
│ FK   PatientID            │
│ FK   ProviderID           │
│      MedicationName       │
│      Dosage               │
│      Frequency            │
│      StartDate            │
│      EndDate              │
│      Status               │
└──────────┬────────────────┘
           │
           │ 1
           │
           │ m
┌──────────▼────────────────┐
│       LabResult           │
│───────────────────────────│
│ PK   LabResultID          │
│ FK   PatientID            │
│ FK   ProviderID           │
│      TestName             │
│      Result               │
│      ReferenceRange       │
│      Date                 │
│      Status               │
└────────────────────────────┘

┌───────────────────────────┐
│        Provider           │
│───────────────────────────│
│ PK   ProviderID           │
│      FirstName            │
│      LastName             │
│      Specialty            │
│      LicenseNumber        │
│      Phone                │
│      Email                │
└──────────┬────────────────┘
           │
           │ 1
           │
           │ m
┌──────────▼────────────────┐
│        Claim              │
│───────────────────────────│
│ PK   ClaimID              │
│ FK   PatientID            │
│ FK   ProviderID           │
│      ServiceDate          │
│      Amount               │
│      Status               │
│      PaidDate             │
│      DenialReason         │
└──────────┬────────────────┘
           │
           │ 1
           │
           │ 1
┌──────────▼────────────────┐
│       Insurance           │
│───────────────────────────│
│ PK   InsuranceID          │
│ FK   PatientID            │
│      ProviderName         │
│      PolicyNumber         │
│      GroupNumber          │
│      EffectiveDate        │
│      ExpirationDate       │
│      CoverageType         │
└────────────────────────────┘
```

---

## 8.3 Normalization

### What is Normalization?

**Normalization** is the process of organizing data to reduce redundancy and improve integrity.

**The Normal Forms:**

| Form | Description | Example |
|------|-------------|---------|
| **1NF** | No repeating groups; atomic values | One value per cell |
| **2NF** | Fully dependent on primary key | No partial dependencies |
| **3NF** | No transitive dependencies | No non-key dependencies |

### Normalization Example

**Unnormalized Data:**

```
Appointment (ApptID, Date, Time, PatientName, PatientPhone, PatientEmail, 
            ProviderName, ProviderSpecialty, Notes)
```

**Problems:**
- Patient data repeats for each appointment
- Provider data repeats for each appointment
- Updates require multiple changes

**1NF (No Repeating Groups):**

```
Appointment (ApptID, PatientID, ProviderID, Date, Time, Notes)
Patient (PatientID, Name, Phone, Email)
Provider (ProviderID, Name, Specialty)
```

**2NF (No Partial Dependencies):**

```
Appointment (ApptID, PatientID, ProviderID, Date, Time, Notes)
Patient (PatientID, Name, Phone, Email)
Provider (ProviderID, Name, Specialty)
```

**3NF (No Transitive Dependencies):**

```
Appointment (ApptID, PatientID, ProviderID, Date, Time, Notes)
Patient (PatientID, Name, Phone, Email)
Provider (ProviderID, Name, Specialty)
```

**Your Turn: Normalize a Data Structure**

Take this denormalized structure and normalize it:

```
Claim (ClaimID, PatientName, PatientAddress, ProviderName, ProviderSpecialty,
      ServiceDate, ServiceCode, ServiceDescription, Amount, PaidAmount,
      InsuranceName, InsurancePolicy, InsuranceGroup)
```

**Your Normalized Version:**

```
[Your solution]
```

---

## 8.4 Data Dictionaries

### What is a Data Dictionary?

A **Data Dictionary** (or data catalog) is a centralized repository of information about data elements, including definitions, relationships, and usage.

**Why You Need One:**
- Consistency across the organization
- Clear definitions for all data
- Standardized naming conventions
- Source of truth for developers and analysts

### Complete Data Dictionary Template

```
DATA DICTIONARY
MediConnect Integrated Health Platform
Version: 1.0
Date: [Date]

| Entity Name | Attribute | Data Type | Length | Required? | Description | Source | Example |
|-------------|-----------|-----------|--------|-----------|-------------|--------|---------|
| Patient | PatientID | INT | 10 | Yes | Unique patient identifier | System | 10001 |
| Patient | FirstName | VARCHAR | 50 | Yes | Patient's first name | Patient | Sarah |
| Patient | LastName | VARCHAR | 50 | Yes | Patient's last name | Patient | Johnson |
| Patient | DOB | DATE | - | Yes | Date of birth | Patient | 1985-03-15 |
| Patient | Gender | VARCHAR | 10 | No | Patient's gender | Patient | Female |
| Patient | Phone | VARCHAR | 15 | Yes | Primary phone number | Patient | (555) 123-4567 |
| Patient | Email | VARCHAR | 100 | No | Email address | Patient | sarah@email.com |
| Patient | Address1 | VARCHAR | 100 | Yes | Street address | Patient | 123 Main St |
| Patient | Address2 | VARCHAR | 100 | No | Suite/Apt | Patient | Apt 4B |
| Patient | City | VARCHAR | 50 | Yes | City | Patient | Springfield |
| Patient | State | VARCHAR | 2 | Yes | State | Patient | IL |
| Patient | Zip | VARCHAR | 10 | Yes | ZIP code | Patient | 62701 |
| Patient | EmergencyContact | VARCHAR | 100 | No | Emergency contact name | Patient | John Smith |
| Patient | EmergencyPhone | VARCHAR | 15 | No | Emergency phone | Patient | (555) 234-5678 |
| Patient | CreatedDate | DATETIME | - | Yes | When record created | System | 2024-01-15 10:00:00 |
| Patient | ModifiedDate | DATETIME | - | Yes | Last update | System | 2024-01-16 14:30:00 |

| Entity Name | Attribute | Data Type | Length | Required? | Description | Source | Example |
|-------------|-----------|-----------|--------|-----------|-------------|--------|---------|
| Appointment | AppointmentID | INT | 10 | Yes | Unique appointment ID | System | 50001 |
| Appointment | PatientID | INT | 10 | Yes | Reference to Patient | System | 10001 |
| Appointment | ProviderID | INT | 10 | Yes | Reference to Provider | System | 20005 |
| Appointment | Date | DATE | - | Yes | Appointment date | Patient | 2024-02-10 |
| Appointment | Time | TIME | - | Yes | Appointment time | Patient | 14:30:00 |
| Appointment | Duration | INT | - | Yes | Minutes | System | 30 |
| Appointment | Status | VARCHAR | 20 | Yes | Status | System | Scheduled |
| Appointment | Type | VARCHAR | 30 | Yes | Appointment type | Patient | Routine |
| Appointment | Notes | TEXT | - | No | Additional notes | Staff | Patient prefers morning |
| Appointment | CreatedDate | DATETIME | - | Yes | When record created | System | 2024-01-18 09:00:00 |
| Appointment | ModifiedDate | DATETIME | - | Yes | Last update | System | 2024-01-18 09:05:00 |

| Entity Name | Attribute | Data Type | Length | Required? | Description | Source | Example |
|-------------|-----------|-----------|--------|-----------|-------------|--------|---------|
| Provider | ProviderID | INT | 10 | Yes | Unique provider ID | System | 20005 |
| Provider | FirstName | VARCHAR | 50 | Yes | Provider's first name | Provider | Michael |
| Provider | LastName | VARCHAR | 50 | Yes | Provider's last name | Provider | Chen |
| Provider | Specialty | VARCHAR | 50 | Yes | Medical specialty | Provider | Cardiology |
| Provider | LicenseNumber | VARCHAR | 20 | Yes | State license | Provider | IL-123456 |
| Provider | NPI | VARCHAR | 10 | Yes | NPI number | Provider | 1234567890 |
| Provider | Phone | VARCHAR | 15 | Yes | Contact phone | Provider | (555) 345-6789 |
| Provider | Email | VARCHAR | 100 | No | Work email | Provider | mchen@clinic.com |
| Provider | CreatedDate | DATETIME | - | Yes | When record created | System | 2024-01-10 08:00:00 |
| Provider | ModifiedDate | DATETIME | - | Yes | Last update | System | 2024-01-10 08:00:00 |

[Continue for all entities: MedicalRecord, Prescription, LabResult, Claim, Insurance]
```

---

## 8.5 Data Flow Diagrams (DFDs)

### What are Data Flow Diagrams?

**Data Flow Diagrams** show how data moves through a system, including inputs, outputs, stores, and processes.

**Components:**

| Element | Symbol | Description |
|---------|--------|-------------|
| **Process** | Circle/Rounded Rectangle | Transforms data |
| **Data Store** | Open Rectangle | Stores data |
| **External Entity** | Square/Rectangle | Outside the system |
| **Data Flow** | Arrow | Movement of data |

### MediConnect DFD Example

**Context Diagram (Level 0):**

```
           ┌────────────────────────────────────────────────┐
           │                                                │
           │          MediConnect System                    │
           │                                                │
Patient ───┤ Appointment Request                            │
           │                            Appointment ────────┤ Patient
           │                                                │
Provider ──┤ Patient Data                                   │
           │                            Medical Record ─────┤ Provider
           │                                                │
Insurance──┤ Insurance Verification                         │
           │                            Claim Submission ───┤ Insurance
           │                                                │
 Admin ────┤ Schedule Management                            │
           │                            Reports ────────────┤ Admin
           │                                                │
           └────────────────────────────────────────────────┘
```

**Level 1 DFD (Patient Scheduling):**

```
                  ┌──────────────┐
                  │   Patient    │
                  └──────┬───────┘
                         │ Appointment Request
                         ↓
              ┌──────────────────────┐
              │    Process 1.1       │
              │  Check Availability  │
              └──────────┬───────────┘
                         │
                         ↓
              ┌──────────────────────┐
              │    Process 1.2       │
              │  Schedule Appointment │
              └──────────┬───────────┘
                         │
                         ↓
              ┌──────────────────────┐
              │    Process 1.3       │
              │  Confirm Appointment │
              └──────────┬───────────┘
                         │
                         ↓
              ┌──────────────────────┐
              │    Process 1.4       │
              │  Update Schedules    │
              └──────────┬───────────┘
                         │
           ┌─────────────┼─────────────┐
           ↓             ↓             ↓
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│   Data Store:    │ │   Data Store:    │ │   Data Store:    │
│   Patient DB     │ │   Provider DB    │ │Appointment DB    │
└──────────────────┘ └──────────────────┘ └──────────────────┘
```

---

## 8.6 CRUD Matrices

### What is a CRUD Matrix?

**CRUD** stands for Create, Read, Update, Delete. A CRUD matrix maps which data entities each role or process interacts with.

**Why Use CRUD Matrices:**
- Identify who needs access to what data
- Understand data ownership
- Identify integration points
- Support security planning

### MediConnect CRUD Matrix

| Role/Process | Patient | Provider | Appointment | Medical Record | Prescription | Lab Result | Claim | Insurance |
|--------------|---------|----------|-------------|----------------|--------------|------------|-------|-----------|
| **Patient** | R, U | R | C, R, U, D | R | R | R | R | R |
| **Clinician** | C, R, U | R | C, R, U | C, R, U | C, R, U | C, R | R | R |
| **Front Desk** | C, R, U | R | C, R, U, D | R | R | R | R | C, R, U |
| **Billing** | R | R | R | R | R | R | C, R, U, D | R |
| **IT Admin** | C, R, U, D | C, R, U, D | C, R, U, D | C, R, U, D | C, R, U, D | C, R, U, D | C, R, U, D | C, R, U, D |
| **Practice Manager** | R | R, U | R | R | R | R | R | R |
| **Compliance** | R | R | R | R | R | R | R | R |

**Legend:**
- **C** = Create (can add new records)
- **R** = Read (can view records)
- **U** = Update (can modify records)
- **D** = Delete (can remove records)

**Your Turn: Create a CRUD Matrix**

Create a CRUD matrix for the MediConnect system with these roles:

```
CRUD MATRIX: MEDICONNECT

| Role | Patient | Appointment | MedicalRecord | Prescription | LabResult | Claim | Insurance |
|------|---------|-------------|---------------|--------------|-----------|-------|-----------|
| Patient | | | | | | | |
| Clinician | | | | | | | |
| Nurse | | | | | | | |
| Admin Staff | | | | | | | |
| Lab Tech | | | | | | | |
| Pharmacist | | | | | | | |
| Billing Clerk | | | | | | | |
| Manager | | | | | | | |
| IT Admin | | | | | | | |
```

---

## 8.7 Reference Data, Master Data, and Metadata

### Understanding Data Types

**1. Reference Data**

Data that defines permissible values for other data.

**MediConnect Examples:**
- State codes (IL, CA, NY)
- Gender codes (M, F, Other)
- Appointment status (Scheduled, Cancelled, Completed)
- Insurance types (Private, Medicare, Medicaid)
- Specialty codes (Cardiology, Oncology, etc.)

**2. Master Data**

Core business entities that are shared across the organization.

**MediConnect Examples:**
- Patient records
- Provider records
- Organization structure
- Product/service catalog
- Location/clinic data

**3. Metadata**

Data about data—describing structure, meaning, and context.

**MediConnect Examples:**
- Data dictionary (defined above)
- Data lineage (where data comes from)
- Data quality metrics
- Usage statistics

**MediConnect Reference Data Table:**

```
REFERENCE DATA: Appointment Status

| Status ID | Status Code | Description | Active |
|-----------|-------------|-------------|--------|
| 1 | Scheduled | Appointment is scheduled | Yes |
| 2 | Confirmed | Patient has confirmed | Yes |
| 3 | Checked-In | Patient has arrived | Yes |
| 4 | In-Progress | With provider | Yes |
| 5 | Completed | Appointment finished | Yes |
| 6 | Cancelled | Patient cancelled | Yes |
| 7 | No-Show | Patient did not attend | Yes |
| 8 | Rescheduled | Appointment moved | Yes |
```

---

## 8.8 Hands-On: Data Modeling Artifacts

### Your Task: Create the Complete Data Package

**Deliverable 1: Entity Relationship Diagram (ERD)**

Create a complete ERD for MediConnect with:
- All entities identified
- Attributes for each entity
- Primary keys defined
- Relationships defined with cardinality
- Foreign keys identified

**Deliverable 2: Normalized Data Structure**

Normalize the following data structure to 3NF:

```
PATIENT_APPOINTMENT (ApptID, PatientName, PatientPhone, PatientInsurance,
                     ProviderName, ProviderSpecialty, Date, Time, Treatment,
                     Medication, LabTest, LabResult)
```

**Deliverable 3: Data Dictionary**

Create a data dictionary for at least 5 entities.

**Deliverable 4: Data Flow Diagram**

Create a DFD for the patient scheduling process.

**Deliverable 5: CRUD Matrix**

Create a CRUD matrix for all roles and entities.

**Deliverable 6: Reference Data**

Define reference data tables for at least 3 domains.

---

## 8.9 Check Your Understanding

### Knowledge Check Questions

**1. What is data modeling and why is it important?**
```
[Your answer]
```

**2. What are the three components of an ERD?**
```
[Your answer]
```

**3. What is the difference between a primary key and a foreign key?**
```
[Your answer]
```

**4. What is normalization and what are the three normal forms?**
```
[Your answer]
```

**5. What is a data dictionary and what does it contain?**
```
[Your answer]
```

**6. What is the difference between a Data Flow Diagram and an ERD?**
```
[Your answer]
```

**7. What is a CRUD matrix and how is it used?**
```
[Your answer]
```

**8. What is the difference between reference data, master data, and metadata?**
```
[Your answer]
```

**9. What is cardinality and how is it represented in ERDs?**
```
[Your answer]
```

**10. How do data models support requirements and development?**
```
[Your answer]
```

---

## 8.10 Summary & Reference

### Key Takeaways from Module 8

✅ Data modeling creates a blueprint for information requirements
✅ ERDs show entities, attributes, and relationships
✅ Normalization reduces redundancy and improves integrity
✅ Data dictionaries provide consistent data definitions
✅ DFDs show how data flows through the system
✅ CRUD matrices map data interactions by role
✅ Reference data defines permissible values
✅ Metadata describes data characteristics
✅ Data models support system design and development

### Data Modeling Quick Reference

| Artifact | Purpose | Audience |
|----------|---------|----------|
| ERD | Data structure and relationships | Developers, architects |
| Normalization | Data quality, reduce redundancy | Developers, DBAs |
| Data Dictionary | Consistent definitions | All stakeholders |
| DFD | Data movement and processes | Developers, business |
| CRUD Matrix | Data access and permissions | Security, development |
| Reference Data | Valid values | Developers, QA |

### Module Deliverables Checklist

You should have completed these items for your portfolio:

- [ ] Entity Relationship Diagram (ERD) with all entities
- [ ] Normalized data structures (3NF)
- [ ] Complete Data Dictionary (5+ entities)
- [ ] Data Flow Diagram (at least Level 0 and Level 1)
- [ ] CRUD Matrix (all roles and entities)
- [ ] Reference Data Tables
- [ ] Data Modeling Documentation

### Recommended Additional Reading

- BABOK® Guide v3, Chapter 7: Requirements Analysis and Design Definition
- "Data Modeling Made Simple" by Steve Hoberman
- "The Data Model Resource Book" by Len Silverston
- "Information Modeling and Relational Databases" by Terry Halpin
- "Managing Reference Data in Enterprise Databases" by Malcolm Chisholm
- "Master Data Management" by David Loshin
