*******IMPORTANT NOTE********
Using below guidance, create table and load data in SCHEMA PRIVATE_BASEDATA created using step 2a-CreateListingToplogy


====================================================
OPTION1: UPLOAD DATA FROM LOCAL MACHINE USING EXCEL
====================================================
VIDEO WALKTHROUGH: https://www.youtube.com/watch?v=csmS5V2ONr8
GITHUB PAGE: https://github.com/Snowflake-Labs/Excelerator

====================================================
OPTION2: UPLOAD DATA FROM CLOUD OBJECT STORES 
====================================================
VIDEO WALKTHROUGH: Coming Soon
CODE IS AS FOLLOWS

Step1: Create Stage
Step2: Create Table
Step3: Load Data Once
Step4: Setup Load Data Recurring

--STEP1: CREATE STAGE: START
-----------------------------
-- Copyright (c) 2020 Snowflake Inc. All rights reserved.
-- Create a stage using simple access or a storage integration to allow Snowflake access to your files in object store
-- This template follows the documentation located here:
-- https://docs.snowflake.com/en/sql-reference/sql/create-storage-integration.html
-- https://docs.snowflake.com/en/sql-reference/sql/create-stage.html
-- This template offers walkthroughs for AWS, Azure, and GCP - please jump to the appropriate section for you

----------------------------------------------

use role mpadmin_role;
use warehouse mpadmin_wh;
set LISTING_NAME ='INVENTORY';

    
-- If your data is in AWS S3

-- Simple access approach, which requires using access key
-- Replace "MY_KEY" and "MY_SECRET_KEY" with your values

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

CREATE OR REPLACE STAGE PRIVATE_STAGE
URL = 's3://provider-accelerator-testing/test1/' 
CREDENTIALS = (AWS_KEY_ID = 'MY_KEY' AWS_SECRET_KEY = 'MY_SECRET_KEY')
;

-- Storage integration approach, which is more secure
-- Replace STORAGE_AWS_ROLE_ARN, STORAGE_ALLOWED_LOCATIONS, and URL with your values
-- Before creating storage integration, work with your AWS administrator and follow the directions below
-- https://docs.snowflake.com/en/user-guide/data-load-s3-config.html#step-1-configure-access-permissions-for-the-s3-bucket

CREATE STORAGE INTEGRATION MPLISTING_STORAGE
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::001234567890:role/myrole'
ENABLED = TRUE
STORAGE_ALLOWED_LOCATIONS = ('s3://mybucket1/path1/', 's3://mybucket2/path2/')
;

DESC STORAGE INTEGRATION MPLISTING_STORAGE;

-- Provide the values of STORAGE_AWS_IAM_USER_ARN and STORAGE_AWS_EXTERNAL_ID to your AWS administrator and follow the directions below
-- https://docs.snowflake.com/en/user-guide/data-load-s3-config.html#step-5-grant-the-iam-user-permissions-to-access-bucket-objects
-- Now create the stage, replacing URL with your value and using your database & schema 

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

CREATE OR REPLACE STAGE PRIVATE_STAGE
URL = 's3://mybucket1/path1/'
STORAGE_INTEGRATION = MPLISTING_STORAGE
;


