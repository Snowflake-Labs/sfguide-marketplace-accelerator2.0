/*************************************************************************************************************
Script:             Marketplace Accelerator 2.0 Unique Products Listing Fulfillment
Create Date:        2022-04-21
Author:             A. Gupta
Description:        Script contains example call to stored procedure that add procured data to container (shares) 
                    delivered to a specific paying consumer of a given data product
                    Requires MPAdmin Role (This role is created by 1-PrepareAccount.sql)
                    NOTE: Applies only to data products of Unique category
*************************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author                              Comments
------------------- -------------------                 --------------------------------------------
2022-04-21          A. Gupta              		        Initial Publish
*************************************************************************************************************/
/*========================= 
PLISTING FULFILL (UNIQUE): START
=========================*/  

=======================================================================
STEP1 DELIVERY - Once procurement is complete, prepare commercial objects (consumer facing) for unique product 
       curated for a given consumer
=======================================================================
--------------------------------------
-- CALL sp_mpadmin_Plisting_addobject
-- Call this SP wtih ConsumerName Parameter for data product customized per consumer 
-- Iteratively call this SP to add multpile objects
-- NOTE: Ensure objects name in view_sql are fully qualified
--------------------------------------
use role mpadmin_role;
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_Plisting_addobject
    (
     LISTING_NAME               =>'INVENTORY',
     CONSUMER_NAME              =>'ABC_INC', 
     VIEW_NAME                  =>'INVENTORY_MAIN_CURATED',
     VIEW_SQL                   =>'select b.station_name as start_station_name, c.station_name as end_station_name, tripduration, starttime, stoptime 
                                    from mplisting_INVENTORY.private_basedata.INVENTORY_main_tbl a 
                                    join mplisting_INVENTORY.private_basedata.INVENTORY_another_tbl b
                                    on a.start_station_id = b.station_id 
                                    join mplisting_INVENTORY.private_basedata.INVENTORY_another_tbl c
                                    on a.end_station_id = c.station_id;'
    );
    
call mpadmin.util.sp_mpadmin_Plisting_addobject
    (
     LISTING_NAME               =>'INVENTORY',
     CONSUMER_NAME              =>'ABC_INC', 
     VIEW_NAME                  =>'INVENTORY_ANOTHER',
     VIEW_SQL                   =>'select * from mplisting_INVENTORY.private_basedata.INVENTORY_another_tbl;'
    );
    
DESCRIBE SHARE PSHARE_XNY_CORP_TO_ABC_INC_INVENTORY ;

/* -- DELETES views added by sp_mpadmin_Plisting_addobject_revoke
-- -- VIEW_SQL parameter is not mandatory, And can be passed as empty string.
call mpadmin.util.sp_mpadmin_Plisting_addobject_revoke
    (
     LISTING_NAME               =>'INVENTORY',
     CONSUMER_NAME              =>'ABC_INC', 
     VIEW_NAME                  =>'INVENTORY_MAIN',
     VIEW_SQL                   =>'select * from mplisting_INVENTORY.private_basedata.INVENTORY_main_tbl;'
    );
-- */  

/* -- DROP the consumer and all consumer specific objects from the listing. 
call mpadmin.util.sp_mpadmin_Plisting_dropconsumer
    (
     LISTING_NAME               =>'INVENTORY',
     CONSUMER_NAME              =>'ABC_INC'
    );
-- */

=======================================================================
STEP2 DELIVERY - Create a "PRIVATE" listing for commercial objects
Note: this listing is not visible to any consumer until the consumer account url is explicitly added per STEP3
=======================================================================
Create a private listing via UI and attach share created in step STEP1 For example, PSHARE_XNY_CORP_TO_ABC_INC_INVENTORY  share is attached to private listing
Follow steps in documentation here: https://other-docs.snowflake.com/en/listings/listings-creating-and-publishing.html#creating-a-listing

=======================================================================
STEP3 DELIVERY - Add consumer account to private listing
=======================================================================
Add a consumer account name (url) to private listing



/*========================= 
PLISTING FULFILL (UNIQUE): END
=========================*/  