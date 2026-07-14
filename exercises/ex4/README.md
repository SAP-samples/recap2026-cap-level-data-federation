# Exercise 4 - Consume Data Product "Customer" from S/4

From a modelling point of view, there is no difference between consuming
data from another CAP app (like you did in the previous exercises) or consuming
a Data Product:
* you import a package that describes the API
* you define consumption views on top of the imported entities 
* you use the consumption views in the model

In this exercise, you will import the metadata for S/4 Data Product "Customer" to the xtravels app.
You will then replace local entity `Passenger` with entity `Customer` from the Data Product.

<br>![](/exercises/ex4/images/04_00_0010.png)


This session focuses on the CAP part of the integration with a BDC Data Product.
Prior to the session, we have already
* prepared a BDC tenant with the "Customer" Data Product installed
* created a HANA Remote Source in the HANA instance, which points to the share (see also [assets/HANA-setup](../../assets/HANA-setup.md))
* created a schema `DP_VT_CUSTOMER` in the HANA instance with virtual tables pointing
  to the share tables in the BDC tenant.
* prepared a user-provided service `grantor-dp-admin` in Cloud Foundry that holds credentials for accessing this schema.

You will then deploy the database model of the xtravels app to HANA with the Data Product entity `Customer`
in the CAP app to be connected to the corresponding virtual tables via a synonym.

<br>![](/exercises/ex4/images/04_00_0020.png)


