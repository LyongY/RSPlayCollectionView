//
//  RSPlayCellClass.m
//  OCRSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/9.
//  Copyright © 2020 LyongY. All rights reserved.
//

#import "RSPlayCellBase.h"

@implementation RSPlayCellBase

- (void)updateWith:(NSIndexPath *)indexPath dataSourceElement:(RSPlayModelBase *)element {
    NSString *str = [NSString stringWithFormat:@"%@ 需要重写此方法", NSStringFromClass([self class])];
    NSAssert(NO, str);
}

@end
