trigger TaskTrigger on Task (after insert) {
	List<Task> taskList = new List<Task>();
	for(Task objTask : trigger.new){
		if(objTask.Subject == 'Call' && objTask.Status == 'Completed'){
			taskList.add(objTask);
		}
	}	
	if(taskList.size() > 0){
		TaskTriggerHandler.sendEmailAlert(taskList);
	}
}