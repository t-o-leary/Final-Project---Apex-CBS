--------------------------------------------------------
--  DDL for Function TEST_CBA_CUSTOM_AUTH for testing password
--------------------------------------------------------

CREATE OR REPLACE FUNCTION "NCIPROJECT"."TEST_CBA_CUSTOM_AUTH" (
    p_username IN VARCHAR2,
    p_password IN VARCHAR2
) RETURN BOOLEAN IS
    l_hash_password   VARCHAR2(4000);
    l_stored_password VARCHAR2(4000);
    l_count           NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-------------1-------------');  
    DBMS_OUTPUT.PUT_LINE('user:'||p_username);
    DBMS_OUTPUT.PUT_LINE('pass:'||p_password);  
    DBMS_OUTPUT.PUT_LINE('l_hash_password:'||l_hash_password);
    DBMS_OUTPUT.PUT_LINE('l_stored_password:'||l_stored_password);  
    DBMS_OUTPUT.PUT_LINE('l_count:'||l_count);
    DBMS_OUTPUT.PUT_LINE('--------------------------');



    SELECT
        COUNT(*)
    INTO l_count
    FROM
        campus_users
    WHERE
        upper(username) = upper(p_username);

    DBMS_OUTPUT.PUT_LINE('-------------2-------------');  
    DBMS_OUTPUT.PUT_LINE('user:'||p_username);
    DBMS_OUTPUT.PUT_LINE('pass:'||p_password);  
    DBMS_OUTPUT.PUT_LINE('l_hash_password:'||l_hash_password);
    DBMS_OUTPUT.PUT_LINE('l_stored_password:'||l_stored_password);  
    DBMS_OUTPUT.PUT_LINE('l_count:'||l_count);
    DBMS_OUTPUT.PUT_LINE('--------------------------');

    IF l_count > 0 THEN
        SELECT
            password
        INTO l_stored_password
        FROM
            campus_users
        WHERE
            upper(username) = upper(p_username);

        l_hash_password := custom_authentication.hash_password(p_username, p_password);

    DBMS_OUTPUT.PUT_LINE('------------3-------------');  
    DBMS_OUTPUT.PUT_LINE('user:'||p_username);
    DBMS_OUTPUT.PUT_LINE('pass:'||p_password);  
    DBMS_OUTPUT.PUT_LINE('l_hash_password:'||l_hash_password);
    DBMS_OUTPUT.PUT_LINE('l_stored_password:'||l_stored_password);  
    DBMS_OUTPUT.PUT_LINE('l_count:'||l_count);
    DBMS_OUTPUT.PUT_LINE('--------------------------');

        IF l_hash_password = l_stored_password THEN
    DBMS_OUTPUT.PUT_LINE('-------------4-------------');  
    DBMS_OUTPUT.PUT_LINE('Return: True');
    DBMS_OUTPUT.PUT_LINE('--------------------------');

            RETURN TRUE;
        ELSE
     DBMS_OUTPUT.PUT_LINE('-------------4-------------');  
    DBMS_OUTPUT.PUT_LINE('Return: false');
    DBMS_OUTPUT.PUT_LINE('--------------------------');


            RETURN FALSE;
        END IF;
    ELSE
     DBMS_OUTPUT.PUT_LINE('-------------5-------------');  
    DBMS_OUTPUT.PUT_LINE('Return: false2');
    DBMS_OUTPUT.PUT_LINE('--------------------------');
        RETURN FALSE;
    END IF;

END;
/



-- testing script adding booking

DECLARE
    v_booking_id NUMBER;
BEGIN
    v_booking_id := campus_booking_pkg.create_modify_booking(
        p_booking_id   => null,
        p_resource_id  => 10, -- example resource ID
        p_user_id      => 1, -- example user ID
        p_start_ts     => TO_TIMESTAMP_TZ('2025-10-30 09:00:00 Europe/Dublin', 'YYYY-MM-DD HH24:MI:SS TZR'),
        p_end_ts       => TO_TIMESTAMP_TZ('2025-10-30 23:00:00 Europe/Dublin', 'YYYY-MM-DD HH24:MI:SS TZR'),
        p_notes        => 'Booking of Projector',
        p_status       => 'CONFIRMED'
    );

    DBMS_OUTPUT.PUT_LINE('Booking created with ID: ' || v_booking_id);
END;