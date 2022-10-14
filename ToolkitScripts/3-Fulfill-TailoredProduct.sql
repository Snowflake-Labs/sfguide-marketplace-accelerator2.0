/*************************************************************************************************************
Script:             Marketplace Accelerator 2.0 Standard and Custom Products Listing Setup
Create Date:        2022-04-21
Author:             A. Gupta
Description:        Script contains example call to stored procedure that add procured data to container (shares) 
                    delivered to paying consumers of a given data product
                    Requires MPAdmin Role (This role is created by 1-PrepareAccount.sql)
                    NOTE: Applies only to data products of Standard and Custom category
*************************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author                              Comments
------------------- -------------------                 --------------------------------------------
2022-04-21          A. Gupta              		        Initial Publish
2022-10-14          A. Gupta                          Added example to show cross region consumer fulfillment
*************************************************************************************************************/

/*========================= 
PLISTING FULFILL (TAILORED): START
=========================*/  

=======================================================================
STEP1 - Create & apply Row Access Policy (row security), Dynamic Data Masking (column security) 
        to define filtering rules. 
=======================================================================

--Set context
use role mpadmin_role;
use warehouse mpadmin_wh;
use schema mplisting_INVENTORY.private_util;


-- Entitlement table is created for each listing as part of 2a-CreateListingToplogy
select * from mplisting_INVENTORY.private_util.entitlement_example;

--Create Row access policy that allows filtering of data
-- Learn more about RAP here - https://docs.snowflake.com/en/user-guide/security-row.html
-- Column Level security (Dynamic data masking is not demonstrated but the flow is very similar to RAP). Learn more about DDM here - https://docs.snowflake.com/en/user-guide/security-column.html
--drop row access policy entitlement_station_id;
create or replace row access policy mplisting_INVENTORY.private_util.entitlement_station_id_row_policy as (ENTITLEMENT_COLA_ARG number) returns boolean ->
  --IF Provider account then show all data
  'CR58915' = current_account() 
  -- ELSE enforce below rule
      or exists (
            select 1 from mplisting_INVENTORY.private_util.entitlement_example
              where  ENTITLEMENT_COLA = ENTITLEMENT_COLA_ARG
              and upper(consumer_snowflake_accountlocator) = current_account()
              and upper(consumer_snowflake_accountregion) = current_region()
              );
                    


-- Apply above defined policies to private base data tables

alter table mplisting_INVENTORY.private_basedata.INVENTORY_main_tbl add row access policy mplisting_INVENTORY.private_util.entitlement_station_id_row_policy on (start_station_id);
alter table mplisting_INVENTORY.private_basedata.INVENTORY_another_tbl add row access policy mplisting_INVENTORY.private_util.entitlement_station_id_row_policy on (station_id);

/* -- REVOKE above actions
alter table mplisting_INVENTORY.private_basedata.INVENTORY_another_tbl  drop row access policy mplisting_INVENTORY.private_util.entitlement_station_id_row_policy;
alter table mplisting_INVENTORY.private_basedata.INVENTORY_main_tbl  drop row access policy mplisting_INVENTORY.private_util.entitlement_station_id_row_policy;
*/

=======================================================================
STEP2 - Prepare commercial objects (consumer facing) for your tailored products
NOTE: Objects in this step produce zero records until entitlement table entries 
      are made as shown in STEP3
=======================================================================
--------------------------------------
-- CALL sp_mpadmin_Plisting_addobject
-- Call this SP to add objects for your final commercial data to be exposed to consumers
-- Iteratively call this SP to add multpile objects
-- NOTE1: Ensure objects name in view_sql are fully qualified
-- Best Practice: Ensure View Name is same as CTAS Table Name from SampleData. This helps with consumer queries running on sample data 
--                works seamlessly with commercial data as well.
--------------------------------------


use role mpadmin_role;
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_Plisting_addobject
    (
     LISTING_NAME               =>'INVENTORY',
     VIEW_NAME                  =>'INVENTORY_MAIN',
     VIEW_SQL                   =>'select * from mplisting_INVENTORY.private_basedata.INVENTORY_main_tbl;'
    );
    
call mpadmin.util.sp_mpadmin_Plisting_addobject
    (
     LISTING_NAME               =>'INVENTORY',
     VIEW_NAME                  =>'INVENTORY_ANOTHER',
     VIEW_SQL                   =>'select * from mplisting_INVENTORY.private_basedata.INVENTORY_another_tbl;'
    );


-- To double check share has correct objects
DESCRIBE SHARE PSHARE_XNY_CORP_TO_COMMON_INVENTORY;


/* -- REVOKE actions by sp_mpadmin_Plisting_addobject
-- -- VIEW_SQL parameter is not mandatory, And can be passed as empty string.
call mpadmin.util.sp_mpadmin_Plisting_addobject_revoke
    (
     LISTING_NAME               =>'INVENTORY',
     VIEW_NAME                  =>'INVENTORY_MAIN',
     VIEW_SQL                   =>'select * from mplisting_INVENTORY.private_basedata.INVENTORY_main_tbl;'
    );
-- */   


=======================================================================
STEP3 - Create a "PRIVATE" listing for commercial data 
Note: this listing is not visible to any consumer until the consumer account url is explicitly added per STEP5
=======================================================================

Create a private listing via UI and attach share created in step STEP1 For example, PSHARE_XNY_CORP_TO_COMMON_INVENTORY share is attached to private listing
Follow steps in documentation here: https://other-docs.snowflake.com/en/listings/listings-creating-and-publishing.html#creating-a-listing


================================================================================
STEP4 DELIVERY - Once procurement is complete, add entries to entitlement table 
        and test consumer view
================================================================================

-- From my provider account I can see all records
select current_account();
--CR58915
select * from MPLISTING_INVENTORY.SHARED_INVENTORY_COMMON.INVENTORY_ANOTHER;
select start_station_id, sum(tripduration) from MPLISTING_INVENTORY.SHARED_INVENTORY_COMMON.INVENTORY_MAIN group by start_station_id;

-- Insert entries into entitlement table. Request the output of "select current_account(), current_region();" from your consumer to fill in the values for consumer_snowflake_accountlocator and consumer_snowflake_accountregion
--truncate table mplisting_INVENTORY.private_util.entitlement_example;
insert into mplisting_INVENTORY.private_util.entitlement_example (consumer_name, consumer_snowflake_accountlocator, consumer_snowflake_accountregion, entitlement_colA)
values ('ABC_INC','uda09462','PUBLIC.AWS_US_WEST_2',128),
('ABC_INC','uda09462','PUBLIC.AWS_US_WEST_2',323),
('ABC_INC','uda09462','PUBLIC.AWS_US_WEST_2',3374),
('ABC_INC','uda09462','PUBLIC.AWS_US_WEST_2',3272);


-- Validation Process. What a given consumer will see
alter session set SIMULATED_DATA_SHARING_CONSUMER = uda09462;
select * from MPLISTING_INVENTORY.SHARED_INVENTORY_COMMON.INVENTORY_ANOTHER;
select start_station_id, sum(tripduration) from MPLISTING_INVENTORY.SHARED_INVENTORY_COMMON.INVENTORY_MAIN group by start_station_id;
alter session unset SIMULATED_DATA_SHARING_CONSUMER;


=======================================================================
STEP5 DELIVERY - Add consumer account to private listing
=======================================================================
Add a consumer account name (url) to private listing

/*========================= 
PLISTING FULFILL (TAILORED): END
=========================*/ 

