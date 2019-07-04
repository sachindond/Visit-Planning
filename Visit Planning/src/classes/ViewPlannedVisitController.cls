/** Date : 27/6/2019
**/
public class ViewPlannedVisitController {
    
    // Wrapper to hold all visit planning records
    public class GetAllVisitsWrapper{
        @AuraEnabled public string recordId{get;set;}
        @AuraEnabled public string visitRecordName{get;set;}
        @AuraEnabled public date visitDate{get;set;}
        @AuraEnabled public string lookupRecordId{get;set;}
        @AuraEnabled public string lookupRecordName{get;set;}
        @AuraEnabled public string status{get;set;}
    }
    // Method to get list of visit Planning 
    // Logic: Get the values from custom settings and prepare dynamic query.
    // Get the result and loop over it and fill the wrapper class
    // Need to get review from Vinit.
    @AuraEnabled
    public static List<GetAllVisitsWrapper> getListOfAllVisitPlanning(string dateVar){
        system.debug('date field'+dateVar);
        try{
            List<GetAllVisitsWrapper> lstOfGetAllVisitWrapper = new List<GetAllVisitsWrapper>();
            List<string> lstOfLookupFields = new List<string>();
            // get the custom setting values
            List<Visit_Planning_Settings__c> lstOfVisitPlanningCustomSetting = Visit_Planning_Settings__c.getall().values();
            // Prepare base query and append lookup field values 
            string strBaseQuery = 'select id,Visit_Date__c,Name,Status__c';
            string strLookupFields = '';
            string strLookupFieldRecordName = '';
            if(lstOfVisitPlanningCustomSetting.size()>0){
                for(Visit_Planning_Settings__c vpSettings:lstOfVisitPlanningCustomSetting){
                    strLookupFields += ','+ vpSettings.Lookup_Field_Name__c; 
                    lstOfLookupFields.add(vpSettings.Lookup_Field_Name__c);
                    
                }
                
                if(string.isNotBlank(strLookupFields))
                    strLookupFieldRecordName = strLookupFields.replace('__c','__r.Name');
                
                // prepare complete query and use database.query to execute it.
                // we use replace here to get name of correspoing lookup record
                
                string strCompleteQuery = strBaseQuery+strLookupFields+strLookupFieldRecordName+' '+'from Visit_Plan__c where Visit_Date__c ='+dateVar+' Order by Name';
                system.debug('**Complete QueryString ***'+strCompleteQuery);
                List<Visit_Plan__c> lstOfVisitPlan = database.query(strCompleteQuery);
                system.debug('****list of visist plans *** '+lstOfVisitPlan);
                if(lstOfVisitPlan.size()>0){
                    for(Visit_Plan__c vp :lstOfVisitPlan){
                        GetAllVisitsWrapper visitsWrapperObj = new GetAllVisitsWrapper();
                        visitsWrapperObj.status =  vp.Status__c;
                        visitsWrapperObj.recordId = vp.Id;
                        visitsWrapperObj.visitRecordName = vp.Name;
                        visitsWrapperObj.visitDate = vp.Visit_Date__c;
                        // dynamic logic to get values and name of lookup fields using custom setting
                        // Need review of VINIT
                        for(string s : lstOfLookupFields){
                            if((string)vp.get(s)!=null){
                                visitsWrapperObj.lookupRecordId =(string)vp.get(s);
                                // we used below method to get related field values for Lookup's,
                                // as salesforce throws an error if we used get(Lookup__r.Name) so to overcome this error 
                                // we used this helper method
                                visitsWrapperObj.lookupRecordName = string.valueOf(getFieldValue(vp,s.replace('__c','__r.Name')));
                                
                            }
                        }
                        lstOfGetAllVisitWrapper.add(visitsWrapperObj);
                    }
                }
            }
            system.debug('*** list of visits Wrapper Class ***'+lstOfGetAllVisitWrapper);
            return lstOfGetAllVisitWrapper;
        }catch(exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'ViewPlannedVisitController.getListOfAllVisitPlanning', '');    
            return null;
        }
    }
    /* This is method used to get values from related fields
Logic: if we want to access any lookup field such ass lookup__r.Name in that case,
sObject get method throws an error so solution below method  
*/	
    public static Object getFieldValue(SObject o,String field){
        if(o == null){
            return null;
        }
        if(field.contains('.')){
            String nextField = field.substringAfter('.');
            String relation = field.substringBefore('.');
            return getFieldValue((SObject)o.getSObject(relation),nextField);
        }else{
            return o.get(field);
        }
    }
    
    // Method to update Visit Plan Record on CheckOut button clicked
    // with Comments and Check out location lat long
    @AuraEnabled
    public static boolean updateCheckoutLocationOnVisitPlanningRecord(string checkoutComments, string recordId, decimal checkoutLat, decimal checkoutLong){
        List<Visit_Plan__c> lstUpdateVisitPlan = new List<Visit_Plan__c>();
        try{
            // check record id and comment fields are not blank
            if(string.isNotBlank(recordId)){
                Visit_Plan__c vp = new Visit_Plan__c(Id=recordId);
                vp.Check_Out_Comments__c = checkoutComments;
                vp.Check_Out_Date_Time__c = datetime.now();
                vp.Check_Out_Location__Latitude__s = checkoutLat;
                vp.Check_Out_Location__Longitude__s = checkoutLong;
                lstUpdateVisitPlan.add(vp);
            }
            if(lstUpdateVisitPlan.size()>0){
                system.debug('***list to update visit plan'+lstUpdateVisitPlan);
                update lstUpdateVisitPlan;
            }
            return true;
        }catch(exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'ViewPlannedVisitController.updateVisitPlanningRecord', '');    
            return false;
        }
    }
    // Method to Update Check In Location Lat Long on Visit Planning Record
    @AuraEnabled
    public static boolean updateCheckInLocationOnVisitPlanningRecord(string recordId, decimal checkInLat, decimal checkInLong){
        List<Visit_Plan__c> lstToUpdateVisitPlanCheckInLocation = new List<Visit_Plan__c>();
        try{
            if(string.isNotBlank(recordId)){
                Visit_Plan__c vp = new Visit_Plan__c(Id = recordId);
                // set current date time latitude and longitude
                vp.Check_In_Date_Time__c = datetime.now();
                vp.Check_In_Location__Latitude__s = checkInLat;
                vp.Check_In_Location__Longitude__s = checkInLong;
                lstToUpdateVisitPlanCheckInLocation.add(vp);
            }
            if(lstToUpdateVisitPlanCheckInLocation.size()>0){
                system.debug('**** Check in Update Location'+lstToUpdateVisitPlanCheckInLocation);
                update lstToUpdateVisitPlanCheckInLocation;
            }
            return true;
            
        }catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'ViewPlannedVisitController.updateCheckInLocationOnVisitPlanningRecord', '');    
            return false;
        }
    }
    // Method to delete Visit Planning Record
    @AuraEnabled
    public static boolean deleteVisitPlanningRecord(string recordId){
        try{
            if(string.isNotEmpty(recordId)){
                delete [select id from Visit_Plan__c where id=:recordId];
            }
            return true;
        }catch(Exception oEx){
            Logger.Log('Error','Line Number: ' + oEx.getLineNumber() + ' Message: ' + oEx.getMessage(), 'ViewPlannedVisitController.deleteVisitPlanningRecord', '');    
            return false;
        }
    }
}