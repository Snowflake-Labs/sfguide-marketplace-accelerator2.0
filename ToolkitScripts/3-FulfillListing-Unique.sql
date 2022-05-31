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

--------------------------------------
-- CALL sp_mpadmin_Plisting_addobject
-- Call this SP wtih ConsumerName Parameter for data product customized per consumer 
-- Iteratively call this SP to add multpile objects
--------------------------------------
use role mpadmin_role;
use warehouse mpadmin_wh;
call mpadmin.util.sp_mpadmin_Plisting_addobject
    (
     LISTING_NAME               =>'SHIPPING',
     CONSUMER_NAME              =>'ABC_INC', 
     VIEW_NAME                  =>'SHIPPING_MAIN_SECURE_VW',
     VIEW_SQL                   =>'select * from mplisting_SHIPPING.private_basedata.SHIPPING_main_tbl;'
    );
    
call mpadmin.util.sp_mpadmin_Plisting_addobject
    (
     LISTING_NAME               =>'SHIPPING',
     CONSUMER_NAME              =>'ABC_INC', 
     VIEW_NAME                  =>'SHIPPING_ANOTHER_SECURE_VW',
     VIEW_SQL                   =>'select * from mplisting_SHIPPING.private_basedata.SHIPPING_another_tbl;'
    );
    


/* -- DELETES views added by sp_mpadmin_Plisting_addobject_revoke
-- -- VIEW_SQL parameter is not mandatory, And can be passed as empty string.
call mpadmin.util.sp_mpadmin_Plisting_addobject_revoke
    (
     LISTING_NAME               =>'SHIPPING',
     CONSUMER_NAME              =>'ABC_INC', 
     VIEW_NAME                  =>'SHIPPING_MAIN_SECURE_VW',
     VIEW_SQL                   =>'select * from mplisting_SHIPPING.private_basedata.SHIPPING_main_tbl;'
    );
-- */  

/* -- DROP the consumer and all consumer specific objects from the listing. 
call mpadmin.util.sp_mpadmin_Plisting_dropconsumer
    (
     LISTING_NAME               =>'SHIPPING',
     CONSUMER_NAME              =>'ABC_INC'
    );
-- */

/*========================= 
PLISTING FULFILL (UNIQUE): END
=========================*/  
