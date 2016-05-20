//
//  NVDicts+CoreDataProperties.h
//  
//
//  Created by Admin on 18/05/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NVDicts.h"

NS_ASSUME_NONNULL_BEGIN

@interface NVDicts (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *isActive;
@property (nullable, nonatomic, retain) NSString *from;
@property (nullable, nonatomic, retain) NSString *to;
@property (nullable, nonatomic, retain) NSNumber *progress;
@property (nullable, nonatomic, retain) NVTemplates *template1;
@property (nullable, nonatomic, retain) NSSet<NVContent *> *contentUnit;

@end

@interface NVDicts (CoreDataGeneratedAccessors)

- (void)addContentUnitObject:(NVContent *)value;
- (void)removeContentUnitObject:(NVContent *)value;
- (void)addContentUnit:(NSSet<NVContent *> *)values;
- (void)removeContentUnit:(NSSet<NVContent *> *)values;

@end

NS_ASSUME_NONNULL_END