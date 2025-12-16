--------------------------------------------------------
--  File created - Monday-December-08-2025   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Sequence SEQ_BOOKINGS
--------------------------------------------------------

CREATE SEQUENCE "NCIPROJECT"."SEQ_BOOKINGS" MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE NOORDER NOCYCLE NOKEEP NOSCALE GLOBAL;
--------------------------------------------------------
--  DDL for Sequence SEQ_BOOKING_ATTENDEES
--------------------------------------------------------

CREATE SEQUENCE "NCIPROJECT"."SEQ_BOOKING_ATTENDEES" MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE NOORDER NOCYCLE NOKEEP NOSCALE GLOBAL;
--------------------------------------------------------
--  DDL for Sequence SEQ_CAMPUS_USERS
--------------------------------------------------------

CREATE SEQUENCE "NCIPROJECT"."SEQ_CAMPUS_USERS" MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE NOORDER NOCYCLE NOKEEP NOSCALE GLOBAL;
--------------------------------------------------------
--  DDL for Sequence SEQ_RESOURCES
--------------------------------------------------------

CREATE SEQUENCE "NCIPROJECT"."SEQ_RESOURCES" MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 NOCACHE NOORDER NOCYCLE NOKEEP NOSCALE GLOBAL;
--------------------------------------------------------
--  DDL for Table BOOKINGS
--------------------------------------------------------

CREATE TABLE "NCIPROJECT"."BOOKINGS" (
    "BOOKING_ID"       NUMBER DEFAULT "NCIPROJECT"."SEQ_BOOKINGS"."NEXTVAL",
    "RESOURCE_ID"      NUMBER,
    "USER_ID"          NUMBER,
    "START_TS"         TIMESTAMP(6) WITH TIME ZONE,
    "END_TS"           TIMESTAMP(6) WITH TIME ZONE,
    "STATUS"           VARCHAR2(20 BYTE)  DEFAULT 'CONFIRMED',
    "BOOKING_REF"      VARCHAR2(64 BYTE) ,
    "NOTES"            VARCHAR2(4000 BYTE) ,
    "CHECKIN"          VARCHAR2(5 BYTE) ,
    "CREATION_DATE"    DATE DEFAULT sysdate,
    "CREATED_BY"       VARCHAR2(100 BYTE) ,
    "LAST_UPDATE_DATE" DATE,
    "LAST_UPDATED_BY"  VARCHAR2(100 BYTE) 
);
--------------------------------------------------------
--  DDL for Table BOOKING_ATTENDEES
--------------------------------------------------------

CREATE TABLE "NCIPROJECT"."BOOKING_ATTENDEES" (
    "ATTENDEE_ID"      NUMBER DEFAULT nciproject.seq_booking_attendees.nextval,
    "BOOKING_ID"       NUMBER,
    "INTERNAL_FLAG"    VARCHAR2(5 BYTE) ,
    "USER_ID"          NUMBER,
    "ATTENDEE_NAME"    VARCHAR2(100 BYTE) ,
    "EMAIL"            VARCHAR2(100 BYTE) ,
    "NOTES"            VARCHAR2(4000 BYTE) ,
    "CREATION_DATE"    DATE DEFAULT sysdate,
    "CREATED_BY"       VARCHAR2(100 BYTE) ,
    "LAST_UPDATE_DATE" DATE,
    "LAST_UPDATED_BY"  VARCHAR2(100 BYTE) 
);
--------------------------------------------------------
--  DDL for Table CAMPUS_USERS
--------------------------------------------------------

CREATE TABLE "NCIPROJECT"."CAMPUS_USERS" (
    "USER_ID"          NUMBER DEFAULT "NCIPROJECT"."SEQ_CAMPUS_USERS"."NEXTVAL",
    "USERNAME"         VARCHAR2(200 BYTE) ,
    "FULL_NAME"        VARCHAR2(200 BYTE) ,
    "EMAIL"            VARCHAR2(200 BYTE) ,
    "STUDENT_STAFF_NO" VARCHAR2(30 BYTE) ,
    "DEPARTMENT"       VARCHAR2(200 BYTE) ,
    "USER_ROLE"        VARCHAR2(50 BYTE)  DEFAULT 'Student',
    "PROFILE_IMAGE"    BLOB,
    "FILE_NAME"        VARCHAR2(200 BYTE) ,
    "MIME_TYPE"        VARCHAR2(50 BYTE) ,
    "FILE_SIZE"        NUMBER,
    "MFA_CODE"         NUMBER,
    "MFA_DATE"         DATE,
    "PASSWORD"         VARCHAR2(200 BYTE) ,
    "CREATION_DATE"    DATE DEFAULT sysdate,
    "CREATED_BY"       VARCHAR2(100 BYTE) ,
    "LAST_UPDATE_DATE" DATE,
    "LAST_UPDATED_BY"  VARCHAR2(100 BYTE) 
);
--------------------------------------------------------
--  DDL for Table RESOURCES
--------------------------------------------------------

CREATE TABLE "NCIPROJECT"."RESOURCES" (
    "RESOURCE_ID"        NUMBER DEFAULT "NCIPROJECT"."SEQ_RESOURCES"."NEXTVAL",
    "CODE"               VARCHAR2(50 BYTE) ,
    "NAME"               VARCHAR2(20 BYTE) ,
    "LOCATION"           VARCHAR2(200 BYTE) ,
    "CAPACITY"           NUMBER,
    "RESOURCE_TYPE"      VARCHAR2(50 BYTE) ,
    "RESOURCE_AVAILABLE" NUMBER DEFAULT 1,
    "EQUIPMENT"          VARCHAR2(2000 BYTE) ,
    "NOTES"              VARCHAR2(2000 BYTE) ,
    "FLOOR"              VARCHAR2(200 BYTE) ,
    "DEPARTMENT"         VARCHAR2(50 BYTE) ,
    "BOOKABLE_BY"        VARCHAR2(50 BYTE) ,
    "ACTIVE_FLAG"        CHAR(1 BYTE)  DEFAULT 'Y',
    "CREATION_DATE"      DATE DEFAULT sysdate,
    "CREATED_BY"         VARCHAR2(100 BYTE) ,
    "LAST_UPDATE_DATE"   DATE,
    "LAST_UPDATED_BY"    VARCHAR2(100 BYTE) 
);
--------------------------------------------------------
--  DDL for View BOOKINGS_V
--------------------------------------------------------

