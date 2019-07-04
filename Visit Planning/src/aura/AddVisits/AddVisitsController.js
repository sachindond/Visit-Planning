({
    doInit : function(component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.selectedDate', today);
		console.log("** do Init **");
        helper.getObjectList(component, event, helper);
	},
	saveVisits : function(component, event, helper) {
		var selectedObjectAPIName = component.get('v.selectedValue');
        var selectedObjectRecord = component.get("v.selectedLookUpRecord");
        console.log("****selectedLookUpRecord***",selectedObjectRecord.Id);
        var selectedVisitDate = component.find("idVisitDate").get("v.value");
        console.log("selectedVisitDate****",selectedVisitDate);
        var reasonForVisit = component.find("idVisitReason").get("v.value");
        console.log("***Reason for visit",reasonForVisit);
        
        // save visit record
        var action = component.get("c.saveVisitPlanningRecord");
        action.setParams({'objectAPIName':selectedObjectAPIName,
                          'objectRecordId':selectedObjectRecord.Id,
                          'selectedVisitDate':selectedVisitDate,
                          'reasonForVisit' :reasonForVisit});
        action.setCallback(this,function(res){
            
            if(res.getState()==='SUCCESS'){
                var returnResponse = res.getReturnValue();
                console.log("***Return After Save ***",returnResponse);
                if(returnResponse == true){
                    // call helper to show toast message
                    helper.showToastMessage('Visit Plan Added Successfully!','Success!','success');
                     $A.get('e.force:refreshView').fire();
                }else{
                    helper.showToastMessage('Visit Plan Failed To Insert Please Contact Your Admin!','Error!','error');
                }
            }
        });
        $A.enqueueAction(action);
  	},
    // This method nevigate from add component to view lightning component
    viewPlannedVisits: function(component, event, helper) {
        /*
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ViewPlannedVisits"
            
        });
        evt.fire();
        */
        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__component",
            "attributes": {
                "componentName": "c__ViewPlannedVisits"
            }, 
            "state": {
                'message':'This is the target page'
            }
        };
        navService.navigate(pageReference);
    },
    clearData : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})