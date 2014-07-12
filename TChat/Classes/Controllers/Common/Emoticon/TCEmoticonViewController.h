//
//  TCEmoticonViewController.h
//  TChat
//
//  Created by SWATI KIRVE on 11/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCEmoticonTableViewCell.h"
#import "TCAppDelegate.h"

@interface TCEmoticonViewController : UIViewController<UICollectionViewDataSource,
UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) TCEmoticonTableViewCell *emoticonCell;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end