/*
----------------------------------------------

-- If your data is in Azure Blob Storage
-- Replace AZURE_TENANT_ID and STORAGE_ALLOWED_LOCATIONS with your values

CREATE STORAGE INTEGRATION MPLISTING_STORAGE
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = AZURE
ENABLED = TRUE
AZURE_TENANT_ID = '<tenant_id>'
STORAGE_ALLOWED_LOCATIONS = ('azure://myaccount.blob.core.windows.net/mycontainer/path1/', 'azure://myaccount.blob.core.windows.net/mycontainer/path2/')
;

DESC STORAGE INTEGRATION MPLISTING_STORAGE;

-- Provide the values of AZURE_CONSENT_URL and AZURE_MULTI_TENANT_APP_NAME to your Azure administrator and follow the directions below
-- https://docs.snowflake.com/en/user-guide/data-load-azure-config.html#step-2-grant-snowflake-access-to-the-storage-locations
-- Now create the stage, replacing URL with your value and using your database & schema 

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

CREATE OR REPLACE STAGE PRIVATE_STAGE
URL = 'azure://myaccount.blob.core.windows.net/load/files/'
STORAGE_INTEGRATION = MPLISTING_STORAGE
;

----------------------------------------------

-- If your data is in Google Cloud Storage
-- Replace STORAGE_ALLOWED_LOCATIONS with your values

CREATE STORAGE INTEGRATION MPLISTING_STORAGE
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = GCS
ENABLED = TRUE
STORAGE_ALLOWED_LOCATIONS = ('gcs://mybucket1/path1/', 'gcs://mybucket2/path2/')
;

DESC STORAGE INTEGRATION MPLISTING_STORAGE;

-- Provide the value of STORAGE_GCP_SERVICE_ACCOUNT to your GCP administrator and follow the directions below
-- https://docs.snowflake.com/en/user-guide/data-load-gcs-config.html#step-3-grant-the-service-account-permissions-to-access-bucket-objects
-- Now create the stage, replacing URL with your value and using your database & schema 

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

CREATE OR REPLACE STAGE PRIVATE_STAGE
URL = 'gcs://load/files/'
STORAGE_INTEGRATION = MPLISTING_STORAGE
;

*/
--STEP1: CREATE STAGE: END

-----------------------------
--STEP2: CREATE TABLE: START
-----------------------------

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

-- For a regular structured database table:

create or replace TABLE CUSTOMER_TBL (
	C_CUSTKEY NUMBER(38,0),
	C_NAME VARCHAR(25),
	C_ADDRESS VARCHAR(40),
	C_NATIONKEY NUMBER(38,0),
	C_PHONE VARCHAR(15),
	C_ACCTBAL NUMBER(12,2),
	C_MKTSEGMENT VARCHAR(10),
	C_COMMENT VARCHAR(117)
);


-- For a schema-less table loaded with semi-structured data (JSON, etc)

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

CREATE OR REPLACE TABLE MY_TABLE (
COL1 VARIANT NOT NULL COMMENT 'A COLUMN TO HOLD SEMI-STRUCTURED DATA THAT CANNOT BE NULL - SEE THE DOCS FOR DETAILS',
COL2 TIMESTAMP_LTZ COMMENT 'IT IS A GOOD PRACTICE TO INCLUDE A TIMESTAMP FOR WHEN THE ROW WAS INSERTED'
) 
COMMENT='A TABLE COMMENT'
;

--STEP2: CREATE TABLE: END

-----------------------------
--STEP3: LOAD DATA ONCE: START
-----------------------------
--set context
use role mpadmin_role;
use warehouse mpadmin_wh;

-- Create one or more file formats for your data files, depending on how many different formats you use
-- Create a CSV file format named my_csv_format that defines the following rules for data files: fields are delimited using the pipe character (|), files include a single header line that will be skipped, the strings NULL and null will be replaced with NULL values, empty strings will be interpreted as NULL values, files will be compressed/decompressed using GZIP compression. Your rules may be different - parameters can be changed or omitted based on your files.

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

CREATE OR REPLACE FILE FORMAT MY_FORMAT
TYPE = CSV
FIELD_DELIMITER = '|'
SKIP_HEADER = 1
NULL_IF = ('NULL', 'null')
EMPTY_FIELD_AS_NULL = TRUE
COMPRESSION = GZIP
;

-- Optional if needed: Create a JSON file format that uses the defaults for all JSON parameters

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

CREATE OR REPLACE FILE FORMAT MY_FORMAT
TYPE = JSON;

