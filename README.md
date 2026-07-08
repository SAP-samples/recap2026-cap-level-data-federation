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

In this session 
Data Federation
basic pricciple CALESI
provider: define service which is the API, export API package
consumer: import the API package, build consumption view, use in moel as if own entity
technically 2 modes: service-level replication and synonyms
finally consume BDC data product, works along the same lines

### Further reading

* [CAP-Level Service Integration](https://cap.cloud.sap/docs/guides/integration/calesi)
* [CAP-level Data Federation](https://cap.cloud.sap/docs/guides/integration/data-federation)



## Exercises

- [Preparation](exercises/ex0/)
- [Exercise 1 - Create API package for flight data...](exercises/ex1/)
    - [Exercise 1.1 - ...](exercises/ex1/README.md#exercise-11---create-xflights-project)
    - ...
- Exercise 2 - Service-level replication
- Exercise 3 - Synonyms
- Exercise 4 - Consume Data Product



## How to obtain support

Support for the content in this repository is available during the actual time of the workshop event for which this content has been designed.



## License
Copyright 2026 SAP SE or an SAP affiliate company and recap2026-cap-level-data-federation contributors. Please see our [LICENSE](LICENSE) for copyright and license information. Detailed information including third-party components and their licensing/copyright information is available [via the REUSE tool](https://api.reuse.software/info/github.com/SAP-samples/recap2026-cap-level-data-federation).
