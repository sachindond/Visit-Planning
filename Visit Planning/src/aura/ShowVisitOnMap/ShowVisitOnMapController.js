({
	doInit : function(component, event, helper) {
		var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.selectedDate', today);
        //helper.getVisitPlans(component, event, helper);
        helper.getSubordinateList(component, event, helper);
	},
    // Method shows list of visit planned which is Checkout lat and long
    onChangeDateFilterOfMap : function(component, event, helper) {
        console.log("*******onChangeDateFilterOfMap")
     	helper.getVisitPlans(component, event, helper) ;
    },
    onChangeSubordinateList: function(component, event, helper) {
     	   helper.getVisitPlans(component, event, helper);
    }
})