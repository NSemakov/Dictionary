//
//  NVMainStrategy.m
//  UpYourDictionary
//
//  Created by Admin on 20/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVMainStrategy.h"
static const NSInteger numberOfWords = 10;
static const NSInteger countAim = 20;
@implementation NVMainStrategy

+(NVMainStrategy*) sharedManager{
    static NVMainStrategy* manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[NVMainStrategy alloc]init];
    });
    return manager;
}

-(void) pauseAlgo{
    /*
     приостановить выполнение. например, при переключении на другой словарь. Сначала остановить этот, затем включить другой.
     Что хорошо - прогресс при этом не стирается. Все остается на своих местах.
     */
}
-(NSString*) performAlgo{
    NSString* result = nil;
    /*
     эта функция вызывается по таймеру какой-то другой функцией из таймера.
     взять текущий словарь, если нет контента, создать контент
     взять слово из темплейта, проверить есть ли оно в контенте
     если есть берем следующее
     если нет - подходит, добавляем в контент, переводим, счетчик в 0.
     Берем слово с наименьшим счетчиком, показываем (local notification) (пока что выводим на экран, где словари и настройки).
     счетчик увеличиваем. ну и т.д. по стратегии. сюда же доп проверки на количество.
     */
#warning all in background thread, notification - on main
    self.activeDict =[self.fetchedDict firstObject];
    
    if (self.activeDict) {//есть активный словарь
        self.activeTemplate=self.activeDict.template1;
        NSArray* activeContent =self.fetchedContent;

        if ([activeContent count] > 0) { //есть активный контент
            if ([activeContent count] < numberOfWords) {//меньше 10 слов?
                if ([self.fetchedAllowedWords count] > 0) { //в источнике слов еще есть неиспользованные слова для перевода
                    //берем любое слово из источника, переводим, добавляем в контент и перевызываем эту же функцию.
                    [self takeWordTranslateAdd];
                } else { //больше нет слов в источнике для перевода.
                    //просто работаем - извлекаем с наим. счетчиком, показываем пушем, увеличиваем счетчик и кладем обратно.
                    result = [self routineWork];
                }
            } else { //больше 10 слов
                //работаем - извлекаем с наим. счетчиком, показываем пушем, увеличиваем счетчик и кладем обратно.
                result = [self routineWork];
            }
        } else {//нет активного контента
            if ([self.fetchedAllowedWords count]> 0) {//в 1 еще есть слова, значит самое начало
                //берем любое слово из источника, переводим, добавляем в контент и перевызываем эту же функцию.
                [self takeWordTranslateAdd];
            } else {//в 1 нет слов, значит конец
                result = @"end01";
            }
        }
    } else {//если нет активного словаря.
        
    }
    return result;
}
-(NSString*) routineWork {
    //работаем - извлекаем с наим. счетчиком, показываем пушем, увеличиваем счетчик и кладем обратно.
    NVContent* contentToShow = self.fetchedWordsAllowedToShow.firstObject;
    NSString* stringToShow = [NSString stringWithFormat:@"%@ - %@",contentToShow.word,contentToShow.translation];
#warning show in local notification; increase count by 1 and save to context;
    [self.delegate showWord:contentToShow.word translation:contentToShow.translation];
    contentToShow.counter = @([contentToShow.counter integerValue]+1);
    NSError* error = nil;
    [self.managedObjectContext save:&error];
    if (!error) {
        [self resetFetchedProperties];
    }
    return stringToShow;
}
-(void) takeWordTranslateAdd{
    //берем любое слово из источника, переводим, добавляем в контент и перевызываем эту же функцию.
    
    NVWords* newWord = [self.fetchedAllowedWords firstObject];
    NSString* wordToTranslate = newWord.word;
    NSString* fromLangShort = self.activeDict.fromShort;
    NSString* toLangShort = self.activeDict.toShort;
    __weak NVMainStrategy* weakSelf = self;
    [[NVServerManager sharedManager] POSTTranslatePhrase:wordToTranslate fromLang:fromLangShort toLang:toLangShort OnSuccess:^(NSString* translation) {
        //все оставшиеся действия надо делать здесь.
        if (weakSelf.managedObjectContext) {
            NVContent* newContent=[NSEntityDescription insertNewObjectForEntityForName:@"NVContent" inManagedObjectContext:weakSelf.managedObjectContext];
            newContent.word = newWord.word;
            newContent.translation = translation;
            newContent.counter = @(0);
            newContent.dict = weakSelf.activeDict;
            
            NSError* error = nil;
            
            if ([weakSelf.managedObjectContext save:&error]) {
                [weakSelf resetFetchedProperties];
            } else {
                NSLog(@"error: %@\n userInfo:%@",error.localizedDescription,error.userInfo);
            }
            
            [weakSelf performAlgo];
        }
        
    } onFailure:^(NSString *error) {
        
    }];
    
}

