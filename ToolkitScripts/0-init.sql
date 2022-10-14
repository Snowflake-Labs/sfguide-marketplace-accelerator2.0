/*************************************************************************************************************
Script:             Marketplace Accelerator 2.0 Initialization 
Create Date:        2022-04-21
Author:             A. Gupta
Description:        Script installs accelerator toolkit. Execute this file as is 
		    Requires Accountadmin role
*************************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author                              Comments
------------------- -------------------                 --------------------------------------------
2022-04-21          A. Gupta              		Initial Publish
*************************************************************************************************************/

/*========================= 
INIT() STORED PROC: BEGIN 
=========================*/ 

use role accountadmin;
create database if not exists MPADMIN QUOTED_IDENTIFIERS_IGNORE_CASE=true DATA_RETENTION_TIME_IN_DAYS= 30;
create schema if not exists MPADMIN.util; 

--set context to create utility procedures
use role accountadmin;
use schema MPADMIN.util;


create procedure if not exists sp_accountadmin_onetimesetup (PROVIDER_NAME varchar)
    returns string
    language javascript
    execute as caller
    as
    $$
    // Set variables
    var mp_provider_name = PROVIDER_NAME.toUpperCase();
    var MP_ADMIN_PREFIX ='MPADMIN';
    var mp_admin_dbname= 'MPADMIN';
    var mp_admin_schemaname= 'util';
    var mp_admin_rolename = MP_ADMIN_PREFIX.concat('_role').toUpperCase();
    var mp_admin_whname = MP_ADMIN_PREFIX.concat('_wh').toUpperCase();
    var mp_admin_tbl_basedboverride = 'listing_basedb_override'.toUpperCase();
    var mp_admin_tbl_provider = 'provider'.toUpperCase();
    var mp_admin_tbl_basedboverride_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_basedboverride);
    var mp_admin_tbl_provider_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_provider);
   
   var sql_command1 = `create role if not exists `+ mp_admin_rolename;
   var sql_command2 = `create warehouse if not exists `+ mp_admin_whname + ` auto_suspend=60`;
   var create_table1 = `create table if not exists `+mp_admin_tbl_basedboverride_qualified+` (
                          listing_name varchar(255), 
                          basedatabase_name varchar(255), 
                          modified_by string default current_user(),
                          modified_by_role string default current_role(),
                          modified_on_ts timestamp default current_timestamp()
                          ) comment = 'Table stores overrides to default basedatabase for listing ';`
                          
   var create_table2 = `create table if not exists `+mp_admin_tbl_provider_qualified+` (
                          provider_name varchar(255), 
                          modified_by string default current_user(),
                          modified_by_role string default current_role(),
                          modified_on_ts timestamp default current_timestamp()
                          ) comment = 'Table stores name of the provider. This name is used as suffix, prefix to create consumer facing objects'; `
                          
   var insert_table2 = `insert into `+mp_admin_tbl_provider_qualified+` (provider_name) values ('`+mp_provider_name+`')`;
   
   var grant_command1 = `grant CREATE DATA EXCHANGE LISTING  on account to `+ mp_admin_rolename;
   var grant_command2 = `grant CREATE SHARE on account to `+ mp_admin_rolename;  
   var grant_command3 = `grant import SHARE  on account to `+ mp_admin_rolename; 
   var grant_command4 = `grant execute task on account to `+ mp_admin_rolename; 
   var grant_command5 = `grant override share restrictions on account to role `+ mp_admin_rolename; 
   var grant_command6 = `grant ownership on database `+ mp_admin_dbname + ` to ` + mp_admin_rolename; 
   var grant_command7 = `grant ownership on warehouse `+ mp_admin_whname + ` to ` + mp_admin_rolename; 
   var grant_command8 = `grant ownership on schema `+ mp_admin_dbname + `.`+ mp_admin_schemaname + ` to ` + mp_admin_rolename; 
   var grant_command9 = `grant ownership on ALL tables in schema `+ mp_admin_dbname + `.`+ mp_admin_schemaname + ` to ` + mp_admin_rolename; 
   var grant_command10 = `grant ownership on ALL procedures in schema `+ mp_admin_dbname + `.`+ mp_admin_schemaname + ` to ` + mp_admin_rolename; 
   var grant_command11 = `grant role  `+ mp_admin_rolename+ ` to role accountadmin; --create a role hierarchy with accountadmin`;
   var grant_command12 = `grant create database  on account to `+ mp_admin_rolename;
   var grant_command13 =  `grant imported privileges on database snowflake to role `+ mp_admin_rolename;
   
   // Create role, warehouse, user  for MarketplaceAdmin
    try {
    // Create role, warehouse  for MarketplaceAdmin
                snowflake.execute (
                    {sqlText: sql_command1}
                    );
                     snowflake.execute (
                    {sqlText: sql_command2}
                    );
              
   // Create control tables and set provider name in provider table
                snowflake.execute (
                    {sqlText: create_table1}
                    );
                     snowflake.execute (
                    {sqlText: create_table2}
                    );	
                     snowflake.execute (
                    {sqlText: insert_table2}
                    );	

     // Grant ownership to marketplace database and warehouse. 
     // Grant minimum privileges required for market place administration
                snowflake.execute (
                    {sqlText: grant_command1}
                    );
                     snowflake.execute (
                    {sqlText: grant_command2}
                    );
                     snowflake.execute (
                    {sqlText: grant_command3}
                    );    
                     snowflake.execute (
                    {sqlText: grant_command4}
                    );
                    snowflake.execute (
                    {sqlText: grant_command5}
                    );
                    snowflake.execute (
                    {sqlText: grant_command6}
                    );
                    snowflake.execute (
                    {sqlText: grant_command7}
                    );
                    snowflake.execute (
                    {sqlText: grant_command8}
                    );    
                    snowflake.execute (
                    {sqlText: grant_command9}
                    );   
                    snowflake.execute (
                    {sqlText: grant_command10}
                    );   
                    snowflake.execute (
                    {sqlText: grant_command11}
                    );   
                    snowflake.execute (
                    {sqlText: grant_command12}
                    );   
                    snowflake.execute (
                    {sqlText: grant_command13}
                    );     
                }
                
            catch (err)  {
                return "Failed: " + err;   // Return a success/error indicator.
                }
     
     success_msg =  "Marketplace Objects Successfully Created In Your Account."
     success_msg += "\n ================================================================="
     success_msg += "\n Marketplace Admin Role Name: ".concat(mp_admin_rolename) 
     success_msg += "\n Admin Database Name: ".concat(mp_admin_dbname) 
     success_msg += "\n Admin Compute Warehouse Name: ".concat(mp_admin_whname) 
     success_msg += "\n Control Table1 Name: ".concat(mp_admin_tbl_provider_qualified) 
     success_msg += "\n Control Table2 Name: ".concat(mp_admin_tbl_basedboverride_qualified) 
     success_msg += "\n Provider Name set to value: ".concat(mp_provider_name).concat(" in table: ").concat(mp_admin_tbl_provider_qualified)
     success_msg += "\n Procedure 'sp_accountadmin_onetimesetup' that created these object has been placed under ".concat(mp_admin_dbname).concat('->').concat(mp_admin_schemaname).concat(' , for future reference')
     return success_msg
    $$
    ;

