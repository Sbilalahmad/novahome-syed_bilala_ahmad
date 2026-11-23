public with sharing class GetShipmentInfo {
    public class Request {
        @InvocableVariable(required=true description='Shipment tracking number')
        public String trackingNumber;
    }

    public class Result {
        @InvocableVariable public Boolean found;
        @InvocableVariable public String message;
        @InvocableVariable public String shipmentNumber;
        @InvocableVariable public String shipmentStatus;
        @InvocableVariable public String carrier;
        @InvocableVariable public String shipmentDate;
        @InvocableVariable public String expectedDelivery;
        @InvocableVariable public String actualDelivery;
        @InvocableVariable public String notes;
    }

    @InvocableMethod(label='Get Shipment Info' description='Returns the shipment status for a tracking number')
    public static List<Result> getShipments(List<Request> requests) {
        Set<String> trackingNumbers = new Set<String>();
        for (Request request : requests) {
            if (String.isNotBlank(request.trackingNumber)) {
                trackingNumbers.add(request.trackingNumber.trim());
            }
        }

        Map<String, Shipment__c> shipmentByTracking = new Map<String, Shipment__c>();
        for (Shipment__c shipment : [
            SELECT Name, Tracking_Number__c, Shipment_Status__c, Carrier__c, Shipment_Date__c,
                   Expected_Delivery_Date__c, Actual_Delivery_Date__c, Delivery_Notes__c
            FROM Shipment__c
            WHERE Tracking_Number__c IN :trackingNumbers
        ]) {
            String key = shipment.Tracking_Number__c == null ? null : shipment.Tracking_Number__c.trim().toLowerCase();
            if (key != null) {
                shipmentByTracking.put(key, shipment);
            }
        }

        List<Result> results = new List<Result>();
        for (Request request : requests) {
            Result result = new Result();
            Shipment__c shipment = String.isBlank(request.trackingNumber)
                ? null
                : shipmentByTracking.get(request.trackingNumber.trim().toLowerCase());
            if (shipment == null) {
                result.found = false;
                result.message = 'No shipment found for that tracking number.';
            } else {
                result.found = true;
                result.message = 'Shipment found.';
                result.shipmentNumber = shipment.Name;
                result.shipmentStatus = shipment.Shipment_Status__c;
                result.carrier = shipment.Carrier__c;
                result.shipmentDate = shipment.Shipment_Date__c == null ? null : String.valueOf(shipment.Shipment_Date__c);
                result.expectedDelivery = shipment.Expected_Delivery_Date__c == null ? null : String.valueOf(shipment.Expected_Delivery_Date__c);
                result.actualDelivery = shipment.Actual_Delivery_Date__c == null ? null : String.valueOf(shipment.Actual_Delivery_Date__c);
                result.notes = shipment.Delivery_Notes__c;
            }
            results.add(result);
        }
        return results;
    }
}
