/*************************************************************************************************************
Script:             Marketplace Accelerator 2.0 Account Preparation
Create Date:        2022-04-21
Author:             A. Gupta
Description:        Script contains an example call to stored procedures that prepares your snowflake account.
                    Requires AccountAdmin Role
*************************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author                              Comments
------------------- -------------------                 --------------------------------------------
2022-04-21          A. Gupta              		        Initial Publish
*************************************************************************************************************/

--------------------------------------
-- CALL sp_accountadmin_onetimesetup(): creates a mpadmin warehouse (compute) and mpadmin role with minimum privileges for marketplace admin functions
--------------------------------------
-- RUN WITH ACCOUNTADMIN ROLE. RUN THIS PROCEDURE FOR FIRST TIME SETUP ONLY

use role accountadmin; 
create warehouse if not exists temporary_compute_wh; -- If compute_wh does not exist, use any warehouse that accountadmin has access to
call MPADMIN.util.sp_accountadmin_onetimesetup
    ( PROVIDER_NAME=>'XnY_CORP'
    );
drop warehouse if exists temporary_compute_wh; 

/* -- REVOKE actions by sp_accountadmin_onetimesetup 
use role accountadmin; 
drop database if exists MPADMIN; 
drop warehouse if exists mpadmin_wh;
drop role if exists mpadmin_role;
-- */

--------------------------------------
-- CALL sp_accountadmin_creatempadminuser(): creates a mpadmin user and assigns to mpadmin role with minimum privileges for marketplace admin functions
--------------------------------------
-- RUN WITH ACCOUNTADMIN ROLE. RUN THIS PROCEDURE TO PROVISION Marketplace ADMIN Users
-- Variable1: user name for marketplace admin user
-- Variable2: temporary password (forced to change on login) for marketplace admin user

                          /*
use role accountadmin; 
use warehouse compute_wh; -- If compute_wh does not exist, use any warehouse that accountadmin has access to
call mpadmin_db.util.sp_accountadmin_creatempadminuser('mpadmin_user1','ThisPasswordIsSecretToNoOne');
                          */
 grant role mpadmin_role to user peter;
--grant role mpadmin_role to user john;
