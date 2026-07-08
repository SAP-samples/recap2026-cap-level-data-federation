using { sap.capire.travels as our, sap } from '../db/schema';



@fiori service TravelService {

  entity Travels as projection on our.Travels actions {
    action deductDiscount( percent: Percentage not null ) returns Travels;
    action acceptTravel();
    action rejectTravel();
    action reopenTravel();
  }

  // Also expose related entities as read-only projections
  @readonly entity TravelAgencies as projection on our.TravelAgencies;
  @readonly entity Currencies as projection on sap.common.Currencies;
  @readonly entity Passengers as projection on our.Passengers;




}

// Custom type for percentage values
type Percentage : Integer @assert.range: [1,100];
