//
//  LWBViewController.m
//  LongWeiboImage
//
//  Created by uistrong on 13-7-24.
//  Copyright (c) 2013年 uistrong. All rights reserved.
//

#import "LWBViewController.h"
#import "LWBLongImageCreater.h"

@interface LWBViewController ()

@end

@implementation LWBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    LWBLongImageCreater *creater = [[LWBLongImageCreater alloc] init];
    
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"IMG_1099.JPG" ofType:nil];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"IMG_1101.JPG" ofType:nil];
    
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:path1,kLongWeiboImage,@"中文 中文 中文 中文 中文 中文 中文 中文 中文  ",kLongWeiboImageBrief,nil];
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:path2,kLongWeiboImage,@"中文 中文 中文 中文 中文 中文 中文 中文 中文  ",kLongWeiboImageBrief,nil];
    
    
    [creater addElement:dic1];
    [creater addElement:dic2];
    UIImage *img = [creater build];
    
    self.imgView.frame = CGRectMake(0, 0, img.size.width/2, img.size.height/2);
    self.imgView.image = img;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
