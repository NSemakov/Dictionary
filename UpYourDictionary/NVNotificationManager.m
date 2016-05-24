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
                [self startFireAlertAtDate:fireDate numberOfWords:n];
            }
            //интервал из настроек и перевод его из часов в секунды
            
        }

}
-(void) cancelNotificationsCompleteWay{
    UIApplication* app =[UIApplication sharedApplication];
    NSArray* arrayOfScheduledNotification = [app scheduledLocalNotifications];
    NSInteger initialCount = [arrayOfScheduledNotification count];
    for (NSInteger i = [arrayOfScheduledNotification count]; i>0; i--) {
        if (initialCount!= [[app scheduledLocalNotifications] count]) {
            //если в процессе отката вызвалась нотификация по времени и их стало меньше, тогда перевызовем этот метод еще раз
            [self cancelNotificationsCompleteWay];
        }
        UILocalNotification* lastNotify = [arrayOfScheduledNotification objectAtIndex:i-1];
        NSMutableArray* userInfoArray = [lastNotify.userInfo objectForKey:@"contentToShowArray"];
        for (NVContent* content in userInfoArray) {//отменяем каждое слово в нотификации
            NSManagedObjectContext* moc = [[NVDataManager sharedManager] managedObjectContext];
            NVContent* dbContent = [self fetchedContentWithContent:content];
            dbContent.counter = @([dbContent.counter integerValue]-1);
            if ([dbContent.counter isEqual:@(0)]) {//если счетчик стал 0, значит удаляем из активной таблицы
                [moc deleteObject:dbContent];
            } else {
                //просто сохраняем с уменьшенным счетчиком
            }
            NSError* error = nil;
            [moc save:&error];

        }

        [app cancelLocalNotification:lastNotify];
    }
    
}

-(void) generateNewNotifications{
    __weak NVNotificationManager* weakSelf = self;
    //create local notifications in background
    dispatch_queue_t queue = dispatch_queue_create("com.UpYourDictionary.multithreading.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        //cancel all notifications
        [weakSelf cancelNotificationsCompleteWay];
        NSInteger settingsWords = [[NSUserDefaults standardUserDefaults] integerForKey:NVNumberOfWordsToShow];
        NSInteger numberOfNotifies = (int) (settingsWords/wordsInOneNotify) + (((settingsWords % wordsInOneNotify)>0) ? 1:0);  //кол-во нотификаций
        NSInteger timeToPush = [[NSUserDefaults standardUserDefaults] integerForKey:NVTimeToPush];
        if (timeToPush == 0) {
            timeToPush = 2;}
        for (NSInteger i = 0; i<62; i=i+numberOfNotifies) {
            for (NSInteger j=1; j<=numberOfNotifies; j++) {//формируем пачку нотификаций, если в одну не помещается
                NSInteger x = settingsWords-(j-1)*wordsInOneNotify;
                NSInteger n = (x>wordsInOneNotify)? wordsInOneNotify : x;
                //формируем конкретную нотификацию в зависимости от кол-ва слов.
                NSDate* fireDate= [NSDate dateWithTimeIntervalSinceNow:4*60*60+20+i*timeToPush*60*60];
                [weakSelf startFireAlertAtDate:fireDate numberOfWords:n];
                
            }
            //интервал из настроек и перевод его из часов в секунды
            
        }
    });
}
-(void) startFireAlertAtDate:(NSDate*) fireDate numberOfWords:(NSInteger)numberWords{

    NSString* stringToShow=@"";
    NSMutableArray* userInfoArray = [NSMutableArray new];
    for (NSInteger m = 1 ; m<=numberWords; m++){
        fireDate= [NSDate dateWithTimeIntervalSinceNow:m];//нотификации в пачке друг за другом идут, с периодом 1с
        NVContent* contentToShow = [[NVMainStrategy sharedManager] algoResultHandler];
        if (!contentToShow) { //не работаем без активного словаря
            return;
        }
        NSString* stringToShowTemp = [NSString stringWithFormat:@" %@ - %@;",contentToShow.word,contentToShow.translation];
        [stringToShow stringByAppendingString:stringToShowTemp];
        [userInfoArray addObject:contentToShow.word];//несколько словарей в нотификации, т.к. несколько слов
#warning can't be not property-list types, like NVContent*
    }

    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate ; //Enter the time here in seconds.
    localNotification.alertBody= stringToShow;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.repeatInterval= 0; //Repeating instructions here.
    localNotification.soundName= UILocalNotificationDefaultSoundName;
    localNotification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:userInfoArray,@"contentToShowArray", nil];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

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
}

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
