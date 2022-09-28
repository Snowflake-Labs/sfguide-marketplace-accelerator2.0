# sfguide-marketaplace-accelerator2.0
Accelerator 2.0 is built from past provider learnings and evolved best practices. It aims to speed up launching products on marketplace and go-to-market globally within hours instead of weeks. It does so by delivering a blueprint and toolkit scripts that deploy the blueprint

## Step1: Determine data product's category
![image](https://user-images.githubusercontent.com/68336854/192832487-f4944d76-8ce1-4189-a23a-5d3ee68bbd84.png)

## Step2: Choose the blueprint specific to data product category
![image](https://user-images.githubusercontent.com/68336854/192829999-c23b5cf7-fb96-42a4-8440-a2cd44d4e61d.png)

## Step3: Deploy blueprint using toolkit scripts 
[Toolkit scripts](https://github.com/sfc-gh-amgupta/sfguide-marketaplace-accelerator2.0/tree/main/ToolkitScripts) are included in this github repository. <br /> 
> Highly recommend reviewing [toolkit process flow diagram](https://github.com/sfc-gh-amgupta/sfguide-marketaplace-accelerator2.0/blob/main/Toolkit%20Process%20Flow%20Diagram.pdf) and [toolkit topology diagram](https://github.com/Snowflake-Labs/sfguide-marketaplace-accelerator2.0/blob/main/Toolkit%20Topology%20Diagram.pdf).


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
Contains example call to stored procedure that add procured data to container (shares) delivered to a specific paying consumer of a given data product. <br /> 
**Applies only to data products of Unique category*

### [Optional] 4-Optional-SpecialCaseHandling.sql 
*Requires AccountAdmin and MPAdmin Role*  <br />
Script is leveraged when container (database) to store base data, for a given data product, is already in its own database. In such case, the existing database can also be used to setup listing. The .sql file contains example calls for such setup

### Enforced Best Practices by Toolkit
1. Materialize objects for sample listings to marginalize replication cost for lead generation. Leverage create-table-as in conjunction with sampling clause 
2. Ensure all shared objects and their dependencies are co-located under the same database. E.g. When sharing a secure view ensure all referenced tables in view definition are in same database as secure view. _Required for correct functioning of cross-cloud auto-fulfillment_
3. Ensure [external tables](https://docs.snowflake.com/en/user-guide/database-replication-intro.html#replicated-database-objects) are _not_ co-located under the same database as shared object. _Required for correct functioning of cross-cloud auto-fulfillment_
4. Set time travel on all objects. 1 day for standard edition, 7 days for higher editions.  Set at database/schema level
5. Case insensitive object identifiers. Set at database/schema level. Note: ignore case parameter does not work in retrospective
6. Separation of duties: Create role for marketplace administrator functions while leveraging accountadmin (privileged role) only as needed. 
7. Develop naming scheme for Private listings and other objects. Example: Include provider name, consumer name,  Product name in private listing name. In  XNYCORP_TO_ABCINC_INVENTORY private listing, XNYCORP is provider name, ABC_INC is consumer name and INVENTORY is product name. This helps with querying usage insights via sql or provider_studio UI

### Not Enforced Best Practices by Toolkit (But highly Recommended)
1. Use private listings for data delivery over direct shares. Private listings enable usage metrics and remote region-cloud auto fulfillment
2. Enable change tracking on shared tables and tables under shared views
3. Add comments on all objects and attributes which serves as data dictionary for consumers
4. If row access policy for tailored products is implemented on large tables (>500G), set clustering key on filtering attributes in the policy


