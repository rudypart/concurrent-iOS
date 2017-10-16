//
//  NSString+Crp.m
//  Concurrent-iOS
//
//  Created by joey_qi on 2017/10/16.
//  Copyright © 2017年 joey_qi. All rights reserved.
//

#import "NSString+Crp.h"

@implementation NSString (Crp)

- (NSString *)crp
{
    return [self stringByAppendingString:@"abc"];
}

@end
