public class VisitPlanningController {
    
    @AuraEnabled
    public static List<Visit_Plan__c> GetVisitsForToday(){
        system.debug('Inside Get Visits for Today...');
        List<Visit_Plan__c> TodaysVisits  = new List<Visit_Plan__c>();
        TodaysVisits = [SELECT Id, Owner.Name, Name, Visit_Date__c, Visit_To_Lead__r.Name,
                        Check_In_Date_Time__c, Check_In_Location__c, Check_Out_Date_Time__c, 
                        Check_Out_Location__c, Visit_To_Account__r.Name, Visit_To_Contact__r.Name
                        FROM Visit_Plan__c Where Visit_Date__c = TODAY Order By Name];
        
        return TodaysVisits;
    }
    
    @AuraEnabled
    public static List<SearchItemWrapper> GetSearchableRecords(string objectname){
        try{
            system.debug('objectname: ' + objectname);
            List<sObject> RecordList = new List<sObject>();
            If(objectname == 'Account')
            {
                RecordList = [SELECT Id, Name From Account Limit 10];
            }
            else if(objectname == 'Lead')
            {
                RecordList = [SELECT Id, Name From Lead Limit 10];
            }
            else if(objectname == 'Contact')
            {
                RecordList = [SELECT Id, Name From Contact Limit 10];
            }
            
            List<SearchItemWrapper> SearchedItemsList = new List<SearchItemWrapper>();
            If(RecordList.size() > 0)
            {
                For(sObject currentRecord: RecordList)
                {
                    SearchItemWrapper newItem = new SearchItemWrapper();
                    newItem.RecordId = currentRecord.Id;
                    newItem.RecordName = (String)currentRecord.get('Name');
                    SearchedItemsList.add(newItem);
                }
                return SearchedItemsList;
            }
            else
                return null;
        }
        catch(Exception oEx)
        {
            system.debug('Error Occured in GetSearchableRecords method: ' + oEx.getMessage() + ' Line No: ' + oEx.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Visit_Plan__c> SaveNewVisits(List<Visit_Plan__c> selectedVisits, string selecteddate){
        try{
            system.debug('Inside SaveNewVisits...');
            system.debug('selectedVisits List: ' + selectedVisits);
            
            List<Visit_Plan__c> newVisitListForUpsert = new List<Visit_Plan__c>();
            For(Visit_Plan__c currentVisit: selectedVisits)
            {
                Visit_Plan__c newVisitPlan = new Visit_Plan__c();
                newVisitPlan.Id = currentVisit.Id;
                newVisitPlan.Visit_To_Lead__c = currentVisit.Visit_To_Lead__c;
                newVisitPlan.Visit_Date__c = currentVisit.Visit_Date__c;
                newVisitListForUpsert.add(newVisitPlan);
            }
            system.debug('newVisitListForUpsert: ' + newVisitListForUpsert);
            upsert newVisitListForUpsert;
            return GetVisitsForDate(selecteddate);
        }
        catch(Exception oEx)
        {
            system.debug('Error Occured in SaveNewVisits method: ' + oEx.getMessage() + ' Line No: ' + oEx.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Visit_Plan__c> GetVisitsForDate(string selecteddate){
        try{
            system.debug('Inside GetVisitsForDate...');
            system.debug('selecteddate: ' + selecteddate);
            List<Visit_Plan__c> visitPlans = [SELECT Id, Owner.Name, Name, Visit_Date__c, Visit_To_Lead__r.Name, Visit_To_Lead__c,
                                              Check_In_Date_Time__c, Check_In_Location__c, Check_Out_Date_Time__c, 
                                              Check_Out_Location__c, Visit_To_Account__c, Visit_To_Account__r.Name, Visit_To_Contact__r.Name, Visit_To_Contact__c
                                              FROM Visit_Plan__c Where Visit_Date__c =: Date.valueOf(selecteddate) Order By Name];
            
            system.debug('visitPlans: ' + visitPlans);
            return visitPlans;
        }
        catch(Exception oEx)
        {
            system.debug('Error Occured in GetVisitsForDate method: ' + oEx.getMessage() + ' Line No: ' + oEx.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Visit_Plan__c> DeleteSingleVisit (string VisitReletedID, string selecteddate){
        try{
            system.debug('Inside DeleteSingleVisit method apex...');
            system.debug('VisitReletedID: ' + VisitReletedID);
            system.debug('selecteddate: ' + selecteddate);
            
            Delete [Select Id From Visit_Plan__c Where Visit_To_Lead__c =: VisitReletedID 
                    AND Visit_Date__c =: Date.valueOf(selecteddate)];
            
            system.debug('Record deleted...');
            return GetVisitsForDate(selecteddate);            
        }
        catch(Exception oEx)
        {
            system.debug('Error Occured in DeleteSingleVisit method: ' + oEx.getMessage() + ' Line No: ' + oEx.getLineNumber());
        }
        return null;
    }
    
    /***************************** New Development Started 24/6/2018 By Sachin Dond *********************/
    // This method access custom setting from which we get object list where user plan to visits
    @AuraEnabled
    public static List<CustomSettingWrapper> getObjectListFromCustomSettig(){
        // access custom setting;
        List<CustomSettingWrapper> lstOfObjectAPINames = new List<CustomSettingWrapper>();
        List<Visit_Planning_Settings__c> lstOfVisitPlanningCustomSetting = Visit_Planning_Settings__c.getall().values();
        if(lstOfVisitPlanningCustomSetting.size()>0){
            for(Visit_Planning_Settings__c vpObj : lstOfVisitPlanningCustomSetting){
                // create map of Object label and Object API key
                CustomSettingWrapper wrapperObj = new CustomSettingWrapper();
                wrapperObj.objectLabel = vpObj.Object_Label__c;
                wrapperObj.objectAPIName =  vpObj.Object_API_Name__c;
                lstOfObjectAPINames.add(wrapperObj);
            }
        }
        system.debug('**list of Objects and API keys'+lstOfObjectAPINames);
        return lstOfObjectAPINames;
    }
    // This is method used fetch lookup values based on Object Name 
    @AuraEnabled
    public static List<sObject> getObjectRecordsSearchResults(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
    // Method to save Visit Planning Record
    // Logic : We used here dynamic method of apex to set value to the field : objectInstance.put('APINAME',Value)
    @AuraEnabled
    public static void saveVisitPlanningRecord(string objectAPIName,string objectRecordId,string selectedVisitDate,string reasonForVisit ){
        // get the custom setting and create map of API name and Correspoinding lookup field to access it;
        try{
            List<Visit_Plan__c> lstInsertVisitPlanningRecord = new List<Visit_Plan__c>();
            List<Visit_Planning_Settings__c> lstOfVisitPlanningCustomSetting = Visit_Planning_Settings__c.getall().values();
            Map<String,String> mapAPINameWithLookupField = new Map<String,String>();
            if(lstOfVisitPlanningCustomSetting.size()>0){
                for(Visit_Planning_Settings__c vpObj : lstOfVisitPlanningCustomSetting){
                    mapAPINameWithLookupField.put(vpObj.Object_API_Name__c,vpObj.Lookup_Field_Name__c);
                }
            }
            system.debug('***map of API mapAPINameWithLookupField '+mapAPINameWithLookupField);
            // create Visit Planning Record and User Map to get Look up field Name
            Visit_Plan__c vpRecordObj = new Visit_Plan__c();
            // this is dynamic way to assign value to api name we access it via map created from custom setting
            vpRecordObj.put(mapAPINameWithLookupField.get(objectAPIName),objectRecordId);
            vpRecordObj.Reason_For_Visit__c = reasonForVisit;
            vpRecordObj.Visit_Date__c = date.valueOf(selectedVisitDate);
            lstInsertVisitPlanningRecord.add(vpRecordObj);
            system.debug('** list to insert Visit Planning Records**'+lstInsertVisitPlanningRecord);
            if(lstInsertVisitPlanningRecord.size()>0){
                insert lstInsertVisitPlanningRecord;
            }
        }Catch(Exception ex){
            System.debug('**Exception Occur Line Number : '+ex.getLineNumber() +'Error Message :'+ex.getMessage());
        }
    }    
    
    
    
    
    
    
    
    
    
    public class SearchItemWrapper{
        @AuraEnabled public Id RecordId{get;set;}
        @AuraEnabled public String RecordName{get;set;}      
    }
    
    public class CustomSettingWrapper{
        @AuraEnabled public String objectLabel{get;set;}
        @AuraEnabled public String objectAPIName{get;set;}    
    }
}