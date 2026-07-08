using { sap.common } from '@sap/cds/common';

//  Workaround for @cds.autoexpose kicking in too eagerly ...
annotate common.Currencies with @cds.autoexpose:false;
annotate common.Countries with @cds.autoexpose:false;
annotate common.Languages with @cds.autoexpose:false;
