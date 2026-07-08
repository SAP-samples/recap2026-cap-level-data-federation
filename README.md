# CAP-level data federation

<!--- Once repo is publicly visible, register repository https://api.reuse.software/register -->

[![REUSE status](https://api.reuse.software/badge/github.com/SAP-samples/recap2026-cap-level-data-federation)](https://api.reuse.software/info/github.com/SAP-samples/recap2026-cap-level-data-federation)

Created for a [re>≡CAP 2026](https://recap-conf.dev/) hands-on workshop.



## Prerequisites

To follow the exercises, you need the following things to be installed on your computer:

* [Node.js and cds-dk](https://cap.cloud.sap/docs/get-started/#node-js-and-cds-dk)
* [git](https://cap.cloud.sap/docs/get-started/#git-and-github) (gh and github not needed)
* [Cloud Foundry CLI `cf`](https://help.sap.com/docs/btp/sap-business-technology-platform/download-and-install-cloud-foundry-command-line-interface)
* (recommended) [Visual Studio Code](https://cap.cloud.sap/docs/get-started/#visual-studio-code)



## Names

In this document, we use the following abbreviations:
* CAP for [SAP Cloud Application Programming Model](https://cap.cloud.sap/docs/)
* HANA for [SAP HANA Cloud, SAP HANA Database](https://www.sap.com/products/data-cloud/hana.html)
* BTP for [SAP Business Technology Platform](https://www.sap.com/products/technology-platform.html)
* BDC for [SAP Business Data Cloud](https://www.sap.com/products/data-cloud.html)



## Overview

In this session, you use [CAP-Level Service Integration](https://cap.cloud.sap/docs/guides/integration/calesi)
and [CAP-level Data Federation](https://cap.cloud.sap/docs/guides/integration/data-federation)
to make flights masterdata of CAP application _xflights_ ("provider app") available to another
CAP application _xtravels_ ("consumer app").
The apps are simplified versions of the public CAP sample applications
[xflights](https://github.com/capire/xflights) and [xtravels](https://github.com/capire/xtravels).

In the provider, you define API services to expose the data and export them as API packages.
In the consumer, you import the API packages, build consumption views on top and use them
in the CDS model as if they were local entities.
You federate data both via service-level replication and via HANA synonyms.
Finally, you also import the API of a BDC Data Product to xtravels and use the synonym approach
to access the its data.



## Exercises

- [Preparation](exercises/ex0/)
- [Exercise 1 - Create API package for xflights](exercises/ex1/)
- [Exercise 2 - Service-level replication](exercises/ex2/)
- [Exercise 3 - Synonym-based federation](exercises/ex3)
- [Exercise 4 - Consume Data Product "Customer" from S/4](exercises/ex4/)



## How to obtain support

Support for the content in this repository is available during the actual time of the workshop event for which this content has been designed.



## License
Copyright 2026 SAP SE or an SAP affiliate company and recap2026-cap-level-data-federation contributors. Please see our [LICENSE](LICENSE) for copyright and license information. Detailed information including third-party components and their licensing/copyright information is available [via the REUSE tool](https://api.reuse.software/info/github.com/SAP-samples/recap2026-cap-level-data-federation).