> [!TIP]
> In Exercises 4.1 and 4.2 you use [SAP Business Accelerator Hub](https://api.sap.com/) to find
Data Product "Customer" and download its metadata. If you can't access SAP Business Accelerator Hub,
you can jump directly to step 3 of  [Exercise 4.2](#exercise-42---download-data-product-metadata)
and use the metadata file provided in [_assets/ex4_](../../ws/_assets/ex4).



## Exercise 4.1 - Discovery

After completing these steps, you will have found Data Product "Customer" from S/4
in [SAP Business Accelerator Hub](https://api.sap.com/).

1. Go to [SAP Business Accelerator Hub](https://api.sap.com/).

    <br>![](/exercises/ex4/images/04_01_0010.png)

2. In the top row, go to tab [Data Products](https://api.sap.com/dataproducts).

    <br>![](/exercises/ex4/images/04_01_0020.png)

3. Here you can browse the available Data Products.
Enter "Customer" in the search field and press "Return".

    <br>![](/exercises/ex4/images/04_01_0030.png)

4. Click on the tile for Data Product [Customer](https://api.sap.com/dataproduct/sap-s4com-Customer-v1/overview).

    <br>![](/exercises/ex4/images/04_01_0040.png)



## Exercise 4.2 - Download Data Product metadata

After completing these steps, you will have downloaded a CSN file with the metadata of
Data Product "Customer" to _ws/xtravels_.

1. At the bottom of the screen for Data Product "Customer", follow the link to the
[Delta Sharing API](https://api.sap.com/api/sap-s4com-Customer-v1/overview).

    <br>![](/exercises/ex4/images/04_02_0010.png)

2. On this page, you find the "ORD ID" that uniquely identifies this API.
The ID is based on the [Open Resource Discovery (ORD)](https://open-resource-discovery.github.io/specification/introduction) protocol.
The API is described as "CSN Interop JSON", which can be downloaded from here.

    <br>![](/exercises/ex4/images/04_02_0020.png)

3. Download the CSN Interop JSON.

    If you should not be able to download the CSN Interop JSON for any reason,
    you can use [_assets/ex4/sap-s4com-Customer-v1.json_](../../ws/_assets/ex4/sap-s4com-Customer-v1.json).

4. Copy the file to folder _xtravels_ in your workspace.

    <br>![](/exercises/ex4/images/04_02_0030.png)



## Exercise 4.3 - Import Data Product metadata

After completing these steps, you will have imported the Data Product's
metadata as API package into your xtravels project.

1. Go to the terminal of the xtravels app.

2. Import the Data Product metadata to the CDS model of the xtravels app
with this command:
    ```sh
    cds import --data-product sap-s4com-Customer-v1.json
    ```

    The import creates a folder _xtravels\apis\imported\sap-s4com-customer-v1_
    that structurally is almost identical to the API package of the xflights app.

    <br>![](/exercises/ex4/images/04_03_0010.png)

    > Depending on the version of the _cds toolkit_, folder _\_i18n_ and file _cds-plugin.js_ may be missing.
    This is no problem for this session.

3. Have a look at file _services.cds_ in the new folder.  
Here you find the Data Product `Customer` represented as a service,
and the data sets of the Data Product are represented as entities:
    ```cds
    @cds.external : true
    @data.product : true
    @protocol : 'none'
    service sap.s4com.Customer.v1 {
      entity Customer {
        key Customer : String(10);
        CustomerName : String(80);
        CustomerFullName : String(220);
        //...
      }
      entity CustomerCompanyCode {
        key Customer : String(10);
        key CompanyCode : String(4);
        AccountingClerk : String(2);
        ReconciliationAccount : String(10);
        //...
      }
      //...
    }
    ```

    The name of the service reflects the ORD ID of the Data Product.

4. Have a look at file _annotations.cds_ in the same folder.  
The Data Product entities come with a lot of annotations, e.g. `@title` for labels.
The corresponding localized texts are also part of the Data Products's API package in folder _\_i18n_.

5. Have a look at file _xtravels/package.json_. A new dependency has been added:

    <br>![](/exercises/ex4/images/04_03_0020.png)


6. In the xtravels terminal, run
    ```sh
    npm install
    ```



## Exercise 4.4 - Add consumption view

After completing these steps, you will have created a consumption view
for entity `Customer` of the imported API.

1. In folder _xtravels/apis_, add a new file _customers.cds_.

2. Fill the new file with this content:
    ```cds
    using { sap.s4com.Customer.v1 as Cust } from 'sap-s4com-customer-v1';

    namespace sap.capire.customer;

    @federated entity Customers as projection on Cust.Customer {
      Customer as ID,
      CustomerName as Name,
      StreetName as Street,
      PostalCode,
      CityName as City,
      TelephoneNumber1 as PhoneNumber
    }

    annotate Cust with @data.product: 'via-synonym'
                       @cds.persistence.namingMode: 'quoted';
    ```

You won't use the other entities of the Data Product in our xtravels app,
thus you don't add consumption views for them.

Note that this file does not only define a consumption view. It also
adds two annotations to the imported service. They are necessary in order for
the synonym plugin to handle this service:
* `@data.product: 'via-synonym'` 
* `@cds.persistence.namingMode: 'quoted'` tells the synonym plugin that the
  synonym targets don't use the default CAP name mapping, but have case sensitive
  database names.



## Exercise 4.5 - Use the Data Product in the model

After completing these steps, you will have replaced local entity `Passenger`
with entity `Customer` of the Data Product.

1. In file _xtravels/db/schema.cds_, below the `using` directives at the top of the file, add
    ```cds
    using { sap.capire.customer as c } from '../apis/customers';
    ```

2. In the same file, adapt entity `Travels` so that it now uses the consumption view `Customer` instead
of entity `Passengers`.  
    Change the target of association `Customer` from
    ```cds
    Customer     : Association to Passengers;
    ```
    to
    ```cds
    Customer     : Association to c.Customers;
    ```

1. In file _srv/travel-service.cds_, below the `using` directives at the top of the file, add
    ```cds
    using { sap.capire.customer as c } from '../apis/customers';
    ```

3. In the same file, add a projection for
    `Customer` below the projection for `Passenger` inside service `TravelService`:
    ```cds
      entity Customers as projection on c.Customers;
    ```

No further adaptations of the model are necessary. This of course is only possible
because the xtravels app was from the beginning designed in such a way that
entity `Passengers` can easily be replaced by the Data Product entity `Customers`.



## Exercise 4.6 - Local testing

After completing these steps, you will have run the xtravels app locally with
the Data Product entity `Customers` being mocked by a local table.

Following the CAP principle of "local development and testing", you first
test the xtravels app with the Data Product entities being mocked by local
tables in a SQLite in-memory database.

1. Add some test data: copy file
[assets/ex4/sap.s4com-Customer.v1.Customer.csv](../../ws/_assets/ex4/sap.s4com-Customer.v1.Customer.csv)
to folder _xtravels/db/data_. This provides some test data for mocking the
`Customer` entity.

    <br>![](/exercises/ex4/images/04_06_0010.png)

    Have a look into the csv file: it only contains data for the columns actually used
    in the consumption view.

2. In the xtravels terminal, run
    ```sh
    cds watch
    ```

3. Observe the console output. It indicates that a local table is created for `Customer`
and is filled with the data from the csv file.

    <br>![](/exercises/ex4/images/04_06_0020.png)

4. Open the automatically served index page in your browser at [localhost:4004](http://localhost:4004/).

5. Click the link [/travels/webapp](http://localhost:4004/travels/webapp/index.html) to start the Fiori UI.  

    <br>![](/exercises/ex4/images/04_06_0030.png)

    The app looks almost like the last time you have started it.
    <!-- in [Exercise 2.5](../ex2/README.md#exercise-25---run-the-xtravels-app-with-flights-being-mocked). -->
    This time, however, you see different data for `Customer`, namely the test data you have just added via the csv file.

6. Stop cds watch in the xtravels terminal by typing `Ctrl+C`.

## Exercise 4.7 - Deploy to HANA

After completing these steps, you will have deployed the xtravels app to HANA.
Customer information is read via synonyms from the virtual tables pointing to the
BDC shares.

1. Before we actually deploy to HANA, run this command in the xtravels terminal:
    ```sh
    cds build --for hana
    ```
    Have a look at the generated HDI files in folder _xtravels/gen/db_. There now is a bunch of files for
    the imported Customer service:
    ```txt
    gen/db
    ├── cfg/gen
    |   ├── ...
    |   └── sap.s4com.Customer.v1.hdbsynonymconfig
    └── src/gen
        ├── ...
        ├── sap.s4com.Customer.v1.Customer.hdbview
        ├── sap.s4com.Customer.v1.Customer#mock.hdbtable
        ├── ...
        ├── sap.s4com.Customer.v1.hdbgrants
        └── sap.s4com.Customer.v1.hdbsynonym
    ```

2. Replace the content of file _xtravels/.env_ with
    ```txt
    TARGET_CONTAINER=db
    SERVICE_REPLACEMENTS='[{"key":"sap.capire.flights.data_syn","service":"xflights-db"},{"key":"sap.s4com.Customer.v1","service":"grantor-dp-admin"}]'
    ```
    This adds another service replacements, where we map the logical service name `sap.s4com.Customer.v1`to
    the physical name `grantor-dp-admin`.

3. In the xtravels terminal, execute
    ```sh
    cds bind --to grantor-dp-admin
    ```
    Now the xtravels app is bound to the service.

4. In the xtravels terminal, execute
    ```sh
    cds deploy --to hana --resolve-bindings --profile hybrid
    ```
    This re-deploys the database part of xtravels to HANA, this time including all the artifacts
    for the `Customer` service.

5. Start the app in hybrid mode. In the xtravels terminal, run
    ```sh
    cds watch --profile hybrid
    ```

6. Go to the [xtravels web app](http://localhost:4004/travels/webapp/index.html).

    <br>![](/exercises/ex4/images/04_07_0010.png)

    Look at the data. You will notice that the customer data (names, address, ...) has changed, because you
    no longer see the local mock data, but the data from the Data Product in the BDC tenant.



## Summary

You've now consumed a BDC Data Product, incorporated it into the xtravels model
and used the synonym plugin to connect your local entities to the virtual tables
pointing to the BDC data.
