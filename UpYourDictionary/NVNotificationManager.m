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
   //create local notifications in background

    NSInteger notifyLeft = [[UIApplication sharedApplication].scheduledLocalNotifications count];
    NSDate* lastNofityFireDate = [[UIApplication sharedApplication].scheduledLocalNotifications lastObject].fireDate;
    NSInteger settingsWords = [[NSUserDefaults standardUserDefaults] integerForKey:NVNumberOfWordsToShow];
    NSInteger numberOfNotifies = (int) (settingsWords/wordsInOneNotify) + (((settingsWords % wordsInOneNotify)>0) ? 1:0);  //кол-во нотификаций
    NSInteger timeToPush = [[NSUserDefaults standardUserDefaults] integerForKey:NVTimeToPush];
    if (timeToPush == 0) {
        timeToPush = 2;}
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

}
-(void) cancelNotificationsCompleteWay{
    //отмена нотификаций, а также откат алгоритма
    UIApplication* app =[UIApplication sharedApplication];
    NSArray* arrayOfScheduledNotification = [app scheduledLocalNotifications];
    NSInteger initialCount = [arrayOfScheduledNotification count];
    for (NSInteger i = initialCount; i>0; i--) {
        if (initialCount!= [[app scheduledLocalNotifications] count]) {
            //если в процессе отката вызвалась нотификация по времени и их стало меньше, тогда перевызовем этот метод еще раз
            [self cancelNotificationsCompleteWay];
        }
        UILocalNotification* lastNotify = [arrayOfScheduledNotification objectAtIndex:i-1];
        NSDate* lastNotifyFireDate = lastNotify.fireDate;
        //NSMutableArray* userInfoArray = ;
        NVNotifyInUse* notifyInUse = [self fetchedNotifyWithDate:lastNotifyFireDate];
        
        for (NVContent* content in notifyInUse.content) {//отменяем каждое слово в нотификации
            content.counter = @([content.counter integerValue]-1);
            if ([content.counter isEqual:@(0)]) {//если счетчик стал 0, значит удаляем из активной таблицы
                [self.managedObjectContext deleteObject:content];
            } else {
                //просто сохраняем с уменьшенным счетчиком
            }
        }
        NSError* error = nil;
        [self.managedObjectContext save:&error];
        //[app cancelLocalNotification:lastNotify];
    }
    [app cancelAllLocalNotifications];
    NSArray* arrayOfLeftNotifies = [self fetchedAllNotifies];
    for (NVNotifyInUse* notify in arrayOfLeftNotifies) {
        [self.managedObjectContext deleteObject:notify];
    }
    NSError* error = nil;
    [self.managedObjectContext save:&error];
}

-(void) generateNewNotifications{
    __weak NVNotificationManager* weakSelf = self;
    
    //create local notifications in background
    dispatch_queue_t queue = dispatch_queue_create("com.UpYourDictionary.multithreading.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        //cancel all notifications
        [weakSelf cancelNotificationsCompleteWay];
        
        NSInteger settingsWords = [[NSUserDefaults standardUserDefaults] integerForKey:NVNumberOfWordsToShow];
        if (settingsWords == 0) {
            settingsWords = 1;}
        NSInteger numberOfNotifies = (int) (settingsWords/wordsInOneNotify) + (((settingsWords % wordsInOneNotify)>0) ? 1:0);  //кол-во нотификаций
        NSInteger timeToPush = [[NSUserDefaults standardUserDefaults] integerForKey:NVTimeToPush];
        if (timeToPush == 0) {
            timeToPush = 2;}
        
        for (NSInteger i = 0; i<62; i=i+numberOfNotifies) {
            for (NSInteger j=1; j<=numberOfNotifies; j++) {//формируем пачку нотификаций, если в одну не помещается
                NSInteger x = settingsWords-(j-1)*wordsInOneNotify;
                NSInteger n = (x>wordsInOneNotify)? wordsInOneNotify : x;
                //формируем конкретную нотификацию в зависимости от кол-ва слов.
                NSDate* fireDate= [NSDate dateWithTimeIntervalSinceNow:20+i*timeToPush*60*60];
                [weakSelf startFireAlertAtDate:fireDate numberOfWords:n iteration:j];
                
            }
        }
    });
}
-(void) putUserInfoInCoreData:(NSSet*) userInfoSet onFireDate:(NSDate*) fireDate{
    /*NSMutableDictionary* userInfoDict = [NSMutableDictionary dictionaryWithObject:userInfoArray forKey:fireDate];
    NSMutableDictionary* containerDict = [[NSUserDefaults standardUserDefaults] objectForKey:NVNotifyKey];
    if (!containerDict) {//если не существует, создаем
        containerDict = [NSMutableDictionary new];
    }
    [containerDict setObject:userInfoDict forKey:fireDate];//добавляем в контейнер
    [[NSUserDefaults standardUserDefaults] setObject:containerDict forKey:NVNotifyKey];//добавляем сам контейнер*/
    NVNotifyInUse* newNotify= [NSEntityDescription insertNewObjectForEntityForName:@"NVNotifyInUse" inManagedObjectContext:self.managedObjectContext];
    newNotify.fireDate = fireDate;
    //newNotify.content = userInfoSet;
    [newNotify addContent:userInfoSet];
    NSError* error = nil;
    [self.managedObjectContext save:&error];
}
-(void) startFireAlertAtDate:(NSDate*) fireDate numberOfWords:(NSInteger)numberWords iteration:(NSInteger) iteration{
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
        NSLog(@"from nvnotman. localNot:%@ body:%@",localNotification.fireDate,localNotification.alertBody);
    }
    
    

}
-(NVNotifyInUse*) fetchedNotifyWithDate:(NSDate*) fireDate
{
    NSManagedObjectContext* moc = [[NVDataManager sharedManager] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVNotifyInUse" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    //[fetchRequest setRelationshipKeyPathsForPrefetching:@[@"NVTemplates",@"NVContent"]];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
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
        NSLog(@"error: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
}
-(NSArray*) fetchedAllNotifies
{
    NSManagedObjectContext* moc = [[NVDataManager sharedManager] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVNotifyInUse" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    //[fetchRequest setRelationshipKeyPathsForPrefetching:@[@"NVTemplates",@"NVContent"]];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
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
        //_fetchedWordsAllowedToShow = resultArray;
        return resultArray;
    } else {
        NSLog(@"error: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
}
- (NSManagedObjectContext*) managedObjectContext{
    if (!_managedObjectContext) {
        _managedObjectContext=[[NVDataManager sharedManager] managedObjectContext];
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
 */
@end
