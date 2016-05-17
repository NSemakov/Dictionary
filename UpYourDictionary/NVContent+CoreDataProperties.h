//
//  NVContent+CoreDataProperties.h
//  
//
//  Created by Admin on 18/05/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NVContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface NVContent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *word;
@property (nullable, nonatomic, retain) NSString *translation;
@property (nullable, nonatomic, retain) NSNumber *count;
@property (nullable, nonatomic, retain) NVDicts *dict;

@end

NS_ASSUME_NONNULL_END
