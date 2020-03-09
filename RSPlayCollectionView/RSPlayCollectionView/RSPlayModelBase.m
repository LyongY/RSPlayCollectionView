//
//  RSPlayCollectionCellRealExistence.m
//  OCRSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/9.
//  Copyright © 2020 LyongY. All rights reserved.
//

#import "RSPlayModelBase.h"

@implementation RSPlayModelBase

- (BOOL)realExistence {
    NSString *str = [NSString stringWithFormat:@"%@ 需要重写此方法", NSStringFromClass([self class])];
    NSAssert(NO, str);
    return NO;
}

@end
