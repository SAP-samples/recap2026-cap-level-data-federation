# Exercise 3 - Synonym-based federation

In this exercise, you will change the federation method in xtravels
from servicel-level replication to federation via HANA synonyms
with the help of the new synonym plugin __TODO LINK__.

All file or directory paths in this exercise are relative to the workspace folder _ws_
created in the [Preparation](../ex0/README.md) section.


## Exercise 3.1 - Log on to Cloud Foundry

After completing these steps, you will have logged on to Cloud Foundry via
the Cloud Foundry CLI. This is necessary to deploy the database part of xflights and xtravels
to HANA via the CDS CLI in subsequent steps.

We have prepared a subaccount in BTP that has access to a HANA instance.
In the subaccount, there already are users for this exercise.
Your username is `capworkshopuser+0XX@gmail.com`, where `XX` is the number
assigned to you for the session.

1. Go to the xtravels terminal and execute
    ```sh
    cf login -a https://api.cf.eu10-005.hana.ondemand.com --origin aoykcp1ee-platform
    ```

2. At the prompt, enter user and password. Replace XX with your number and
use the password provided to you.
    ```
    Email: capworkshopuser+0XX@gmail.com
    Password: ...
    ```



## Exercise 3.2 - Add API service to xflights

After completing these steps, you will have defined a new API service in the
xflights app, which uses HANA synonyms as federation method.
The steps are essentially the same as in [Exercise 1](../ex1/README.md).


1. Copy file _xflights/srv/data-service.cds_ to _xflights/srv/data-service-syn.cds_.

2. In the new file _xflights/srv/data-service-syn.cds_, make the following adjustments :
    * Rename the service to `sap.capire.flights.data_syn`.
    * Remove annotations `@hcql @rest @odata @graphql` that have been added for service level data federation.
    * Add annotation `@data.product: 'via-synonym'` to enable data federation via synonyms:
    ```cds
    @data.product: 'via-synonym'
    service sap.capire.flights.data_syn {
      // ...
    }
    ```

3. Use `cds export` to generate the API for the service definition.
We don't publish this API, but share it with the consumer via the _apis_ folder in the workspace.
In the xflights terminal, execute
    ```sh
    cds export srv/data-service-syn.cds --texts --data --plugin --to ../apis/data-service-syn
    ```

4. Adapt the generated API package in folder _apis/data-service-syn_:
* In _package.json_, change the name to `@capire/xflights-data-syn`.
* In _index.cds_, add
    ```cds
    // Workaround for @cds.autoexpose kicking in too eagerly ...
    annotate sap.common.Currencies with @cds.autoexpose:false;
    annotate sap.common.Countries with @cds.autoexpose:false;
    annotate sap.common.Languages with @cds.autoexpose:false;
    ```
* (optional) Slightly modify the data in the _data/...csv_ files. Later, this will allow
  you to see whether you view data coming from local mock tables fed by these _csv_ files,
  or data coming from the xflights tables. For example, prepend the names of Airlines with
  "(test)", like so:
    ```csv
    ID,modifiedAt,name,icon,currency_code
    GA,2026-04-20T14:39:39.329Z,(test) Green Albatros,https://..,CAD
    FA,2026-04-20T14:39:39.329Z,(test) Fly Africa,https://..,ZAR
    ...
    ```

The only difference between this API service and the one created for replication in [Exercise 1](../ex1/README.md)
is the annotations at the service (and the names, of course).



## Exercise 3.3. - Deploy xflights to HANA

After completing these steps, you will have deployed the database model of the xflights app to HANA.

1. Install the synonym plugin. In the xflights terminal, execute
    ```sh
    npm install git+https://github.tools.sap/cap/cds-df-synonyms.git
    ```

2. In the xflights terminal, execute
    ```sh
    cds add hana
    ```

3. Add to file _xflights/db/undeploy.json_:
    ```
    "src/gen/**/*.hdbrole"
    ```

4. Before we actually deploy to HANA, run
    ```sh
    cds build --for hana
    ```
    and have a look at the generated HDI files in folder _xflights/gen/db/src/gen_.
    The synonym plugin has added the role definition files _sap.capire.flights.data_syn.hdbrole_
    and _sap.capire.flights.data_syn#.hdbrole_ that provide `SELECT` access to the HANA views
    corresponding to the entities in the API service.

5. Deploy xflights to HANA:
    ```sh
    cds deploy --to hana
    ```



## Exercise 3.4 - Use the new API package in xtravels

After completing these steps, you have changed the model in xtravels to use the
new API package.

We just have to import the new API package and let the consumption views point to
the entities of the new API package. The rest of the model can stay as is.

1. In the xtravels terminal, execute
    ```sh
    npm add ../apis/data-service-syn
    ```

2. In file _xtravels/apis/xflights.cds_, use the new API for the flight information. Change
    ```cds
    using { sap.capire.flights.data as external } from '@capire/xflights-data';
    ```
    to
    ```cds
    using { sap.capire.flights.data_syn as external } from '@capire/xflights-data-syn';
    ```


2. In the xtravels terminal, start the app to test it locally:
    ```sh
    cds watch
    ```

