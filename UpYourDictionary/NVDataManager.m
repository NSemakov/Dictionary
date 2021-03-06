//
//  NVDataManager.m
//  1
//
//  Created by Admin on 24.08.15.
//  Copyright (c) 2015 Admin. All rights reserved.
//

#import "NVDataManager.h"

@implementation NVDataManager
+(NVDataManager*) sharedManager{
    static NVDataManager* manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[NVDataManager alloc]init];
    });
    return manager;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize privateManagedObjectContext = _privateManagedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "NV._" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UpYourDictionary" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSString* curSystemLang = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    NSURL *storeURL;
    if ([curSystemLang isEqualToString:@"ru"]) {
        storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"UpYourDictionaryRu.sqlite"];
    } else {
        storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"UpYourDictionaryEn.sqlite"];
    }
    
    /*start from Ray*/
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]]) {
        NSString* dbName;
        if ([curSystemLang isEqualToString:@"ru"]) {
            dbName = @"UpYourDictionaryRu";
        } else {
            dbName = @"UpYourDictionaryEn";
        }
        //NSLog(@"path:%@",[[NSBundle mainBundle] pathForResource:dbName ofType:@"sqlite"]);
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:dbName ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Oops, could copy preloaded data");
        }
    }
    /*end from ray*/
    NSError *error = nil;
    //NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        */
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)privateManagedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_privateManagedObjectContext != nil) {
        return _privateManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_privateManagedObjectContext setPersistentStoreCoordinator:coordinator];
    [_privateManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    return _privateManagedObjectContext;
}
- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    [_managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}
#pragma mark - saving downloaded content
- (BOOL) addDataToDb:(NSArray*) templateArray withName:(NSString*) templateName langShort:(NSString*) langShort productID:(NSString*) productID{
    BOOL isSuccessful = NO;
    NSManagedObjectContext* moc = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    moc.persistentStoreCoordinator = self.persistentStoreCoordinator;
    
    NVTemplates *newTemplate = [NSEntityDescription
                                insertNewObjectForEntityForName:@"NVTemplates"
                                inManagedObjectContext:moc];
    newTemplate.productID = productID;
    newTemplate.name = templateName;
    if (langShort) {
        if ([langShort isEqualToString:@"ru"]) {
            newTemplate.lang = @"Russian";
            newTemplate.langShort = @"ru";
        } else if ([langShort isEqualToString:@"en"]){
            newTemplate.lang = @"English";
            newTemplate.langShort = @"en";
        }
    }
    
    for (NSString* str in templateArray) {
        NVWords *newWord = [NSEntityDescription
                            insertNewObjectForEntityForName:@"NVWords"
                            inManagedObjectContext:moc];
        newWord.word = str;
        NSMutableSet* wordsFromTemplate = [NSMutableSet setWithSet:newTemplate.word];
        
        [wordsFromTemplate addObject:newWord];
        [newTemplate setWord:wordsFromTemplate];
        NSError *error;
        if (![moc save:&error]) {
            NSLog(@"Whoops, couldn't save: %@, user info :%@", error.localizedDescription, error.userInfo);
        } else{
            isSuccessful = YES;
        }
    }
    return isSuccessful;
}

#pragma mark - fetching
- (NSArray*) fetchTemplatesForNonNilProductIds{
    NSManagedObjectContext* moc = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    moc.persistentStoreCoordinator = self.persistentStoreCoordinator;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NVTemplates" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"(productID != nil)"];
    [fetchRequest setPredicate:predicate];
    
    NSError* error = nil;
    NSArray* resultArray= [moc executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        NSMutableArray* arrayOfProductIds = [[NSMutableArray alloc]init];
        for (NVTemplates* templ in resultArray) {
            NSLog(@"NVDataManager. Template productID: %@",templ.productID);
            [arrayOfProductIds addObject:templ.productID];
        }
        return arrayOfProductIds;
    } else {
        NSLog(@"error: %@, local description: %@",error.userInfo, error.localizedDescription);
        return nil;
    }
}
@end
