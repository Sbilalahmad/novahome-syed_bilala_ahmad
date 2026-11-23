public with sharing class GetLoyaltyInfo {
    public class Request {
        @InvocableVariable(required=true description='Customer email address')
        public String customerEmail;
    }

    public class Result {
        @InvocableVariable public Boolean found;
        @InvocableVariable public String message;
        @InvocableVariable public String memberNumber;
        @InvocableVariable public String firstName;
        @InvocableVariable public Integer loyaltyPoints;
        @InvocableVariable public String membershipTier;
        @InvocableVariable public String memberStatus;
        @InvocableVariable public String membershipStartDate;
    }

    @InvocableMethod(label='Get Loyalty Info' description='Returns the loyalty member record for a customer email address')
    public static List<Result> getMembers(List<Request> requests) {
        Set<String> emails = new Set<String>();
        for (Request request : requests) {
            if (String.isNotBlank(request.customerEmail)) {
                emails.add(request.customerEmail.trim().toLowerCase());
            }
        }

        Map<String, Loyalty_Member__c> memberByEmail = new Map<String, Loyalty_Member__c>();
        for (Loyalty_Member__c member : [
            SELECT Name, Email__c, First_Name__c, Loyalty_Points__c, Membership_Tier__c,
                   Member_Status__c, Membership_Start_Date__c
            FROM Loyalty_Member__c
            WHERE Email__c IN :emails
        ]) {
            String key = member.Email__c == null ? null : member.Email__c.toLowerCase();
            if (key != null) {
                memberByEmail.put(key, member);
            }
        }

        List<Result> results = new List<Result>();
        for (Request request : requests) {
            Result result = new Result();
            Loyalty_Member__c member = String.isBlank(request.customerEmail)
                ? null
                : memberByEmail.get(request.customerEmail.trim().toLowerCase());
            if (member == null) {
                result.found = false;
                result.message = 'No loyalty membership found for that email address.';
            } else {
                result.found = true;
                result.message = 'Loyalty membership found.';
                result.memberNumber = member.Name;
                result.firstName = member.First_Name__c;
                result.loyaltyPoints = member.Loyalty_Points__c == null ? 0 : member.Loyalty_Points__c.intValue();
                result.membershipTier = member.Membership_Tier__c;
                result.memberStatus = member.Member_Status__c;
                result.membershipStartDate = member.Membership_Start_Date__c == null ? null : String.valueOf(member.Membership_Start_Date__c);
            }
            results.add(result);
        }
        return results;
    }
}