CREATE OR REPLACE VIEW "NCIPROJECT"."BOOKINGS_V" (
    "ID",
    "NAME",
    "DEPARTMENT",
    "START_TS",
    "END_TS",
    "STATUS",
    "RESOURCE_TYPE",
    "CSS_CLASS",
    "RESOURCE_ID",
    "RESOURCE_CODE",
    "USER_ID",
    "USERNAME",
    "FULL_NAME",
    "USER_DEPARTMENT",
    "CHECKEDIN",
    "CHECKIN",
    "LOCATION",
    "CAL_START_TS",
    "CAL_END_TS",
    "NOTES",
    "INVITED_ATTENDEES"
) DEFAULT COLLATION "USING_NLS_COMP" AS
    SELECT
        booking_id id,
        name ||
        CASE
            WHEN resource_type = 'Equipment' THEN
                    ''
            ELSE
                ' ('
                || capacity
                || ')'
        END
        name,
        r.department,
        start_ts,
        end_ts,
        CASE
            WHEN ( current_timestamp BETWEEN start_ts AND end_ts )
                 AND checkin IS NOT NULL THEN
                'In Use'
            ELSE
                status
        END status,
        resource_type,
        CASE resource_type
            WHEN 'Desk' THEN
                'apex-cal-green'
            WHEN 'Meeting Room' THEN
                'apex-cal-yellow'
            WHEN 'Lecture Hall' THEN
                'apex-cal-red'
            WHEN 'Equipment'    THEN
                'apex-cal-silver'
        END AS css_class,
        r.resource_id,
        r.code resource_code,
        u.user_id,
        u.username,
        u.full_name,
        u.department user_department,
        checkin checkedin,
        CASE
            WHEN ( current_timestamp BETWEEN start_ts - INTERVAL '15' MINUTE AND end_ts )
                 AND checkin IS NULL THEN
                'Click here to Check in'
            ELSE
                ''
        END checkin,
        location,
        to_char(start_ts, 'YYYY-MM-DD')
        || 'T'
        || to_char(start_ts, 'HH24:MI:SS') cal_start_ts,
        to_char(end_ts, 'YYYY-MM-DD')
        || 'T'
        || to_char(end_ts, 'HH24:MI:SS')   cal_end_ts,
        b.notes,
        (
            SELECT
                COUNT(*)
            FROM
                booking_attendees a
            WHERE
                b.booking_id = a.booking_id
        ) invited_attendees
    FROM
        bookings     b,
        resources    r,
        campus_users u
    WHERE
            b.resource_id = r.resource_id
        AND b.user_id = u.user_id
  --and status = 'CONFIRMED'
    ORDER BY
        start_ts DESC;
REM INSERTING into NCIPROJECT.BOOKINGS
SET DEFINE OFF;


--------------------------------------------------------
--  DDL for Index IDX_ATTENDEES
--------------------------------------------------------

CREATE INDEX "NCIPROJECT"."IDX_ATTENDEES" ON
    "NCIPROJECT"."BOOKING_ATTENDEES" (
        "BOOKING_ID",
        "EMAIL"
    );
--------------------------------------------------------
--  DDL for Index SYS_C0028089
--------------------------------------------------------

CREATE UNIQUE INDEX "NCIPROJECT"."SYS_C0028089" ON
    "NCIPROJECT"."RESOURCES" (
        "RESOURCE_ID"
    );
--------------------------------------------------------
--  DDL for Index SYS_C0028090
--------------------------------------------------------

CREATE UNIQUE INDEX "NCIPROJECT"."SYS_C0028090" ON
    "NCIPROJECT"."RESOURCES" (
        "CODE"
    );
--------------------------------------------------------
--  DDL for Index SYS_C0028110
--------------------------------------------------------

CREATE UNIQUE INDEX "NCIPROJECT"."SYS_C0028110" ON
    "NCIPROJECT"."CAMPUS_USERS" (
        "USER_ID"
    );
--------------------------------------------------------
--  DDL for Index SYS_C0028111
--------------------------------------------------------

CREATE UNIQUE INDEX "NCIPROJECT"."SYS_C0028111" ON
    "NCIPROJECT"."CAMPUS_USERS" (
        "USERNAME"
    );
--------------------------------------------------------
--  DDL for Index SYS_C0028137
--------------------------------------------------------

CREATE UNIQUE INDEX "NCIPROJECT"."SYS_C0028137" ON
    "NCIPROJECT"."BOOKINGS" (
        "BOOKING_ID"
    );
--------------------------------------------------------
--  DDL for Index SYS_C0028186
--------------------------------------------------------

CREATE UNIQUE INDEX "NCIPROJECT"."SYS_C0028186" ON
    "NCIPROJECT"."BOOKING_ATTENDEES" (
        "ATTENDEE_ID"
    );
--------------------------------------------------------
--  DDL for Index SYS_C0028137
--------------------------------------------------------

CREATE UNIQUE INDEX "NCIPROJECT"."SYS_C0028137" ON
    "NCIPROJECT"."BOOKINGS" (
        "BOOKING_ID"
    );
    
    
--------------------------------------------------------
--  DDL for Index SYS_C0028089
--------------------------------------------------------

CREATE UNIQUE INDEX "NCIPROJECT"."SYS_C0028089" ON
    "NCIPROJECT"."RESOURCES" (
        "RESOURCE_ID"
    );

--------------------------------------------------------
--  DDL for Trigger TRG_BIU_BOOKINGS
--------------------------------------------------------

CREATE OR REPLACE TRIGGER "NCIPROJECT"."TRG_BIU_BOOKINGS" FOR
    INSERT OR UPDATE ON bookings
