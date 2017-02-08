--
-- Copyright 2010-2016 Boxfuse GmbH
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--         http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

CREATE TYPE my_type AS (my_type_id integer);

CREATE TYPE """my_type2""" AS (my_type_id integer);

CREATE TYPE bug_status AS ENUM ('new', 'open', 'closed');

CREATE TYPE """bug_status2""" AS ENUM ('new', 'open', 'closed');

CREATE TYPE full_name_type AS OBJECT
( FirstName       VARCHAR2(80),
  MiddleName      VARCHAR2(80),
  LastName        VARCHAR2(80) );
/

create or replace
TYPE full_name_type_array AS TABLE of full_name_type;
/

CREATE TYPE full_mailing_address_type AS OBJECT
( full_name    full_name_type,
  Street       VARCHAR2(80),
  City         VARCHAR2(80),
  State        CHAR(2));
/

CREATE TABLE customer (
  full_address  full_mailing_address_type
);

INSERT INTO customer VALUES (
  full_mailing_address_type(
    full_name_type('John', 'F', 'Kennedy'),
    'Whitehouse plaza',
    'Washington',
    'DC'
  )
);

CREATE OR REPLACE TYPE fact_row IS OBJECT (
    FACT_TIME      TIMESTAMP,
    DIMENSION_VALUE VARCHAR(4000),
    MEASURE_VALUE   NUMBER,
    MEMBER PROCEDURE display_fact_row (SELF IN OUT fact_row)
  );
/

/*
  There is a bug in the EDB JDBC driver that prevents the proper execution of the following Type Body
 */
CREATE OR REPLACE TYPE BODY fact_row AS
  MEMBER PROCEDURE display_fact_row (SELF IN OUT fact_row) IS
  BEGIN
   DBMS_OUTPUT.PUT_LINE('FACT_TIME       :' || FACT_TIME);
   DBMS_OUTPUT.PUT_LINE('DIMENSION_VALUE :' || FACT_TIME);
   DBMS_OUTPUT.PUT_LINE('MEASURE_VALUE   :' || FACT_TIME);
  END;
END;
/