create procedure if not exists sp_accountadmin_creatempadminuser (MP_ADMIN_USERNAME varchar, MP_ADMIN_TEMP_PASSWORD varchar)
    returns string
    language javascript
    execute as caller
    as
    $$
    // Set variables
    var MP_ADMIN_PREFIX ='MPADMIN';
    var mp_admin_dbname= 'MPADMIN';
    var mp_admin_schemaname= 'util';
    var mp_admin_rolename = MP_ADMIN_PREFIX.concat('_role').toUpperCase();
    var mp_admin_whname = MP_ADMIN_PREFIX.concat('_wh').toUpperCase();
    var mp_admin_username = MP_ADMIN_USERNAME.toUpperCase();
    var mp_admin_temp_password = MP_ADMIN_TEMP_PASSWORD;
    var snow_account_name_tmp= snowflake.createStatement({sqlText: `select current_account()`}).execute(); snow_account_name_tmp.next(); snow_account_name = snow_account_name_tmp.getColumnValue(1);	
    var snow_account_region_tmp= snowflake.createStatement({sqlText: `select current_region()`}).execute(); snow_account_region_tmp.next(); snow_account_region = snow_account_region_tmp.getColumnValue(1);
    //return mp_admin_rolename.concat(',',mp_admin_whname,',',mp_admin_username,',',mp_admin_temp_password,',',snow_account_name,',',snow_account_region);
    
    var sql_command1 = `create user `+ mp_admin_username + ` password=`+ mp_admin_temp_password + ` default_role=`+ mp_admin_rolename + ` must_change_password = true default_warehouse = `+ mp_admin_whname + ` default_namespace=`+mp_admin_dbname;
    var grant_command1 = `grant role  `+ mp_admin_rolename+ ` to user ` + mp_admin_username; 
     try {
     snowflake.execute (
                    {sqlText: sql_command1}
                    );
     snowflake.execute (
                    {sqlText: grant_command1}
                    );     
         }
                
            catch (err)  {
                return "Failed: " + err;   // Return a success/error indicator.
                }
     
     success_msg =  "Marketplace Admin Successfully Provisioned. Credentials are as below"
     success_msg += "\n ================================================================="
     success_msg += "\n Marketplace Admin User: ".concat(mp_admin_username)
     success_msg += "\n Marketplace Admin User Temporary Password: ".concat(mp_admin_temp_password)
     success_msg += "\n Marketplace Admin Role Name: ".concat(mp_admin_rolename) 
     success_msg += "\n Database Name: ".concat(mp_admin_dbname) 
     success_msg += "\n Compute Warehouse Name: ".concat(mp_admin_whname) 
     success_msg += "\n Snowflake Account Name: ".concat(snow_account_name) 
     success_msg += "\n Snowflake Account Region: ".concat(snow_account_region) 
     success_msg += "\n Procedure 'sp_accountadmin_creatempadminuser' that created these object has been placed under ".concat(mp_admin_dbname).concat('->').concat(mp_admin_schemaname).concat(' , for future reference')
     return success_msg
    $$
    ;



create procedure if not exists sp_mpadmin_listing_setup (LISTING_NAME varchar(240), CREATE_SAMPLE_LISTING_FLAG BOOLEAN)
    returns string
    language javascript
    execute as caller
    as
    $$
    // Set variables
    
    var mp_listing_name = LISTING_NAME.toUpperCase();
    var mp_samplelisting_flag = CREATE_SAMPLE_LISTING_FLAG;
    var mp_sampledatabase_name = 'MPLISTING_'.concat(mp_listing_name).concat('_SAMPLE');
    
  //To handle existing basedata database scenarios
  var mp_admin_dbname= 'MPADMIN';
  var mp_admin_schemaname= 'util';
  var mp_admin_tbl_basedboverride = 'listing_basedb_override'.toUpperCase();
  var mp_admin_tbl_basedboverride_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_basedboverride);
  result=snowflake.execute({ sqlText:  `select basedatabase_name from `+mp_admin_tbl_basedboverride_qualified+` where listing_name = '`+LISTING_NAME+`';`});
    if (result.next()) {var mp_database_name =result.getColumnValue(1); }
    else { var mp_database_name = 'MPLISTING_'.concat(mp_listing_name);}
      
    var mp_listing_basedata_schemaname = "PRIVATE_BASEDATA";
    var mp_listing_util_schemaname = "PRIVATE_UTIL";
    var mp_listing_common_schemaname = "SHARED_".concat(mp_listing_name).concat('_COMMON');
    var mp_samplelisting_common_schemaname = "SHARED_".concat(mp_listing_name).concat('_SAMPLE');
    var mp_listing_basedata_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_basedata_schemaname);
    var mp_listing_util_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_util_schemaname);
    var mp_listing_common_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_common_schemaname);
    var mp_samplelisting_common_schemaname_qualified = mp_sampledatabase_name.concat('.').concat(mp_samplelisting_common_schemaname);
    var entitlement_tablename_qualified = mp_listing_util_schemaname_qualified.concat('.ENTITLEMENT_EXAMPLE');
    var entitlement_tablesequence_qualified = mp_listing_util_schemaname_qualified.concat('.SEQ_ENTITLEMENT');
 
    
    var samplesql_command1 = `create database if not exists `+ mp_sampledatabase_name+` comment = 'Database to hold samples of objects supporting the listing'` ;
    var samplesql_command2 = `drop schema if exists `+ mp_sampledatabase_name+`.public` ;
    var samplesql_command3 = `create schema if not exists `+mp_samplelisting_common_schemaname_qualified+` comment = 'Schema to hold samples of shared objects of the listing.'` ;
    
    var sql_command1 = `create database if not exists `+ mp_database_name+` comment = 'Database to hold objects supporting the listing'` ;
    //var sql_command2 = `drop schema if  exists `+mp_database_name+`.public` ; // removed to handle existing Basedatabase which may have non empty public schema
    var sql_command3 = `create schema if not exists `+mp_listing_basedata_schemaname_qualified+` comment = 'Schema to hold private data objects for the listing'` ;
    var sql_command4 = `create schema if not exists `+mp_listing_util_schemaname_qualified+` comment = 'Schema to hold private utility objects including entitlement for the listing'` ;
    var sql_command5 = `create schema if not exists `+mp_listing_common_schemaname_qualified+` comment = 'Schema to hold shared objects common to all consumers of the listing.'` ;
    var sql_command6 = `create sequence if not exists `+entitlement_tablesequence_qualified+` comment = 'Sequence to support entitlement table'`;
    var sql_command7 = `create table if not exists  `+ entitlement_tablename_qualified+`
                        (
                          entitlement_key number default `+entitlement_tablesequence_qualified +`.nextval not null,  
                          consumer_name string not null,
                          consumer_crm_identifier string null, 
                          consumer_snowflake_accountlocator string not null,
			  consumer_snowflake_accountregion string not null, -- Important to capture this fielf for cross-region consumers
			  entitlement_COLA VARCHAR(100), -- To be edited per the requirement
                          entitlement_COLB VARCHAR(100), -- To be edited per the requirement
                          entitlement_COLC VARCHAR(100), -- To be edited per the requirement
                          entitlement_eff_date date default current_date() not null,
                          entitlement_exp_date date,
                          modified_by string default current_user(),
                          modified_by_role string default current_role(),
                          modified_on_ts timestamp default current_timestamp()
                         ) 
                           comment = 'Example table to store entitlements for the listing'`;
    
    try {
    
     //create sample database and schema only if create_sample_listing_flag is true
     if (mp_samplelisting_flag)   {
          snowflake.execute ({sqlText: samplesql_command1}); 
          snowflake.execute ({sqlText: samplesql_command2});  
          snowflake.execute ({sqlText: samplesql_command3});  }                  
     snowflake.execute ({sqlText: sql_command1});
  //   snowflake.execute ({sqlText: sql_command2}); // removed to handle existing Basedatabase which may have non empty public schema
     snowflake.execute ({sqlText: sql_command3});
     snowflake.execute ({sqlText: sql_command4});
     snowflake.execute ({sqlText: sql_command5});
     snowflake.execute ({sqlText: sql_command6});
     snowflake.execute ({sqlText: sql_command7});                          
         }
     catch (err)  {return "Failed: " + err;}
                          
  
     success_msg =  "Objects for Listing (".concat(mp_listing_name).concat(") are now available.")
     success_msg += "\n ================================================================"
     success_msg += "\n Listing Database: ".concat(mp_database_name)
     success_msg += "\n Schema for Private Base Data: ".concat(mp_listing_basedata_schemaname_qualified)
     success_msg += "\n Schema for Private Utility Objects: ".concat(mp_listing_util_schemaname_qualified)  
     success_msg += "\n Schema for Shared Objects Common to all Consumers: ".concat(mp_listing_common_schemaname_qualified)                       
     success_msg += "\n Entitlement Table: ".concat(entitlement_tablename_qualified)
     success_msg += "\n Sequence for Entitlement Table: ".concat(entitlement_tablesequence_qualified)
     
     //display this success_msg only if create_sample_listing_flag is true
     if (mp_samplelisting_flag)   {     
     success_msg += "\n Sample Listing Database: ".concat(mp_sampledatabase_name)        
     success_msg += "\n Schema for Sample Shared Objects: ".concat(mp_samplelisting_common_schemaname_qualified)                          
     }                     
     success_msg += "\n To learn more about these objects run DESCRIBE command"
     return success_msg
    $$
    ;

