//
//  NVTemplates+CoreDataProperties.h
//  UpYourDictionary
//
//  Created by Admin on 28/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NVTemplates.h"

NS_ASSUME_NONNULL_BEGIN

@interface NVTemplates (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *lang;
@property (nullable, nonatomic, retain) NSString *langShort;
@property (nullable, nonatomic, retain) NSSet<NVDicts *> *dict;
@property (nullable, nonatomic, retain) NSSet<NVWords *> *word;

@end

@interface NVTemplates (CoreDataGeneratedAccessors)

- (void)addDictObject:(NVDicts *)value;
- (void)removeDictObject:(NVDicts *)value;
- (void)addDict:(NSSet<NVDicts *> *)values;
- (void)removeDict:(NSSet<NVDicts *> *)values;

- (void)addWordObject:(NVWords *)value;
- (void)removeWordObject:(NVWords *)value;
- (void)addWord:(NSSet<NVWords *> *)values;
- (void)removeWord:(NSSet<NVWords *> *)values;

@end

NS_ASSUME_NONNULL_END
