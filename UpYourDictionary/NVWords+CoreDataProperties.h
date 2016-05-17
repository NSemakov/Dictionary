//
//  NVWords+CoreDataProperties.h
//  
//
//  Created by Admin on 18/05/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NVWords.h"

NS_ASSUME_NONNULL_BEGIN

@interface NVWords (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *word;
@property (nullable, nonatomic, retain) NSSet<NVTemplates *> *template1;

@end

@interface NVWords (CoreDataGeneratedAccessors)

- (void)addTemplate1Object:(NVTemplates *)value;
- (void)removeTemplate1Object:(NVTemplates *)value;
- (void)addTemplate1:(NSSet<NVTemplates *> *)values;
- (void)removeTemplate1:(NSSet<NVTemplates *> *)values;

@end

NS_ASSUME_NONNULL_END