-- Overloading sp_mpadmin_listing_setup to always create sample database for a given listing
create procedure if not exists sp_mpadmin_listing_setup (LISTING_NAME varchar(240))
    returns string
    language javascript
    execute as caller
    as
    $$
       result=snowflake.execute({ sqlText:  `call MPADMIN.util.sp_mpadmin_listing_setup  ('`+LISTING_NAME+`',1);`});
       result.next();
        return result.getColumnValue(1);
    $$ ;      


create procedure if not exists  sp_mpadmin_addsamplelisting (LISTING_NAME varchar(240), SAMPLELISTING_NAME_SUFFIX varchar(240))
    returns string
    language javascript
    execute as caller
    as
    $$
    // Set variables
    var productized_listing_name = LISTING_NAME.toUpperCase();
    var samplelisting_name_suffix = SAMPLELISTING_NAME_SUFFIX.toUpperCase();
    var mp_listing_name = productized_listing_name.concat(samplelisting_name_suffix);
  
   //To handle existing basedata database scenarios
  var mp_admin_dbname= 'MPADMIN';
  var mp_admin_schemaname= 'util';
  var mp_admin_tbl_basedboverride = 'listing_basedb_override'.toUpperCase();
  var mp_admin_tbl_basedboverride_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_basedboverride);
  result=snowflake.execute({ sqlText:  `select basedatabase_name from `+mp_admin_tbl_basedboverride_qualified+` where listing_name = '`+LISTING_NAME+`';`});
    if (result.next()) {var mp_database_name =result.getColumnValue(1); }
    else { var mp_database_name = 'MPLISTING_'.concat(productized_listing_name); }

    var mp_listing_basedata_schemaname = "PRIVATE_BASEDATA";
    var mp_listing_basedata_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_basedata_schemaname);
    var mp_sampledatabase_name = 'MPLISTING_'.concat(mp_listing_name).concat('_SAMPLE');
    var mp_samplelisting_common_schemaname = "SHARED_".concat(mp_listing_name).concat('_SAMPLE');
    var mp_samplelisting_common_schemaname_qualified = mp_sampledatabase_name.concat('.').concat(mp_samplelisting_common_schemaname);


    var samplesql_command1 = `create database if not exists `+ mp_sampledatabase_name+` comment = 'Database to hold samples of objects supporting the listing'` ;
    var samplesql_command2 = `drop schema if exists `+ mp_sampledatabase_name+`.public` ; 
    var samplesql_command3 = `create schema if not exists `+mp_samplelisting_common_schemaname_qualified+` comment = 'Schema to hold samples of shared objects of the listing.'` ;
   
   
   //check if corresponding productized listing objects exist. If not error else continue
    try { snowflake.execute({ sqlText: `describe schema `+mp_listing_basedata_schemaname_qualified}); } 
catch (err) { return "ERROR: Corresponding productized listing objects do not exist. call sp_mpadmin_listing_setup('".concat(productized_listing_name).concat("',0) before running this procedure");}
    
     //create sample database and schema only if create_sample_listing_flag is true
     try {     
          snowflake.execute ({sqlText: samplesql_command1}); 
          snowflake.execute ({sqlText: samplesql_command2});  
          snowflake.execute ({sqlText: samplesql_command3});                                      
         }
     catch (err)  {return "Failed: " + err;}
                          
  
     success_msg =  "Objects for Sample Listing (".concat(mp_listing_name).concat(") are now available.")
     success_msg += "\n ================================================================"
     success_msg += "\n Sample Listing Database: ".concat(mp_sampledatabase_name)        
     success_msg += "\n Schema for Sample Shared Objects: ".concat(mp_samplelisting_common_schemaname_qualified)                                          
     success_msg += "\n To learn more about these objects run DESCRIBE command"
     return success_msg
    $$
    ;


--grant ownership on all procedures in schema MPADMIN.util to role mpadmin_role;

create procedure if not exists  sp_mpadmin_Plisting_addobject (LISTING_NAME varchar, CONSUMER_NAME varchar, VIEW_NAME varchar, VIEW_SQL varchar)
    returns string
    language javascript
    execute as caller
    as
    $$
    // Set variables
    var mp_listing_name = LISTING_NAME.toUpperCase();
    var mp_listing_consumer_name = CONSUMER_NAME.toUpperCase();
        
    //set provider name variable from provider table
    var mp_admin_dbname= 'MPADMIN';
    var mp_admin_schemaname= 'util';
    var mp_admin_tbl_provider = 'provider'.toUpperCase();
    var mp_admin_tbl_provider_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_provider);
    result=snowflake.execute({ sqlText:  `select any_value(provider_name) from `+mp_admin_tbl_provider_qualified});
    result.next()
    var mp_listing_provider_name=result.getColumnValue(1); 
    
    var mp_listing_secureview_name = VIEW_NAME.toUpperCase();
    var mp_listing_secureview_sql = VIEW_SQL;
    
  //To handle existing basedata database scenarios
  var mp_admin_dbname= 'MPADMIN';
  var mp_admin_schemaname= 'util';
  var mp_admin_tbl_basedboverride = 'listing_basedb_override'.toUpperCase();
  var mp_admin_tbl_basedboverride_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_basedboverride);
  result=snowflake.execute({ sqlText:  `select basedatabase_name from `+mp_admin_tbl_basedboverride_qualified+` where listing_name = '`+LISTING_NAME+`';`});
    if (result.next()) {var mp_database_name =result.getColumnValue(1); }
    else { var mp_database_name = 'MPLISTING_'.concat(mp_listing_name);}
      
    var mp_listing_basedata_schemaname = "PRIVATE_BASEDATA";
    var mp_listing_basedata_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_basedata_schemaname);
    var mp_consumer_share_name = 'PSHARE_'.concat(mp_listing_provider_name).concat('_TO_').concat(mp_listing_consumer_name).concat('_').concat(mp_listing_name);
    var mp_consumer_dbname = mp_database_name;
    var mp_consumer_schemaname = 'SHARED_'.concat(mp_listing_name).concat('_').concat(mp_listing_consumer_name);
    var mp_consumer_schemaname_qualified = mp_consumer_dbname.concat('.').concat(mp_consumer_schemaname);
    var mp_consumer_secureview_name_qualified = mp_consumer_schemaname_qualified.concat('.').concat(mp_listing_secureview_name);
    var mpadmin_dbname = 'MPADMIN';       
   
    
