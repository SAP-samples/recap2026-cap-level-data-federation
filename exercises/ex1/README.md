# Exercise 1 - Create API package for xflights

In this exercise, you will create an API package for flights data in xflights.

All file or directory paths in this exercise are relative to the workspace folder _ws_
created in the [Preparation](../ex0/README.md) section.


## Exercise 1.1 - Inspect xflight's domain model

Your workspace already contains a folder xflights with a complete app.

<br>![xflights entity graph](/exercises/ex1/images/01_01_0010.png)

Look at _xflights/db/schema.cds_. Here are the basic entities for flight information:

* Airlines  
  A list of airlines that operate flights (e.g. "Sunset Wings").
* Airports  
  Airports where flights depart and arrive.
* FlightConnections  
  Defines flight connections. Each connection is operated by an airline
  and has a departure and an arrival airport (e.g. "SW0058" by Sunset Wings from San Francisco to Frankfurt departing at 01:45 P.M.).
* Flights  
  Lists the concrete flights, i.e. a connection operated at a given date (e.g. "SW0058" operated at 2023-07-31).
* Supplements  
  Things you can add to a flight, like additional luggage, food, drinks.

<br>![xflights entity graph](/exercises/ex1/images/01_01_0020.png)

Corresponding initial data can be found in the _csv_ files in folder _xflights/db/data_.



## Exercise 1.2 - Add service API

After completing these steps, you will have a new service that acts as an API to retrieve flights data from the xflights app.

1. In folder _xflights/srv_, create a file _data-service.cds_.

2. Fill the new file with this content:
    ```cds
    using sap.capire.flights as x from '../db';

    /**
    * Master data service providing flight-related data, e.g. Flights, Airlines,
    * Airports, and Supplements (e.g. extra luggage, meals, etc.).
    */
    @hcql @rest @odata @graphql
    service sap.capire.flights.data {

      // Serve Flights data via denormalized view
      @readonly entity Flights as projection on x.Flights {
        key flight.ID,
        key date,
        flight.{*} excluding {ID},  // flattened FlightConnections
        *,
      } excluding { flight, createdAt, createdBy, modifiedBy }  // don't need assoc flight any more

      // Serve Airlines, Airports, Supplements as is
      @readonly entity Airlines    as projection on x.Airlines    excluding { createdAt, createdBy, modifiedBy };
      @readonly entity Airports    as projection on x.Airports    excluding { createdAt, createdBy, modifiedBy };
      @readonly entity Supplements as projection on x.Supplements excluding { createdAt, createdBy, modifiedBy };
    }


    // Temporary workarounds
    using from './workaround';
    ```

In this service, entity `Flights` is not a simple one-to-one projection of the respective entity in the domain model.
Instead of having two separate entities for connections and flights, the connection data is directly pulled into
the `Flights` entity ("denormalization"). This is done via the flight association that is part of entity
`sap.capire.flights.Flights`.
This denormalization is applied because a consumer simply wants to see the list of flights and doesn't need to be
bothered with the fact that in xflights the data is normalized - separated into two entities ("use-case oriented service").

As this service is intended to be imported in other apps, we have chosen
a name with a namespace prefix that indicates where it comes from.