COMPOUND TRIGGER
/* ==============================================================================================================
  Author       : Tim O’Leary
  Student ID   : 23287021
  Version      : 1.0
  Program      : Higher Diploma in Science in Computing
  Module       : Project (HDSDEV_JAN25)
  Lecturer     : Lisa Murphy

  Description  : Trigger on BOOKINGS for INSERT and UPDATE.
                 - BEFORE EACH ROW: captures :NEW values (resource_id, start_ts, end_ts, booking_id),
                   assigns seq_bookings.NEXTVAL and booking_ref 
                 - AFTER STATEMENT: counts overlapping, non-cancelled bookings for the captured
                   resource/time window and calls campus_booking_pkg.check_booking_conflict with
                   the captured values and the computed count.
                 - Purpose: detect/prevent booking conflicts.

  Notes        :
    - Uses v('APP_USER') with fallback to USER; v('APP_USER') is NULL outside APEX — confirm intent.
    - Business logic checks: NVL(b.status, 'CONFIRMED') != 'CANCELLED' treats NULL as CONFIRMED — verify this aligns
        with business rules.

============================================================================================================== */




  -- Top-level record type to capture relevant row values
    TYPE booking_rec IS RECORD (
            resource_id bookings.resource_id%TYPE,
            start_ts    bookings.start_ts%TYPE,
            end_ts      bookings.end_ts%TYPE,
            booking_id  bookings.booking_id%TYPE
    );
    booking_data booking_rec;
    v_count      NUMBER;
    BEFORE EACH ROW IS BEGIN
  -- Capture the :NEW values for later statement-level processing
        booking_data.resource_id := :new.resource_id;
        booking_data.start_ts := :new.start_ts;
        booking_data.end_ts := :new.end_ts;
        booking_data.booking_id := :new.booking_id;
        IF inserting THEN
    -- Ensure booking_id and booking_ref are populated for new rows
            IF :new.booking_id IS NULL THEN
                :new.booking_id := seq_bookings.nextval;
                :new.booking_ref := campus_booking_pkg.generate_booking_ref;
            END IF;

    -- Set created_by from APEX application user if available, otherwise DB user
            :new.created_by := coalesce(
                v('APP_USER'),
                user
            );
        ELSE
    -- For updates, set audit columns
            :new.last_updated_by := coalesce(
                v('APP_USER'),
                user
            );
            :new.last_update_date := sysdate;
        END IF;

    END BEFORE EACH ROW;
    AFTER STATEMENT IS BEGIN
  -- Count overlapping, non-cancelled bookings for the captured resource and time window
        SELECT
            COUNT(*)
        INTO v_count
        FROM
            bookings b
        WHERE
                b.resource_id = booking_data.resource_id
            AND nvl(b.status, 'CONFIRMED') != 'CANCELLED'
            AND b.start_ts < booking_data.end_ts
            AND b.end_ts > booking_data.start_ts
            AND ( booking_data.booking_id IS NULL
                  OR b.booking_id != booking_data.booking_id );

  -- Delegate conflict handling to package procedure
        campus_booking_pkg.check_booking_conflict(
            p_resource_id => booking_data.resource_id,
            p_start_ts    => booking_data.start_ts,
            p_end_ts      => booking_data.end_ts,
            p_booking_id  => booking_data.booking_id,
            p_count       => nvl(v_count, 0)
        );

    END AFTER STATEMENT;
END trg_biu_bookings;
/

ALTER TRIGGER "NCIPROJECT"."TRG_BIU_BOOKINGS" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TRG_BIU_BOOKING_ATTENDEES
--------------------------------------------------------

CREATE OR REPLACE TRIGGER "NCIPROJECT"."TRG_BIU_BOOKING_ATTENDEES" BEFORE
    INSERT OR UPDATE ON booking_attendees
    FOR EACH ROW
DECLARE

/* =============================================================================================================
  Author       : Tim O’Leary
  Student ID   : 23287021
  Version      : 1.0
  Program      : Higher Diploma in Science in Computing
  Module       : Project (HDSDEV_JAN25)
  Lecturer     : Lisa Murphy

  Description  : Trigger on BOOKING_ATTENDEES for INSERT and UPDATE.
                 
  Notes        :
    - Uses v('APP_USER') which is NULL outside APEX; falls back to USER.
============================================================================================================= */ BEGIN
  -- If inserting a new attendee row
    IF inserting THEN

    -- Ensure primary key is populated; use sequence if not provided
        IF :new.attendee_id IS NULL THEN
            :new.attendee_id := seq_booking_attendees.nextval;
        END IF;

    -- Set created_by from APEX application user when available, otherwise DB user
        :new.created_by := coalesce(
            v('APP_USER'),
            user
        );
    ELSE
    -- For updates, maintain audit columns
        :new.last_updated_by := coalesce(
            v('APP_USER'),
            user
        );
        :new.last_update_date := sysdate;
    END IF;
END trg_biu_booking_attendees;
/

ALTER TRIGGER "NCIPROJECT"."TRG_BIU_BOOKING_ATTENDEES" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TRG_BIU_CAMPUS_USERS
--------------------------------------------------------

CREATE OR REPLACE TRIGGER "NCIPROJECT"."TRG_BIU_CAMPUS_USERS" 
/* =============================================================================================================
  Author       : Tim O’Leary
  Student ID   : 23287021
  Version      : 1.0
  Program      : Higher Diploma in Science in Computing
  Module       : Project (HDSDEV_JAN25)
  Lecturer     : Lisa Murphy

  Description  : Trigger on CAMPUS_USERS for INSERT and UPDATE.
                 - Manage profile image metadata: compute FILE_SIZE from BLOB and
                   enforce a 50 MB limit; clear metadata when blob is removed.
                 - Hash password when provided on insert or when changed on update.

  Notes        :
    - Uses v('APP_USER') which is NULL outside APEX; falls back to USER.
    - Enforces attachment size limit via DBMS_LOB.GETLENGTH; ensure PROFILE_IMAGE is a BLOB.
    - Password hashing delegates to CUSTOM_AUTHENTICATION.hash_password(username, password).

============================================================================================================= */ BEFORE
    INSERT OR UPDATE ON campus_users
    FOR EACH ROW
DECLARE
  -- 2 MB maximum attachment size
    v_max_bytes CONSTANT NUMBER := 2 * 1024 * 1024;
