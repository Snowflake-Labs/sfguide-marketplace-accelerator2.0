/*========================= 
PLISTING FULFILL (Standard / Custom): START
EXAMPLE USECASE: PAID LISTINGS
=========================*/  

--------------------------------------
-- CALL sp_mpadmin_Plisting_addobject
-- Call this SP to add objects for productized listing 
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
PLISTING FULFILL (Standard / Custom): END
EXAMPLE USECASE: PAID LISTINGS
=========================*/ 