3. Open the automatically served index page in your browser at [localhost:4004](http://localhost:4004/)
   and click .... 
   The imported service is mocked and we again see flights data from _csv_ files, this time from the new API package.


__TODO__ may prefix test datsa with "test-rep" and "tes-syn" ?



## Exercise 3.5 - Prepare xtravels for HANA deployment

After completing these steps, the xtravels app is ready to be deployed to HANA.

1. Install the synonym plugin. In the xtravels terminal, execute
    ```sh
    npm install git+https://github.tools.sap/cap/cds-df-synonyms.git
    ```

2. In the xtravels terminal, execute
    ```sh
    cds add hana
    ```

3. Add to file _xtravels/db/undeploy.json_:
    ```
    "src/gen/**/*.hdbsynonym",
    "cfg/gen/**/*.hdbsynonymconfig"
    ```

4. Before we actually deploy, run
    ```sh
    cds build --for hana
    ```
    and have a look at the generated HDI files in folder _xtravels/gen/db_:
    ```
    gen/db
    ├── src/gen
    |   ├── sap.capire.flights.data_syn.Airlines_#proxy.hdbtable
    |   ├── sap.capire.flights.data_syn.Airports_#proxy.hdbtable
    |   ├── sap.capire.flights.data_syn.Flights_#proxy.hdbtable
    |   ├── sap.capire.flights.data_syn.Supplements_#proxy.hdbtable
    |   ├── sap.capire.flights.data_syn.SupplementTypes_#proxy.hdbtable
    |   ├── sap.capire.flights.data_syn.hdbgrants
    |   └── sap.capire.flights.data_syn.hdbsynonym
    └── cfg/gen
        └── sap.capire.flights.data_syn.hdbsynonymconfig
    ```

For each entity in the imported service we find a mock table and a synonym definition
(all synonyms are all defined in one file). These synonym definitions point to
the local mock tables. 
In addition, there is a _.hdbsynonymconfig_ file that overrides the basic synonym definitions
and redirects the synonyms to the "exported" views in xflights.
Finally, we have a _.hdbgrants_ file that grants the HDI user of xtravels
access to these xflights views.

By deploying with or without the _.hdbsynonymconfig_ file, we can switch
the synonyms and control whether they point to the local mock tables
or to the views in xflights.



## Exercise 3.6 - Deploy xtravels to HANA without .hdbsynonymconfig

After completing these steps, you will have deployed the xtravels app to HANA.
Flight information is read via synonyms from the local mock tables.

We first make a deployment without the _.hdbsynonymconfig_ file so that the local mock files
are used. Then we redeploy with the _.hdbsynonymconfig_ and thus redirect the synonyms to the
xflights HDI container.

1. In folder _xtravels/db_, add a new file _.hdiignore_ with the following content:
    ```txt
    **/sap.capire.flights.data_syn.hdbgrants
    **/sap.capire.flights.data_syn.hdbsynonymconfig
    ```

2. In the xtravels terminal, execute
    ```sh
    cds deploy --to hana
    ```

3. Run xtravels in hybrid mode:
    ```sh
    cds watch --profile hybrid
    ```

4. See output ...


5. Stop `cds watch` in the xtravels terminal by typing `Ctrl+C`.



## Exercise 3.7 - Deploy xtravels to HANA with .hdbsynonymconfig

After completing these steps, you will have re-deployed the xtravels app to HANA.
Flight information is now read via synonyms directly from the xflights database.

The generated files _.hdbsynonymconfig_ and _.hdbgrants_ use `sap.capire.flights.data_syn` as a logical
service name. Upon deployment, this logical service name needs to be resolved to a physical service
that provides the actual name of the target schema for the synonym as well as credentials to
access the xflights schema. We use the HDI container service that resulted from the xflights deployment
in the previous section for this.

1. Remove file _db/.hdiignore_.

2. Bind to the HDI container service for xflights. In the xtravels terminal, run
    ```sh
    cds bind xflights-db -2 xflights-db
    ```

3. In folder _xtravels_, add a new file _.env_ with the following content:
    ```sh
    TARGET_CONTAINER=db
    SERVICE_REPLACEMENTS='[{"key":"sap.capire.flights.data_syn","service":"xflights-db"}]'
    ```
    The first line tells the HDI deployer which is the target container for the deployment
    (this is necessary as we have bound two HDI containers).
    The second line tells the HDI deployer to replace the logical service name
    `sap.capire.flights.data_syn` with the real service name `xflights-db`.

4. Deploy again, using the bindings we have provided. In the xtravels terminal, execute
    ```sh
    cds deploy --to hana --resolve-bindings --profile hybrid
    ```

5. Run xtravels in hybrid mode:
    ```sh
    cds watch --profile hybrid
    ```

6. See output ...


7. Stop `cds watch` in the xtravels terminal by typing `Ctrl+C`.


## Exercise 3.8 - Cleanup

__TODO__ needed ?


## Summary

You've now consumed flight data from CAP app xflights via HANA synonyms.
In the next exercise we will apply the principles of CAP Data Federation to consume a BDC Data Product.

Continue to [Exercise 4 - Consume Data Product "Customer" from S/4](../ex4/README.md)