BEGIN
    IF inserting THEN
    -- Ensure primary key populated
        IF :new.user_id IS NULL THEN
            :new.user_id := seq_campus_users.nextval;
        END IF;

    -- Created by from APEX APP_USER when available, otherwise DB user
        :new.created_by := coalesce(
            v('APP_USER'),
            user
        );
    ELSE
    -- Update audit columns
        :new.last_updated_by := coalesce(
            v('APP_USER'),
            user
        );
        :new.last_update_date := sysdate;
    END IF;

  -- Manage profile image metadata and enforce size limit
    IF :new.profile_image IS NOT NULL THEN
    -- If a BLOB is provided, compute its size
        BEGIN
            :new.file_size := dbms_lob.getlength(:new.profile_image);
        EXCEPTION
            WHEN OTHERS THEN
        -- If DBMS_LOB fails for any reason, set file_size to NULL to avoid incorrect values
                :new.file_size := NULL;
        END;

    -- Enforce maximum size
        IF
            :new.file_size IS NOT NULL
            AND :new.file_size > v_max_bytes
        THEN
            raise_application_error(-20001, 'Attachment exceeds maximum allowed size of 2 MB.');
        END IF;

    ELSE
    -- If blob explicitly cleared (NULL), and no filename provided, clear metadata
        IF :new.file_name IS NULL THEN
            :new.file_size := 0;
            :new.mime_type := NULL;
        END IF;
    END IF;

  -- Password hashing: hash on insert or when password is changed on update
    IF :new.password IS NOT NULL THEN
        IF inserting
        OR (
            updating('PASSWORD')
            AND ( :old.password IS NULL
                  OR :new.password <> :old.password )
        ) THEN
      -- Replace plain password with hashed value
            :new.password := custom_authentication.hash_password(:new.username,
                                                                 :new.password);

        END IF;
    END IF;

END trg_biu_campus_users;
/

ALTER TRIGGER "NCIPROJECT"."TRG_BIU_CAMPUS_USERS" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TRG_BIU_RESOURCES
--------------------------------------------------------

CREATE OR REPLACE TRIGGER "NCIPROJECT"."TRG_BIU_RESOURCES" BEFORE
    INSERT OR UPDATE ON resources
    FOR EACH ROW
/* =============================================================================================================
  Author       : Tim O’Leary
  Student ID   : 23287021
  Version      : 1.0
  Program      : Higher Diploma in Science in Computing
  Module       : Project (HDSDEV_JAN25)
  Lecturer     : Lisa Murphy

  Description  : Trigger on RESOURCES for INSERT and UPDATE.


  Notes        :
    - Uses v('APP_USER') which is NULL outside APEX user DB USER.

============================================================================================================= */



BEGIN
    IF inserting THEN
    -- Ensure primary key populated
        IF :new.resource_id IS NULL THEN
            :new.resource_id := seq_resources.nextval;
        END IF;

    -- Created by from APEX APP_USER when available, otherwise DB user
        :new.created_by := coalesce(
            v('APP_USER'),
            user
        );
    ELSE
    -- Update audit columns
        :new.last_updated_by := coalesce(
            v('APP_USER'),
            user
        );
        :new.last_update_date := sysdate;
    END IF;
END trg_biu_resources;
/

ALTER TRIGGER "NCIPROJECT"."TRG_BIU_RESOURCES" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TRG_BIU_BOOKINGS
--------------------------------------------------------

CREATE OR REPLACE TRIGGER "NCIPROJECT"."TRG_BIU_BOOKINGS" FOR
    INSERT OR UPDATE ON bookings
COMPOUND TRIGGER
/* ==============================================================================================================
  Author       : Tim O’Leary
  Student ID   : 23287021
  Version      : 1.0
  Program      : Higher Diploma in Science in Computing
  Module       : Project (HDSDEV_JAN25)
  Lecturer     : Lisa Murphy

  Description  : Trigger on BOOKINGS for INSERT and UPDATE.
                 - BEFORE EACH ROW: captures :NEW values (resource_id, start_ts, end_ts, booking_id),
                   assigns seq_bookings.NEXTVAL and booking_ref 
                 - AFTER STATEMENT: counts overlapping, non-cancelled bookings for the captured
                   resource/time window and calls campus_booking_pkg.check_booking_conflict with
                   the captured values and the computed count.
                 - Purpose: detect/prevent booking conflicts.

  Notes        :
    - Uses v('APP_USER') with fallback to USER; v('APP_USER') is NULL outside APEX — confirm intent.
    - Business logic checks: NVL(b.status, 'CONFIRMED') != 'CANCELLED' treats NULL as CONFIRMED — verify this aligns
        with business rules.

============================================================================================================== */




  -- Top-level record type to capture relevant row values
    TYPE booking_rec IS RECORD (
            resource_id bookings.resource_id%TYPE,
            start_ts    bookings.start_ts%TYPE,
            end_ts      bookings.end_ts%TYPE,
            booking_id  bookings.booking_id%TYPE
    );
    booking_data booking_rec;
    v_count      NUMBER;
    BEFORE EACH ROW IS BEGIN
  -- Capture the :NEW values for later statement-level processing
        booking_data.resource_id := :new.resource_id;
        booking_data.start_ts := :new.start_ts;
        booking_data.end_ts := :new.end_ts;
        booking_data.booking_id := :new.booking_id;
        IF inserting THEN
    -- Ensure booking_id and booking_ref are populated for new rows
            IF :new.booking_id IS NULL THEN
                :new.booking_id := seq_bookings.nextval;
                :new.booking_ref := campus_booking_pkg.generate_booking_ref;
            END IF;

    -- Set created_by from APEX application user if available, otherwise DB user
            :new.created_by := coalesce(
                v('APP_USER'),
                user
            );
        ELSE
    -- For updates, set audit columns
            :new.last_updated_by := coalesce(
                v('APP_USER'),
                user
            );
            :new.last_update_date := sysdate;
        END IF;

    END BEFORE EACH ROW;
    AFTER STATEMENT IS BEGIN
  -- Count overlapping, non-cancelled bookings for the captured resource and time window
        SELECT
            COUNT(*)
        INTO v_count
        FROM
            bookings b
        WHERE
                b.resource_id = booking_data.resource_id
            AND nvl(b.status, 'CONFIRMED') != 'CANCELLED'
            AND b.start_ts < booking_data.end_ts
            AND b.end_ts > booking_data.start_ts
            AND ( booking_data.booking_id IS NULL
                  OR b.booking_id != booking_data.booking_id );

  -- Delegate conflict handling to package procedure
        campus_booking_pkg.check_booking_conflict(
            p_resource_id => booking_data.resource_id,
            p_start_ts    => booking_data.start_ts,
            p_end_ts      => booking_data.end_ts,
            p_booking_id  => booking_data.booking_id,
            p_count       => nvl(v_count, 0)
        );

    END AFTER STATEMENT;
