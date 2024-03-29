
/*SQL scripts to populate target application tables while normalizing the data loaded in #1.*/

/*SQL Script to normalize the tables*/

--MODIFYING TABLE PROJECT1_BORROWER TO REMOVE MULTIVALUED ATTRIBUTES
ALTER TABLE PROJECT1_BORROWER DROP COLUMN ADDRESS;

ALTER TABLE PROJECT1_BORROWER ADD (
    STREET VARCHAR2(4000) DEFAULT NULL,
    CITY   VARCHAR2(4000) DEFAULT NULL,
    STATE  VARCHAR2(4000) DEFAULT NULL
);

/*SQL Script to Insert Data in the tables*/

--INSERTING DATA IN TABLE PROJECT1_BOOK
INSERT INTO PROJECT1_BOOK (
    ISBN,
    TITLE
)
    SELECT
        ISBN10 AS ISBN,
        TITLE
    FROM
        PROJECT1_BOOKS_LOAD;

--INSERTING DATA IN TABLE PROJECT1_BOOK_AUTHORS
INSERT INTO PROJECT1_BOOK_AUTHORS (
    AUTHOR_ID,
    ISBN
)
    SELECT
        PA.AUTHOR_ID,
        PBL.ISBN
    FROM
            (
            SELECT DISTINCT
                AUTHOR_NAME,
                ISBN
            FROM
                (
                    SELECT
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 1) AUTHOR_NAME,
                        ISBN10 AS ISBN
                    FROM
                        PROJECT1_BOOKS_LOAD
                    WHERE
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 1) IS NOT NULL
                   UNION
                    SELECT
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 2) AUTHOR_NAME,
                        ISBN10 AS ISBN
                    FROM
                        PROJECT1_BOOKS_LOAD
                    WHERE
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 2) IS NOT NULL
                   UNION
                    SELECT
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 3) AUTHOR_NAME,
                        ISBN10 AS ISBN
                    FROM
                        PROJECT1_BOOKS_LOAD
                    WHERE
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 3) IS NOT NULL
                   UNION
                    SELECT
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 4) AUTHOR_NAME,
                        ISBN10 AS ISBN
                    FROM
                        PROJECT1_BOOKS_LOAD
                    WHERE
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 4) IS NOT NULL
                   UNION
                    SELECT
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 5) AUTHOR_NAME,
                        ISBN10 AS ISBN
                    FROM
                        PROJECT1_BOOKS_LOAD
                    WHERE
                        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 5) IS NOT NULL
                )
        ) PBL
        INNER JOIN PROJECT1_AUTHORS PA ON PA.NAME = PBL.AUTHOR_NAME;

--INSERTING DATA IN TABLE PROJECT1_AUTHORS
INSERT INTO PROJECT1_AUTHORS (NAME) SELECT DISTINCT AUTHOR_NAME
FROM
(
    SELECT
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 1) AUTHOR_NAME
    FROM
        PROJECT1_BOOKS_LOAD
    WHERE
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 1) IS NOT NULL
UNION
    SELECT
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 2) AUTHOR_NAME
    FROM
        PROJECT1_BOOKS_LOAD
    WHERE
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 2) IS NOT NULL
UNION
    SELECT
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 3) AUTHOR_NAME
    FROM
        PROJECT1_BOOKS_LOAD
    WHERE
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 3) IS NOT NULL
UNION
    SELECT
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 4) AUTHOR_NAME
    FROM
        PROJECT1_BOOKS_LOAD
    WHERE
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 4) IS NOT NULL
UNION
    SELECT
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 5) AUTHOR_NAME
    FROM
        PROJECT1_BOOKS_LOAD
    WHERE
        REGEXP_SUBSTR(AUTHOR, '[^,]+', 1, 5) IS NOT NULL
);

--INSERTING DATA IN TABLE PROJECT1_LIBRARY_BRANCH
INSERT INTO PROJECT1_LIBRARY_BRANCH (
    BRANCH_ID,
    BRANCH_NAME,
    ADDRESS
)
    SELECT
        BRANCH_ID,
        BRANCH_NAME,
        ADDRESS
    FROM
        PROJECT1_LIBRARY_BRANCH_LOAD;

