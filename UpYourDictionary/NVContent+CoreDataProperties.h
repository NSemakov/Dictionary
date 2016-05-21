//
//  NVContent+CoreDataProperties.h
//  UpYourDictionary
//
//  Created by Admin on 21/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NVContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface NVContent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *counter;
@property (nullable, nonatomic, retain) NSString *translation;
@property (nullable, nonatomic, retain) NSString *word;
@property (nullable, nonatomic, retain) NVDicts *dict;

@end

NS_ASSUME_NONNULL_END