END trg_biu_bookings;
/

ALTER TRIGGER "NCIPROJECT"."TRG_BIU_BOOKINGS" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TRG_BIU_BOOKING_ATTENDEES
--------------------------------------------------------

CREATE OR REPLACE TRIGGER "NCIPROJECT"."TRG_BIU_BOOKING_ATTENDEES" BEFORE
    INSERT OR UPDATE ON booking_attendees
    FOR EACH ROW
DECLARE

/* =============================================================================================================
  Author       : Tim O’Leary
  Student ID   : 23287021
  Version      : 1.0
  Program      : Higher Diploma in Science in Computing
  Module       : Project (HDSDEV_JAN25)
  Lecturer     : Lisa Murphy

  Description  : Trigger on BOOKING_ATTENDEES for INSERT and UPDATE.
                 
  Notes        :
    - Uses v('APP_USER') which is NULL outside APEX; falls back to USER.
============================================================================================================= */ BEGIN
  -- If inserting a new attendee row
    IF inserting THEN

    -- Ensure primary key is populated; use sequence if not provided
        IF :new.attendee_id IS NULL THEN
            :new.attendee_id := seq_booking_attendees.nextval;
        END IF;

    -- Set created_by from APEX application user when available, otherwise DB user
        :new.created_by := coalesce(
            v('APP_USER'),
            user
        );
    ELSE
    -- For updates, maintain audit columns
        :new.last_updated_by := coalesce(
            v('APP_USER'),
            user
        );
        :new.last_update_date := sysdate;
    END IF;
END trg_biu_booking_attendees;
/

ALTER TRIGGER "NCIPROJECT"."TRG_BIU_BOOKING_ATTENDEES" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TRG_BIU_CAMPUS_USERS
--------------------------------------------------------

CREATE OR REPLACE TRIGGER "NCIPROJECT"."TRG_BIU_CAMPUS_USERS" 
/* =============================================================================================================
  Author       : Tim O’Leary
  Student ID   : 23287021
  Version      : 1.0
  Program      : Higher Diploma in Science in Computing
  Module       : Project (HDSDEV_JAN25)
  Lecturer     : Lisa Murphy

  Description  : Trigger on CAMPUS_USERS for INSERT and UPDATE.
                 - Manage profile image metadata: compute FILE_SIZE from BLOB and
                   enforce a 50 MB limit; clear metadata when blob is removed.
                 - Hash password when provided on insert or when changed on update.

  Notes        :
    - Uses v('APP_USER') which is NULL outside APEX; falls back to USER.
    - Enforces attachment size limit via DBMS_LOB.GETLENGTH; ensure PROFILE_IMAGE is a BLOB.
    - Password hashing delegates to CUSTOM_AUTHENTICATION.hash_password(username, password).

============================================================================================================= */ BEFORE
    INSERT OR UPDATE ON campus_users
    FOR EACH ROW
DECLARE
  -- 50 MB maximum attachment size
    v_max_bytes CONSTANT NUMBER := 50 * 1024 * 1024;
BEGIN
    IF inserting THEN
    -- Ensure primary key populated
        IF :new.user_id IS NULL THEN
            :new.user_id := seq_campus_users.nextval;
        END IF;

    -- Created by from APEX APP_USER when available, otherwise DB user
        :new.created_by := coalesce(
            v('APP_USER'),
            user
        );
    ELSE
    -- Update audit columns
        :new.last_updated_by := coalesce(
            v('APP_USER'),
            user
        );
        :new.last_update_date := sysdate;
    END IF;

  -- Manage profile image metadata and enforce size limit
    IF :new.profile_image IS NOT NULL THEN
    -- If a BLOB is provided, compute its size
        BEGIN
            :new.file_size := dbms_lob.getlength(:new.profile_image);
        EXCEPTION
            WHEN OTHERS THEN
        -- If DBMS_LOB fails for any reason, set file_size to NULL to avoid incorrect values
                :new.file_size := NULL;
        END;

    -- Enforce maximum size
        IF
            :new.file_size IS NOT NULL
            AND :new.file_size > v_max_bytes
        THEN
            raise_application_error(-20001, 'Attachment exceeds maximum allowed size of 50 MB.');
        END IF;

    ELSE
    -- If blob explicitly cleared (NULL), and no filename provided, clear metadata
        IF :new.file_name IS NULL THEN
            :new.file_size := 0;
            :new.mime_type := NULL;
        END IF;
    END IF;

  -- Password hashing: hash on insert or when password is changed on update
    IF :new.password IS NOT NULL THEN
        IF inserting
        OR (
            updating('PASSWORD')
            AND ( :old.password IS NULL
                  OR :new.password <> :old.password )
        ) THEN
      -- Replace plain password with hashed value
            :new.password := custom_authentication.hash_password(:new.username,
                                                                 :new.password);

        END IF;
    END IF;

END trg_biu_campus_users;
/

ALTER TRIGGER "NCIPROJECT"."TRG_BIU_CAMPUS_USERS" ENABLE;
--------------------------------------------------------
--  DDL for Trigger TRG_BIU_RESOURCES
--------------------------------------------------------

CREATE OR REPLACE TRIGGER "NCIPROJECT"."TRG_BIU_RESOURCES" BEFORE
    INSERT OR UPDATE ON resources
    FOR EACH ROW
