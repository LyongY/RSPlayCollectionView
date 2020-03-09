//
//  Model.h
//  OCRSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/7.
//  Copyright © 2020 LyongY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OCRSPlayCollectionView-Swift.h>
#import "RSPlayModelBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface Model : RSPlayModelBase

- (instancetype)initWithNum:(NSInteger)num;

- (void)clean;

@end

NS_ASSUME_NONNULL_END