// check if entered sql is valid
try { snowflake.execute({ sqlText: `explain `+mp_listing_secureview_sql }); } 
catch (err) { return "SQL Check Failed: "  + err }

// check if all required objects else fail
try {snowflake.execute({ sqlText: `describe schema `+mp_listing_basedata_schemaname_qualified}); } 
catch (err) { return "ERROR: Listing is not setup yet. Call procedure sp_mpadmin_listing_setup('".concat(mp_listing_name).concat("') before running this procedure.");}

//create consumer specific schema
var sql_command1 = `create schema if not exists `+ mp_consumer_schemaname_qualified+` comment = 'Schema to hold objects shared with consumer (`+ mp_listing_consumer_name+`) for the listing (`+mp_listing_name+`)'`;
//create consumer specific share
var sql_command2 = `create share if not exists `+ mp_consumer_share_name+` comment = 'This is outbound productized share for Consumer (`+ mp_listing_consumer_name+`)'`;
//create secure view with sql text in consumer specific schema
var sql_command3 = `create secure view if not exists `+mp_consumer_secureview_name_qualified+` as `+mp_listing_secureview_sql;


//add secure view to consumer specific share 
var grant_command1 = `grant usage on database `+mp_consumer_dbname+` to share `+mp_consumer_share_name;
var grant_command2 = `grant usage on schema `+mp_consumer_schemaname_qualified+` to share `+mp_consumer_share_name;
var grant_command3 = `grant select on view `+mp_consumer_secureview_name_qualified+` to share `+mp_consumer_share_name;


try {
//execute create secure view and add to share
     snowflake.execute ({sqlText: sql_command1});
     snowflake.execute ({sqlText: sql_command2});
     snowflake.execute ({sqlText: sql_command3});
     
     snowflake.execute ({sqlText: grant_command1});    
     snowflake.execute ({sqlText: grant_command2});    
     snowflake.execute ({sqlText: grant_command3});    
     }
     catch (err)  {return "Failed: " + err;   }
                          
  
     success_msg =  "Object Successfully Added to Listing Share for the Consumer(".concat(mp_listing_consumer_name).concat(').')
     success_msg += "\n ================================================================="
     success_msg += "\n Consumer Specific Share for the listing: ".concat(mp_consumer_share_name)
     success_msg += "\n Object Added to the Share: ".concat(mp_consumer_secureview_name_qualified)
     success_msg += "\n Object Stored in Schema: ".concat(mp_consumer_schemaname_qualified)	
     success_msg += "\n To double-check run: DESCRIBE SHARE ".concat(mp_consumer_share_name).concat(" ;")
     return success_msg
    
    $$
    ;

-- Overloading sp_mpadmin_Plisting_addobject to add objects for COMMON productized listing
create procedure if not exists  sp_mpadmin_Plisting_addobject (LISTING_NAME varchar, VIEW_NAME varchar, VIEW_SQL varchar)
    returns string
    language javascript
    execute as caller
    as
    $$
       result=snowflake.execute({ sqlText:  `call MPADMIN.util.sp_mpadmin_Plisting_addobject  ('`+LISTING_NAME+`','COMMON','`+VIEW_NAME+`','`+VIEW_SQL+`');`});
       result.next();
        return result.getColumnValue(1);
    $$ ;     


create procedure if not exists  sp_mpadmin_Slisting_addobject (LISTING_NAME varchar(240), SAMPLELISTING_NAME_SUFFIX varchar(240), CTAS_TABLE_NAME varchar, CTAS_SQL varchar)
    returns string
    language javascript
    execute as caller
    as
    $$
    // Set variables
    var productized_listing_name = LISTING_NAME.toUpperCase();
    var samplelisting_name_suffix = SAMPLELISTING_NAME_SUFFIX.toUpperCase();
    var mp_listing_name = productized_listing_name.concat(samplelisting_name_suffix);
        
    //set provider name variable from provider table
    var mp_admin_dbname= 'MPADMIN';
    var mp_admin_schemaname= 'util';
    var mp_admin_tbl_provider = 'provider'.toUpperCase();
    var mp_admin_tbl_provider_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_provider);
    result=snowflake.execute({ sqlText:  `select any_value(provider_name) from `+mp_admin_tbl_provider_qualified});
    result.next()
    var mp_listing_provider_name=result.getColumnValue(1); 
    
    var mp_listing_secureview_name = CTAS_TABLE_NAME.toUpperCase();
    var mp_listing_secureview_sql = CTAS_SQL;
    var mp_sampledatabase_name = 'MPLISTING_'.concat(mp_listing_name).concat('_SAMPLE');
    var mp_samplelisting_common_schemaname = "SHARED_".concat(mp_listing_name).concat('_SAMPLE');
    var mp_samplelisting_common_schemaname_qualified = mp_sampledatabase_name.concat('.').concat(mp_samplelisting_common_schemaname);

  //To handle existing basedata database scenarios
  var mp_admin_dbname= 'MPADMIN';
  var mp_admin_schemaname= 'util';
  var mp_admin_tbl_basedboverride = 'listing_basedb_override'.toUpperCase();
  var mp_admin_tbl_basedboverride_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_basedboverride);
  result=snowflake.execute({ sqlText:  `select basedatabase_name from `+mp_admin_tbl_basedboverride_qualified+` where listing_name = '`+LISTING_NAME+`';`});
    if (result.next()) {var mp_database_name =result.getColumnValue(1); }
    else { var mp_database_name = 'MPLISTING_'.concat(productized_listing_name); }
    

    var mp_listing_basedata_schemaname = "PRIVATE_BASEDATA";
    var mp_listing_basedata_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_basedata_schemaname);
    var mp_samplelisting_secureview_name_qualified = mp_samplelisting_common_schemaname_qualified.concat('.').concat(mp_listing_secureview_name);
    var mp_samplelisting_share_name = 'SSHARE_'.concat(mp_listing_provider_name).concat('_TO_COMMON_').concat(mp_listing_name).concat('_SAMPLE');
    var mpadmin_dbname = 'MPADMIN';       
   
    
// check if entered sql is valid
try { snowflake.execute({ sqlText: `explain `+mp_listing_secureview_sql }); } 
catch (err) { return "SQL Check Failed: "  + err }

// check if all required objects else fail
try {snowflake.execute({ sqlText: `describe schema `+mp_listing_basedata_schemaname_qualified}); } 
catch (err) { return "ERROR: Listing is not setup yet. Call procedure sp_mpadmin_listing_setup('".concat(mp_listing_name).concat("') before running this procedure.");}
try {snowflake.execute({ sqlText: `describe schema `+mp_samplelisting_common_schemaname_qualified}); } 
catch (err) { return "ERROR: Sample listing is not setup yet. Call procedure sp_mpadmin_addsamplelisting('".concat(productized_listing_name).concat("','").concat(samplelisting_name_suffix).concat("') before running this procedure.");}

//create sample listing specific share
var sql_command1 = `create share if not exists `+ mp_samplelisting_share_name+` comment = 'This is outbound sample share common for all consumers'`;
//create secure view with sql text in consumer specific schema
var sql_command2 = `create table if not exists `+mp_samplelisting_secureview_name_qualified +` as `+mp_listing_secureview_sql;


