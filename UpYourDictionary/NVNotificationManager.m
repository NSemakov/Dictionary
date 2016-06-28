//
//  NVNotificationManager.m
//  UpYourDictionary
//
//  Created by Admin on 24/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVNotificationManager.h"

@implementation NVNotificationManager
+(NVNotificationManager*) sharedManager{
    static NVNotificationManager* manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[NVNotificationManager alloc]init];
    });
    return manager;
}
-(void) addNewNotificationToFullSet{

[self.managedObjectContext performBlock:^{
    NSInteger notifyLeft = [[UIApplication sharedApplication].scheduledLocalNotifications count];
    NSDate* lastNofityFireDate = [[UIApplication sharedApplication].scheduledLocalNotifications lastObject].fireDate;
    NSInteger settingsWords = [[NSUserDefaults standardUserDefaults] integerForKey:NVNumberOfWordsToShow];
    NSInteger numberOfNotifies = (int) (settingsWords/wordsInOneNotify) + (((settingsWords % wordsInOneNotify)>0) ? 1:0);  //кол-во нотификаций
    NSInteger timeToPush = [[NSUserDefaults standardUserDefaults] integerForKey:NVTimeToPush];
    if (timeToPush == 0) {
        timeToPush = 2;}
    [self createNotificationInCycleTimeToPush:timeToPush numberOfNotifies:numberOfNotifies settingsWords:settingsWords prevDate:lastNofityFireDate maxIter:62-notifyLeft];
}];
}
-(void) refreshProgressOfDictionaryWithCallback:(void(^)(void))callback {
    [self.managedObjectContext performBlock:^{
        //прогресс из первой нотификации устанавливаем в текущий прогресс словаря при заходе в приложение.
        /* Есть 2 варианта: еще есть нотификации в списке, тогда их проверяем. Нет нотификаций. Это возможно либо если не было интернета, чтобы загрузить следующие, либо конец словаря.
         
         */
        BOOL flagFirstOptionIsOK = NO;
        UIApplication* app =[UIApplication sharedApplication];
        NSArray* arrayOfScheduledNotification = [app scheduledLocalNotifications];
        NSInteger initialCount = [arrayOfScheduledNotification count];
        if (initialCount > 0) {
            UILocalNotification* firstNotify = [arrayOfScheduledNotification firstObject];
            NSDate* firstNotifyFireDate = firstNotify.fireDate;
            NVNotifyInUse* notifyInUse = [self fetchedNotifyWithDate:firstNotifyFireDate];

            if (notifyInUse) {
                [NVMainStrategy sharedManager].activeDict.progress = notifyInUse.progressOfDict;
                NSError* error = nil;
                [self.managedObjectContext save:&error];
                if (error) {
                    NSLog(@"error refreshProgress: %@, userInfo: %@",error.localizedDescription,error.userInfo);
                } else {
                    flagFirstOptionIsOK = YES;
                }
            } else {
                [self.managedObjectContext rollback];
            }
        }
        
        if (!flagFirstOptionIsOK) {//2й вариант, т.к. первый не сработал.
            if (! [NVMainStrategy sharedManager].activeDict && [NVMainStrategy sharedManager].activeDictByUser) {
                [NVMainStrategy sharedManager].activeDictByUser.progress = @(100);
            }
        }
    }];
    if (callback) {
        callback();
    }
}
-(void) cancelNotificationsCompleteWayWithCallback:(void(^)(void)) callback{
    [self.managedObjectContext performBlock:^{
    //отмена нотификаций, а также откат алгоритма
    UIApplication* app =[UIApplication sharedApplication];
    NSArray* arrayOfScheduledNotification = [app scheduledLocalNotifications];
    NSInteger initialCount = [arrayOfScheduledNotification count];
        /*отдельно включаем активность словаря, если он был в нотификациях выключен по окончании*/
        UILocalNotification* lastNotify = [arrayOfScheduledNotification firstObject];
        NSDate* lastNotifyFireDate = lastNotify.fireDate;
        NVNotifyInUse* notifyInUse = [self fetchedNotifyWithDate:lastNotifyFireDate];
        NVContent* content = [notifyInUse.content anyObject];
        content.dict.isActiveProgram = @(YES);
        /**/
    for (NSInteger i = initialCount; i>0; i--) {
        UILocalNotification* lastNotify = [arrayOfScheduledNotification objectAtIndex:i-1];
        NSDate* lastNotifyFireDate = lastNotify.fireDate;

        NVNotifyInUse* notifyInUse = [self fetchedNotifyWithDate:lastNotifyFireDate];
        
        for (NVContent* content in notifyInUse.content) {//отменяем каждое слово в нотификации
            //NSLog(@"content to cancel: %@, counter before: %@, fireDate:%@",content.word,content.counter,notifyInUse.fireDate);
            content.counter = @([content.counter integerValue]-1);
            if ([content.counter isEqual:@(0)]) {//если счетчик стал 0, значит удаляем из активной таблицы
                [self.managedObjectContext deleteObject:content];
            } else {
                //просто сохраняем с уменьшенным счетчиком
            }
        }
        if (notifyInUse) {
            [self.managedObjectContext deleteObject:notifyInUse];
        }
        
        NSError* error = nil;
        [self.managedObjectContext save:&error];
        //[app cancelLocalNotification:lastNotify];
        NSLog(@"cancelled %ld",(long)i);
    }
    [app cancelAllLocalNotifications];
    NSArray* arrayOfLeftNotifies = [self fetchedAllNotifies];
    for (NVNotifyInUse* notify in arrayOfLeftNotifies) {
        [self.managedObjectContext deleteObject:notify];
    }
    NSError* error = nil;
        if ([self.managedObjectContext save:&error]){
            if (callback) {
                callback();
            }
        }
    }];
}

