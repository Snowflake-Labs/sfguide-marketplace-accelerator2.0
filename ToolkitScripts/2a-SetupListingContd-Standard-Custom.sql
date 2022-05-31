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
SETUP CONTINUED (Standard / Custom): START
=========================*/  

--------------------------------------
-- CALL sp_mpadmin_Plisting_addobject
-- Call this SP to add objects for productized listing (final commercial data is added here)
-- Iteratively call this SP to add multpile objects
--------------------------------------
use role mpadmin_role;
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_Plisting_addobject
    (
     LISTING_NAME               =>'SHIPPING',
     VIEW_NAME                  =>'SHIPPING_MAIN_SECURE_VW',
     VIEW_SQL                   =>'select * from mplisting_SHIPPING.private_basedata.SHIPPING_main_tbl;'
    );

/* -- REVOKE actions by sp_mpadmin_Plisting_addobject
-- -- VIEW_SQL parameter is not mandatory, And can be passed as empty string.
call mpadmin.util.sp_mpadmin_Plisting_addobject_revoke
    (
     LISTING_NAME               =>'SHIPPING',
     VIEW_NAME                  =>'SHIPPING_MAIN_SECURE_VW',
     VIEW_SQL                   =>'select * from mplisting_SHIPPING.private_basedata.SHIPPING_main_tbl;'
    );
-- */   

/*========================= 
SETUP CONTINUED (Standard / Custom): END
=========================*/ 