--INSERTING DATA IN TABLE PROJECT1_BOOK_COPIES
INSERT INTO PROJECT1_BOOK_COPIES (
    ISBN,
    BRANCH_ID,
    NO_OF_COPIES
)
    SELECT
        BOOK_ID AS ISBN,
        BRANCH_ID,
        NO_OF_COPIES
    FROM
        PROJECT1_BOOK_COPIES_LOAD;

--INSERTING DATA IN TABLE PROJECT1_BORROWER
INSERT INTO PROJECT1_BORROWER (
    CARD_NO,
    SSN,
    FNAME,
    LNAME,
    STREET,
    CITY,
    STATE,
    PHONE
)
    SELECT
        ID0000ID   AS CARD_NO,
        SSN,
        FIRST_NAME AS FNAME,
        LAST_NAME  AS LNAME,
        ADDRESS    AS STREET,
        CITY,
        STATE,
        PHONE
    FROM
        PROJECT1_BORROWERS_LOAD; SELECT
    COUNT(*)
FROM
    PROJECT1_BORROWER
SELECT
    COUNT(*)
FROM
    PROJECT1_BORROWER;

/*Exactly 400 books check-outs for exactly 200 different borrowers and exactly 100 different books. Same borrower should not check out same book more than once*/

--INSERTING DATA IN TABLE PROJECT1_BOOK_LOANS
INSERT INTO PROJECT1_BOOK_LOANS (
    BOOK_ID,
    CARD_NO
)
    SELECT
        BOOK_ID,
        CARD_NO
    FROM
        (
            WITH RAND_BORROWER1 AS (
                SELECT
                    ROWNUM ROW_ID,
                    CARD_NO
                FROM
                    (
                        SELECT
                            *
                        FROM
                            PROJECT1_BORROWER
                        WHERE
                            ROWNUM <= 200
                        ORDER BY
                            DBMS_RANDOM.RANDOM
                    )
            ), RAND_BORROWER2 AS (
                SELECT
                    ROWNUM ROW_ID,
                    CARD_NO
                FROM
                    (
                        SELECT
                            *
                        FROM
                            RAND_BORROWER1
                        ORDER BY
                            ROW_ID DESC
                    )
            )
            SELECT
                RB2.ROW_ID,
                RB2.CARD_NO
            FROM
                RAND_BORROWER2 RB2
            UNION ALL
            SELECT
                RB1.ROW_ID,
                RB1.CARD_NO
            FROM
                RAND_BORROWER1 RB1
        ) TEMP1
        LEFT JOIN (
            SELECT
                ROWNUM ROW_ID,
                BOOK_ID
            FROM
                (
                    WITH RAND_BOOKS AS (
                        SELECT
                            ROWNUM ROW_ID,
                            BOOK_ID
                        FROM
                            (
                                SELECT
                                    *
                                FROM
                                    PROJECT1_BOOK_COPIES
                                WHERE
                                    ROWNUM <= 100
                                ORDER BY
                                    DBMS_RANDOM.RANDOM
                            )
                    )
                    SELECT
                        *
                    FROM
                        RAND_BOOKS
                    UNION ALL
                    SELECT
                        *
                    FROM
                        RAND_BOOKS
                )
        ) TEMP2 ON TEMP1.ROW_ID = TEMP2.ROW_ID
    ORDER BY
        CARD_NO;

