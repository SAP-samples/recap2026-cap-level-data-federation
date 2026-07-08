# Exercise 2 - Service-level replication

In this exercise, you will consume the new API package in a second CAP application xtravels.
It is a travel agency app, where you can book travels and flights.
xtravels will consume the flights master data provided by the xflights app via service-level replication.

The xtravels app is almost complete, the only thing that is missing is the master data entities
`Flights` and `Supplements`, which you will get by importing the API package
provided in the previous exercise.

All file or directory paths in this exercise are relative to the workspace folder _ws_
created in the [Preparation](../ex0/README.md) section.



## Exercise 2.1 - Inspect xtravels

Your workspace already contains a folder _xtravels_ with an
almost complete xtravels app, including a Fiori UI in _xtravels/app/travels_.

<br>![xtravels folder structure](/exercises/ex2/images/02_01_0010.png)

Note that the model is "broken". In _xtravels/db/schema.cds_ there are some incomplete association definitions.
The editor may show some error indicators, e.g. red underlines in this file. Don't worry about them, they
will disappear when we add the missing parts.

1. Have a look at the main entities of xtravels in file _xtravels/db/schema.cds_:
    * Travels:  
      A list of travels. Each travel is assigned to a customer and has some flight bookings.
    * Passengers:  
      The list of customers.
    * Bookings:  
      A list of flight bookings. This entity has incomplete association definitions `Flight` and `booked`,
      where the association target is missing. We will fix this once we have imported the API package.

    <br>![entity diagram](/exercises/ex2/images/02_01_0020.png)

2. In VS Code, split the terminal:

    <br>![vs code, splitting terminals](/exercises/ex2/images/02_01_0030.png)

3. In the new terminal, change to the _xtravels_ folder (assuming the terminal has opened in
   your workspace root folder _ws_):
    ```sh
    cd xtravels
    ```

    Your VS Code window should now look like this:

    <br>![vs code, two terminals](/exercises/ex2/images/02_01_0040.png)



## Exercise 2.2 - Import API package

After completing these steps, you will have imported the API package with the flight data
that you have exported from the xflights app in the previous exercise.

1. In the _xtravels_ terminal, execute
    ```sh
    npm add ../apis/data-service
    ```

2. Look into _xtravels/package.json_. A new dependency has been added:

    <br>![package.json](/exercises/ex2/images/02_02_0010.png)
    
    Due to the workspace definition in _package.json_ (the one in the _ws_ folder),
    the exported API package in _apis_ is used to satisfy this new dependency.
    In _node\_modules_, you can find a symbolic link for _@capire/xflights-data_ pointing
    to _apis/data-service_.



## Exercise 2.3 - Consumption views

After completing these steps, you will have defined _consumption views_ on
top of the imported entities.

Consumption views allow you to
* capture which entities and elements you actually want to use (the imported API may be "wider" than you need it)
* map names to match your domain (the imported API may use a different terminology)
* flatten data from associations directly into the consumption view ("denormalization")
* add the `@federated` annotation to express the intent to have the data federated, i.e. in close access locally.
  This is essential for the service-level replication that we will switch on below.

> [!TIP]
> Always define consumption views on top of imported entities.
In the rest of your application (model and custom code), never directly reference the imported entities,
but always use the consumption views as "single point of access".

1. In folder _xtravels/apis_, create a new file _xflights.cds_.

2. Fill the new file with this content:
    ```cds
    using { sap.capire.flights.data as external } from '@capire/xflights-data';
    namespace sap.capire.xflights;

    /**
     * Consumption view declaring the subset of fields we actually want to use
    * from the external Flights entity, with associations like airline, origin,
    * destination flattened (aka denormalized).
    */
    @federated entity Flights as projection on external.Flights {
      ID, date, departure, arrival, free_seats, modifiedAt,
      price, currency,
      airline.icon     as icon @UI.IsImageURL,    // TODO move anno to xflights
      airline.name     as airline,
      origin.name      as origin,
      destination.name as destination,
    }

    /**
     * Consumption view declaring the subset of fields we actually want to use
    * from the external Supplements entity.
    */
    @federated entity Supplements as projection on external.Supplements {
      ID, type, descr, price, currency, modifiedAt
    }
    ```



__OLD__
This is a so called "consumption" view that acts as single point of
access to the Data Product entity. All references to the Data Product
in your app's model and custom code should address this entity.

