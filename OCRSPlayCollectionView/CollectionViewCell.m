//
//  CollectionViewCell.m
//  OCRSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/7.
//  Copyright © 2020 LyongY. All rights reserved.
//

#import "CollectionViewCell.h"
#import <OCRSPlayCollectionView-Swift.h>

@interface CollectionViewCell()

@property (nonatomic, strong) UILabel *label;

@end

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] init];
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.label];
        [self addConstraints:@[
            [self.label.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.label.leftAnchor constraintEqualToAnchor:self.leftAnchor],
            [self.label.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [self.label.rightAnchor constraintEqualToAnchor:self.rightAnchor],
        ]];
        
        self.backgroundView = [self backgroundViewWithBorderColor:UIColor.grayColor];
        self.selectedBackgroundView = [self backgroundViewWithBorderColor:UIColor.redColor];
    }
    return self;
}

- (UIView *)backgroundViewWithBorderColor:(UIColor *)color {
    UIView *view = [UIView new];
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = 2;
    return view;
}

- (void)updateWithRSPlayCollectionView:(RSPlayCollectionView *)collection indexPath:(NSIndexPath *)indexPath dataSourceElement:(RSPlayModelBase *)element {
    self.label.text = [NSString stringWithFormat:@"%@", element];
}

@end
