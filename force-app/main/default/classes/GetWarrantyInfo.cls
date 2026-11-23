public with sharing class GetWarrantyInfo {
    public class Request {
        @InvocableVariable(required=true description='Customer email address')
        public String customerEmail;
    }

    public class Result {
        @InvocableVariable public Boolean found;
        @InvocableVariable public String message;
        @InvocableVariable public String productName;
        @InvocableVariable public String warrantyType;
        @InvocableVariable public String warrantyStatus;
        @InvocableVariable public String startDate;
        @InvocableVariable public String endDate;
        @InvocableVariable public String description;
    }

    @InvocableMethod(label='Get Warranty Info' description='Returns the most recent warranty for a customer email address')
    public static List<Result> getWarranties(List<Request> requests) {
        Set<String> emails = new Set<String>();
        for (Request request : requests) {
            if (String.isNotBlank(request.customerEmail)) {
                emails.add(request.customerEmail.trim().toLowerCase());
            }
        }

        Map<String, Warranty__c> latestByEmail = new Map<String, Warranty__c>();
        for (Warranty__c warranty : [
            SELECT Customer_Email__c, Product_Name__c, Warranty_Type__c, Warranty_Status__c,
                   Warranty_Start_Date__c, Warranty_End_Date__c, Warranty_Description__c
            FROM Warranty__c
            WHERE Customer_Email__c IN :emails
            ORDER BY Warranty_End_Date__c DESC
        ]) {
            String key = warranty.Customer_Email__c == null ? null : warranty.Customer_Email__c.toLowerCase();
            if (key != null && !latestByEmail.containsKey(key)) {
                latestByEmail.put(key, warranty);
            }
        }

        List<Result> results = new List<Result>();
        for (Request request : requests) {
            Result result = new Result();
            Warranty__c warranty = String.isBlank(request.customerEmail)
                ? null
                : latestByEmail.get(request.customerEmail.trim().toLowerCase());
            if (warranty == null) {
                result.found = false;
                result.message = 'No warranty found for that email address.';
            } else {
                result.found = true;
                result.message = 'Warranty found.';
                result.productName = warranty.Product_Name__c;
                result.warrantyType = warranty.Warranty_Type__c;
                result.warrantyStatus = warranty.Warranty_Status__c;
                result.startDate = warranty.Warranty_Start_Date__c == null ? null : String.valueOf(warranty.Warranty_Start_Date__c);
                result.endDate = warranty.Warranty_End_Date__c == null ? null : String.valueOf(warranty.Warranty_End_Date__c);
                result.description = warranty.Warranty_Description__c;
            }
            results.add(result);
        }
        return results;
    }
}
