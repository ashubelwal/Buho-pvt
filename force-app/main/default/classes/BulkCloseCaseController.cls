public class BulkCloseCaseController {
    ApexPages.StandardSetController setCon;
    
    public BulkCloseCaseController(ApexPages.StandardSetController controller){
        setCon = controller;
    }
    
    public pageReference UpdateStatusToClose(){
        system.debug('setCon--> '+setCon);
        system.debug('setCon.getSelected()--> '+setCon.getSelected());
        List<Case> objcaseToupdateList = [SELECT Id, Reason, Status, Comments FROM Case 
                                          WHERE Id IN: setCon.getSelected()];
        for(Case objCase : objcaseToupdateList){
            System.debug('Case Status = ' + objCase.Status);
            objCase.Status = 'Closed';
            objCase.Reason = 'Invalid Case';
            objCase.Comments = 'Updated to \'Closed\' from List View';
        }
        
        if(objcaseToupdateList.size()>0){
            try{
                update objcaseToupdateList;
            }catch(Exception e){
                system.debug('Something went Wrong : '+e.getMessage());
            }
        }
        return new PageReference('/500');
        //return null;
    }
}