//add secure view to consumer specific share 
var grant_command1 = `grant usage on database `+mp_sampledatabase_name+` to share `+mp_samplelisting_share_name;
var grant_command2 = `grant usage on schema `+mp_samplelisting_common_schemaname_qualified+` to share `+mp_samplelisting_share_name;
var grant_command3 = `grant select on view `+mp_samplelisting_secureview_name_qualified+` to share `+mp_samplelisting_share_name;


try {
//execute create secure view and add to share
     snowflake.execute ({sqlText: sql_command1});
     snowflake.execute ({sqlText: sql_command2});
     
     snowflake.execute ({sqlText: grant_command1});    
     snowflake.execute ({sqlText: grant_command2});    
     snowflake.execute ({sqlText: grant_command3});    
     }
     catch (err)  {return "Failed: " + err;   }
                          
  
     success_msg =  "Object Successfully Added to Sample Listing Share"
     success_msg += "\n ================================================================="
     success_msg += "\n Share for sample listing: ".concat(mp_samplelisting_share_name)
     success_msg += "\n Object Added to the Share: ".concat(mp_samplelisting_secureview_name_qualified)
     success_msg += "\n Object Stored in Schema: ".concat(mp_samplelisting_common_schemaname_qualified)	
     success_msg += "\n To double-check run: DESCRIBE SHARE ".concat(mp_samplelisting_share_name).concat(" ;")
     return success_msg
    
    $$
    ;


-- Overloading sp_mpadmin_Slisting_addobject to add objects for sample listing when there is only 1 sample listing per productized listing. Common usecase
create procedure if not exists sp_mpadmin_Slisting_addobject (LISTING_NAME varchar, CTAS_TABLE_NAME varchar, CTAS_SQL varchar)
    returns string
    language javascript
    execute as caller
    as
    $$
       result=snowflake.execute({ sqlText:  `call MPADMIN.util.sp_mpadmin_Slisting_addobject  ('`+LISTING_NAME+`','','`+CTAS_TABLE_NAME+`','`+CTAS_SQL+`');`});
       result.next();
        return result.getColumnValue(1);
    $$ ;     



create procedure if not exists sp_accountadmin_listing_basedb_override (LISTING_NAME varchar(240), OVERRIDE_BASEDATABASE_NAME varchar(240))
    returns string
    language javascript
    execute as caller
    as
    $$
    // Set variables
    
    var mp_listing_name = LISTING_NAME.toUpperCase();
    var mp_basedb_name = OVERRIDE_BASEDATABASE_NAME.toUpperCase();

    var mp_admin_dbname= 'MPADMIN';
    var mp_admin_schemaname= 'util';
    var mp_admin_tbl_basedboverride = 'listing_basedb_override'.toUpperCase();
    var mp_admin_tbl_basedboverride_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_basedboverride);
    
    var MP_ADMIN_PREFIX ='MPADMIN';
    var mp_admin_rolename = MP_ADMIN_PREFIX.concat('_role').toUpperCase();

    try {snowflake.execute({ sqlText: `describe table `+mp_admin_tbl_basedboverride_qualified});} 
    catch (err) {return "Call sp_accountadmin_onetimesetup procedure before continuing. Failed with error: " + err;   } 
    
    result=snowflake.execute({ sqlText:  `select basedatabase_name from `+mp_admin_tbl_basedboverride_qualified+` where listing_name = '`+mp_listing_name+`';`});
    if (result.next()) {return 'ERROR: Override for the listing already exists. To check, OverrideDB name, query override table: '.concat(mp_admin_tbl_basedboverride_qualified)}

    
    // grant minimum privileges on the basedb objects for MPADMIN to perform its functions
    try {
             snowflake.execute({ sqlText: `grant create schema on database `+mp_basedb_name+` to role `+mp_admin_rolename }); 
             snowflake.execute({ sqlText: `grant usage on database `+mp_basedb_name+` to role `+mp_admin_rolename+ ` with grant option` });  //With grant option is needed to be able to grant usage on this database to shares. As this database is not owned by MPADMIN_ROLE
             snowflake.execute({ sqlText: `grant usage on all schemas in database  `+mp_basedb_name+` to role `+mp_admin_rolename });         
             snowflake.execute({ sqlText: `grant select on all tables in database  `+mp_basedb_name+` to role `+mp_admin_rolename });  
             snowflake.execute({ sqlText: `grant select on all views in database  `+mp_basedb_name+` to role `+mp_admin_rolename });  
             snowflake.execute({ sqlText: `grant usage on all functions in database  `+mp_basedb_name+` to role `+mp_admin_rolename });  
             snowflake.execute({ sqlText: `grant usage on all procedures in database  `+mp_basedb_name+` to role `+mp_admin_rolename });  
             snowflake.execute({ sqlText: `grant usage on future schemas in database  `+mp_basedb_name+` to role `+mp_admin_rolename });  
             snowflake.execute({ sqlText: `grant select on future tables in database  `+mp_basedb_name+` to role `+mp_admin_rolename });  
             snowflake.execute({ sqlText: `grant select on future views in database  `+mp_basedb_name+` to role `+mp_admin_rolename });  
             snowflake.execute({ sqlText: `grant usage on future functions in database  `+mp_basedb_name+` to role `+mp_admin_rolename });  
             snowflake.execute({ sqlText: `grant usage on future procedures in database `+mp_basedb_name+` to role `+mp_admin_rolename });  

             // Record Override DB name for the listing. Will be used by sp_mpadmin_listing_setup and other procedures to retreive baseDb name
             snowflake.execute({ sqlText: `insert into `+mp_admin_tbl_basedboverride_qualified+` (listing_name, basedatabase_name) values ('`+mp_listing_name+`','`+mp_basedb_name+`')` });    
        }
    catch (err)  {return "Failed: " + err;   }

     success_msg =  "BaseDB Succesfully Overriden for the listing (".concat(mp_listing_name).concat(").");
     success_msg += "\n ================================================================="
     success_msg += "\n BaseDB Set to: ".concat(mp_basedb_name)
     success_msg += "\n for Listing: ".concat(mp_listing_name)

     return success_msg
   
    $$ ;  

