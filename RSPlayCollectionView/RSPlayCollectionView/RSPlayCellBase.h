//
//  RSPlayCellClass.h
//  OCRSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/9.
//  Copyright © 2020 LyongY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSPlayModelBase;

@protocol RSPlayCellClassProtocol <NSObject>

- (void)updateWith:(NSIndexPath *)indexPath dataSourceElement:(RSPlayModelBase *)element;

@end

NS_ASSUME_NONNULL_BEGIN

@interface RSPlayCellBase : UICollectionViewCell <RSPlayCellClassProtocol>

@end

NS_ASSUME_NONNULL_END
