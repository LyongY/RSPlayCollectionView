//
//  RSPlayCollectionCellRealExistence.h
//  OCRSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/9.
//  Copyright © 2020 LyongY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RSPlayModelProtocol <NSObject>

- (BOOL)realExistence;

@end

NS_ASSUME_NONNULL_BEGIN

@interface RSPlayModelBase : NSObject <RSPlayModelProtocol>

@end

NS_ASSUME_NONNULL_END