The service has some annotations that control how the data of the entities is exposed.
Among others, there is the CAP specific
[hcql protocol](https://cap.cloud.sap/docs/releases/2026/jun26#new-hcql-protocol-adapter),
which basically is the transport of CQL - an extension of SQL that adds support for path expressions - over HTTP.

<!--
TODO
You can start `cds watch` and see these services ... http://localhost:4005/  ... _.env_
OR do this later when actually triggering replication
-->


## Exercise 1.3 - Export API service

After completing these steps, you will have an API package for the new service `sap.capire.flights.data`.

1. In VS Code, open a terminal

    <br>![vs code - open terminal](/exercises/ex1/images/01_03_0010.png)

2. In the new terminal, change to the _xflights_ folder (assuming the terminal has opened in
   your workspace root folder _ws_):
    ```sh
    cd xflights
    ```

3. Export the new data service to an API package that can be consumed by other applications.
   In the xflights terminal, run
    ```sh
    cds export srv/data-service.cds --texts --data --plugin --to ../apis/data-service
    ```

    What do the options mean?
    * `--texts` adds I18n text bundles with label texts etc. to the API package
    * `--data` adds some initial data to the package. This data is extracted by starting the app
      in the background and querying the entities in the service.
    * `--plugin` turns the package into a CAP plugin to benefit from CAP's plug & play configuration features in consuming apps.

    Output:

    <br>![terminal output cds export](/exercises/ex1/images/01_03_0020.png)

    The most important part is the service definition in _apis/data-service/services.csn_.
    It is a CSN that contains only the entities exposed in service `sap.capire.flights.data`.
    Note that the CSN only describes the API: the query sections are not present in the entities.

<!--
    ```txt
    Exporting APIs to ..\apis\data-service ...

      > ..\apis\data-service\index.cds
      > ..\apis\data-service\services.csn
      > ..\apis\data-service\_i18n\i18n.properties
      > ..\apis\data-service\_i18n\i18n_de.properties
      > ..\apis\data-service\_i18n\i18n_fr.properties
      > ..\apis\data-service\cds-plugin.js
      > ..\apis\data-service\package.json
      > ..\apis\data-service\data\sap.capire.flights.data.Flights.csv
      > ..\apis\data-service\data\sap.capire.flights.data.Airlines.csv
      > ..\apis\data-service\data\sap.capire.flights.data.Airports.csv
      > ..\apis\data-service\data\sap.capire.flights.data.Supplements.csv
    ```
-->


4. Adapt the generated API package in folder _apis/data-service_:
  * In _package.json_, change the name to `@capire/xflights-data`. This name will be used later to
      reference the API in the model of the consuming app xtravels.
    ```json
    {
      "name": "@capire/xflights-data",
      "version": "0.1.1",
      "cds": { /* ... */ }
    }
    ```
  * In _index.cds_, add these annotations:
    ```cds
    // Workaround for @cds.autoexpose kicking in too eagerly ...
    annotate sap.common.Currencies with @cds.autoexpose:false;
    annotate sap.common.Countries with @cds.autoexpose:false;
    annotate sap.common.Languages with @cds.autoexpose:false;
    ```
    This workaround is needed, because the auto-exposure mechanism of the compiler doesn't yet seamlessly work together with exporting and importing APIs.
  * Slightly modify the data in the _csv_ files in _apis/data-service/data_. Later, this will allow you to distinguish
    data coming from local mock tables fed by these csv files from data coming directly from the xflights tables via replication or synonyms.
    For example, prepend the names of airlines and airports with "(test-rep)", like so:  
    _airlines.csv_
    ```csv 
      ID,modifiedAt,name,icon,currency_code
      GA,2026-07-07T14:30:11.830Z,(test-rep) Green Albatros,https://...,CAD
      FA,2026-07-07T14:30:11.830Z,(test-rep) Fly Africa,https://...,ZAR
    ...
    ```
    _airports.csv_
    ```csv
    ID,modifiedAt,name,city,country_code
    FRA,2026-07-06T10:08:58.522Z,(test-rep) Frankfurt Airport,Frankfurt/Main,DE
    HAM,2026-07-06T10:08:58.522Z,(test-rep) Hamburg Airport,Hamburg,DE
    MUC,2026-07-06T10:08:58.522Z,(test-rep) Munich Airport,Munich,DE
    ...
    ```



## Exercise 1.4 - Publish the API package

Usually you would now publish the API package to make it available for consumers,
for example in [npmjs.com](https://www.npmjs.com/) or in
[GitHub Packages](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-npm-registry).

In our example this is not necessary: due to the workspace setup in _ws/package.json_,
we can consume the API package in xtravels directly from the _apis_ folder.



## Exercise 1.5 -  Clean-up

In case you started xflights with `cds watch`, terminate it.


## Summary

You've now exposed flight data via an API service and created an API package for it.
In the next exercise you will consume this API in the xtravels app.

Continue to [Exercise 2 - Service-level replication](../ex2/README.md)