/* =============================================================================================================
  Author       : Tim O’Leary
  Student ID   : 23287021
  Version      : 1.0
  Program      : Higher Diploma in Science in Computing
  Module       : Project (HDSDEV_JAN25)
  Lecturer     : Lisa Murphy

  Description  : Trigger on RESOURCES for INSERT and UPDATE.


  Notes        :
    - Uses v('APP_USER') which is NULL outside APEX user DB USER.

============================================================================================================= */



BEGIN
    IF inserting THEN
    -- Ensure primary key populated
        IF :new.resource_id IS NULL THEN
            :new.resource_id := seq_resources.nextval;
        END IF;

    -- Created by from APEX APP_USER when available, otherwise DB user
        :new.created_by := coalesce(
            v('APP_USER'),
            user
        );
    ELSE
    -- Update audit columns
        :new.last_updated_by := coalesce(
            v('APP_USER'),
            user
        );
        :new.last_update_date := sysdate;
    END IF;
END trg_biu_resources;
/

ALTER TRIGGER "NCIPROJECT"."TRG_BIU_RESOURCES" ENABLE;
--------------------------------------------------------
--  DDL for Package CAMPUS_BOOKING_PKG
--------------------------------------------------------

CREATE OR REPLACE PACKAGE "NCIPROJECT"."CAMPUS_BOOKING_PKG" AS

/* =============================================================================================================
  Author       : Tim O’Leary
  Student ID   : 23287021
  Version      : 1.0
  Program      : Higher Diploma in Science in Computing
  Module       : Project (HDSDEV_JAN25)
  Lecturer     : Lisa Murphy

  Description  : Package campus_booking_pkg centralises booking operations:
                 - check_booking_conflict: validates time ranges, loads resource metadata,
                   computes or accepts overlapping booking counts, and raises an error when
                   availability is exceeded.
                 - create_modify_booking: inserts or updates bookings, generates booking_ref,
                   calls conflict checking, and returns booking_id.
                 - set_booking_status: updates a booking's status.
                 - notify_booking_created: placeholder to resolve booking owner and send notifications.
                 - generate_booking_ref: returns a GUID-based booking reference.

  Notes        :
    - Conflict detection: check_booking_conflict validates p_start_ts < p_end_ts and requires the resource
      to be active (active_flag = 'Y'); callers should handle NO_DATA_FOUND where appropriate.
    - Count handling: callers may pass a precomputed p_count to avoid re-querying; when p_count is zero
      the procedure computes overlapping bookings itself.
    - Error handling: uses RAISE_APPLICATION_ERROR for errors.
    - Due to time constrants create_modify_booking, inserts or updates bookings are done from standard apex functionality 
============================================================================================================= */



  -- Validate overlapping bookings for a resource/time window.
    PROCEDURE check_booking_conflict (
        p_resource_id IN bookings.resource_id%TYPE,
        p_start_ts    IN bookings.start_ts%TYPE,
        p_end_ts      IN bookings.end_ts%TYPE,
        p_booking_id  IN bookings.booking_id%TYPE DEFAULT NULL,
        p_count       IN NUMBER DEFAULT 0
    );

  -- Update booking status
    PROCEDURE set_booking_status (
        p_booking_id IN bookings.booking_id%TYPE,
        p_status     IN bookings.status%TYPE
    );

  -- Notify stakeholders that a booking was created (implementation placeholder)
    PROCEDURE notify_booking_created (
        p_booking_id IN bookings.booking_id%TYPE
    );

  -- Insert or update a booking; returns booking_id
    FUNCTION create_modify_booking (
        p_booking_id  IN bookings.booking_id%TYPE,
        p_resource_id IN bookings.resource_id%TYPE,
        p_user_id     IN bookings.user_id%TYPE,
        p_start_ts    IN bookings.start_ts%TYPE,
        p_end_ts      IN bookings.end_ts%TYPE,
        p_notes       IN bookings.notes%TYPE,
        p_status      IN bookings.status%TYPE
    ) RETURN NUMBER;

  -- Generate a unique booking reference
    FUNCTION generate_booking_ref RETURN VARCHAR2;

END campus_booking_pkg;
/
--------------------------------------------------------
--  DDL for Package CUSTOM_AUTHENTICATION
--------------------------------------------------------

CREATE OR REPLACE PACKAGE "NCIPROJECT"."CUSTOM_AUTHENTICATION" AS

