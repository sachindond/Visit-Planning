({
    doInit : function(component, event, helper) {
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
            
        });
        $A.enqueueAction(action);
  	},
    viewPlannedVisits: function(component, event, helper) {
		
	}
})