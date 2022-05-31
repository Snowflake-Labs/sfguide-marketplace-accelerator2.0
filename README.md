# sfguide-marketaplace-accelerator2.0
Accelerator 2.0 aims to speed up launching products on marketplace and go-to-market globally within hours instead of weeks. It does so by delivering a blueprint and toolkit scripts that deploy the blueprint

## Step1: Determine data product's category
![image](https://user-images.githubusercontent.com/68336854/171227875-c6ee5e7b-8ea4-46e5-8134-48eaf918ef40.png)

## Step2: Choose the blueprint specific to data product category
![image](https://user-images.githubusercontent.com/68336854/171283446-c2355caf-b9d9-4884-9ad7-ff6ac08aa44a.png)

## Step3: Deploy blueprint using toolkit scripts 
[Toolkit scripts](https://github.com/sfc-gh-amgupta/sfguide-marketaplace-accelerator2.0/tree/main/ToolkitScripts) are included in this github repository. Also see, included [toolkit process flow diagram](https://github.com/sfc-gh-amgupta/sfguide-marketaplace-accelerator2.0/blob/main/Toolkit%20Process%20Flow%20Diagram.pdf) for reference.


### 0-init.sql 
*Requires AccountAdmin Role*  <br />
Installs toolkit. Execute this file as is.

### 1-PrepareAccount.sql 
*Requires AccountAdmin Role*  <br />
Contains an example call to stored procedures that prepares your snowflake account. 

### 2-SetupListing.sql 
*Requires MPAdmin Role*  <br />
Contains example call to stored procedures that create containers to store base data and enable adding sample data; for a given data product (listing)

### 2a-SetupListingContd-Standard-Custom.sql 
*Requires MPAdmin Role*  <br />
Contains example call to stored procedure that add procured data to container (shares) delivered to paying consumers of a given data product.  <br /> 
**Applies only to data products of Standard and Custom category*

### 3-FulfillListing-Unique.sql 
*Requires MPAdmin Role*  <br />
contains example call to stored procedure that add procured data to container (shares) delivered to a specific paying consumer of a given data product. <br /> 
**Applies only to data products of Unique category*

### [Optional] 4-Optional-SpecialCaseHandling.sql 
*Requires AccountAdmin and MPAdmin Role*  <br />
Script is leveraged when container (database) to store base data, for a given data product, is already in its own database. In such case, the existing database can also be used to setup listing. The .sql file contains example calls for such setup




