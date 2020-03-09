//
//  ViewController.m
//  OCRSPlayCollectionView
//
//  Created by Raysharp666 on 2020/3/7.
//  Copyright © 2020 LyongY. All rights reserved.
//

#import "ViewController.h"
#import <OCRSPlayCollectionView-Swift.h>
#import "CollectionViewCell.h"
#import "Model.h"

@interface ViewController () <RSPlayCollectionViewDelegate>

@property (nonatomic, strong) RSArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _dataSource = [[RSArray alloc] initWith:@[
        [[Model alloc] initWithNum:1],
        [[Model alloc] initWithNum:2],
        [[Model alloc] initWithNum:3],
        [[Model alloc] initWithNum:4],
        [[Model alloc] initWithNum:5],
        [[Model alloc] initWithNum:6],
        [[Model alloc] initWithNum:7],
        [[Model alloc] initWithNum:8],
        [[Model alloc] initWithNum:9],
        [[Model alloc] initWithNum:10],
    [[Model alloc] initWithNum:11],
    [[Model alloc] initWithNum:12],
    ].mutableCopy
                   ];
    
    
    RSPlayCollectionView *collection = [[RSPlayCollectionView alloc] init:_dataSource registClass:CollectionViewCell.class spliteModel:SpliteModeFour selectedIndex:5 delegate:self emptyElement:^RSPlayModelBase * _Nonnull{
        return [[Model alloc] initWithNum:999];
    }];
    
    [self.view addSubview:collection];
    collection.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints:@[
        [collection.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:50],
        [collection.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0],
        [collection.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-100],
        [collection.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0],
    ]];

}

- (void)rsplayCollectionView:(RSPlayCollectionView *)collectionView willDisappearArray:(NSArray<NSNumber *> *)willDisappearArray {
    NSLog(@"willDisappearArray: %@", willDisappearArray);
}

- (void)rsplayCollectionView:(RSPlayCollectionView *)collectionView didDisappearArray:(NSArray<NSNumber *> *)didDisappearArray {
    NSLog(@"didDisappearArray: %@", didDisappearArray);
}

- (void)rsplayCollectionView:(RSPlayCollectionView *)collectionView didAppearArray:(NSArray<NSNumber *> *)didAppearArray {
    NSLog(@"didAppearArray: %@", didAppearArray);
}

- (void)rsplayCollectionView:(RSPlayCollectionView *)collectionView selectIndex:(NSInteger)selectIndex {
    NSLog(@"selectIndex: %ld", (long)selectIndex);
}

- (void)rsplayCollectionView:(RSPlayCollectionView *)collectionView deselectIndex:(NSInteger)deselectIndex {
    NSLog(@"deselectIndex: %ld", (long)deselectIndex);
}

- (void)rsplayCollectionView:(RSPlayCollectionView *)collectionView selectedItem:(NSInteger)selectedIndex moveTo:(NSInteger)index {
    NSLog(@"selectedItem: %ld moveTo: %ld", (long)selectedIndex, (long)index);
}

- (void)rsplayCollectionView:(RSPlayCollectionView *)collectionView cleanIndex:(NSInteger)cleanIndex {
    Model *model = (Model *)_dataSource.array[cleanIndex];
    [model clean];
    NSLog(@"cleanIndex: %ld", (long)cleanIndex);
}

@end