--MERGING THE DATE COLUMNS IN TABLE PROJECT1_BOOK_LOANS
MERGE INTO PROJECT1_BOOK_LOANS PBL
USING (
    SELECT
        ROWNUM ROW_ID,
        DATE_OUT,
        DATE_IN,
        DUE_DATE
    FROM
        (
            SELECT
                TEMP          AS DATE_OUT,
                DUE_DATE,
                DUE_DATE + 10 AS DATE_IN
            FROM
                (
                    SELECT
                        TEMP,
                        TEMP + 60 AS DUE_DATE
                    FROM
                        (
                            SELECT
                                TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2022-01-01', 'J'),
                                                                TO_CHAR(DATE '2022-10-30', 'J'))),
                                        'J') AS TEMP
                            FROM
                                DUAL
                            CONNECT BY
                                LEVEL <= 400
                        )
                )
            WHERE
                ROWNUM <= 200
            UNION ALL
            SELECT
                TEMP          AS DATE_OUT,
                DUE_DATE,
                DUE_DATE - 10 AS DATE_IN
            FROM
                (
                    SELECT
                        TEMP,
                        TEMP + 60 AS DUE_DATE
                    FROM
                        (
                            SELECT
                                TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(DATE '2022-01-01', 'J'),
                                                                TO_CHAR(DATE '2022-10-30', 'J'))),
                                        'J') AS TEMP
                            FROM
                                DUAL
                            CONNECT BY
                                LEVEL <= 400
                        )
                )
            WHERE
                ROWNUM <= 200
        )
) TABLE_DATE ON ( PBL.LOAN_ID = TABLE_DATE.ROW_ID )
WHEN MATCHED THEN UPDATE
SET PBL.DATE_OUT = TABLE_DATE.DATE_OUT,
    PBL.DATE_IN = TABLE_DATE.DATE_IN,
    PBL.DUE_DATE = TABLE_DATE.DUE_DATE;

/*Exactly 50 fines records for 50 different borrowers. Fines should generated by books checked back in late.*/

--INSERTING DATA IN TABLE PROJECT1_FINES
INSERT INTO PROJECT1_FINES (
    LOAN_ID,
    FINE_AMT,
    PAID
)
    SELECT
        LOAN_ID,
        5   AS FINE_AMT,
        CASE
            WHEN MOD(LOAN_ID, 2) <> 0 THEN
                'YES'
            ELSE
                'NO'
        END AS PAID
    FROM
        (
            SELECT
                LOAN_ID,
                ROW_NUMBER()
                OVER(PARTITION BY CARD_NO
                     ORDER BY
                         CARD_NO
                ) AS RANK,
                CARD_NO,
                DUE_DATE,
                DATE_IN
            FROM
                PROJECT1_BOOK_LOANS
        ) TEMP
    WHERE
            TEMP.RANK = 2
        AND DATE_IN > DUE_DATE
            AND ROWNUM <= 50
    ORDER BY
        DBMS_RANDOM.RANDOM;

/*Book Search and Availability*/

WITH SEARCH AS (
    SELECT
        TEMP.BRANCH_ID,
        TEMP.ISBN,
        TITLE,
        NAME,
        CASE
            WHEN NO_OF_COPIES > 0 THEN
                'BOOKS ARE AVAILABLE'
            ELSE
                'BOOKS ARE NOT AVAILABLE'
        END AS AVAILIBILITY_STATUS
    FROM
             (
            SELECT
                BOOK_COPIES.ISBN AS ISBN,
                LIBRARY_BRANCH.BRANCH_ID,
                BOOK_COPIES.NO_OF_COPIES
            FROM
                     PROJECT1_BOOK_COPIES BOOK_COPIES
                INNER JOIN PROJECT1_LIBRARY_BRANCH LIBRARY_BRANCH ON LIBRARY_BRANCH.BRANCH_ID = BOOK_COPIES.BRANCH_ID
        ) TEMP
        INNER JOIN PROJECT1_BOOK         BOOK ON TEMP.ISBN = BOOK.ISBN
        INNER JOIN PROJECT1_BOOK_AUTHORS BOOK_AUTHORS ON TEMP.ISBN = BOOK_AUTHORS.ISBN
        INNER JOIN PROJECT1_AUTHORS      AUTHORS ON BOOK_AUTHORS.AUTHOR_ID = AUTHORS.AUTHOR_ID
)
SELECT
    *
FROM
    SEARCH
WHERE
    BRANCH_ID = &BRANCH_SEARCH
UNION ALL
SELECT
    *
FROM
    SEARCH
WHERE
    UPPER(TITLE) LIKE UPPER('%&Keyword%')
UNION ALL
SELECT
    *
FROM
    SEARCH
WHERE
    UPPER(NAME) LIKE UPPER('%&Keyword%');
