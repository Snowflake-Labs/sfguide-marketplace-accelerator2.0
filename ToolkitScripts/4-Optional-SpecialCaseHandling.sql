/*************************************************************************************************************
Script:             Marketplace Accelerator 2.0 - Optional Special Case Handling
Create Date:        2022-04-21
Author:             A. Gupta
Description:        Script is leveraged when container (database) to store base data, for a given data product, 
                    is already in its own database. In such case, the existing database can also be used to setup 
                    listing. This .sql file contains example calls for such setup
                    Requires Accountadmin and MPAdmin Role (This role is created by 1-PrepareAccount.sql)
*************************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author                              Comments
------------------- -------------------                 --------------------------------------------
2022-04-21          A. Gupta              		        Initial Publish
*************************************************************************************************************/

/*========================= 
EXISTING BASEDB OVERRIDE: BEGIN
This script is used to handle cases when provider already has existing DB in Snowflake to be used for listing as BaseDB
=========================*/ 

--------------------------------------
-- As ACCOUNTADMIN, CALL sp_accountadmin_listing_basedb_override 
-- Prerequisite: Call sp_accountadmin_onetimesetup(<providerName>)
--------------------------------------

use role accountadmin;
use warehouse mpadmin_wh;
call mpadmin.util.sp_accountadmin_listing_basedb_override
    (
     LISTING_NAME               =>'EDUCATION',
     OVERRIDE_BASEDATABASE_NAME =>'CITIBIKE'
    );


/* -- REVOKE actions by sp_accountadmin_listing_basedb_override
-- -- OVERRIDE_BASEDATABASE_NAME parameter is not mandatory, And can be passed as empty string.
call mpadmin.util.sp_accountadmin_listing_basedb_override_revoke
    (
     LISTING_NAME               =>'EDUCATION',
     OVERRIDE_BASEDATABASE_NAME =>'CITIBIKE'
    );
-- */

/*========================= 
EXISTING BASEDB OVERRIDE: END
=========================*/ 


/*========================= 
EXISTING BASEDB LISTING SETUP STORED PROC: BEGIN 
=========================*/ 
--------------------------------------
-- CALL sp_mpadmin_listing_setup()
--------------------------------------

use role mpadmin_role;
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_listing_setup
    (LISTING_NAME               =>'EDUCATION'); 

/* -- REVOKE actions by sp_mpadmin_listing_setup
call mpadmin.util.sp_mpadmin_listing_setup_revoke
    (LISTING_NAME               =>'EDUCATION'); 
-- */


--------------------------------------
-- CALL sp_mpadmin_Slisting_addobject 
-- Call this SP to add objects for sample listing when there was a prefix provided to setup sample listing objects
-- Iteratively call this SP to add multpile objects
--------------------------------------
use role mpadmin_role;
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_Slisting_addobject
    (
     LISTING_NAME               =>'EDUCATION',
     CTAS_TABLE_NAME            =>'EDUCATION_MAIN_TBL',
     CTAS_SQL                   =>'select * from "CITIBIKE"."DEMO"."STATIONS"  sample (1000 rows);'
     );


/* -- REVOKE actions by sp_mpadmin_Slisting_addobject
-- -- CTAS_SQL parameter is not mandatory, And can be passed as empty string.
call mpadmin.util.sp_mpadmin_Slisting_addobject_revoke
    (
     LISTING_NAME               =>'EDUCATION',
     CTAS_TABLE_NAME            =>'EDUCATION_MAIN_TBL',
     CTAS_SQL                   =>'select * from mplisting_EDUCATION.private_basedata.EDUCATION_main_tbl  sample (4 rows);'
    );  
-- */   
 
/*========================= 
EXISTING BASEDB LISTING SETUP STORED PROC: END
=========================*/  

/*========================= 
EXISTING BASEDB PLISTING FULFILL (CUSTOMIZED): START
=========================*/  

