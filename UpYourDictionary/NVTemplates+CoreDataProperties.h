//
//  NVTemplates+CoreDataProperties.h
//  
//
//  Created by Admin on 18/05/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NVTemplates.h"

NS_ASSUME_NONNULL_BEGIN

@interface NVTemplates (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<NVWords *> *word;
@property (nullable, nonatomic, retain) NSSet<NVDicts *> *dict;

@end

@interface NVTemplates (CoreDataGeneratedAccessors)

- (void)addWordObject:(NVWords *)value;
- (void)removeWordObject:(NVWords *)value;
- (void)addWord:(NSSet<NVWords *> *)values;
- (void)removeWord:(NSSet<NVWords *> *)values;

- (void)addDictObject:(NVDicts *)value;
- (void)removeDictObject:(NVDicts *)value;
- (void)addDict:(NSSet<NVDicts *> *)values;
- (void)removeDict:(NSSet<NVDicts *> *)values;

@end

NS_ASSUME_NONNULL_END
