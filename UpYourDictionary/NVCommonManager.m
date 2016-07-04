//
//  NVCommonManager.m
//  UpYourDictionary
//
//  Created by Admin on 04/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVCommonManager.h"

@implementation NVCommonManager
+(NVCommonManager*) sharedManager{
    static NVCommonManager* manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager=[[NVCommonManager alloc]init];
    });
    return manager;
}
-(void) configureInitialState{
    [NVCommonManager setupFontsForBars];
}

+ (void)setupFontsForView:(UIView *)view andSubViews:(BOOL)isSubViews
{
    if ([view respondsToSelector:@selector(setFont:)] && [view respondsToSelector:@selector(font)]) {
        id viewObj = view;
        UIFont* font = [self getReadyFont];
        [viewObj setFont:font];
        /*if ([font.fontName isEqualToString:@"AcademyEngravedLetPlain"]) {
            //[viewObj setFont:[UIFont fontWithName:PRIMARY_FONT size:font.pointSize]];
        } else if ([font.fontName hasPrefix:@"AmericanTypewriter"]) {
            //[viewObj setFont:[UIFont fontWithName:SECONDARY_FONT size:font.pointSize]];
        }*/
        if ([view respondsToSelector:@selector(textColor)]) {
            [viewObj setTextColor:[UIColor whiteColor]];
        }
    }
    if (isSubViews) {
        for (UIView *sview in view.subviews) {
            [self setupFontsForView:sview andSubViews:YES];
        }
    }
}

+ (void)setupBackgroundImage:(id) viewController {
    //UIImage* image = [UIImage imageNamed:@"board2"];
    UIImage* image = [UIImage imageNamed:@"board1_24"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    if ([viewController isKindOfClass:[UITableViewController class]]) {
        UITableViewController* tableVC = (UITableViewController*) viewController;
        
        
        [imageView setFrame:tableVC.tableView.bounds];
        tableVC.tableView.backgroundView = imageView;
        //NSLog(@"image: %@, background :%@",tempImageView,self.tableView.backgroundView);
    } else if ([viewController isKindOfClass:[UIViewController class]]) {
        //add image, add constraints, move to back
        
        UIViewController* vc = (UIViewController*) viewController;
        if ([vc respondsToSelector:@selector(tableView)]) {
            [imageView setFrame:((UITableViewController*)vc).tableView.bounds];
            ((UITableViewController*)vc).tableView.backgroundView = imageView;
        }
        UIImageView* imageView = [[UIImageView alloc]initWithImage:image];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [vc.view addSubview:imageView];
        [vc.view sendSubviewToBack:imageView];
        NSDictionary *viewsDictionary = @{@"imageView":imageView};
        NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[imageView]-(0)-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];
        
        NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[imageView]-(0)-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];
        [vc.view addConstraints:constraint_POS_V];
        [vc.view addConstraints:constraint_POS_H];
        
    }
}
+ (UIFont*) getReadyFont{
    UIFontDescriptor *userFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    float userFontSize = [userFont pointSize];
    UIFont *font = [UIFont fontWithName:@"Chalkboard SE" size:userFontSize];
    return font;
}
+ (UIFont*) getReadyFontWithMultiplier:(CGFloat) multiplier{
    UIFontDescriptor *userFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    float userFontSize = [userFont pointSize];
    UIFont *font = [UIFont fontWithName:@"Chalkboard SE" size:userFontSize * multiplier];
    return font;
}
+ (CGFloat) heightForOneLabel:(NSString*)text width:(CGFloat) width {
    NSAttributedString * attributedString = [[NSAttributedString alloc] initWithString:text attributes:
                                             @{ NSFontAttributeName: [NVCommonManager getReadyFont]}];
    CGSize constraintSize = CGSizeMake(width - 30, MAXFLOAT);
    CGRect rect = [attributedString boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    //Add back in the extra padding above and below label on table cell.
    rect.size.height = rect.size.height + 30;
    return rect.size.height;
}
+ (void)setupFontsForBars{
    UIColor* commonColor = [UIColor whiteColor];
    UIImage* imageForBars = [UIImage imageNamed:@"board5"];
    [[UINavigationBar appearance] setTintColor:commonColor];
    [[UINavigationBar appearance] setBackgroundImage:imageForBars forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName:commonColor,NSFontAttributeName:[NVCommonManager getReadyFontWithMultiplier:1.2]}];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:commonColor, NSForegroundColorAttributeName,[NVCommonManager getReadyFontWithMultiplier:1.2], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [[UIToolbar appearance] setBackgroundImage:imageForBars forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearanceWhenContainedIn:[UIToolbar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:commonColor, NSForegroundColorAttributeName,[NVCommonManager getReadyFontWithMultiplier:1.2], NSFontAttributeName, nil] forState:UIControlStateNormal];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
