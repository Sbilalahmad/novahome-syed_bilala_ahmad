public with sharing class CreateEscalationCase {
    public class Request {
        @InvocableVariable(required=true description='Short summary of the customer request')
        public String subject;

        @InvocableVariable(description='Full details of the customer request')
        public String details;

        @InvocableVariable(description='Customer email address')
        public String customerEmail;
    }

    public class Result {
        @InvocableVariable public Boolean created;
        @InvocableVariable public String caseNumber;
        @InvocableVariable public String message;
    }

    @InvocableMethod(label='Create Escalation Case' description='Creates a support case for human follow-up')
    public static List<Result> createCases(List<Request> requests) {
        List<Case> cases = new List<Case>();
        for (Request request : requests) {
            cases.add(new Case(
                Subject = request.subject,
                Description = request.details,
                SuppliedEmail = request.customerEmail,
                Origin = 'Web',
                Status = 'New'
            ));
        }
        insert cases;

        List<Result> results = new List<Result>();
        for (Integer i = 0; i < cases.size(); i++) {
            Result result = new Result();
            result.created = true;
            result.caseNumber = cases[i].CaseNumber;
            result.message = 'Support case created.';
            results.add(result);
        }
        return results;
    }
}