-(void) generateNewNotificationsWithCallback:(void(^)(void))callback{

    [self.managedObjectContext performBlock:^{
        //cancel all notifications
        [self cancelNotificationsCompleteWayWithCallback:^{
            NSInteger settingsWords = [[NSUserDefaults standardUserDefaults] integerForKey:NVNumberOfWordsToShow];
            if (settingsWords == 0) {
                settingsWords = 2;}
            NSInteger numberOfNotifies = (int) (settingsWords/wordsInOneNotify) + (((settingsWords % wordsInOneNotify)>0) ? 1:0);  //кол-во нотификаций
            NSInteger timeToPush = [[NSUserDefaults standardUserDefaults] integerForKey:NVTimeToPush];
            if (timeToPush == 0) {
                timeToPush = 2;}
            /*------*/
            NSDate* prevDate = [NSDate date];
            
            /*form first notification after 300 sec*/
            for (NSInteger j=1; j<=numberOfNotifies; j++) {//формируем пачку нотификаций, если в одну не помещается
                NSInteger x = settingsWords-(j-1)*wordsInOneNotify;
                NSInteger n = (x>wordsInOneNotify)? wordsInOneNotify : x;
                //формируем конкретную нотификацию в зависимости от кол-ва слов.
                [self startFireAlertAtDate:[NSDate dateWithTimeInterval:300 sinceDate:prevDate] numberOfWords:n iteration:j];
            }
            /*-----end of form first notification after 300 sec*/
            [self createNotificationInCycleTimeToPush:timeToPush numberOfNotifies:numberOfNotifies settingsWords:settingsWords prevDate:prevDate maxIter:62];

            if (callback) {
                callback();
            }
        }];
   }];
}
- (void) createNotificationInCycleTimeToPush:(NSInteger) timeToPush numberOfNotifies:(NSInteger) numberOfNotifies settingsWords:(NSInteger) settingsWords prevDate:(NSDate*) prevDate maxIter:(NSInteger) maxIter{
    NSInteger i = 0;
    while (i<maxIter) {
        NSDate* fireDate = [NSDate dateWithTimeInterval:timeToPush*60*60 sinceDate:prevDate];
        NSLog(@"start date: %@",fireDate);
        NSCalendar *theCalendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [theCalendar components:NSCalendarUnitHour fromDate:fireDate];
        NSInteger newHour = components.hour;
        if (newHour < 6) {
            NSDateComponents* componentsForModify = [theCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond  fromDate:fireDate];
            componentsForModify.hour = 6;
            fireDate = [theCalendar dateFromComponents:componentsForModify];
        } else if (newHour > 23) {
            NSDateComponents* componentsForModify = [theCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth| NSCalendarUnitDay| NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond  fromDate:fireDate];
            componentsForModify.day ++;
            componentsForModify.hour = 6;
            fireDate = [theCalendar dateFromComponents:componentsForModify];
        } else {
            //usual work
        }
        NSLog(@"end date: %@",fireDate);
        
        for (NSInteger j=1; j<=numberOfNotifies; j++) {//формируем пачку нотификаций, если в одну не помещается
            NSInteger x = settingsWords-(j-1)*wordsInOneNotify;
            NSInteger n = (x>wordsInOneNotify)? wordsInOneNotify : x;
            //формируем конкретную нотификацию в зависимости от кол-ва слов.
            [self startFireAlertAtDate:fireDate numberOfWords:n iteration:j];
        }
        if (self.delegateToRefresh) {
            [self.delegateToRefresh refreshProgressBar];
        }
        prevDate = fireDate;
        i=i+numberOfNotifies;
    }
}

