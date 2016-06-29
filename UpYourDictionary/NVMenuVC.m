//
//  NVMenuVC.m
//  UpYourDictionary
//
//  Created by Admin on 21/05/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "NVMenuVC.h"
#import "NVMainStrategy.h"
@interface NVMenuVC ()

@end

@implementation NVMenuVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NVMainStrategy* manager = [NVMainStrategy sharedManager];
    manager.delegate = self;
    
}

-(void)viewDidAppear:(BOOL)animated{
  

}
-(void)viewWillAppear:(BOOL)animated{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) showWord:(NSString*) word translation:(NSString*) translation{
    //self.textFieldTest.text = [NSString stringWithFormat:@"%@ - %@",word,translation];
}
/*- (CGRect)adjustedRectForLabel:(UILabel *)label {
 CGRect rect =
 [label.attributedText boundingRectWithSize:CGSizeMake(200.f, CGFLOAT_MAX)
 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine)
 context:nil];
 //CGFloat adjustedFontSize = label.font.pointSize * context.actualScaleFactor;
 rect = CGRectIntegral(rect);
 return rect;
 
 }*/
@end
