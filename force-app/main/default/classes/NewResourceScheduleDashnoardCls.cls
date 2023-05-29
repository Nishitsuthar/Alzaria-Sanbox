public with sharing class NewResourceScheduleDashnoardCls {

    @AuraEnabled
    public static  combinedProjectCalendarWrapperClone getScheduleItemsByProject(String fromDate, String toDate, string slectedTradetypeId, string slectedprojectId, string slectedcontactId, String projectSearch,String resourceSearch, String alltypeSearch){

        string userName = userInfo.getUserId();
        system.debug(userName);
        list<Network> netRec = [SELECT Id FROM Network];
        system.debug('%%%'+netRec.size());
        if(netRec.size() > 0){
            string strQry = 'Select Id,Name, isPortalEnabled From User Where id=: userName';
            list<User> userRec = Database.query(strQry);

            if(userRec[0].get('isPortalEnabled').toString() == 'true'){
                resourceSearch = userRec[0].Name;
                alltypeSearch  = '';
            }
        }
        system.debug('projectSearch-->'+projectSearch+' resourceSearch-->'+resourceSearch+' alltypeSearch-->'+alltypeSearch);

        system.debug(slectedTradetypeId + '----slectedTradetypeId---' + slectedprojectId + '-------slectedprojectId-' + slectedcontactId);
        system.debug('====' + fromDate + '======' + toDate);
        Map<Id, list<buildertek__Project_Task__c>> scheduleitemmap = new Map<Id, list<buildertek__Project_Task__c>>();
        Map<Id, string> contactnamemap = new Map<Id, string>();
        list<buildertek__Project_Task__c> schudleitemList = new list<buildertek__Project_Task__c>();
        list<buildertek__Project_Task__c> scitemList = new list<buildertek__Project_Task__c>();
        list<buildertek__Schedule__c> SchedulerList = new list<buildertek__Schedule__c>();
        list<contact> conresource = new list<contact>();
        List<buildertek__Project__c> projectRecordList = new List<buildertek__Project__c>();

        String str = fromDate;
        List<String> res = str.split('-');
        System.debug(Date.newInstance(Integer.valueOf(res[0]),Integer.valueOf(res[1]),Integer.valueOf(res[2])));

        String str2 = toDate;
        List<String> res2 = str2.split('-');
        System.debug(Date.newInstance(Integer.valueOf(res2[0]),Integer.valueOf(res2[1]),Integer.valueOf(res2[2])));

        date startDate  = Date.newInstance(Integer.valueOf(res[0]),Integer.valueOf(res[1]),Integer.valueOf(res[2]));
        date endDate = Date.newInstance(Integer.valueOf(res2[0]),Integer.valueOf(res2[1]),Integer.valueOf(res2[2]));

        system.debug('-------startDate' + startDate);
        system.debug('-------endDate' + endDate);
        String dtFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';


        list<contact> resources = new list<contact>();
        list<buildertek__Project_Task__c> schduleitems = new List<buildertek__Project_Task__c>();

        String projectSearchVal = '%'+''+'%';
        if(projectSearch != '' && projectSearch != null){
            projectSearchVal = '%'+projectSearch+'%';
        }

        String resourceSearchVal = '%'+''+'%';
        if(resourceSearch != null && resourceSearch!= ''){
            resourceSearchVal = '%'+resourceSearch+'%';
        }

        String alltypeSearchVal = '%'+''+'%';
        if(alltypeSearch != null && alltypeSearch!= ''){
            alltypeSearchVal = '%'+alltypeSearch+'%';
        }

        system.debug(projectSearchVal+'--'+alltypeSearchVal+'---'+resourceSearchVal);


        String taskQuery = 'Select id,buildertek__Start__c,buildertek__Finish__c, Name, buildertek__Duration__c,buildertek__Schedule__c,buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Resource__c,buildertek__Resource__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource__r.Name, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c, ';
        taskQuery += ' buildertek__Contractor_Resource__r.AccountId,buildertek__Resource__r.AccountId,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name ';
        taskQuery += ' From buildertek__Project_Task__c where ';
        taskQuery += ' buildertek__Start__c <=:endDate AND buildertek__Finish__c >=: startDate ';

        if(projectSearch !='' || projectSearch != null || resourceSearch != null || resourceSearch != '' ){
            system.debug('test3');
            if(slectedprojectId != '' && slectedprojectId != null){
                if(projectSearch != '' && projectSearch != null){
                    system.debug(projectSearch);
                    taskQuery += ' AND (buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: projectSearchVal) ';

                }else{
                    taskQuery += ' AND (buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId) ';
                }
            }else if(projectSearch != '' && projectSearch != null){
                system.debug(projectSearch);
                taskQuery += ' AND (buildertek__Schedule__r.buildertek__Project__c != null AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: projectSearchVal) ';
            }
            if(resourceSearch != null && resourceSearch != ''){
                taskQuery += ' AND (buildertek__Contractor_Resource__r.Name LIKE: resourceSearchVal OR buildertek__Resource__r.Name LIKE: resourceSearchVal) ';
            }else{
                taskQuery += ' AND (buildertek__Contractor_Resource__c != null OR buildertek__Resource__c != null) ';
            }

        }else{
            if(slectedprojectId != '' && slectedprojectId != null){
                taskQuery += ' AND (buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId) AND (buildertek__Contractor_Resource__c != null OR buildertek__Resource__c != null) ';
            }else{
                taskQuery += '(buildertek__Schedule__r.buildertek__Project__c != null) AND (buildertek__Contractor_Resource__c != null OR buildertek__Resource__c != null) ';
            }
        }

        schduleitems = Database.query(taskQuery);
        system.debug(schduleitems.Size());
        system.debug(schduleitems);
        List<String> scheduleitemIdList = new List<String>();
        for(buildertek__Project_Task__c item:schduleitems){
            if(!scheduleitemIdList.contains(item.id)){
                scheduleitemIdList.add(item.id);
            }
        }


        system.debug(scheduleitemIdList);
        List<buildertek__Project_Task__c> tasksforalltypesearch = new List<buildertek__Project_Task__c>();
        String taskQuery2;
        if(alltypeSearch != '' && alltypeSearch !=null){

            taskQuery2 = 'Select id,buildertek__Start__c,buildertek__Finish__c,buildertek__Duration__c, Name, buildertek__Schedule__c,buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Resource__c,buildertek__Resource__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource__r.Name, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c, ';
            taskQuery2 += ' buildertek__Contractor_Resource__r.Account.Name,buildertek__Resource__r.Account.Name,buildertek__Contractor_Resource__r.AccountId,buildertek__Resource__r.AccountId,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name ';
            taskQuery2 += ' From buildertek__Project_Task__c where id IN: scheduleitemIdList AND (buildertek__Contractor_Resource__c != null OR buildertek__Resource__c != null) AND ';
            taskQuery2 += ' (buildertek__Start__c <=:endDate AND buildertek__Finish__c >=: startDate) ';
            if(slectedprojectId != '' && slectedprojectId != null){
                if(alltypeSearch != '' && alltypeSearch != null){
                    taskQuery2 += ' AND ((buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: alltypeSearchVal) ';
                }
            }else {
                taskQuery2 += ' AND ((buildertek__Schedule__r.buildertek__Project__c != null AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: alltypeSearchVal) ';
            }

            taskQuery2 += ' OR ((buildertek__Contractor_Resource__r.Name LIKE: alltypeSearchVal OR buildertek__Resource__r.Name LIKE: alltypeSearchVal)) ';
            taskQuery2 += ' OR (buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal OR buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal) ';
            taskQuery2 += ' OR (buildertek__Contractor_Resource__r.Account.Name LIKE: alltypeSearchVal OR buildertek__Resource__r.Account.Name LIKE: alltypeSearchVal)) ';

            tasksforalltypesearch =  Database.query(taskQuery2);
        }


        system.debug(tasksforalltypesearch.size());


         List<String> filteredTasksIds = new List<String>();
        for(buildertek__Project_Task__c allTypeSearchTask : tasksforalltypesearch){
            system.debug(allTypeSearchTask.buildertek__Schedule__r.buildertek__Project__r.Name);
            system.debug(allTypeSearchTask.buildertek__Contractor_Resource__r.Name);
            if(allTypeSearchTask.buildertek__Resource__c != null){
                system.debug(allTypeSearchTask.buildertek__Resource__r.Name);
            }
            system.debug(allTypeSearchTask);
            system.debug(allTypeSearchTask.buildertek__Contractor_Resource__r.Account.Name);
            if(!filteredTasksIds.contains(allTypeSearchTask.Id)){
                filteredTasksIds.add(allTypeSearchTask.Id);
                system.debug(allTypeSearchTask) ;
            }
        }




        List<String> filteredTasks = new  List<String>();

        system.debug(filteredTasksIds);

        if(filteredTasksIds.size()>0 && (projectSearch !='' || projectSearch != null || resourceSearch != null || resourceSearch != '')) {
            for(buildertek__Project_Task__c filterTask : schduleitems){
                system.debug(filterTask);
                if(filteredTasksIds.contains(filterTask.Id)){
                    filteredTasks.add(filterTask.Id);
                }
            }
        }else{
            filteredTasks = filteredTasksIds;
        }

       system.debug(filteredTasks.Size());

        set<Id> conid = new set<Id>();
        set<Id> scheduleids = new set<Id>();
        set<Id> accountRecIds = new Set<Id>();
        if(filteredTasks.Size() > 0){
            List<buildertek__Project_Task__c> filteredTaskList = [Select id,buildertek__Start__c,buildertek__Finish__c,buildertek__Duration__c, Name, buildertek__Schedule__c,buildertek__Schedule__r.buildertek__Project__c,
                                                                  buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Resource__c,buildertek__Resource__r.Name,
                                                                  buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource__r.Name,
                                                                  buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c,
                                                                  buildertek__Resource__r.Account.Name,buildertek__Contractor_Resource__r.Account.Name,buildertek__Contractor_Resource__r.AccountId,buildertek__Resource__r.AccountId,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__c,
                                                                  buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,
                                                                  buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name
                                                                   From buildertek__Project_Task__c where id IN: filteredTasks];
            system.debug(filteredTaskList.size());
            for (buildertek__Project_Task__c scitem : filteredTaskList){

                if(!conid.contains(scitem.buildertek__Contractor_Resource__c) && scitem.buildertek__Contractor_Resource__c != null){ // && (scitem.buildertek__Contractor_Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    conid.add(scitem.buildertek__Contractor_Resource__c);
                }
                if(!conid.contains(scitem.buildertek__Resource__c) && scitem.buildertek__Resource__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    conid.add(scitem.buildertek__Resource__c);
                }
                scheduleids.add(scitem.buildertek__Schedule__c);

                system.debug(fromDate+','+ toDate+','+scitem.buildertek__Start__c+','+scitem.buildertek__Finish__c);
            }
        }else{
            for (buildertek__Project_Task__c scitem : schduleitems){

                if(!conid.contains(scitem.buildertek__Contractor_Resource__c) && scitem.buildertek__Contractor_Resource__c != null){
                    conid.add(scitem.buildertek__Contractor_Resource__c);
                }
                if(!conid.contains(scitem.buildertek__Resource__c) && scitem.buildertek__Resource__c != null){
                    conid.add(scitem.buildertek__Resource__c);
                }
                scheduleids.add(scitem.buildertek__Schedule__c);

                system.debug(fromDate+','+ toDate+','+scitem.buildertek__Start__c+','+scitem.buildertek__Finish__c);
            }
        }

        system.debug(conid);
        SchedulerList = [select Id, Name, buildertek__Contractor__c, buildertek__Contractor__r.Name, buildertek__Project__c, buildertek__Project__r.Name
                         from buildertek__Schedule__c
                         where Id IN :scheduleids];
        resources = [select id, Name,AccountId,Account.Name
                     from Contact
                     where Id IN :conid];

        for(Contact con : resources){
            if(!accountRecIds.contains(con.AccountId)){
                accountRecIds.add(con.AccountId);
            }
        }


        string Query = 'select id,Name,buildertek__Duration__c,buildertek__Completion__c,buildertek__Schedule__c,buildertek__Dependency__c,buildertek__Contractor_Resource__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor_Resource__r.buildertek__Simultaneous_Tasks__c,';
        Query += 'buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.buildertek__Contractor__c,buildertek__Schedule__r.buildertek__Contractor__r.Name,buildertek__Schedule__r.buildertek__Contractor__r.buildertek__Simultaneous_Tasks__c,buildertek__Schedule__r.Name,buildertek__Dependency__r.Name,';
        Query += ' buildertek__Contractor_Resource__r.AccountId,buildertek__Resource__r.AccountId,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name, ';
        Query += 'buildertek__Resource__r.Name,buildertek__Resource__r.Account.Name,buildertek__Contractor_Resource__r.Account.Name,buildertek__Resource__c,buildertek__Start__c,buildertek__Finish__c from ';
        Query += 'buildertek__Project_Task__c where ';
        Query += 'buildertek__Schedule__c != null and buildertek__Schedule__r.buildertek__Project__c != null and (buildertek__Start__c <=:endDate AND buildertek__Finish__c >=: startDate)'; //buildertek__Start__c >=:startDate OR buildertek__Finish__c <=: endDate

        if(projectSearch !='' || projectSearch != null || resourceSearch != null || resourceSearch != ''){

            if(slectedprojectId != '' && slectedprojectId != null){
                if(projectSearch != '' && projectSearch != null){
                    system.debug(projectSearch);
                    Query += ' AND (buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: projectSearchVal) ';
                }else{
                    Query += ' AND (buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId) ';
                }
            }else if(projectSearch != '' && projectSearch != null){
                Query += ' AND (buildertek__Schedule__r.buildertek__Project__c != null AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: projectSearchVal) ';
            }
            if(resourceSearch != null && resourceSearch != ''){
                Query += ' AND (buildertek__Contractor_Resource__r.Name LIKE: resourceSearchVal OR buildertek__Resource__r.Name LIKE: resourceSearchVal) ';
                Query += ' and (buildertek__Contractor_Resource__c IN:conid OR buildertek__Resource__c IN:conid)';
            }else{
                Query += ' and (buildertek__Contractor_Resource__c IN:conid OR buildertek__Resource__c IN:conid)';
            }
        }else{
            if (slectedprojectId != null && slectedprojectId != ''){
                Query += ' and buildertek__Schedule__r.buildertek__Project__c=:slectedprojectId';
            }
            Query += ' and (buildertek__Contractor_Resource__c IN:conid OR buildertek__Resource__c IN:conid)';
        }


        schudleitemList = Database.query(Query);
         system.debug('schudleitemList----->' + schudleitemList.size());

        List<buildertek__Project_Task__c> tasksforalltypesearch2 = new List<buildertek__Project_Task__c>();
        String taskQuery3;
        if(alltypeSearch != '' && alltypeSearch !=null){

            taskQuery3 = 'select id,Name,buildertek__Duration__c,buildertek__Completion__c,buildertek__Schedule__c,buildertek__Dependency__c,buildertek__Contractor_Resource__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor_Resource__r.buildertek__Simultaneous_Tasks__c,';
            taskQuery3 += 'buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.buildertek__Contractor__c,buildertek__Schedule__r.buildertek__Contractor__r.Name,buildertek__Schedule__r.buildertek__Contractor__r.buildertek__Simultaneous_Tasks__c,buildertek__Schedule__r.Name,buildertek__Dependency__r.Name,';
            taskQuery3 += ' buildertek__Contractor_Resource__r.AccountId,buildertek__Contractor_Resource__r.Account.Name,buildertek__Resource__r.Account.Name,buildertek__Resource__r.AccountId,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name, ';
            taskQuery3 += 'buildertek__Resource__r.Name,buildertek__Resource__c,buildertek__Start__c,buildertek__Finish__c from ';
            taskQuery3 += 'buildertek__Project_Task__c where id IN:schudleitemList AND ';
            taskQuery3 += '(buildertek__Contractor_Resource__c IN:conid OR buildertek__Resource__c IN:conid) AND buildertek__Schedule__c != null and buildertek__Schedule__r.buildertek__Project__c != null and (buildertek__Start__c <=:endDate AND buildertek__Finish__c >=: startDate)'; //buildertek__Start__c >=:startDate OR buildertek__Finish__c <=: endDate
            if(slectedprojectId != '' && slectedprojectId != null){
                if(alltypeSearch != '' && alltypeSearch != null){
                    taskQuery3 += ' AND ((buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: alltypeSearchVal) ';
                }
            }else {
                taskQuery3 += ' AND ((buildertek__Schedule__r.buildertek__Project__c != null AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: alltypeSearchVal) ';
            }

            taskQuery3 += ' OR ((buildertek__Contractor_Resource__r.Name LIKE: alltypeSearchVal OR buildertek__Resource__r.Name LIKE: alltypeSearchVal)) ';
            taskQuery3 += ' OR (buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal OR buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal) ';
            taskQuery3 += ' OR (buildertek__Contractor_Resource__r.Account.Name LIKE: alltypeSearchVal OR buildertek__Resource__r.Account.Name LIKE: alltypeSearchVal)) ';

            tasksforalltypesearch2 =  Database.query(taskQuery3);
        }


        List<String> filteredTasksIds2 = new List<String>();
        for(buildertek__Project_Task__c allTypeSearchTask : tasksforalltypesearch2){
            system.debug(allTypeSearchTask.buildertek__Schedule__r.buildertek__Project__r.Name);
            system.debug(allTypeSearchTask.buildertek__Contractor_Resource__r.Name);
            if(allTypeSearchTask.buildertek__Resource__c != null){
                system.debug(allTypeSearchTask.buildertek__Resource__r.Name);
            }
            system.debug(allTypeSearchTask);
            system.debug(filteredTasksIds2);
            system.debug(allTypeSearchTask.buildertek__Contractor_Resource__r.Account.Name);
            if(!filteredTasksIds2.contains(allTypeSearchTask.Id)){
                filteredTasksIds2.add(allTypeSearchTask.Id);
                system.debug(allTypeSearchTask) ;
            }
        }



        system.debug(filteredTasksIds2.size());


        List<String> filteredTasks2 = new  List<String>();

        system.debug(filteredTasksIds2);

        if(filteredTasksIds2.size()>0 && (projectSearch !='' || projectSearch != null || resourceSearch != null || resourceSearch != '')) {
            //filteredTasks.addAll(filteredTasksIds);
            for(buildertek__Project_Task__c filterTask : schudleitemList){
                system.debug(filterTask);
                if(filteredTasksIds2.contains(filterTask.Id)){
                    filteredTasks2.add(filterTask.Id);
                }
            }
        }else{
            filteredTasks2 = filteredTasksIds2;
        }

       system.debug(filteredTasks2.Size());


        if(filteredTasks2.Size() > 0){
            List<buildertek__Project_Task__c> filteredTaskList2 = [select id,Name,buildertek__Duration__c,buildertek__Completion__c,buildertek__Schedule__c,buildertek__Dependency__c,buildertek__Contractor_Resource__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor_Resource__r.buildertek__Simultaneous_Tasks__c,
                                                                    buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.buildertek__Contractor__c,buildertek__Schedule__r.buildertek__Contractor__r.Name,buildertek__Schedule__r.buildertek__Contractor__r.buildertek__Simultaneous_Tasks__c,buildertek__Schedule__r.Name,buildertek__Dependency__r.Name,
                                                                   buildertek__Contractor_Resource__r.AccountId,buildertek__Resource__r.AccountId,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,
                                                                   buildertek__Resource__r.Name,buildertek__Resource__r.Account.Name,buildertek__Contractor_Resource__r.Account.Name,buildertek__Resource__c,buildertek__Start__c,buildertek__Finish__c,


                                                                   buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c
                                                                   From buildertek__Project_Task__c where id IN: filteredTasks2];
            system.debug(filteredTaskList2.size());
            schudleitemList = filteredTaskList2;
        }
        system.debug('schudleitemList----->' + schudleitemList.size());

        Map<String,List<buildertek__Project_Task__c>> ProjScheduleTaskMap = new Map<String,List<buildertek__Project_Task__c>>();
        List<String> projectIdList = new List<String>();
        for(buildertek__Project_Task__c schItemTask : schudleitemList){
            system.debug(schItemTask.buildertek__Schedule__r.buildertek__Project__c);
            if(schItemTask.buildertek__Schedule__r.buildertek__Project__c != null){

                system.debug(schItemTask.buildertek__Schedule__r.buildertek__Project__r.Name);
                projectIdList.add(schItemTask.buildertek__Schedule__r.buildertek__Project__c);
                if(ProjScheduleTaskMap.get(schItemTask.buildertek__Schedule__r.buildertek__Project__c) != null){
                    List<buildertek__Project_Task__c> projTask = ProjScheduleTaskMap.get(schItemTask.buildertek__Schedule__r.buildertek__Project__c);
                    projTask.add(schItemTask);
                    ProjScheduleTaskMap.put(schItemTask.buildertek__Schedule__r.buildertek__Project__c,projTask);
                }else{
                    List<buildertek__Project_Task__c> projTask = new List<buildertek__Project_Task__c>();
                    projTask.add(schItemTask);
                    ProjScheduleTaskMap.put(schItemTask.buildertek__Schedule__r.buildertek__Project__c,projTask);
                }
            }
        }

        system.debug(ProjScheduleTaskMap.keySet().Size());

        //will get only schedule items of schedule that is linked to project
        projectRecordList = [Select Id,Name, buildertek__Customer__c,buildertek__Customer__r.Name From buildertek__Project__c WHERE ID IN: projectIdList];

        Map<Id, string> tradeTypenamemap = new Map<Id, string>();
        Map<Id, string> contactAccountMap = new Map<Id, string>();
        Map<Id, Decimal> contactSimulateMap = new Map<Id, Decimal>();
        for (contact conrec : [Select id, Name, AccountId, buildertek__Simultaneous_Tasks__c
                               from Contact
                               where id in :conid]){ // AND Name LIKE : resourceSearchVal
                                    if(resourceSearch != '' && resourceSearch != null){
                                       if(conrec.Name.containsIgnoreCase(resourceSearch)){
                                           if (conrec.AccountId != null){
                                               contactAccountMap.put(conrec.id, conrec.AccountId);
                                               if (conrec.buildertek__Simultaneous_Tasks__c != null){
                                                   contactSimulateMap.put(conrec.id, conrec.buildertek__Simultaneous_Tasks__c);
                                               }
                                           }
                                       }
                                   }else{
                                       if (conrec.AccountId != null){
                                           contactAccountMap.put(conrec.id, conrec.AccountId);
                                           if (conrec.buildertek__Simultaneous_Tasks__c != null){
                                               contactSimulateMap.put(conrec.id, conrec.buildertek__Simultaneous_Tasks__c);
                                           }
                                       }
                                   }

                               }
        for (Account accrec : [Select id, Name, buildertek__Trade_Type_Lookup__c, buildertek__Simultaneous_Tasks__c, buildertek__Trade_Type_Lookup__r.Name
                               from account
                               where id in :contactAccountMap.values() ]){
                                   if (accrec.buildertek__Trade_Type_Lookup__c != null){
                                       tradeTypenamemap.put(accrec.id, accrec.buildertek__Trade_Type_Lookup__r.Name);
                                   }
                               }


        string contactQuery = 'Select id,Name,Account.Name,AccountId,buildertek__Simultaneous_Tasks__c From Contact Where ';
        contactQuery += ' id != null ';
        if (slectedTradetypeId != null && slectedTradetypeId != ''){
            contactQuery += ' AND Account.buildertek__Trade_Type_Lookup__c=: slectedTradetypeId';
        }
        if(resourceSearch != null && resourceSearch != ''){
            contactQuery += ' AND (Name LIKE: resourceSearchVal) ';
            contactQuery += ' and (id IN: conid)';
        }else{
            contactQuery += ' AND id IN: conid';
        }

        contactQuery += ' order by Name asc';
        system.debug('--contactQuery---' + contactQuery);
        conresource = Database.query(contactQuery);

        for (buildertek__Project_Task__c scitem : schudleitemList){
            system.debug(fromDate+','+ toDate+','+scitem.buildertek__Start__c+','+scitem.buildertek__Finish__c);
            if (!scheduleitemmap.containsKey(scitem.buildertek__Contractor_Resource__c)){
                scheduleitemmap.put(scitem.buildertek__Contractor_Resource__c, new List<buildertek__Project_Task__c>());
            }
            scheduleitemmap.get(scitem.buildertek__Contractor_Resource__c).add(scitem);

            if(scitem.buildertek__Resource__c != scitem.buildertek__Contractor_Resource__c && scitem.buildertek__Resource__c!= null){
                if(!scheduleitemmap.containsKey(scitem.buildertek__Resource__c)){
                    scheduleitemmap.put(scitem.buildertek__Resource__c, new List<buildertek__Project_Task__c>());
                }
                scheduleitemmap.get(scitem.buildertek__Resource__c).add(scitem);
            }
            if (scitem.buildertek__Contractor_Resource__c != null){
                contactnamemap.put(scitem.buildertek__Contractor_Resource__c, scitem.buildertek__Contractor_Resource__r.Name);
            }
            if(scitem.buildertek__Resource__c != scitem.buildertek__Contractor_Resource__c && scitem.buildertek__Resource__c != null){
                contactnamemap.put(scitem.buildertek__Resource__c, scitem.buildertek__Resource__r.Name);
            }
        }


        Map<String,List<ResourceCalendarWrap>> accountResourceLinkList = new Map<String,List<ResourceCalendarWrap>>();
        Map<String,List<ResourceCalendarWrap.ProjectTaskRecords>> projectTaskLinkMap = new Map<String,List<ResourceCalendarWrap.ProjectTaskRecords>>();
        //Map<Id,List<NewResourceDashboardCalendarWrap.ProjectTaskRecords>> contactTaskMap = new Map<Id,List<NewResourceDashboardCalendarWrap.ProjectTaskRecords>>();
        Map<Id,List<ResourceCalendarWrap.ProjectTaskRecords>> contactTaskMap = new Map<Id,List<ResourceCalendarWrap.ProjectTaskRecords>>();
        list<ResourceCalendarWrap> RecordList = new list<ResourceCalendarWrap>();
        Map<Id,List<String>> contactTaskIdMap = new Map<Id,List<String>>();
        Map<Id,ResourceCalendarWrap.ProjectTaskRecords> taskMap = new Map<Id,ResourceCalendarWrap.ProjectTaskRecords>();
        if(schudleitemList.Size() > 0){
            list<ResourceCalendarWrap.ProjectTaskRecords> EquipmentRecordList = new list<ResourceCalendarWrap.ProjectTaskRecords>();

            for (buildertek__Project_Task__c pse : schudleitemList){
                ResourceCalendarWrap.ProjectTaskRecords EquipmentRec = new ResourceCalendarWrap.ProjectTaskRecords();
                Datetime dt = (DateTime)pse.buildertek__Start__c;
                String dayOfWeek = dt.format('yyyy-MM-dd');
                EquipmentRec.title = pse.Name;
                EquipmentRec.startString = '';
                EquipmentRec.endString = '';
                string s = string.valueOfGmt(pse.buildertek__Start__c);
                String strDate = s.split(' ')[0];
                String sMonth = String.valueof(pse.buildertek__Start__c.month());
                system.debug('sMonth***'+sMonth);
                String sDay = String.valueof(pse.buildertek__Start__c.day());
                system.debug('sDay***'+sDay);
                if (sMonth.length() == 1){
                    sMonth = '0' + sMonth;
                }
                if (sDay.length() == 1){
                    sDay = '0' + sDay;
                }
                string ndate = sMonth + '/' + sDay + '/' + String.valueof(pse.buildertek__Start__c.year());
                if (pse.buildertek__Finish__c != null){
                    string FinishDate = string.valueOfGmt(pse.buildertek__Finish__c);
                    String FinishDatestrDate = FinishDate.split(' ')[0];
                    String FinishDatesMonth = String.valueof(pse.buildertek__Finish__c.month());
                    String FinishDatesDay = String.valueof(pse.buildertek__Finish__c.day());
                    if (FinishDatesMonth.length() == 1){
                        FinishDatesMonth = '0' + FinishDatesMonth;
                    }
                    if (FinishDatesDay.length() == 1){
                        FinishDatesDay = '0' + FinishDatesDay;
                    }
                    string FinishDatendate = FinishDatesMonth + '/' + FinishDatesDay + '/' + String.valueof(pse.buildertek__Finish__c.year());
                    string ndate1 = String.valueof(pse.buildertek__Start__c.year())+'-' + sMonth + '-' + sDay;
                    Datetime dt1 = DateTime.newInstance(date.valueOf(ndate1), Time.newInstance(0, 0, 0, 0));
                    String dateStr = dt1.format('EEEE');
                    EquipmentRec.weekName = dateStr;
                    system.debug('--dateStr--->' + dateStr);
                    //system.debug('--dayOfWeek--->'+dayOfWeek);

                    system.debug('--ndate--->' + ndate1);
                    EquipmentRec.day = ndate;
                    EquipmentRec.endday = FinishDatendate;
                    EquipmentRec.projectId = pse.buildertek__Schedule__r.buildertek__Project__r.Name;
                    EquipmentRec.contractresourceId = pse.buildertek__Contractor_Resource__r.Name;
                    //EquipmentRec.internalresourceId = pse.buildertek__Resource__r.Name;
                    EquipmentRec.Id = pse.id;
                    EquipmentRec.taskdescription = pse.Name;
                    EquipmentRec.taskdays = integer.valueof(pse.buildertek__Duration__c);
                    EquipmentRec.Completion = integer.valueof(pse.buildertek__Completion__c);
                    EquipmentRec.startdate = pse.buildertek__Start__c;
                    EquipmentRec.enddate = pse.buildertek__Finish__c;
                    EquipmentRec.Eid = pse.buildertek__Schedule__c;
                    EquipmentRec.Model = pse.buildertek__Schedule__r.Name;
                    EquipmentRec.UnitId = pse.buildertek__Resource__r.Name;
                    EquipmentRecordList.add(EquipmentRec);
                    taskMap.put(pse.id,EquipmentRec);
                    if(projectTaskLinkMap.get(pse.buildertek__Schedule__r.buildertek__Project__c) != null){
                        list<ResourceCalendarWrap.ProjectTaskRecords> calendarList = projectTaskLinkMap.get(pse.buildertek__Schedule__r.buildertek__Project__c);
                        calendarList.add(EquipmentRec);
                        projectTaskLinkMap.put(pse.buildertek__Schedule__r.buildertek__Project__c,calendarList);

                    }else{
                        list<ResourceCalendarWrap.ProjectTaskRecords> calendarList = new list<ResourceCalendarWrap.ProjectTaskRecords>();
                        calendarList.add(EquipmentRec);
                        projectTaskLinkMap.put(pse.buildertek__Schedule__r.buildertek__Project__c,calendarList);
                    }

                    if(contactTaskMap.get(pse.buildertek__Contractor_Resource__c) != null && pse.buildertek__Contractor_Resource__c != null){
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = contactTaskMap.get(pse.buildertek__Contractor_Resource__c);
                        tasksList.add(EquipmentRec);
                        contactTaskMap.put(pse.buildertek__Contractor_Resource__c,tasksList);
                        List<String> idsList = contactTaskIdMap.get(pse.buildertek__Contractor_Resource__c);
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Contractor_Resource__c, idsList);
                    }else if(pse.buildertek__Contractor_Resource__c != null){
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = new list<ResourceCalendarWrap.ProjectTaskRecords>();
                        tasksList.add(EquipmentRec);
                        contactTaskMap.put(pse.buildertek__Contractor_Resource__c,tasksList);
                        List<String> idsList = new List<String>();
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Contractor_Resource__c, idsList);
                    }
                    if(contactTaskMap.get(pse.buildertek__Resource__c) != null && pse.buildertek__Resource__c != null && pse.buildertek__Resource__c != pse.buildertek__Contractor_Resource__c){
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = contactTaskMap.get(pse.buildertek__Resource__c);
                        tasksList.add(EquipmentRec);
                        contactTaskMap.put(pse.buildertek__Resource__c,tasksList);
                        List<String> idsList = contactTaskIdMap.get(pse.buildertek__Resource__c);
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Resource__c, idsList);
                    }else if(pse.buildertek__Resource__c != null && pse.buildertek__Resource__c != pse.buildertek__Contractor_Resource__c){
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = new list<ResourceCalendarWrap.ProjectTaskRecords>();
                        tasksList.add(EquipmentRec);
                        contactTaskMap.put(pse.buildertek__Resource__c,tasksList);
                        List<String> idsList = new List<String>();
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Resource__c, idsList);
                    }
                }
            }

        }

        List<String> resourceTaskList = new List<String>();

        for (contact con : conresource){
            if (contactnamemap.get(con.id) != null){
                ResourceCalendarWrap projectRec = new ResourceCalendarWrap();
                // list<ResourceCalendarWrap.ProjectTaskRecordsList> SchedulertaskRecordList = new list<ResourceCalendarWrap.ProjectTaskRecordsList>();

                projectRec.ContractresourceId = con.id;

                projectRec.ContractresourceName = contactnamemap.get(con.Id);
                if(contactnamemap.get(con.Id) !=null && contactnamemap.get(con.Id) !=''){
                    projectRec.FirstLetterofContractresourceName = contactnamemap.get(con.Id).toUpperCase().substring(0,1);
                }
                //projectRec.simultaneousTasksContractor = cona;
                if (contactSimulateMap.containsKey(con.Id)){
                    projectRec.simultaneousTasksContractorResources = contactSimulateMap.get(con.Id);
                }
                if (scheduleitemmap.get(con.id) != null){
                    projectRec.tasks = string.valueof(scheduleitemmap.get(con.id).size());
                }
                if (contactAccountMap.get(con.id) != null){
                    system.debug(tradeTypenamemap.get(contactAccountMap.get(con.id)));
                    projectRec.TradeType = tradeTypenamemap.get(contactAccountMap.get(con.id));
                    if(tradeTypenamemap.get(contactAccountMap.get(con.id))!=null){
                        system.debug((projectRec.TradeType.toLowerCase()).contains(alltypeSearch.toLowerCase()));
                    }

                }
                projectRec.Companyname = con.Account.Name;
                System.debug(projectRec.ContractresourceId);

                //get selected resources tasks
                if(slectedcontactId != '' && slectedcontactId != null){
                    System.debug(projectRec.ContractresourceId);
                    if(con.Id == slectedcontactId){
                        System.debug(projectRec.ContractresourceId);
                       projectRec.ProjectTaskRecordsList = contactTaskMap.get(con.Id);
                    }
                }else{
                    System.debug(projectRec.ContractresourceId);
                    projectRec.ProjectTaskRecordsList = contactTaskMap.get(con.Id);
                   // resourceTaskList.addAll(contactTaskIdMap.get(con.Id));
                }

                if(alltypeSearch != '' && alltypeSearch != null){
                    system.debug(alltypeSearch);
                    system.debug((projectRec.ContractresourceName.toLowerCase()));
                    system.debug((projectRec.ContractresourceName.toLowerCase()).contains(alltypeSearch.toLowerCase()));

                    if((projectRec.ContractresourceName.toLowerCase()).contains(alltypeSearch.toLowerCase()) || (projectRec.Companyname != null  && (projectRec.Companyname.toLowerCase()).contains(alltypeSearch.toLowerCase()))
                       || (projectRec.TradeType != null && (projectRec.TradeType.toLowerCase()).contains(alltypeSearch.toLowerCase()))){
                        system.debug(alltypeSearch);
                        resourceTaskList.addAll(contactTaskIdMap.get(con.Id));
                        RecordList.add(projectRec);
                    }
                }else{
                    system.debug(alltypeSearch);
                    RecordList.add(projectRec);
                }


            }

        }

        system.debug(projectTaskLinkMap);

        //List<buildertek__Project_Task__c> projectAlltypeFilterTask = new List<buildertek__Project_Task__c>();
        Map<String,List<ResourceCalendarWrap.ProjectTaskRecords>> projectAlltypeFilterTask = new Map<String,List<ResourceCalendarWrap.ProjectTaskRecords>>();
        if(resourceTaskList.size() > 0){
            for(buildertek__Project_Task__c task : schudleitemList){
                if(resourceTaskList.indexOf(task.id) > -1){
                    if(projectAlltypeFilterTask.get(task.buildertek__Schedule__r.buildertek__Project__c) != null){
                        list<ResourceCalendarWrap.ProjectTaskRecords> calendarList = projectAlltypeFilterTask.get(task.buildertek__Schedule__r.buildertek__Project__c);
                        calendarList.add(taskMap.get(task.id));
                        projectAlltypeFilterTask.put(task.buildertek__Schedule__r.buildertek__Project__c,calendarList);

                    }else{
                        list<ResourceCalendarWrap.ProjectTaskRecords> calendarList = new list<ResourceCalendarWrap.ProjectTaskRecords>();
                        calendarList.add(taskMap.get(task.id));
                        projectAlltypeFilterTask.put(task.buildertek__Schedule__r.buildertek__Project__c,calendarList);
                    }
                }

            }
        }


        system.debug(resourceTaskList);
        system.debug(projectAlltypeFilterTask.keyset());
        system.debug(projectAlltypeFilterTask.Size());

        system.debug(projectRecordList);
        List<projectResourceWrapperClone> projResWrapList = new List<projectResourceWrapperClone>();
        Set<String> projeRecSet = new Set<String>();
        for(buildertek__Project__c proj : projectRecordList){
            projectResourceWrapperClone projRec = new projectResourceWrapperClone();
            system.debug(proj.buildertek__Customer__c);
            system.debug(proj.Name);

                system.debug(projRec);

            if(alltypeSearch != '' && alltypeSearch != null && resourceSearch != '' && resourceSearch !=null){
                if(projectAlltypeFilterTask.keyset().Size() > 0){
                    if(projectAlltypeFilterTask.keyset().contains(proj.Id)){
                        projRec.CalendarWrapList = projectAlltypeFilterTask.get(proj.Id);
                        projRec.projectRecAccName = proj.buildertek__Customer__r.Name;
                        projRec.projectRecAccId = proj.buildertek__Customer__c;
                        projRec.projectRecName = proj.Name;
                        projRec.projectRecId = proj.Id;
                        projeRecSet.add(proj.Id);
                        projResWrapList.add(projRec);
                        system.debug(projRec);
                    }

                }
            }else{
                projRec.CalendarWrapList = projectTaskLinkMap.get(proj.Id);
                projRec.projectRecAccName = proj.buildertek__Customer__r.Name;
                projRec.projectRecAccId = proj.buildertek__Customer__c;
                projRec.projectRecName = proj.Name;
                projRec.projectRecId = proj.Id;
                projeRecSet.add(proj.Id);
                projResWrapList.add(projRec);
                system.debug(projRec);
            }


        }

        system.debug('projResWrapList---->'+projResWrapList);
        combinedProjectCalendarWrapperClone combinedWrapper = new combinedProjectCalendarWrapperClone();
        combinedWrapper.projectList = projResWrapList;
        combinedWrapper.calendarTaskList = RecordList;
        return combinedWrapper;
    }

    public class Wrapper{
        @AuraEnabled
        public string recordId{ get; set; }

        @AuraEnabled
        public string Name{ get; set; }

        @AuraEnabled
        public String Tasks{ get; set; }

        @AuraEnabled
        public String TradeType{ get; set; }
    }

    public class projectResourceWrapper{
        @AuraEnabled
        public String projectRecName{get; set;}

        @AuraEnabled
        public String projectRecId{get; set;}

        @AuraEnabled
        public String projectRecAccName{get; set;}

        @AuraEnabled
        public String projectRecAccId{get; set;}

        @AuraEnabled
        public List<ResourceCalendarWrap> CalendarWrapList {get; set;}
    }

    public class projectResourceWrapperClone{
        @AuraEnabled
        public String projectRecName{get; set;}

        @AuraEnabled
        public String projectRecId{get; set;}

        @AuraEnabled
        public String projectRecAccName{get; set;}

        @AuraEnabled
        public String projectRecAccId{get; set;}

        @AuraEnabled
        public List<ResourceCalendarWrap.ProjectTaskRecords> CalendarWrapList {get; set;}
    }

    public class combinedProjectCalendarWrapper{
        @AuraEnabled
        public List<projectResourceWrapper> projectList {get; set;}

        @AuraEnabled
        public List<ResourceCalendarWrap> calendarTaskList {get; set;}
    }

    public class combinedProjectCalendarWrapperClone{
        @AuraEnabled
        public List<projectResourceWrapperClone> projectList {get; set;}

        @AuraEnabled
        public List<ResourceCalendarWrap> calendarTaskList {get; set;}
    }
}