create procedure if not exists sp_accountadmin_listing_basedb_override_revoke (LISTING_NAME varchar(240), OVERRIDE_BASEDATABASE_NAME varchar(240))
    returns string
    language javascript
    execute as caller
    as
    $$
    // Set variables
    
    var mp_listing_name = LISTING_NAME.toUpperCase();
    var mp_basedb_name = OVERRIDE_BASEDATABASE_NAME.toUpperCase();

    var mp_admin_dbname= 'MPADMIN';
    var mp_admin_schemaname= 'util';
    var mp_admin_tbl_basedboverride = 'listing_basedb_override'.toUpperCase();
    var mp_admin_tbl_basedboverride_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_basedboverride);
    
    var MP_ADMIN_PREFIX ='MPADMIN';
    var mp_admin_rolename = MP_ADMIN_PREFIX.concat('_role').toUpperCase();

    try {snowflake.execute({ sqlText: `describe table `+mp_admin_tbl_basedboverride_qualified});} 
    catch (err) {return "Nothing to revoke. Failed with error: " + err;   } 
    
    basedb_check=snowflake.execute({ sqlText:  `select basedatabase_name from `+mp_admin_tbl_basedboverride_qualified+` where listing_name = '`+mp_listing_name+`';`});
    if (!basedb_check.next()) {return 'Nothing to revoke. ERROR: No Entry for the listing in Override table: '.concat(mp_admin_tbl_basedboverride_qualified)}

    
    // grant minimum privileges on the basedb objects for MPADMIN to perform its functions
    try {
             snowflake.execute({ sqlText: `delete from `+mp_admin_tbl_basedboverride_qualified+` where LISTING_NAME='`+mp_listing_name+`'` });    
        }
    catch (err)  {return "Failed: " + err;   }

     success_msg =  "BaseDB Override succesfully revoked for listing (".concat(mp_listing_name).concat(").");
     success_msg += "\n ================================================================="
     success_msg += "\n BaseDB UnSet from: ".concat(basedb_check.getColumnValue(1))
     success_msg += "\n for Listing: ".concat(mp_listing_name)

     return success_msg
   
    $$ ;  


 create procedure if not exists sp_mpadmin_Slisting_addobject_revoke (LISTING_NAME varchar(240), SAMPLELISTING_NAME_SUFFIX varchar(240), CTAS_TABLE_NAME varchar, CTAS_SQL varchar)
    returns string
    language javascript
    execute as caller
    as
    $$
    // Set variables
    var productized_listing_name = LISTING_NAME.toUpperCase();
    var samplelisting_name_suffix = SAMPLELISTING_NAME_SUFFIX.toUpperCase();
    var mp_listing_name = productized_listing_name.concat(samplelisting_name_suffix);
        
    //set provider name variable from provider table
    var mp_admin_dbname= 'MPADMIN';
    var mp_admin_schemaname= 'util';
    var mp_admin_tbl_provider = 'provider'.toUpperCase();
    var mp_admin_tbl_provider_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_provider);
    result=snowflake.execute({ sqlText:  `select any_value(provider_name) from `+mp_admin_tbl_provider_qualified});
    result.next()
    var mp_listing_provider_name=result.getColumnValue(1); 
    
    var mp_listing_secureview_name = CTAS_TABLE_NAME.toUpperCase();
    var mp_listing_secureview_sql = CTAS_SQL;
    var mp_sampledatabase_name = 'MPLISTING_'.concat(mp_listing_name).concat('_SAMPLE');
    var mp_samplelisting_common_schemaname = "SHARED_".concat(mp_listing_name).concat('_SAMPLE');
    var mp_samplelisting_common_schemaname_qualified = mp_sampledatabase_name.concat('.').concat(mp_samplelisting_common_schemaname);

  //To handle existing basedata database scenarios
  var mp_admin_dbname= 'MPADMIN';
  var mp_admin_schemaname= 'util';
  var mp_admin_tbl_basedboverride = 'listing_basedb_override'.toUpperCase();
  var mp_admin_tbl_basedboverride_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_basedboverride);
  result=snowflake.execute({ sqlText:  `select basedatabase_name from `+mp_admin_tbl_basedboverride_qualified+` where listing_name = '`+LISTING_NAME+`';`});
    if (result.next()) {var mp_database_name =result.getColumnValue(1); }
    else { var mp_database_name = 'MPLISTING_'.concat(productized_listing_name); }
    

    var mp_listing_basedata_schemaname = "PRIVATE_BASEDATA";
    var mp_listing_basedata_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_basedata_schemaname);
    var mp_samplelisting_secureview_name_qualified = mp_samplelisting_common_schemaname_qualified.concat('.').concat(mp_listing_secureview_name);
    var mp_samplelisting_share_name = 'SSHARE_'.concat(mp_listing_provider_name).concat('_TO_COMMON_').concat(mp_listing_name).concat('_SAMPLE');
    var mpadmin_dbname = 'MPADMIN';    

try {snowflake.execute({ sqlText: `describe table `+mp_samplelisting_secureview_name_qualified});
    snowflake.execute({ sqlText: `describe share `+mp_samplelisting_share_name});} 
catch (err) {return "Nothing to revoke. Failed with error: " + err;   } 

var sql_command1 = `drop table `+mp_samplelisting_secureview_name_qualified;
try {snowflake.execute ({sqlText: sql_command1});} catch (err)  {return "Failed: " + err;   }

       success_msg =  "Object Successfully Removed from Sample Listing Share"
       success_msg += "\n ================================================================="
       success_msg += "\n Share for sample listing: ".concat(mp_samplelisting_share_name)
       success_msg += "\n Object Removed from the Share: ".concat(mp_samplelisting_secureview_name_qualified)
       success_msg += "\n To double-check run: DESCRIBE SHARE ".concat(mp_samplelisting_share_name).concat(" ;")
       return success_msg
      

    $$   ;  



 create procedure if not exists sp_mpadmin_Slisting_addobject_revoke (LISTING_NAME varchar, CTAS_TABLE_NAME varchar, CTAS_SQL varchar)
    returns string
    language javascript
    execute as caller
    as
    $$
       result=snowflake.execute({ sqlText:  `call MPADMIN.util.sp_mpadmin_Slisting_addobject_revoke  ('`+LISTING_NAME+`','','`+CTAS_TABLE_NAME+`','`+CTAS_SQL+`');`});
       result.next();
        return result.getColumnValue(1);
    $$ ;    

  create procedure if not exists  sp_mpadmin_Plisting_addobject_revoke (LISTING_NAME varchar, CONSUMER_NAME varchar, VIEW_NAME varchar, VIEW_SQL varchar)
    returns string
    language javascript
    execute as caller
    as
    $$
    // Set variables
    var mp_listing_name = LISTING_NAME.toUpperCase();
    var mp_listing_consumer_name = CONSUMER_NAME.toUpperCase();
        
    //set provider name variable from provider table
    var mp_admin_dbname= 'MPADMIN';
    var mp_admin_schemaname= 'util';
    var mp_admin_tbl_provider = 'provider'.toUpperCase();
    var mp_admin_tbl_provider_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_provider);
    result=snowflake.execute({ sqlText:  `select any_value(provider_name) from `+mp_admin_tbl_provider_qualified});
    result.next()
    var mp_listing_provider_name=result.getColumnValue(1); 
    
    var mp_listing_secureview_name = VIEW_NAME.toUpperCase();
    var mp_listing_secureview_sql = VIEW_SQL;
    
  //To handle existing basedata database scenarios
  var mp_admin_dbname= 'MPADMIN';
  var mp_admin_schemaname= 'util';
  var mp_admin_tbl_basedboverride = 'listing_basedb_override'.toUpperCase();
  var mp_admin_tbl_basedboverride_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_basedboverride);
  result=snowflake.execute({ sqlText:  `select basedatabase_name from `+mp_admin_tbl_basedboverride_qualified+` where listing_name = '`+LISTING_NAME+`';`});
    if (result.next()) {var mp_database_name =result.getColumnValue(1); }
    else { var mp_database_name = 'MPLISTING_'.concat(mp_listing_name);}
      
    var mp_listing_basedata_schemaname = "PRIVATE_BASEDATA";
    var mp_listing_basedata_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_basedata_schemaname);
    var mp_consumer_share_name = 'PSHARE_'.concat(mp_listing_provider_name).concat('_TO_').concat(mp_listing_consumer_name).concat('_').concat(mp_listing_name);
    var mp_consumer_dbname = mp_database_name;
    var mp_consumer_schemaname = 'SHARED_'.concat(mp_listing_name).concat('_').concat(mp_listing_consumer_name);
    var mp_consumer_schemaname_qualified = mp_consumer_dbname.concat('.').concat(mp_consumer_schemaname);
    var mp_consumer_secureview_name_qualified = mp_consumer_schemaname_qualified.concat('.').concat(mp_listing_secureview_name);
    var mpadmin_dbname = 'MPADMIN';   
    
    try {snowflake.execute({ sqlText: `describe view `+mp_consumer_secureview_name_qualified});
    snowflake.execute({ sqlText: `describe share `+mp_consumer_share_name});} 