/* =============================================================================================================
  Author       : Tim O’Leary
  Student ID   : 23287021
  Version      : 1.0
  Program      : Higher Diploma in Science in Computing
  Module       : Project (HDSDEV_JAN25)
  Lecturer     : Lisa Murphy

  Description  : Custom authentication package for APEX.
                 - Hash_password: returns a hashed password.

  Notes        :
    - Uses case-insensitive username comparison (UPPER).
    - Returns BOOLEAN from cba_custom_auth
    - Handles NO_DATA_FOUND and other exceptions
    - Ensure campus_users.password stores values produced by Hash_password.
============================================================================================================= */


  -- global username holder (set when authentication succeeds)
    g_username VARCHAR2(1000);

  -- Hash password function
    FUNCTION hash_password (
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN VARCHAR2;

  -- Custom authentication function: returns TRUE when credentials valid
    FUNCTION cba_custom_auth (
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN;

END custom_authentication;
/
--------------------------------------------------------
--  DDL for Package Body CAMPUS_BOOKING_PKG
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY "NCIPROJECT"."CAMPUS_BOOKING_PKG" AS

  -- check_booking_conflict
  -- Validates the requested time window and ensures resource availability.
  -- If p_count = 0 the procedure computes the overlapping booking count itself.

    PROCEDURE check_booking_conflict (
        p_resource_id IN bookings.resource_id%TYPE,
        p_start_ts    IN bookings.start_ts%TYPE,
        p_end_ts      IN bookings.end_ts%TYPE,
        p_booking_id  IN bookings.booking_id%TYPE DEFAULT NULL,
        p_count       IN NUMBER DEFAULT 0
    ) IS

        v_count     NUMBER := p_count;
        v_name      resources.name%TYPE;
        v_type      resources.resource_type%TYPE;
        v_available resources.resource_available%TYPE;
        v_msg       VARCHAR2(4000);
    BEGIN
    -- Basic validation
        IF p_end_ts <= p_start_ts THEN
            raise_application_error(-20001, 'End time must be after start time.');
        END IF;

    -- Load resource metadata; raises NO_DATA_FOUND if resource not active or missing
        SELECT
            name,
            resource_type,
            resource_available
        INTO
            v_name,
            v_type,
            v_available
        FROM
            resources
        WHERE
                resource_id = p_resource_id
            AND active_flag = 'Y';

    -- If caller did not supply a count, compute overlapping bookings now
        IF v_count IS NULL
           OR v_count = 0 THEN
            SELECT
                COUNT(*)
            INTO v_count
            FROM
                bookings b
            WHERE
                    b.resource_id = p_resource_id
                AND nvl(b.status, 'CONFIRMED') != 'CANCELLED'
                AND b.start_ts < p_end_ts
                AND b.end_ts > p_start_ts
                AND ( p_booking_id IS NULL
                      OR b.booking_id != p_booking_id );

        END IF;

    -- Compare against availability
        IF v_count > nvl(v_available, 0) THEN
            IF upper(nvl(v_type, '')) = 'EQUIPMENT' THEN
                v_msg := 'Booking conflict: there are no '
                         || v_name
                         || ' available within that time range.';
            ELSE
                v_msg := 'Booking conflict: '
                         || v_name
                         || ' already booked in that time range.';
            END IF;

            raise_application_error(-20002, v_msg 
        -- debug return info || ' count:' || v_count || ' passed_count:' || p_count || ' available:' || NVL(v_available,0)

            );
        END IF;

    END check_booking_conflict;

  -- create_modify_booking
  -- Inserts a new booking or updates an existing one. Returns booking_id.
  -- Note: this routine calls check_booking_conflict which will compute counts if needed.
    FUNCTION create_modify_booking (
        p_booking_id  IN bookings.booking_id%TYPE,
        p_resource_id IN bookings.resource_id%TYPE,
        p_user_id     IN bookings.user_id%TYPE,
        p_start_ts    IN bookings.start_ts%TYPE,
        p_end_ts      IN bookings.end_ts%TYPE,
        p_notes       IN bookings.notes%TYPE,
        p_status      IN bookings.status%TYPE
    ) RETURN NUMBER IS
        l_booking_id NUMBER;
        l_ref        VARCHAR2(64);
    BEGIN
    -- Validate conflicts (check_booking_conflict will compute overlapping count if needed)
        check_booking_conflict(
            p_resource_id => p_resource_id,
            p_start_ts    => p_start_ts,
            p_end_ts      => p_end_ts,
            p_booking_id  => p_booking_id
        );

        l_ref := generate_booking_ref();
        IF p_booking_id IS NULL THEN
            INSERT INTO bookings (
                resource_id,
                user_id,
                start_ts,
                end_ts,
                status,
                booking_ref,
                notes
            ) VALUES ( p_resource_id,
                       p_user_id,
                       p_start_ts,
                       p_end_ts,
                       'CONFIRMED',
                       l_ref,
                       p_notes ) RETURNING booking_id INTO l_booking_id;

        ELSE
            l_booking_id := p_booking_id;
            UPDATE bookings
            SET
                resource_id = p_resource_id,
                user_id = p_user_id,
                start_ts = p_start_ts,
                end_ts = p_end_ts,
                status = p_status,
                notes = p_notes
            WHERE
                booking_id = p_booking_id;

        END IF;

        COMMIT;
        RETURN l_booking_id;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END create_modify_booking;

  -- generate_booking_ref
    FUNCTION generate_booking_ref RETURN VARCHAR2 IS
    BEGIN
        RETURN rawtohex(sys_guid());
    END generate_booking_ref;

  -- set_booking_status
    PROCEDURE set_booking_status (
        p_booking_id IN bookings.booking_id%TYPE,
        p_status     IN bookings.status%TYPE
    ) IS
    BEGIN
        UPDATE bookings
        SET
            status = p_status
        WHERE
            booking_id = p_booking_id;

        COMMIT;
    END set_booking_status;

  -- notify_booking_created
    PROCEDURE notify_booking_created (
        p_booking_id IN bookings.booking_id%TYPE
    ) IS
        v_user_email VARCHAR2(200);
        v_user_name  VARCHAR2(200);
    BEGIN
        SELECT
            u.email,
            u.full_name
        INTO
            v_user_email,
            v_user_name
        FROM
                 bookings b
            JOIN campus_users u ON b.user_id = u.user_id
        WHERE
            b.booking_id = p_booking_id;

        COMMIT;
    EXCEPTION
        WHEN no_data_found THEN
      -- No user found for booking;
            NULL;
    END notify_booking_created;

END campus_booking_pkg;
/
--------------------------------------------------------
--  DDL for Package Body CUSTOM_AUTHENTICATION
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY "NCIPROJECT"."CUSTOM_AUTHENTICATION" AS

  -- Hash_password
  -- Produces a hashed representation of username+password using APEX utility.
  -- Note: the username is upper-cased to ensure consistent hashing regardless of case.
    FUNCTION hash_password (
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN VARCHAR2 IS
        encrp_password VARCHAR2(4000);
    BEGIN
        encrp_password := apex_util.get_hash(
            apex_t_varchar2(
                upper(p_username),
                p_password
            ),
            FALSE
        );

        RETURN encrp_password;
    END hash_password;

  -- cba_custom_auth
  -- Verifies credentials against campus_users.password.
  -- On success sets CUSTOM_AUTHENTICATION.g_username and returns TRUE.
  -- Returns FALSE on any failure (no user, mismatch, or error).

    FUNCTION cba_custom_auth (
        p_username IN VARCHAR2,
        p_password IN VARCHAR2
    ) RETURN BOOLEAN IS
        l_hash_password   VARCHAR2(4000);
        l_stored_password VARCHAR2(4000);
        l_count           NUMBER := 0;
    BEGIN
    -- Basic existence check
        SELECT
            COUNT(*)
        INTO l_count
        FROM
            campus_users
        WHERE
            upper(username) = upper(p_username);

        IF l_count = 0 THEN
            RETURN FALSE;
        END IF;

    -- Retrieve stored password for the user
        SELECT
            password
        INTO l_stored_password
        FROM
            campus_users
        WHERE
                upper(username) = upper(p_username)
            AND ROWNUM = 1;

    -- Compute hash of supplied credentials
        l_hash_password := hash_password(p_username, p_password);

    -- Compare hashes
        IF
            l_hash_password IS NOT NULL
            AND l_stored_password IS NOT NULL
            AND l_hash_password = l_stored_password
        THEN
      -- Authentication successful: set global username for session use
            g_username := p_username;
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;

    EXCEPTION
        WHEN no_data_found THEN
      -- No matching user/password found
            RETURN FALSE;
        WHEN OTHERS THEN
      -- Log or handle unexpected errors 
            RETURN FALSE;
    END cba_custom_auth;

END custom_authentication;



--------------------------------------------------------------

/
--------------------------------------------------------
--  DDL for Function CBA_CUSTOM_AUTH
--------------------------------------------------------

CREATE OR REPLACE FUNCTION "NCIPROJECT"."CBA_CUSTOM_AUTH" (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
) RETURN BOOLEAN IS
    l_password        VARCHAR2(4000);
    l_stored_password VARCHAR2(4000);

  --  l_expires_on      TIMESTAMP;

    l_count           NUMBER;
BEGIN



    -- First, check to see if the user is in the user table

    SELECT
        COUNT(*)
    INTO l_count
    FROM
        campus_users
    WHERE
        upper(username) = upper(p_username);

    IF l_count > 0 THEN

      -- First, we fetch the stored hashed password & expire date

        SELECT
            password
        INTO l_stored_password
        FROM
            campus_users
        WHERE
            upper(username) = upper(p_username);

        IF l_password = l_stored_password THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    ELSE

      -- The username provided is not in the campus_USERS table

        RETURN FALSE;
    END IF;

END;
/

--------------------------------------------------------
--  Constraints for Table BOOKINGS
--------------------------------------------------------

ALTER TABLE "NCIPROJECT"."BOOKINGS" MODIFY (
    "RESOURCE_ID" NOT NULL ENABLE
);

ALTER TABLE "NCIPROJECT"."BOOKINGS" MODIFY (
    "USER_ID" NOT NULL ENABLE
);

ALTER TABLE "NCIPROJECT"."BOOKINGS" MODIFY (
    "START_TS" NOT NULL ENABLE
);

ALTER TABLE "NCIPROJECT"."BOOKINGS" MODIFY (
    "END_TS" NOT NULL ENABLE
);

ALTER TABLE "NCIPROJECT"."BOOKINGS" ADD PRIMARY KEY ( "BOOKING_ID" );
--------------------------------------------------------
--  Constraints for Table BOOKING_ATTENDEES
--------------------------------------------------------

ALTER TABLE "NCIPROJECT"."BOOKING_ATTENDEES" MODIFY (
    "BOOKING_ID" NOT NULL ENABLE
);

ALTER TABLE "NCIPROJECT"."BOOKING_ATTENDEES" ADD PRIMARY KEY ( "ATTENDEE_ID" );
--------------------------------------------------------
--  Constraints for Table CAMPUS_USERS
--------------------------------------------------------

ALTER TABLE "NCIPROJECT"."CAMPUS_USERS" MODIFY (
    "USERNAME" NOT NULL ENABLE
);

ALTER TABLE "NCIPROJECT"."CAMPUS_USERS" ADD PRIMARY KEY ( "USER_ID" );

ALTER TABLE "NCIPROJECT"."CAMPUS_USERS" ADD UNIQUE ( "USERNAME" );
--------------------------------------------------------
--  Constraints for Table RESOURCES
--------------------------------------------------------

ALTER TABLE "NCIPROJECT"."RESOURCES" MODIFY (
    "CODE" NOT NULL ENABLE
);

ALTER TABLE "NCIPROJECT"."RESOURCES" MODIFY (
    "NAME" NOT NULL ENABLE
);

ALTER TABLE "NCIPROJECT"."RESOURCES" ADD PRIMARY KEY ( "RESOURCE_ID" );

ALTER TABLE "NCIPROJECT"."RESOURCES" ADD UNIQUE ( "CODE" );

ALTER TABLE "NCIPROJECT"."RESOURCES" MODIFY (
    "LOCATION" NOT NULL ENABLE
);

ALTER TABLE "NCIPROJECT"."RESOURCES" MODIFY (
    "RESOURCE_TYPE" NOT NULL ENABLE
);
--------------------------------------------------------
--  Ref Constraints for Table BOOKINGS
--------------------------------------------------------

ALTER TABLE "NCIPROJECT"."BOOKINGS"
    ADD CONSTRAINT "FK_BOOK_RESOURCE"
        FOREIGN KEY ( "RESOURCE_ID" )
            REFERENCES "NCIPROJECT"."RESOURCES" ( "RESOURCE_ID" )
        ENABLE;

ALTER TABLE "NCIPROJECT"."BOOKINGS"
    ADD CONSTRAINT "FK_BOOK_USER"
        FOREIGN KEY ( "USER_ID" )
            REFERENCES "NCIPROJECT"."CAMPUS_USERS" ( "USER_ID" )
        ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table BOOKING_ATTENDEES
--------------------------------------------------------

ALTER TABLE "NCIPROJECT"."BOOKING_ATTENDEES"
    ADD CONSTRAINT "FK_BOOK_ATENDEE"
        FOREIGN KEY ( "BOOKING_ID" )
            REFERENCES "NCIPROJECT"."BOOKINGS" ( "BOOKING_ID" )
        ENABLE;

ALTER TABLE "NCIPROJECT"."BOOKING_ATTENDEES"
    ADD CONSTRAINT "FK_BOOK_USER_ATTEND"
        FOREIGN KEY ( "USER_ID" )
            REFERENCES "NCIPROJECT"."CAMPUS_USERS" ( "USER_ID" )
        ENABLE;