-(void) resetFetchedProperties{
    self.fetchedAllowedWords = nil;
    self.fetchedContent = nil;
    self.fetchedDict = nil;
    self.fetchedWordsAllowedToShow=nil;
}
-(NSString*) algoResultHandler {
    NSString* stringToReturn = nil;
    NSString* result = [self performAlgo];
    if ([result isEqualToString:@"end01"]) {
        stringToReturn = @"Dictionary is done! Choose another one or disable it";
    } else if ([result isEqual:nil]){
        stringToReturn = [self algoResultHandler];
    } else {
        stringToReturn = result;
    }
    return stringToReturn;
}
-(void) startFireAlertAtDate:(NSDate*) fireDate{
    self.activeDict =[self.fetchedDict firstObject];
    if (!self.activeDict) { //не работаем без активного словаря
        return;
    }
    //take settings like number of words, frequency in hours
    NSTimeInterval interval;
    //interval = 60;//12 hours from now
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = fireDate ; //Enter the time here in seconds.
    localNotification.alertBody= [self algoResultHandler];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.repeatInterval= NSCalendarUnitMinute; //Repeating instructions here.
    localNotification.soundName= UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    
}
-(NSArray*) fetchedAllowedWords{
    if (_fetchedAllowedWords != nil) {
        return _fetchedAllowedWords;
    }
    NSMutableArray* array =[NSMutableArray array];
    //NSArray* sourceArray = [self.activeDict.contentUnit allObjects];
    for (NVContent* contentUnit in self.activeDict.contentUnit) {
        [array addObject:contentUnit.word];
    }
    
    return [self fetchedAllowedWordsWhereNotAllowed:[NSSet setWithArray:[array copy]]];
}
-(NSArray*) fetchedWordsAllowedToShow
{
    if (_fetchedWordsAllowedToShow != nil) {
        return _fetchedWordsAllowedToShow;
    }
    self.managedObjectContext = [[NVDataManager sharedManager] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVContent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    //[fetchRequest setRelationshipKeyPathsForPrefetching:@[@"NVTemplates",@"NVContent"]];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"counter" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    //NSManagedObjectID *moID=[self.person objectID];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"dict =%@ AND counter < %d",self.activeDict, countAim];
    [fetchRequest setPredicate:predicate];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSError* error = nil;
    NSArray* resultArray= [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        _fetchedWordsAllowedToShow = resultArray;
        return resultArray;
    } else {
        NSLog(@"error: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
}

-(NSArray*) fetchedAllowedWordsWhereNotAllowed:(NSSet*) forbiddenWords
{
    /*if (_fetchedAllowedWords != nil) {
        return _fetchedAllowedWords;
    }*/
    self.managedObjectContext = [[NVDataManager sharedManager] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVWords" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    //[fetchRequest setRelationshipKeyPathsForPrefetching:@[@"NVTemplates",@"NVContent"]];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"word" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //NSManagedObjectID *moID=[self.person objectID];
    //NSArray* forbiddenWords1 = [NSArray arrayWithObjects:@"one",@"two", nil];
    NSSet* set1 = [NSSet setWithObject:self.activeTemplate];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"(ANY template1 IN %@) && NOT (word IN %@)",set1, forbiddenWords];
    //NSPredicate*  predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"template1"] rightExpression:[NSExpression expressionForConstantValue:array1] modifier:NSDirectPredicateModifier type:NSInPredicateOperatorType options:0];
    [fetchRequest setPredicate:predicate];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSError* error = nil;
    NSArray* resultArray= [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        //_fetchedAllowedWords = resultArray;
        return resultArray;
    } else {
        NSLog(@"error: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
}
- (NSArray *)fetchedContent
{
    if (_fetchedContent != nil) {
        return _fetchedContent ;
    }
    self.managedObjectContext = [[NVDataManager sharedManager] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVContent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    //[fetchRequest setRelationshipKeyPathsForPrefetching:@[@"NVTemplates",@"NVContent"]];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"counter" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //NSManagedObjectID *moID=[self.person objectID];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"dict=%@ AND counter < %d",self.activeDict, countAim];
    [fetchRequest setPredicate:predicate];

    NSError* error = nil;
    NSArray* resultArray= [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        _fetchedContent = resultArray;
        return resultArray;
    } else {
        NSLog(@"error: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
}

- (NSArray *)fetchedDict
{
    if (_fetchedDict != nil) {
        return _fetchedDict ;
    }
    self.managedObjectContext = [[NVDataManager sharedManager] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVDicts" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    //[fetchRequest setRelationshipKeyPathsForPrefetching:@[@"NVTemplates",@"NVContent"]];
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"from" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    //NSManagedObjectID *moID=[self.person objectID];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"isActive = %@",@(true)];
    [fetchRequest setPredicate:predicate];
    NSError* error = nil;
    NSArray* resultArray= [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        _fetchedDict  = resultArray;
        return resultArray;
    } else {
        NSLog(@"error: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
}

@end
