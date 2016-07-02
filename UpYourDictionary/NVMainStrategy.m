//
//  NVMainStrategy.m
//  UpYourDictionary
//
//  Created by Admin on 20/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVMainStrategy.h"

@implementation NVMainStrategy

+(NVMainStrategy*) sharedManager{
    static NVMainStrategy* manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[NVMainStrategy alloc]init];
        manager.setOfTempTakenWords = [[NSMutableSet alloc]init];
        manager.isYandexAvailable = YES;
    });
    return manager;
}

-(void) pauseAlgo{
    /*
     приостановить выполнение. например, при переключении на другой словарь. Сначала остановить этот, затем включить другой.
     Что хорошо - прогресс при этом не стирается. Все остается на своих местах.
     */
}
-(NVContent*) performAlgo{
    //либо NVContent со словом, переводом и счетчиком
    //либо nil - если слово просто было переведено и добавлено. значит этот алгоритм надо вызвать еще раз, чтобы получить слово.
    NVContent* result = nil;

    if (self.activeDict) {//есть активный словарь
        self.activeTemplate=self.activeDict.template1;
        NSArray* activeContent =self.fetchedContent;
        
        if ([activeContent count] > 0) { //есть активный контент
            if ([activeContent count] < numberOfWords) {//меньше 10 слов?
                NSArray* fetchedAllowedWords = self.fetchedAllowedWords;
                if (fetchedAllowedWords && [fetchedAllowedWords count] > 0) { //в источнике слов еще есть неиспользованные слова для перевода
                    //берем любое слово из источника, переводим, добавляем в контент и перевызываем эту же функцию.
                    if (numberOfWords - [activeContent count] > [self.setOfTempTakenWords count]) {
                        [self takeWordTranslateAdd];
                    }
                } else { //больше нет слов в источнике для перевода.
                    //просто работаем - извлекаем с наим. счетчиком, показываем пушем, увеличиваем счетчик и кладем обратно.
                    result = [self routineWork];
                }
            } else { //больше 10 слов
                //работаем - извлекаем с наим. счетчиком, показываем пушем, увеличиваем счетчик и кладем обратно.
                result = [self routineWork];
            }
        } else {//нет активного контента
            NSArray* fetchedAllowedWords = self.fetchedAllowedWords;
            if (fetchedAllowedWords && [fetchedAllowedWords count] > 0) {//в 1 еще есть слова, значит самое начало
                //берем любое слово из источника, переводим, добавляем в контент и перевызываем эту же функцию.
                [self takeWordTranslateAdd];
            } else {//в 1 нет слов, значит конец, сбрасываем активность словаря.
                result = [self performLastStep];
            }
        }
    } else {//если нет активного словаря, вернется nil
        
    }
    return result;
}
-(NVContent*) performLastStep {
    NVContent* newWord=[NSEntityDescription insertNewObjectForEntityForName:@"NVWords" inManagedObjectContext:self.managedObjectContext];
    newWord.word = @"!";
    NVContent* newContent=[NSEntityDescription insertNewObjectForEntityForName:@"NVContent" inManagedObjectContext:self.managedObjectContext];
    newContent.word = newWord.word;
    newContent.translation = NSLocalizedString(@"Dictionary is done! Please, choose another one.", nil);
    newContent.counter = @(1);
    newContent.dict = self.activeDict;
    newContent.originalWord = NSLocalizedString(@"Dictionary is done! Please, choose another one.", nil);
    self.activeDict.isActiveProgram = @(NO);
    //NSLog(@" performLastStep isActive = %@, isActiveProgram = %@",self.activeDict.isActive,self.activeDict.isActiveProgram);
    NSError* error = nil;
    
    if ([self.managedObjectContext save:&error]) {
        [self resetFetchedProperties];
        return newContent;
    } else {
        NSLog(@"error performLastStep: %@\n userInfo:%@",error.localizedDescription,error.userInfo);
        return nil;
    }
    
}
-(NVContent*) routineWork {
    //работаем - извлекаем с наим. счетчиком, но с особенностью при переходе через 0. Если есть 0 и 9, то 0 пока не показываем. Затем показываем пушем, увеличиваем счетчик и кладем обратно.

    NVContent* contentToShow = self.fetchedWordsAllowedToShow.firstObject;

    //[self.delegate showWord:contentToShow.word translation:contentToShow.translation];
    contentToShow.counter = @([contentToShow.counter integerValue]+1);
   // NSLog(@"contentInRoutineWork:%@; Counter:%@",contentToShow.word,contentToShow.counter);
    NSError* error = nil;
    [self.managedObjectContext save:&error];
    if (!error) {
        [self resetFetchedProperties];
    } else {
        NSLog(@"error in routine work: %@,%@",error.description,error.userInfo);
    }
    return contentToShow;
}
-(void) takeWordTranslateAdd{
    //берем любое слово из источника, проверяем, не взято ли оно уже для перевода. переводим, добавляем в контент и .
    NSSet* set = [NSSet setWithArray:self.fetchedAllowedWords];
    NVWords* newWord = [set anyObject];
    if ([self.setOfTempTakenWords containsObject:newWord]) {
        return;
    } else {
        [self.setOfTempTakenWords addObject:newWord];
    }
    NSString* wordToTranslate = newWord.word;
    //NSString* fromLangShort = self.activeDict.fromShort;
    //NSString* toLangShort = self.activeDict.toShort;
    __block NVContent* newContent=[NSEntityDescription insertNewObjectForEntityForName:@"NVContent" inManagedObjectContext:self.managedObjectContext];
    newContent.counter = @(0);
    newContent.dict = self.activeDict;
    newContent.originalWord = wordToTranslate;
    if ([self tranlsateToSourceLangText:wordToTranslate content:newContent] && [self translateToEndLangText:wordToTranslate content:newContent]) {
        //если перевод успешен, тогда сохраняем
        NSError* error = nil;
        if ([self.managedObjectContext save:&error]) {
            [self resetFetchedProperties];
            [self.setOfTempTakenWords removeObject:newWord];
        } else {
            NSLog(@"error takeWordTranslateAdd: %@\n userInfo:%@",error.localizedDescription,error.userInfo);
        }
    } else {
        self.isYandexAvailable = NO;
    }
    
}
-(BOOL) tranlsateToSourceLangText:(NSString*) text content:(NVContent*) content{
    //превращаем два асинхронных вызова в синхронные. Сначала поиск в словаре яндекса, если не найдено, поиск в переводчике. Индикатор - переменная flag.
    __block BOOL isSuccess = NO;
    if ([self.activeTemplate.langShort isEqualToString:self.activeDict.fromShort]) {//прямо копируем слово в источник
        content.word = text;
        isSuccess = YES;
    } else {//если не совпадает, переводим слово и вставляем в источник
        __weak NVMainStrategy* weakSelf = self;

        
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            __block BOOL flag = false;
        //NSLog(@"tranlsateToSourceLangText. lang from %@, lang to %@", self.activeTemplate.langShort,self.activeDict.fromShort);
            [[NVServerManager sharedManager] POSTLookUpDictionary:text fromLang:self.activeTemplate.langShort toLang:self.activeDict.fromShort OnSuccess:^(NSString* translation) {
                //все оставшиеся действия надо делать здесь.
                if (weakSelf.managedObjectContext) {
                    if (translation) {
                        content.word = translation;
                        isSuccess = YES;
                        flag = true;
                    }
                    
                    dispatch_semaphore_signal(semaphore);
                }
            } onFailure:^(NSString *error) {
                NSLog(@"error in dict: %@", error);
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            //поиск в переводчике, если в словаре не найдено
            semaphore = dispatch_semaphore_create(0);
            
            if (!flag){
                [[NVServerManager sharedManager] POSTTranslatePhrase:text fromLang:self.activeTemplate.langShort toLang:self.activeDict.fromShort OnSuccess:^(NSString* translation) {
                    //все оставшиеся действия надо делать здесь.
                    if (weakSelf.managedObjectContext) {
                        content.word = translation;
                        isSuccess = YES;
                        dispatch_semaphore_signal(semaphore);
                    }
                } onFailure:^(NSString *error) {
                    NSLog(@"error in translator: %@", error);
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
    }
    return isSuccess;
}
-(BOOL) translateToEndLangText:(NSString*) text content:(NVContent*) content{//true в случае успешного перевода.
    __block BOOL isSuccess = NO;
    if ([self.activeTemplate.langShort isEqualToString:self.activeDict.toShort]) {//прямо копируем слово в перевод
        content.translation = text;
        isSuccess = YES;
    } else {//если не совпадает, переводим слово и вставляем в перевод
        __weak NVMainStrategy* weakSelf = self;

            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            __block BOOL flag = false;
       // NSLog(@"translateToEndLangText. lang from %@, lang to %@", self.activeTemplate.langShort,self.activeDict.toShort);
            [[NVServerManager sharedManager] POSTLookUpDictionary:text fromLang:self.activeTemplate.langShort toLang:self.activeDict.toShort OnSuccess:^(NSString* translation)
             {
                //все оставшиеся действия надо делать здесь.
                if (weakSelf.managedObjectContext) {
                    content.translation = translation;
                    isSuccess = YES;
                    dispatch_semaphore_signal(semaphore);
                }
            } onFailure:^(NSString *error) {
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            //поиск в переводчике, если в словаре не найдено
            semaphore = dispatch_semaphore_create(0);
            
            if (!flag){
                [[NVServerManager sharedManager] POSTTranslatePhrase:text fromLang:self.activeTemplate.langShort toLang:self.activeDict.toShort OnSuccess:^(NSString* translation) {
                    //все оставшиеся действия надо делать здесь.
                    if (weakSelf.managedObjectContext) {
                        content.translation = translation;
                        isSuccess = YES;
                        dispatch_semaphore_signal(semaphore);
                    }
                } onFailure:^(NSString *error) {
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }    
    }
    return isSuccess;
}

-(void) resetFetchedProperties{
    self.fetchedAllowedWords = nil;
    self.fetchedContent = nil;
    self.fetchedDict = nil;
    self.fetchedWordsAllowedToShow=nil;
    self.activeDict = nil;
    self.activeTemplate = nil;
}
-(NVContent*) algoResultHandler {
    //stringToReturn = @"Dictionary is done! Choose another one or disable it";
    //NSString* stringToReturn = nil;
    NVContent* result = nil;
    if (self.activeDict && self.isYandexAvailable) {
        result = [self performAlgo];
        if (!result) {
            result = [self algoResultHandler];
        }
    }
    self.isYandexAvailable = YES;
    return result;
}
- (NVDicts*) activeDict{
    if ([self.fetchedDict count]>0) {
        return [self.fetchedDict firstObject];
    } else {
        return nil;
    }
}

- (NSArray*) fetchedAllowedWords{
    
    NSMutableArray* array =[NSMutableArray array];
    //NSArray* sourceArray = [self.activeDict.contentUnit allObjects];
    for (NVContent* contentUnit in self.activeDict.contentUnit) {
        [array addObject:contentUnit.originalWord];
        //NSLog(@"fetchedAllowedWords. used words:%@",contentUnit.originalWord);
    }
    
    return [self fetchedAllowedWordsWhereNotAllowed:[NSSet setWithArray:[array copy]]];
}
-(NSArray*) fetchedWordsAllowedToShow
{
    /*if (_fetchedWordsAllowedToShow != nil) {
        return _fetchedWordsAllowedToShow;
    }*/
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
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"dict =%@ AND counter < %@",self.activeDict, @(countAim)];
    [fetchRequest setPredicate:predicate];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSError* error = nil;
    NSArray* resultArray= [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        _fetchedWordsAllowedToShow = resultArray;
        //NSLog(@"resultArray: %@",resultArray);

         //если есть 2 счетчика  со значениями 0 и 9, тогда слово с нулевым значением в конец массива путем сортировки массива по убыванию.
        NSArray *arrayOfCounters = [resultArray valueForKeyPath:@"counter"];
        if ([arrayOfCounters containsObject:@(0)] && [arrayOfCounters containsObject:@(numberOfWords-1)]) {
            resultArray = [resultArray sortedArrayUsingComparator:^NSComparisonResult(NVContent* obj1, NVContent* obj2) {
                if ([obj1.counter integerValue] > [obj2.counter integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                
                if ([obj1.counter integerValue] < [obj2.counter integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                return (NSComparisonResult)NSOrderedSame;
            }];
        }
        /*for (NVContent* content in resultArray) {
            NSLog(@"word:%@,counter:%@",content.word,content.counter);
            //NSLog(@"Running on %@ thread", [NSThread currentThread]);
        }*/
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

    NSSet* set1 = [NSSet setWithObject:self.activeTemplate];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"(ANY template1 IN %@) && NOT (word IN %@)",set1, forbiddenWords];
    //NSPredicate*  predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"template1"] rightExpression:[NSExpression expressionForConstantValue:array1] modifier:NSDirectPredicateModifier type:NSInPredicateOperatorType options:0];
    [fetchRequest setPredicate:predicate];

    NSError* error = nil;
    NSArray* resultArray= [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        return resultArray;
    } else {
        NSLog(@"error: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
}
- (NSArray *)fetchedContent
{
    /*if (_fetchedContent != nil) {
        return _fetchedContent ;
    }*/
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
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"dict=%@ AND counter < %@",self.activeDict, @(countAim)];
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
    /*if (_fetchedDict != nil) {
        return _fetchedDict ;
    }*/

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
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"(isActive = %@) AND (isActiveProgram = %@)",@(YES), @(YES)];
    [fetchRequest setPredicate:predicate];
    NSError* error = nil;
    NSArray* resultArray= [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        _fetchedDict  = resultArray;
        return resultArray;
    } else {
        NSLog(@"error fetchedDict: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
}
- (NVDicts*) activeDictByUser
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVDicts" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"from" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"(isActive = %@)",@(YES)];
    [fetchRequest setPredicate:predicate];
    NSError* error = nil;
    NSArray* resultArray= [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if ([resultArray count]>0) {
            return [resultArray firstObject];
        }
    } else {
        NSLog(@"error isActiveDictByUser: %@, local description: %@",error.userInfo, error.localizedDescription);
    }
    return nil;
}
- (NSInteger) countProgressOfDictionary
{
    if (self.activeDict) {
       
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVContent" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"counter" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"dict =%@ AND counter >= %@",self.activeDict, @(countAim)];
    [fetchRequest setPredicate:predicate];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSError* error = nil;
    NSInteger doneWordsCount = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@, local description: %@",error.userInfo, error.localizedDescription);
        doneWordsCount = 0;
    }
    
    /*-----------*/
    
    fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    entity = [NSEntityDescription entityForName:@"NVWords" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Edit the sort key as appropriate.
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"word" ascending:YES];
    sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSSet* set1 = [NSSet setWithObject:self.activeDict.template1];
    predicate=[NSPredicate predicateWithFormat:@"(ANY template1 IN %@)",set1];
    //NSPredicate*  predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"template1"] rightExpression:[NSExpression expressionForConstantValue:array1] modifier:NSDirectPredicateModifier type:NSInPredicateOperatorType options:0];
    [fetchRequest setPredicate:predicate];
    error = nil;
    NSInteger allWordsCount = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@, local description: %@",error.userInfo, error.localizedDescription);
        allWordsCount = 0;
    }
        //NSLog(@"count:%d, %f",(doneWordsCount *100/ allWordsCount) , (doneWordsCount * 1.0 / allWordsCount) * 100);
    return (doneWordsCount *100 / allWordsCount) ;
} else {
    return 0;
}
}
- (NSManagedObjectContext*) managedObjectContext{
    if (!_managedObjectContext) {
        _managedObjectContext=[[NVDataManager sharedManager] privateManagedObjectContext];
        //_managedObjectContext=[[NVDataManager sharedManager] managedObjectContext];
    }
    return _managedObjectContext;
}

@end
