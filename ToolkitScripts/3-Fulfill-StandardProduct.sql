
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
*************************************************************************************************************/



/*========================= 
PLISTING FULFILL (STANDARD): START
=========================*/  

=======================================================================
STEP1 - Prepare commercial objects (consumer facing) for your standard products
=======================================================================
--------------------------------------
-- CALL sp_mpadmin_Plisting_addobject
-- Call this SP to add objects for your final commercial data to be exposed to consumers
-- Iteratively call this SP to add multpile objects
-- NOTE: Ensure objects name in view_sql are fully qualified
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
STEP2 - Create a "PRIVATE" listing for commercial data 
Note: this listing is not visible to any consumer until the consumer account url is explicitly added per STEP3
=======================================================================

Create a private listing via UI and attach share created in step STEP1 For example, PSHARE_XNY_CORP_TO_COMMON_INVENTORY share is attached to private listing
Follow steps in documentation here: https://other-docs.snowflake.com/en/listings/listings-creating-and-publishing.html#creating-a-listing

=======================================================================
STEP3 DELIVERY - Once procurement is complete, add consumer account to private listing
=======================================================================
Add a consumer account name (url) to private listing

/*========================= 
PLISTING FULFILL (STANDARD): END
=========================*/ 

