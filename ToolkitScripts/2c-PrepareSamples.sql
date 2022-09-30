=======================================================================
STEP1 - Prepare sample data for the listing on marketplace
=======================================================================


--------------------------------------
-- CALL sp_mpadmin_Slisting_addobject 
-- Call this SP to add objects for sample listing 
-- Iteratively call this SP to add multpile objects
-- NOTE: Ensure objects name in ctas_sql are fully qualified
-- Best Practice: Pick naming of CTAS Table Name same as commercial object name 
--                to ensure seamless migration from sample to commercial data
--------------------------------------
use role mpadmin_role;
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_Slisting_addobject
    (
     LISTING_NAME               =>'INVENTORY',
     CTAS_TABLE_NAME            =>'INVENTORY_MAIN',
     CTAS_SQL                   =>'select * from mplisting_INVENTORY.private_basedata.INVENTORY_main_tbl  sample (1000 rows);'
    ); 
    
call mpadmin.util.sp_mpadmin_Slisting_addobject
    (
     LISTING_NAME               =>'INVENTORY',
     CTAS_TABLE_NAME            =>'INVENTORY_ANOTHER',
     CTAS_SQL                   =>'select * from mplisting_INVENTORY.private_basedata.INVENTORY_another_tbl  sample (10 rows);'
    ); 

DESCRIBE SHARE SSHARE_XNY_CORP_TO_COMMON_INVENTORY_SAMPLE;


/* -- REVOKE actions by sp_mpadmin_Slisting_addobject
-- -- CTAS_SQL parameter is not mandatory, And can be passed as empty string.
call mpadmin.util.sp_mpadmin_Slisting_addobject_revoke
    (
     LISTING_NAME               =>'INVENTORY',
     CTAS_TABLE_NAME            =>'INVENTORY_ANOTHER_TBL',
     CTAS_SQL                   =>'select * from mplisting_INVENTORY.private_basedata.INVENTORY_main_tbl  sample (4 rows);'
    );  
-- */   
 
======================================================================
STEP2 - Create a "STANDARD" Listing using UI following guidelines in provider playbook
=======================================================================
For first time providers, Create Profile using guide - https://www.snowflake.com/wp-content/uploads/2022/09/sm_provider_playbook_extended.pdf#page=9
For first time and existing providers, Create a standard listing to host samples using guide - https://www.snowflake.com/wp-content/uploads/2022/09/sm_provider_playbook_extended.pdf#page=10
 
/*========================= 
LISTING SETUP STORED PROC: END
=========================*/  

/*
/*========================= 
[OPTIONAL STORED PROC: BEGIN] 
=========================*/  
/*-------------------------------
ADDITIONAL SAMPLE LISTING SETUP
-------------------------------*/  
-------------------------------------
--   CALL sp_mpadmin_addsamplelisting()
-- To create additional sample listings corresponding to same Commerical Data
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
*/