In the consumption view, you select only those elements of the Data Product entity
that you actually want to use in your application.
In addition, the fields of the imported Data Product entity `Customer` are renamed so
that they match those of entity `Passengers`, which you are going to replace.




## Exercise 2.4 - Use consumption views

After completing these steps, you will have a complete xtravels model, using the
imported entities via the consumption views as if they were local.

We use the imported entities as association targets in _xtravels/db/schema.cds_.
In addition, we expose filght information directly in the travel service.

1. In file _xtravels/db/schema.cds_, below the `using` directive at the top of the file, add
    ```cds
    using { sap.capire.xflights as x } from '../apis/xflights';
    ```
2. In the same file, adapt entity `Bookings` by filling in the missing association targets:
    ```cds
    entity Bookings {
      // ...
          Flight      : Association to x.Flights;  // <--
          // ...
          Supplements : Composition of many {
            // ...
            booked   : Association to x.Supplements;  // <--
            // ...
          };
          // ...
    }
    ```

3. In file _xtravels/srv/travels-service.cds_, below the `using` directive at the top of the file, add
    ```cds
    using { sap.capire.xflights as x } from '../apis/xflights';
    ```

4. In the same file, inside service `TravelService`, add projections
   for `Flights` and `Supplements` below the projection for `Passengers`:
    ```cds
      entity Flights as projection on x.Flights;
      entity Supplements as projection on x.Supplements;
    ```
    Note that `Flights` and `Supplements` are automatically read-only due to
    the inherited annotations from the API service definition in xflights.


__TODO__ use "diff?

__TODO__ we don't need this - add anyway?
// Extend Flights to navigate to back to local Bookings
extend x.Flights with columns {
  Bookings : Association to many Bookings on Bookings.Flight = $self
}

__TODO__ annotations in travels app?



## Exercise 2.5 - Run the xtravels app with flights being mocked

After completing these steps, you will have xtravels running with the entities
from the API package being mocked by local entities.

The imported service is mocked out of the box, which allows to 
test xtravels locally without any connection to xflights.