-- Use your previously defined Warehouse, Database, Schema, Table, Stage, and File Format to load data once
-- Replace "MY_FILE.EXTENSION" with your file name and include a file path if necessary when you have many files organized in object story by folders
-- The example below assumes loading a single file. Please see the documentation for loading multiple files using pattern matching.
-- https://docs.snowflake.com/en/sql-reference/sql/copy-into-table.html

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

-- List files in stage

LS @PRIVATE_STAGE;

-- Run a validation check before loading 

COPY INTO CUSTOMER_TBL 
FROM @PRIVATE_STAGE/[file-path-if-needed]/MY_FILE.EXTENSION 
FILE_FORMAT = (FORMAT_NAME = 'MY_FORMAT')
VALIDATION_MODE = 'RETURN_ERRORS'
;

-- If no errors...

COPY INTO CUSTOMER_TBL 
FROM @PRIVATE_STAGE/[file-path-if-needed]/MY_FILE.EXTENSION 
FILE_FORMAT = (FORMAT_NAME = 'MY_FORMAT')
;

-- View COPY history for the last hour of history
-- https://docs.snowflake.com/en/sql-reference/functions/copy_history.html 

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(TABLE_NAME=>'CUSTOMER_TBL', START_TIME=> DATEADD(HOURS, -1, CURRENT_TIMESTAMP())));

-- View 10 rows of data loaded into the table 

SELECT *
FROM CUSTOMER_TBL
LIMIT 10
;

--STEP3: LOAD DATA ONCE: END

-----------------------------
--STEP4: LOAD DATA RECURRING: START
-----------------------------


-- If you want to use the COPY approach...
-- This approach does not vary based on whether you are in AWS, Azure, or GCP
-- This approach will create a Snowflake task to run a COPY statement on a schedule using documentation located here:
-- https://docs.snowflake.com/en/sql-reference/sql/create-task.html
-- Replace "MY_TASK" with your preferred names
-- Tasks are always created in a suspended state and must be resumed before they will run.
-- The example below assumes a single task to load a single table from a single path of files using the COPY statement from the load_data_once.sql script with a slight alteration that assumes incremental files use the same base file name ("MY_FILE") with a date or timestamp suffix ("MY_FILE_YYYY_MM_DD"). The suffix is ommitted to load any new file that hasn't been loaded before. If you have many independent tables to load, you will repeat this for each table. It is also possible to chain tasks together into a dependency tree for more complicated workflows, but that is not illustrated here.
-- The example below also assumes that this task will be run on a cron schedule of every night at 2am America/Los Angeles time, reflected by the format which is documented in the link above. You can customize the schedule to your needs. Tasks can also be scheduled to run on an interval measured in minutes. See the documentation for more details.

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

CREATE OR REPLACE TASK MY_TASK
WAREHOUSE = mpadmin_wh
SCHEDULE = 'USING CRON 0 2 * * * America/Los_Angeles'
AS 
COPY INTO CUSTOMER_TBL 
FROM @PRIVATE_STAGE/[file-path-if-needed]/MY_FILE.EXTENSION 
FILE_FORMAT = (FORMAT_NAME = 'MY_FORMAT')
;


-- Resume the suspended task

ALTER TASK MY_TASK RESUME;

-- Monitor the task history of the 10 most recent executions of a specified task (completed, still running, or scheduled in the future) scheduled within the last hour:

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

SELECT *
	FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
		SCHEDULED_TIME_RANGE_START=>DATEADD('HOUR',-1,CURRENT_TIMESTAMP()),
		RESULT_LIMIT => 10,
		TASK_NAME=>'MY_TASK'));
		
----------------------------------------------