catch (err) {return "Nothing to revoke. Failed with error: " + err;   } 

var sql_command1 = `drop view `+mp_consumer_secureview_name_qualified;
try {snowflake.execute ({sqlText: sql_command1});} catch (err)  {return "Failed: " + err;   }

     success_msg =  "Object Successfully Removed from Listing Share for the Consumer(".concat(mp_listing_consumer_name).concat(').')
       success_msg += "\n ================================================================="
       success_msg += "\n Consumer Specific Share for the listing: ".concat(mp_consumer_share_name)
     success_msg += "\n Object Removed from the Share: ".concat(mp_consumer_secureview_name_qualified)
     success_msg += "\n To double-check run: DESCRIBE SHARE ".concat(mp_consumer_share_name).concat(" ;")
       return success_msg
      
    $$   ;  
    
create procedure if not exists  sp_mpadmin_Plisting_addobject_revoke (LISTING_NAME varchar, VIEW_NAME varchar, VIEW_SQL varchar)
    returns string
    language javascript
    execute as caller
    as
    $$
       result=snowflake.execute({ sqlText:  `call MPADMIN.util.sp_mpadmin_Plisting_addobject_revoke  ('`+LISTING_NAME+`','COMMON','`+VIEW_NAME+`','`+VIEW_SQL+`');`});
       result.next();
        return result.getColumnValue(1);
    $$ ;     



create procedure if not exists  sp_mpadmin_Plisting_dropconsumer  (LISTING_NAME varchar, CONSUMER_NAME varchar)
    returns string
    language javascript
    execute as caller
    as
    $$
     var mp_listing_name = LISTING_NAME.toUpperCase();
    var mp_listing_consumer_name = CONSUMER_NAME.toUpperCase();
        
    //set provider name variable from provider table
    var mp_admin_dbname= 'MPADMIN';
    var mp_admin_schemaname= 'util';
    var mp_admin_tbl_provider = 'provider'.toUpperCase();
    var mp_admin_tbl_provider_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_provider);
    result=snowflake.execute({ sqlText:  `select any_value(provider_name) from `+mp_admin_tbl_provider_qualified});
    result.next()
    var mp_listing_provider_name=result.getColumnValue(1); 
    
    
  //To handle existing basedata database scenarios
  var mp_admin_dbname= 'MPADMIN';
  var mp_admin_schemaname= 'util';
  var mp_admin_tbl_basedboverride = 'listing_basedb_override'.toUpperCase();
  var mp_admin_tbl_basedboverride_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_basedboverride);
  result=snowflake.execute({ sqlText:  `select basedatabase_name from `+mp_admin_tbl_basedboverride_qualified+` where listing_name = '`+LISTING_NAME+`';`});
    if (result.next()) {var mp_database_name =result.getColumnValue(1); }
    else { var mp_database_name = 'MPLISTING_'.concat(mp_listing_name);}
      
    var mp_listing_basedata_schemaname = "PRIVATE_BASEDATA";
    var mp_listing_basedata_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_basedata_schemaname);
    var mp_consumer_share_name = 'PSHARE_'.concat(mp_listing_provider_name).concat('_TO_').concat(mp_listing_consumer_name).concat('_').concat(mp_listing_name);
    var mp_consumer_dbname = mp_database_name;
    var mp_consumer_schemaname = 'SHARED_'.concat(mp_listing_name).concat('_').concat(mp_listing_consumer_name);
    var mp_consumer_schemaname_qualified = mp_consumer_dbname.concat('.').concat(mp_consumer_schemaname);
    var mpadmin_dbname = 'MPADMIN';   
    
    var entitlement_dbname = mp_consumer_dbname;  
    var entitlement_schemaname = 'PRIVATE_UTIL'; 
    var entitlement_tablename_qualified = entitlement_dbname.concat('.').concat(entitlement_schemaname).concat('.ENTITLEMENT');
    
    try {snowflake.execute({ sqlText: `describe schema `+mp_consumer_schemaname_qualified });
    snowflake.execute({ sqlText: `describe share `+mp_consumer_share_name});} 
    catch (err) {return "Nothing to drop. Failed with error: " + err;   } 
    
    try {
  var result = snowflake.execute({ sqlText:  `select CONSUMER_SNOWFLAKE_ACCOUNTLOCATOR, CONSUMER_SNOWFLAKE_ACCOUNTREGION from `+entitlement_tablename_qualified+` where ENTITLEMENT_CONTAINER_TYPE = 'SHARE' and ENTITLEMENT_CONTAINER_NAME = '`+mp_consumer_share_name+`';`  });  
  var existing_entitlement_check=result.next();
  }  catch (err)  {return "Nothing to drop. Failed with error: " + err;   }   
  
   if (existing_entitlement_check)
    {
    return 'Listing Entitlements exist for the consumer ('.concat(mp_listing_consumer_name).concat('). Call procedure mpadmin.util.sp_mpadmin_Plisting_sendtoconsumer_revoke() before continuing.')
    }
    else
    {
    var sql_command1 = `drop share if exists `+mp_consumer_share_name;
    var sql_command2 = `drop schema if exists `+mp_consumer_schemaname_qualified;
    try {snowflake.execute ({sqlText: sql_command1});
         snowflake.execute ({sqlText: sql_command2});} 
    catch (err)  {return "Failed: " + err;   }

     success_msg =  "Objects Successfully Dropped specific to Consumer(".concat(mp_listing_consumer_name).concat('). for the listing')
     success_msg += "\n ================================================================="
     success_msg += "\n Dropped Consumer Specific Share for the listing: ".concat(mp_consumer_share_name)
     success_msg += "\n Dropped Consumer Specific Schema for the listing: ".concat(mp_consumer_schemaname_qualified)
     return success_msg
    }
    $$ ;     


