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
    (LISTING_NAME               =>'SHIPPING'); 

/* -- REVOKE actions by sp_mpadmin_listing_setup
call mpadmin.util.sp_mpadmin_listing_setup_revoke
    (LISTING_NAME               =>'SHIPPING'); 
-- */

--Load Dummy data for listing
use role accountadmin;
grant usage on database dnb_mp_demo to role mpadmin_role;
grant usage on schema dnb_mp_demo.hotlist to role mpadmin_role;
grant select on table dnb_mp_demo.hotlist.hotlist_tbl to role mpadmin_role; 
use role mpadmin_role;                          
create or replace table mplisting_SHIPPING.private_basedata.SHIPPING_main_tbl as  select * from "WEATHER"."WEATHER_V3"."HISTORY_DAY";
create or replace table mplisting_SHIPPING.private_basedata.SHIPPING_another_tbl as  select * from "DNB_MP_DEMO"."HOTLIST"."HOTLIST_TBL";

--------------------------------------
-- CALL sp_mpadmin_Slisting_addobject 
-- Call this SP to add objects for sample listing 
-- Iteratively call this SP to add multpile objects
--------------------------------------
use role mpadmin_role;
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_Slisting_addobject
    (
     LISTING_NAME               =>'SHIPPING',
     CTAS_TABLE_NAME            =>'SHIPPING_MAIN_TBL',
     CTAS_SQL                   =>'select * from mplisting_SHIPPING.private_basedata.SHIPPING_main_tbl  sample (1000 rows);'
    ); 
    
call mpadmin.util.sp_mpadmin_Slisting_addobject
    (
     LISTING_NAME               =>'SHIPPING',
     CTAS_TABLE_NAME            =>'SHIPPING_ANOTHER_TBL',
     CTAS_SQL                   =>'select * from mplisting_SHIPPING.private_basedata.SHIPPING_another_tbl  sample (4 rows);'
    ); 

DESCRIBE SHARE SSHARE_XNY_CORP_TO_COMMON_SHIPPING_SAMPLE;

/* -- REVOKE actions by sp_mpadmin_Slisting_addobject
-- -- CTAS_SQL parameter is not mandatory, And can be passed as empty string.
call mpadmin.util.sp_mpadmin_Slisting_addobject_revoke
    (
     LISTING_NAME               =>'SHIPPING',
     CTAS_TABLE_NAME            =>'SHIPPING_MAIN_TBL',
     CTAS_SQL                   =>'select * from mplisting_SHIPPING.private_basedata.SHIPPING_main_tbl  sample (4 rows);'
    );  
-- */   
 
/*========================= 
LISTING SETUP STORED PROC: END
=========================*/  

/*========================= 
[OPTIONAL STORED PROC: BEGIN] 
=========================*/  
/*-------------------------------
ADDITIONAL SAMPLE LISTING SETUP
-------------------------------*/  
-------------------------------------
--   CALL sp_mpadmin_addsamplelisting()
-- To create additional sample listings corresponding to same productized lisitng
--------------------------------------
use role mpadmin_role; 
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_addsamplelisting
    (
     LISTING_NAME               =>'EDUCATION',
     SAMPLELISTING_NAME_SUFFIX  =>'_K1'
    );
    
/* -- REVOKE actions by sp_mpadmin_addsamplelisting
call mpadmin.util.sp_mpadmin_addsamplelisting_revoke
    (
     LISTING_NAME               =>'EDUCATION',
     SAMPLELISTING_NAME_SUFFIX  =>'_K1'
    );
-- */     
    
--------------------------------------
-- CALL sp_mpadmin_Slisting_addobject 
-- Call this SP to add objects for sample listing when there was a prefix provided to setup sample listing objects
--------------------------------------
use role mpadmin_role;
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_Slisting_addobject
    (
     LISTING_NAME               =>'EDUCATION',
     SAMPLELISTING_NAME_SUFFIX  =>'_K1',
     PROVIDER_NAME              =>'XnY_CORP', 
     CTAS_TABLE_NAME            =>'EDUCATION_MAIN_TBL',
     CTAS_SQL                   =>'select * from mplisting_education.private_basedata.education_main_tbl  sample (4 rows);'
    );

/* -- REVOKE actions by sp_mpadmin_listing_setup
-- -- CTAS_SQL parameter is not mandatory, And can be passed as empty string.
call mpadmin.util.sp_mpadmin_Slisting_addobject_revoke
    (
     LISTING_NAME               =>'EDUCATION',
     SAMPLELISTING_NAME_SUFFIX  =>'_K1',
     PROVIDER_NAME              =>'XnY_CORP', 
     CTAS_TABLE_NAME            =>'EDUCATION_MAIN_TBL',
     CTAS_SQL                   =>'select * from mplisting_education.private_basedata.education_main_tbl  sample (4 rows);'
    );
-- */ 


/*========================= 
[OPTIONAL STORED PROC: END] 
=========================*/  