-(void) putUserInfoInCoreData:(NSSet*) userInfoSet onFireDate:(NSDate*) fireDate{

    NVNotifyInUse* newNotify= [NSEntityDescription insertNewObjectForEntityForName:@"NVNotifyInUse" inManagedObjectContext:self.managedObjectContext];
    newNotify.fireDate = fireDate;
    newNotify.progressOfDict = @([[NVMainStrategy sharedManager] countProgressOfDictionary]);
    [newNotify addContent:userInfoSet];
    NSError* error = nil;
    [self.managedObjectContext save:&error];
    if (!error) {
        //_fetchedWordsAllowedToShow = resultArray;
    } else {
        NSLog(@"error putUserInfoInCoreData: %@, local description: %@",error.userInfo, error.localizedDescription);
    
    }
}
-(void) startFireAlertAtDate:(NSDate*) fireDate numberOfWords:(NSInteger)numberWords iteration:(NSInteger) iteration{
    if ([[NVServerManager sharedManager] isNetworkAvailable]){
        
    NSDateComponents *secComponent = [[NSDateComponents alloc] init];
    secComponent.second = iteration;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    fireDate = [theCalendar dateByAddingComponents:secComponent toDate:fireDate options:0];
    //fireDate= [NSDate dateWithTimeIntervalSinceNow:iteration];//нотификации в пачке друг за другом идут, с периодом 1с
    NSString* stringToShow=@"";
    NSMutableSet* userInfoSet = [NSMutableSet new];
    for (NSInteger m = 1 ; m<=numberWords; m++){
        
        NVContent* contentToShow = [[NVMainStrategy sharedManager] algoResultHandler];
        if (!contentToShow) { //не работаем без активного словаря
            return;
        }
        //NSLog(@"word:%@     translation:%@",contentToShow.word,contentToShow.translation);
        NSString* stringToShowTemp = [NSString stringWithFormat:@" %@ - %@;",contentToShow.word,contentToShow.translation];
        stringToShow = [stringToShow stringByAppendingString:stringToShowTemp];
        [userInfoSet addObject:contentToShow];//несколько словарей в нотификации, т.к. несколько слов
        //save to user defaults temp userInfo
        

    }
    if ([userInfoSet count]) {//если есть объекты, то работаем
        [self putUserInfoInCoreData:userInfoSet onFireDate:fireDate];
        
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = fireDate ; //Enter the time here in seconds.
        localNotification.alertBody= stringToShow;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.repeatInterval= 0; //Repeating instructions here.
        localNotification.soundName= UILocalNotificationDefaultSoundName;
        localNotification.userInfo = nil;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        NSLog(@"from nvnotman. localNot body:%@",localNotification.alertBody);
    }
    }
}