-- If you want to use the Snowpipe approach...
-- This approach does vary slightly based on whether you are in AWS, Azure, or GCP
-- Replace "MY_TASK" with your preferred names
-- The documentation is located here:
-- https://docs.snowflake.com/en/user-guide/data-load-snowpipe.html
-- There are two ways that Snowpipe can be alerted to new files: cloud service notifications or a REST API call. The method shown below is the notification style, which at the time of this commit is not available on GCP. Please see the documentation to understand how to call the Snowpipe REST API to invoke a pipe.
-- The example below assumes a single pipe to load a single table from a single path of files using the COPY statement from the load_data_once.sql script with a slight alteration that assumes incremental files use the same base file name ("MY_FILE") with a date or timestamp suffix ("MY_FILE_YYYY_MM_DD"). The suffix is ommitted to load any new file that hasn't been loaded before. If you have many independent tables to load, you will repeat this for each table.
-- Compare the stage reference in the pipe definition with existing pipes. Verify that the directory paths for the same S3 bucket do not overlap; otherwise, multiple pipes could load the same set of data files multiple times, into one or more target tables. See the documentation for more details.

----------------------------------------------

-- If your data is in AWS S3
-- Create a pipe

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

CREATE OR REPLACE PIPE MY_PIPE 
AUTO_INGEST = TRUE 
AS
COPY INTO CUSTOMER_TBL 
FROM @PRIVATE_STAGE/[file-path-if-needed]/MY_FILE.EXTENSION 
FILE_FORMAT = (FORMAT_NAME = 'MY_FORMAT')
;

SHOW PIPES;

-- Note the ARN of the SQS queue for the stage in the notification_channel column. Copy the ARN to a convenient location.
-- Follow the steps located here:
-- https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3.html#step-4-configure-event-notifications

-- Retrieve the status of the pipe

SELECT SYSTEM$PIPE_STATUS('MY_PIPE');

-- Manually add a file to your external stage in the proper path to test that the pipe picks up the new file. There could be as much as a 1-2 minute delay from when the file is added to when the notification tells the pipe that a new file has been added. You can test that the new file was loaded by doing a simple 'select count(*) from table' query before and after you upload the file.

----------------------------------------------

-- If your data in in Azure
-- Follow steps 1 and 2 at the link below to configure Azure Event Grid and create a Snowflake notification integration:
-- https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-azure.html#configuring-automated-snowpipe-using-azure-event-grid

-- Create a pipe replacing "MY_NOTIFICATION" with your value from step 2 above

set BASE_SCHEMA = 'MPLISTING_'||$LISTING_NAME||'.PRIVATE_BASEDATA';
use schema identifier($BASE_SCHEMA);

CREATE OR REPLACE PIPE MY_PIPE 
AUTO_INGEST = TRUE
INTEGRATION = 'MY_NOTIFICATION' 
AS
COPY INTO CUSTOMER_TBL 
FROM @PRIVATE_STAGE/[file-path-if-needed]/MY_FILE.EXTENSION 
FILE_FORMAT = (FORMAT_NAME = 'MY_FORMAT')
;

-- Retrieve the status of the pipe

SELECT SYSTEM$PIPE_STATUS('MY_PIPE');

-- Manually add a file to your external stage in the proper path to test that the pipe picks up the new file. There could be as much as a 1-2 minute delay from when the file is added to when the notification tells the pipe that a new file has been added. You can test that the new file was loaded by doing a simple 'select count(*) from table' query before and after you upload the file.



-- Load Dummy data for listing for showcasing next step
/*
use role accountadmin;
--grant imported privileges on database citibike to role mpadmin_role;
grant usage on database citibike to role mpadmin_role;
grant usage on schema citibike.demo to role mpadmin_role;
grant select on table citibike.demo.stations to role mpadmin_role; 
grant select on table citibike.demo.trips to role mpadmin_role; 
use role mpadmin_role; 
alter warehouse mpadmin_wh set warehouse_size = 'large';
create or replace table mplisting_INVENTORY.private_basedata.INVENTORY_another_tbl as  select * from citibike.demo.stations;
create or replace table mplisting_INVENTORY.private_basedata.INVENTORY_main_tbl as  select * from citibike.demo.trips;
alter warehouse mpadmin_wh set warehouse_size = 'xsmall';
*/

-----------------------------
--STEP4: LOAD DATA RECURRING: END
-----------------------------





