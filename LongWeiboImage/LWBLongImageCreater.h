//
//  LWBLongImageCreater.h
//  LongWeiboImage
//
//  Created by uistrong on 13-7-24.
//  Copyright (c) 2013年 uistrong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLongWeiboImageMaxWidth     440
#define kLongWeiboImageMaxHeight    800
#define kLongWeiboImageMaxSize      51200

// 文字边距
#define kFirstFontMarginLeft 10 // 第一行文字左边距
#define kFirstFontMarginTop 10  // 第一行文字上边距
#define kLastFontMarginBottom 30   // 最后一行文字底边距
#define kFontMarginTop 10   // 文字边距

// 字体大小
#define kFontSize   30


#define kLongWeiboImage             @"img"
#define kLongWeiboImageBrief        @"imgBrief"


@interface LWBLongImageCreater : NSObject
{
    NSMutableArray *_arrElement; // 元素,以dictionary存储
}

@property (assign, nonatomic) NSUInteger width;   // 图片宽，最大640
@property (assign, nonatomic) NSUInteger height; // 图片高


- (void) addElement:(NSDictionary*) element;

- (UIImage*) build;
@end
