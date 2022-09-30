/*************************************************************************************************************
Script:             Marketplace Accelerator 2.0 Listing Setup
Create Date:        2022-04-21
Author:             A. Gupta
Description:        Script contains example call to stored procedures that create containers to store base data 
                    and enable adding sample data; for a given data product (listing)
                    Requires MPAdmin Role (This role is created by 1-PrepareAccount.sql)
*************************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author                              Comments
------------------- -------------------                 --------------------------------------------
2022-04-21          A. Gupta              		        Initial Publish
*************************************************************************************************************/

/*========================= 
LISTING SETUP STORED PROC: BEGIN 
=========================*/ 
--------------------------------------
-- CALL sp_mpadmin_listing_setup()
--------------------------------------

use role mpadmin_role;
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_listing_setup
    (LISTING_NAME               =>'INVENTORY'); 

/* -- REVOKE actions by sp_mpadmin_listing_setup
call mpadmin.util.sp_mpadmin_listing_setup_revoke
    (LISTING_NAME               =>'INVENTORY'); 
-- */


/*========================= 
LISTING SETUP STORED PROC: END
=========================*/  