1. In the terminal for _xflights_, ensure the CAP server (for the `cds watch` process) is stopped, [as mentioned at the end of the previous exercise](../ex1/README.md#exercise-19---cleanup).

2. In the terminal for _xtravels_, start the xtravels app.
    ```sh
    cds watch
    ```

3. If `cds watch` works without errors, ignore this step.  
    If you see errors like
    ```
    [persistent-queue] - DataFederationService: Emit failed: Error: Error during request to remote service: Error
    ```
    then
    * ensure to stop all instances of `cds watch`
    * go to your home directory
    * delete file `.cds-services.json`
    * restart `cds watch` in the xtravels terminal


4. Observe the output of `cds watch`.  
The entities in this service are represented as tables in the SQLite in-memory database
and are filled with _csv_ data from the imported package:

    <br>![cds watch output](/exercises/ex2/images/02_05_0010.png)

<!--
    ```log
    [cds] - connect to db > sqlite { url: ':memory:' }
    (node:34040) ExperimentalWarning: SQLite is an experimental feature and might change at any time
    (Use `node --trace-warnings ...` to show where the warning was created)
      > init from ..\apis\data-service\data\sap.capire.flights.data.Supplements.csv 
      > init from ..\apis\data-service\data\sap.capire.flights.data.Flights.csv 
      > init from ..\apis\data-service\data\sap.capire.flights.data.Airports.csv 
      > init from ..\apis\data-service\data\sap.capire.flights.data.Airlines.csv 
    ```
-->

5. Open the automatically served index page in your browser at [localhost:4004](http://localhost:4004/).

6. Click the link [/travels/webapp](http://localhost:4004/travels/webapp/index.html) to start the Fiori UI.
You should see a full fledged xtravels app.

    <br>![xtravels ui](/exercises/ex2/images/02_05_0020.png)

7. Click on any travel to open the details page with the flight bookings.
In the fields with the flight information (e.g. "Airline") you see the local test data from
the imported API package (prefix "test-rep"). These fields automatically got nice labels,
which also came from the API package via the `@title` annotations and the respective texts.

    <br>![xtravels ui](/exercises/ex2/images/02_05_0030.png)



## Exercise 2.6 - Service-level replication

After completing these steps, you will have both apps xflights and xtravels running,
with xtravels being connected to the xflights app as data source for flight data.

We have implemented a generic solution for data federation. The code can be found in _xtravels/srv/data-federation.js_.
Let's have a closer look at this code, which handles these main tasks:

* Prepare Persistence – When the model is loaded, before it's deployed to the database, we collect all
  to be `@federated` entities, check whether their respective services are remote, and if so, turn them
  into tables for local replicas (line 11).
* Setup Replication – Later when all services are served, we connect to each remote one (line 20),
  register a handler for replication (line 21), and schedule it to be invoked repeatedly (line 22).
* Replicate Data – Finally, the replicate handler implements a simple polling-based data federation strategy,
  based on `modifiedAt` timestamps (lines 28-32), with the actual call to remote happening on line 29.


1. Stop `cds watch` in the xtravels terminal by typing `Ctrl+C`.

2. Start `cds watch` in the xflights terminal:
    ```sh
    cds watch
    ```

3. Restart `cds watch` in the xtravels terminal:
    ```sh
    cds watch
    ```

4. Observe the output of `cds watch` in the xtravels terminal.  
This time the xtravels app recognizes that there is another app (xflights) that
exposes service `sap.capire.flights.data` and connects to that service
rather than mocking it (note that no csv data is loaded for the entites
of this service).

    <br>![cds watch output](/exercises/ex2/images/02_06_0010.png)

    The data for `Flights` and `Supplements` is replicated:

    <br>![cds watch output](/exercises/ex2/images/02_06_0020.png)

5. Observe the output of `cds watch` in the xflights terminal.  
Here you can see the incoming calls (from xtravels) to `GET` the
data from entities `Flights` and `Supplements`.

    <br>![](/exercises/ex2/images/02_06_0030.png)

<!--
    ```log
    [hcql] - POST /hcql/data/ {
      SELECT: {
        from: { ref: [ 'sap.capire.flights.data.Flights' ] },
        columns: [
          { ref: [ 'ID' ], as: 'ID' },
          { ref: [ 'date' ], as: 'date' },
          { ref: [ 'departure' ], as: 'departure' },
          { ref: [ 'arrival' ], as: 'arrival' },
          { ref: [ 'free_seats' ], as: 'free_seats' },
          { ref: [ 'modifiedAt' ], as: 'modifiedAt' },
          { ref: [ 'price' ], as: 'price' },
          { ref: [ 'currency_code' ], as: 'currency_code' },
          { ref: [ 'airline', 'icon' ], as: 'icon' },
          { ref: [ 'airline', 'name' ], as: 'airline' },
          { ref: [ 'origin', 'name' ], as: 'origin' },
          { ref: [ 'destination', 'name' ], as: 'destination' }
        ],
        where: [ { ref: [ 'modifiedAt' ] }, '>', { val: 0 } ]
      }
    }
    [hcql] - POST /hcql/data/ {
      SELECT: {
        from: { ref: [ 'sap.capire.flights.data.Supplements' ] },
        columns: [
          { ref: [ 'ID' ], as: 'ID' },
          { ref: [ 'type_code' ], as: 'type_code' },
          { ref: [ 'descr' ], as: 'descr' },
          { ref: [ 'price' ], as: 'price' },
          { ref: [ 'currency_code' ], as: 'currency_code' },
          { ref: [ 'modifiedAt' ], as: 'modifiedAt' }
        ],
        where: [ { ref: [ 'modifiedAt' ] }, '>', { val: 0 } ]
      }
    }
    ```
-->

6. Go to the index page [localhost:4004](http://localhost:4004/) of the xtravels app,
start the [xtravels web app](http://localhost:4004/travels/webapp/index.html),
and click a travel to get to the details page.
You now see the data directly coming from xflights: there is no "(test-rep)" prefix any more.

    <br>![](/exercises/ex2/images/02_06_0040.png)


## Exercise 2.7 - Cleanup

1. Stop `cds watch` in the xtravels terminal by typing `Ctrl+C`.

2. Stop `cds watch` in the xflights terminal by typing `Ctrl+C`.



## Summary

You've now consumed flight data from the xflights app via service-level replication.
In the next exercise we will access the flights data via HANA synonyms

Continue to [Exercise 3 - Synonym-based federation](../ex3/README.md)
