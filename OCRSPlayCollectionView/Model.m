//
//  Model.m
//  OCRSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/7.
//  Copyright © 2020 LyongY. All rights reserved.
//

#import "Model.h"

@interface Model()

@property (nonatomic, assign) NSInteger aaaa;

@end

@implementation Model

- (instancetype)initWithNum:(NSInteger)num {
    self = [super init];
    if (self) {
        _aaaa = num;
    }
    return self;
}

- (BOOL)realExistence {
    return _aaaa <= 10;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%ld", (long)_aaaa];
}

- (void)clean {
    _aaaa = 999;
}

@end