-(NVNotifyInUse*) fetchedNotifyWithDate:(NSDate*) fireDate
{
    NSManagedObjectContext* moc = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVNotifyInUse" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setRelationshipKeyPathsForPrefetching:@[@"content",@"counter"]];
    // Set the batch size to a suitable number.
    //[fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fireDate" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    //NSManagedObjectID *moID=[self.person objectID];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"fireDate =%@ ",fireDate];
    [fetchRequest setPredicate:predicate];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSError* error = nil;
    NSArray* resultArray= [moc executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        //_fetchedWordsAllowedToShow = resultArray;
        return [resultArray firstObject];
    } else {
        NSLog(@"error fetchedNotifyWithDate: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
}
-(NSArray*) fetchedAllNotifies
{
    NSManagedObjectContext* moc = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVNotifyInUse" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    //[fetchRequest setRelationshipKeyPathsForPrefetching:@[@"NVTemplates",@"NVContent"]];
    // Set the batch size to a suitable number.
    //[fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fireDate" ascending:YES];
    //NSArray *sortDescriptors = @[sortDescriptor];
    
    //[fetchRequest setSortDescriptors:sortDescriptors];
    //NSManagedObjectID *moID=[self.person objectID];
    //NSPredicate* predicate=[NSPredicate predicateWithFormat:@"fireDate =%@ ",fireDate];
    //[fetchRequest setPredicate:predicate];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSError* error = nil;
    NSArray* resultArray= [moc executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        return resultArray;
    } else {
        NSLog(@"error fetchedAllNotifies: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
}
- (NSManagedObjectContext*) managedObjectContext{
    if (!_managedObjectContext) {
        _managedObjectContext=[[NVDataManager sharedManager] privateManagedObjectContext];
    }
    return _managedObjectContext;
}
/*
-(NVContent*) fetchedContentWithContent:(NVContent*) contentToFind
{
    NSManagedObjectContext* moc = [[NVDataManager sharedManager] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVContent" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    //[fetchRequest setRelationshipKeyPathsForPrefetching:@[@"NVTemplates",@"NVContent"]];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"counter" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    //NSManagedObjectID *moID=[self.person objectID];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"dict =%@ AND word=%@ AND translation=%@",contentToFind.dict, contentToFind.word,contentToFind.translation];
    [fetchRequest setPredicate:predicate];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSError* error = nil;
    NSArray* resultArray= [moc executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        //_fetchedWordsAllowedToShow = resultArray;
        return [resultArray firstObject];
    } else {
        NSLog(@"error: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
}*/

/*-(void) generateNewNotifications{
 
 //create local notifications in background
 dispatch_queue_t queue = dispatch_queue_create("com.UpYourDictionary.multithreading.queue", DISPATCH_QUEUE_CONCURRENT);
 dispatch_async(queue, ^{
 //cancel all notifications
 [self cancelNotificationsCompleteWay];
 
 NSInteger timeToPush = [[NSUserDefaults standardUserDefaults] integerForKey:NVTimeToPush];
 if (timeToPush == 0) {
 timeToPush = 2;}
 for (NSInteger i = 0; i<62; i++) {
 //интервал из настроек и перевод его из часов в секунды
 NSDate* fireDate= [NSDate dateWithTimeIntervalSinceNow:20+i*timeToPush*60*60];
 [self startFireAlertAtDate:fireDate];
 }
 });
 }*/

/*-(void) startFireAlertAtDate:(NSDate*) fireDate{
 old version of function. not in use
 //take settings like number of words, frequency in hours
 NSTimeInterval interval;
 //interval = 60;//12 hours from now
 NVContent* contentToShow = [[NVMainStrategy sharedManager] algoResultHandler];
 if (!contentToShow) { //не работаем без активного словаря
 return;
 }
 
 NSString* stringToShow = [NSString stringWithFormat:@"%@ - %@",contentToShow.word,contentToShow.translation];
 UILocalNotification* localNotification = [[UILocalNotification alloc] init];
 localNotification.fireDate = fireDate ; //Enter the time here in seconds.
 localNotification.alertBody= stringToShow;
 localNotification.timeZone = [NSTimeZone defaultTimeZone];
 localNotification.repeatInterval= 0; //Repeating instructions here.
 localNotification.soundName= UILocalNotificationDefaultSoundName;
 localNotification.userInfo =[NSDictionary dictionaryWithObjectsAndKeys:contentToShow,@"contentToShow", nil];
 [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
 }
 
 
 -(void) addNewNotificationToFullSet{
 
 [self.managedObjectContext performBlock:^{
 NSInteger notifyLeft = [[UIApplication sharedApplication].scheduledLocalNotifications count];
 NSDate* lastNofityFireDate = [[UIApplication sharedApplication].scheduledLocalNotifications lastObject].fireDate;
 NSInteger settingsWords = [[NSUserDefaults standardUserDefaults] integerForKey:NVNumberOfWordsToShow];
 NSInteger numberOfNotifies = (int) (settingsWords/wordsInOneNotify) + (((settingsWords % wordsInOneNotify)>0) ? 1:0);  //кол-во нотификаций
 NSInteger timeToPush = [[NSUserDefaults standardUserDefaults] integerForKey:NVTimeToPush];
 if (timeToPush == 0) {
 timeToPush = 2;}
 [self createNotificationInCycleTimeToPush:timeToPush numberOfNotifies:numberOfNotifies settingsWords:settingsWords prevDate:lastNofityFireDate maxIter:62-notifyLeft];
 for (NSInteger i = 0; i<62-notifyLeft; i=i+numberOfNotifies) {//max 64 нотификации. с запасом - 62.
 for (NSInteger j=1; j<=numberOfNotifies; j++) {//формируем пачку нотификаций, если в одну не помещается
 NSInteger x = settingsWords-(j-1)*wordsInOneNotify;
 NSInteger n = (x>wordsInOneNotify)? wordsInOneNotify : x;
 //формируем конкретную нотификацию в зависимости от кол-ва слов.
 //NSDate* fireDate= [NSDate dateWithTimeIntervalSinceNow:20+i*timeToPush*60*60];
 NSDateComponents *hourComponent = [[NSDateComponents alloc] init];
 hourComponent.hour = i*timeToPush;
 
 NSCalendar *theCalendar = [NSCalendar currentCalendar];
 NSDate *fireDate = [theCalendar dateByAddingComponents:hourComponent toDate:lastNofityFireDate options:0];
 [self startFireAlertAtDate:fireDate numberOfWords:n iteration:j];
 }
 //интервал из настроек и перевод его из часов в секунды
 }
}];
}
 */
/*
 -(void) generateNewNotificationsWithCallback:(void(^)(void))callback{
 
 [self.managedObjectContext performBlock:^{
 //cancel all notifications
 [self cancelNotificationsCompleteWayWithCallback:^{
 NSInteger settingsWords = [[NSUserDefaults standardUserDefaults] integerForKey:NVNumberOfWordsToShow];
 if (settingsWords == 0) {
 settingsWords = 2;}
 NSInteger numberOfNotifies = (int) (settingsWords/wordsInOneNotify) + (((settingsWords % wordsInOneNotify)>0) ? 1:0);  //кол-во нотификаций
 NSInteger timeToPush = [[NSUserDefaults standardUserDefaults] integerForKey:NVTimeToPush];
 if (timeToPush == 0) {
 timeToPush = 2;}
 
 for (NSInteger i = 0; i<62; i=i+numberOfNotifies) {
 for (NSInteger j=1; j<=numberOfNotifies; j++) {//формируем пачку нотификаций, если в одну не помещается
 NSInteger x = settingsWords-(j-1)*wordsInOneNotify;
 NSInteger n = (x>wordsInOneNotify)? wordsInOneNotify : x;
 //формируем конкретную нотификацию в зависимости от кол-ва слов.
 NSDate* fireDate = [NSDate dateWithTimeIntervalSinceNow:300+i*timeToPush*60*60];
 [self startFireAlertAtDate:fireDate numberOfWords:n iteration:j];
 
 }
 if (self.delegateToRefresh) {
 [self.delegateToRefresh refreshProgressBar];
 }
 NSLog(@"created N:%ld",i);
 }
 if (callback) {
 callback();
 }
 
 }];
 
 }];
 
 }
 */
@end
