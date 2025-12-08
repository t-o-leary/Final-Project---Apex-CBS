[Readme.txt](https://github.com/user-attachments/files/24041722/Readme.txt)
# Campus Booking Application

This repository contains the Oracle APEX application and supporting database scripts for the **Campus Booking App**.

---

## Contents
- `application\f101_CAMPUS_BOOKING_APP.sql`  
  Exported Oracle APEX application file.
- `f101_static_application_files\`  
  Static application files to be loaded into APEX Shared Components.
- `Database\Database extract.sql`  
  SQL script to create required database objects.
- `Application\Readable files\`  
  **Not required for installation.** These files represent the `f101_CAMPUS_BOOKING_APP.sql` split into multiple files for easier review.

---

## Prerequisites
- Oracle APEX installed and accessible.
- Oracle Database with appropriate privileges to run DDL scripts.
- Access to APEX workspace where the application will be imported.

---

## Installation Steps

1. **Import the APEX Application**
   - Navigate to your APEX workspace.
   - Go to **App Builder → Import**.
   - Upload and import the file:  
     ```
     application\f101_CAMPUS_BOOKING_APP.sql
     ```

2. **Load Static Application Files**
   - In APEX, open the imported application.
   - Navigate to **Shared Components → Static Application Files**.
   - Upload all files from:  
     ```
     f101_static_application_files\
     ```

3. **Run Database Script**
   - Connect to your Oracle Database using SQL*Plus or SQL Developer.
   - Execute the script to create required database objects:  
     ```
     @Database\Database extract.sql
     ```

---

## Readable Files (Optional)
The directory `Application\Readable files` contains a **split export** of the application:

- **ZIP Archive Export (Choose On):**  
  Exports the application as a ZIP archive containing separate files for each page, shared component, and other objects.  
  Useful for version control and modular inspection.

- **Readable Format (Choose On):**  
  Generates a human-readable **YAML** version of the application metadata.  

> These files are **not required for installation**

---

## Notes
- Ensure you run the database script **before** testing the application to avoid missing object errors.
- Static files (CSS, JS, images) must be uploaded to ensure proper UI rendering.
- After import, verify application settings such as authentication schemes and workspace mappings.

---
