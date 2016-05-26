//
//  NVNotifyInUse+CoreDataProperties.h
//  UpYourDictionary
//
//  Created by Admin on 26/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NVNotifyInUse.h"

NS_ASSUME_NONNULL_BEGIN

@interface NVNotifyInUse (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *fireDate;
@property (nullable, nonatomic, retain) NSSet<NVContent *> *content;

@end

@interface NVNotifyInUse (CoreDataGeneratedAccessors)

- (void)addContentObject:(NVContent *)value;
- (void)removeContentObject:(NVContent *)value;
- (void)addContent:(NSSet<NVContent *> *)values;
- (void)removeContent:(NSSet<NVContent *> *)values;

@end

NS_ASSUME_NONNULL_END