create procedure if not exists  sp_mpadmin_addsamplelisting_revoke (LISTING_NAME varchar(240), SAMPLELISTING_NAME_SUFFIX varchar(240))
    returns string
    language javascript
    execute as caller
    as
    $$
    // Set variables
    var productized_listing_name = LISTING_NAME.toUpperCase();
    var samplelisting_name_suffix = SAMPLELISTING_NAME_SUFFIX.toUpperCase();
    var mp_listing_name = productized_listing_name.concat(samplelisting_name_suffix);
     //To handle existing basedata database scenarios
  var mp_admin_dbname= 'MPADMIN';
  var mp_admin_schemaname= 'util';
  var mp_admin_tbl_basedboverride = 'listing_basedb_override'.toUpperCase();
  var mp_admin_tbl_basedboverride_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_basedboverride);
  result=snowflake.execute({ sqlText:  `select basedatabase_name from `+mp_admin_tbl_basedboverride_qualified+` where listing_name = '`+LISTING_NAME+`';`});
    if (result.next()) {var mp_database_name =result.getColumnValue(1); }
    else { var mp_database_name = 'MPLISTING_'.concat(productized_listing_name); }

    var mp_listing_basedata_schemaname = "PRIVATE_BASEDATA";
    var mp_listing_basedata_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_basedata_schemaname);
    var mp_sampledatabase_name = 'MPLISTING_'.concat(mp_listing_name).concat('_SAMPLE');
    var mp_samplelisting_common_schemaname = "SHARED_".concat(mp_listing_name).concat('_SAMPLE');
    var mp_samplelisting_common_schemaname_qualified = mp_sampledatabase_name.concat('.').concat(mp_samplelisting_common_schemaname);
   
     // find the share associated with the sample database to drop the share
     snowflake.execute({ sqlText:  `SHOW SHARES;`  });  
      var result = snowflake.execute({ sqlText:  `select "name" from table(result_scan(last_query_id())) where "kind" = 'OUTBOUND' and "database_name"='`+mp_sampledatabase_name+`';`  });  
      result.next();
      var mp_samplelisting_share_name = result.getColumnValue(1);
  
    try {snowflake.execute({ sqlText: `describe schema `+mp_samplelisting_common_schemaname_qualified });} 
    catch (err) {return "Nothing to drop. Failed with error: " + err;   } 
    
    //Check If share was setup by running sp sp_mpadmin_Slisting_addobject  then set share_exists  else unset share_exists 
      try {snowflake.execute({ sqlText: `describe share `+mp_samplelisting_share_name });
            var share_exists_flag =1;} 
    catch (err) {  var share_exists_flag =0; } 
    

    var sql_command1 = `drop share if exists `+mp_samplelisting_share_name;
    var sql_command2 = `drop database if exists `+mp_sampledatabase_name;
    
    try {
        //if share exists drop else only drop database
        if (share_exists_flag) {snowflake.execute ({sqlText: sql_command1}); }
        snowflake.execute ({sqlText: sql_command2});
        } 
    catch (err)  {return "Failed: " + err;   }

     success_msg =  "Objects Sucessfully Dropped for Sample Listing (".concat(mp_listing_name).concat(").")
     success_msg += "\n ================================================================="
     success_msg += "\n Dropped Database for the Sample listing: ".concat(mp_sampledatabase_name)
      
      //Display msg only is share was dropped
      if (share_exists_flag) {
       success_msg += "\n Dropped Share for the Sample listing: ".concat(mp_samplelisting_share_name)
      }
     return success_msg
   
    $$ ;   



create procedure if not exists  sp_mpadmin_listing_setup_revoke (LISTING_NAME varchar(240), CREATE_SAMPLE_LISTING_FLAG BOOLEAN)
    returns string
    language javascript
    execute as caller
    as
    $$
    // Set variables
    
    var mp_listing_name = LISTING_NAME.toUpperCase();
    var mp_samplelisting_flag = CREATE_SAMPLE_LISTING_FLAG;
    var mp_sampledatabase_name = 'MPLISTING_'.concat(mp_listing_name).concat('_SAMPLE');
    
  //To handle existing basedata database scenarios
  var mp_admin_dbname= 'MPADMIN';
  var mp_admin_schemaname= 'util';
  var mp_admin_tbl_basedboverride = 'listing_basedb_override'.toUpperCase();
  var mp_admin_tbl_basedboverride_qualified = mp_admin_dbname.concat('.').concat(mp_admin_schemaname).concat('.').concat(mp_admin_tbl_basedboverride);
  result=snowflake.execute({ sqlText:  `select basedatabase_name from `+mp_admin_tbl_basedboverride_qualified+` where listing_name = '`+LISTING_NAME+`';`});
    if (result.next()) {var basedb_override_flag=1; var mp_database_name =result.getColumnValue(1);  }
    else { var basedb_override_flag=0; var mp_database_name = 'MPLISTING_'.concat(mp_listing_name);}
      
    var mp_listing_basedata_schemaname = "PRIVATE_BASEDATA";
    var mp_listing_util_schemaname = "PRIVATE_UTIL";
    var mp_listing_common_schemaname = "SHARED_".concat(mp_listing_name).concat('_COMMON');
    var mp_samplelisting_common_schemaname = "SHARED_".concat(mp_listing_name).concat('_SAMPLE');
    var mp_listing_basedata_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_basedata_schemaname);
    var mp_listing_util_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_util_schemaname);
    var mp_listing_common_schemaname_qualified = mp_database_name.concat('.').concat(mp_listing_common_schemaname);
    var mp_samplelisting_common_schemaname_qualified = mp_sampledatabase_name.concat('.').concat(mp_samplelisting_common_schemaname);
    var entitlement_tablename_qualified = mp_listing_util_schemaname_qualified.concat('.ENTITLEMENT');
    var entitlement_tablesequence_qualified = mp_listing_util_schemaname_qualified.concat('.SEQ_ENTITLEMENT');

    try {snowflake.execute({ sqlText: `describe schema `+mp_listing_util_schemaname_qualified});} 
    catch (err) {return "Nothing to drop. Failed with error: " + err;   } 
    
    try {snowflake.execute({ sqlText: `describe database `+mp_sampledatabase_name});
    var sampledb_exists_flag =1;} 
    catch (err) {var sampledb_exists_flag =0;} 
    
    //Find all shares associates with listing database and sample database
    snowflake.execute({ sqlText:  `SHOW SHARES;`  });  
    var result = snowflake.execute({ sqlText:  `select "name" from table(result_scan(last_query_id())) where "kind" = 'OUTBOUND' and "database_name" IN ('`+mp_database_name+`','`+mp_sampledatabase_name+`');`});  
    var share_drop_msg="";
    var mp_share_name ="";
   
   // drop all shares associated with listing database and sample database
    while (result.next()) {
        var mp_share_name = result.getColumnValue(1);
        snowflake.execute({ sqlText: `drop share if exists `+mp_share_name });  
        share_drop_msg +="\n Dropped Share for the listing: ".concat(mp_share_name)
    }
    
     if (basedb_override_flag)
        {
        //Find all schemas associated with listing in basedataDB
        var result = snowflake.execute({ sqlText:  `select catalog_name||'.'||schema_name from `+mp_database_name+`.information_schema.schemata where (schema_name in ('`+mp_listing_basedata_schemaname+`','`+mp_listing_util_schemaname+`')) OR (schema_name like 'SHARED_`+mp_listing_name+`%')`});  
        var container_drop_msg=""
        var mp_container_name ="";

        // drop all schemas associated with listing in basedataDB  
        while (result.next()) {
            var mp_container_name = result.getColumnValue(1);
            snowflake.execute({ sqlText: `drop schema if exists `+mp_container_name });  
            container_drop_msg +="\n Dropped Schema for the listing: ".concat(mp_container_name);
            }
        }
        else {snowflake.execute({ sqlText: `drop database if exists `+mp_database_name });  
                container_drop_msg += "\n Dropped Database for the listing: ".concat(mp_database_name);
             }
             
        //drop sample database if exists     
        snowflake.execute({ sqlText: `drop database if exists `+mp_sampledatabase_name });       

     success_msg =  "Objects Sucessfully Dropped for Sample Listing (".concat(mp_listing_name).concat(").");
     success_msg += "\n ================================================================="
     if (sampledb_exists_flag ) {
       success_msg += "\n Dropped Sample Database for the listing: ".concat(mp_sampledatabase_name )
      }
     success_msg += container_drop_msg;
     success_msg += share_drop_msg;
     return success_msg
   
    $$ ;  



create procedure if not exists  sp_mpadmin_listing_setup_revoke (LISTING_NAME varchar(240))
    returns string
    language javascript
    execute as caller
    as
    $$
     result=snowflake.execute({ sqlText:  `call MPADMIN.util.sp_mpadmin_listing_setup_revoke  ('`+LISTING_NAME+`',true);`});
       result.next();
        return result.getColumnValue(1);
   
    $$ ;  

/*========================= 
CREATE STORED PROC: END 
=========================*/ 

/*========================= 
INIT() STORED PROC: END
=========================*/ 