--------------------------------------
-- CALL sp_mpadmin_Plisting_addobject
-- Call this SP wtih ConsumerName Parameter for data product customized per consumer 
-- Iteratively call this SP to add multpile objects
--------------------------------------
use role mpadmin_role;
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_Plisting_addobject
    (
     LISTING_NAME               =>'EDUCATION',
     CONSUMER_NAME              =>'ABC_INC', 
     VIEW_NAME                  =>'EDUCATION_MAIN_SECURE_VW',
     VIEW_SQL                   =>'select * from "CITIBIKE"."DEMO"."STATIONS"'
    );


/* -- DELETES views added by sp_mpadmin_Plisting_addobject_revoke
-- -- VIEW_SQL parameter is not mandatory, And can be passed as empty string.
call mpadmin.util.sp_mpadmin_Plisting_addobject_revoke
    (
     LISTING_NAME               =>'EDUCATION',
     CONSUMER_NAME              =>'ABC_INC', 
     VIEW_NAME                  =>'EDUCATION_MAIN_SECURE_VW',
     VIEW_SQL                   =>'select * from mplisting_EDUCATION.private_basedata.EDUCATION_main_tbl;'
    );
-- */  

/* -- DROP the consumer and all consumer specific objects from the listing. 
call mpadmin.util.sp_mpadmin_Plisting_dropconsumer
    (
     LISTING_NAME               =>'EDUCATION',
     CONSUMER_NAME              =>'ABC_INC'
    );
-- */

/*========================= 
EXISTING BASEDB PLISTING FULFILL (CUSTOMIZED): END
=========================*/  

/*========================= 
EXISTING BASEDB PLISTING FULFILL (COMMON): START
EXAMPLE USECASE: PAID LISTINGS
=========================*/  

--------------------------------------
-- CALL sp_mpadmin_Plisting_addobject
-- Call this SP to add objects for sample listing when there was a prefix provided to setup sample listing objects
-- Iteratively call this SP to add multpile objects
--------------------------------------
use role mpadmin_role;
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_Plisting_addobject
    (
     LISTING_NAME               =>'EDUCATION',
     VIEW_NAME                  =>'EDUCATION_MAIN_SECURE_VW',
     VIEW_SQL                   =>'select * from "CITIBIKE"."DEMO"."STATIONS"'
    );

/* -- REVOKE actions by sp_mpadmin_Plisting_addobject
-- -- VIEW_SQL parameter is not mandatory, And can be passed as empty string.
call mpadmin.util.sp_mpadmin_Plisting_addobject_revoke
    (
     LISTING_NAME               =>'EDUCATION',
     VIEW_NAME                  =>'EDUCATION_MAIN_SECURE_VW',
     VIEW_SQL                   =>''
    );
-- */   

/*========================= 
EXISTING BASEDB PLISTING FULFILL (COMMON): END
EXAMPLE USECASE: PAID LISTINGS
=========================*/ 

/*========================= 
[OPTIONAL STORED PROC: BEGIN] 
=========================*/  
/*-------------------------------
EXISTING BASEDB ADDITIONAL SAMPLE LISTING SETUP
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
     CTAS_TABLE_NAME            =>'EDUCATION_MAIN_TBL',
     CTAS_SQL                   =>'select * from "CITIBIKE"."DEMO"."WEATHER"  sample (1000 rows);'
    );

/* -- REVOKE actions by sp_mpadmin_listing_setup
-- -- CTAS_SQL parameter is not mandatory, And can be passed as empty string.
call mpadmin.util.sp_mpadmin_Slisting_addobject_revoke
    (
     LISTING_NAME               =>'EDUCATION',
     SAMPLELISTING_NAME_SUFFIX  =>'_K1',
     CTAS_TABLE_NAME            =>'EDUCATION_MAIN_TBL',
     CTAS_SQL                   =>'select * from mplisting_EDUCATION.private_basedata.EDUCATION_main_tbl  sample (4 rows);'
    );
-- */ 

/*========================= 
[OPTIONAL STORED PROC: END] 
=========================*/  
