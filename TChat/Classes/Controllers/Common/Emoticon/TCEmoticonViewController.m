//
//  TCEmoticonViewController.m
//  TChat
//
//  Created by SWATI KIRVE on 11/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import "TCEmoticonViewController.h"

@interface TCEmoticonViewController ()

@end

@implementation TCEmoticonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [_flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [_collectionView setCollectionViewLayout:_flowLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionView Datasource Methods
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return XAppDelegate.emoticonsArray.count;
}

-(void)configureCell:(TCEmoticonTableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath{
    
    _emoticonCell.imageView.image = [UIImage imageNamed:[[XAppDelegate.emoticonsArray valueForKey:@"name"] objectAtIndex:indexPath.row]];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = @"cell";
    _emoticonCell = (TCEmoticonTableViewCell*)[self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [self configureCell:_emoticonCell forIndexPath:indexPath];
    
    return _emoticonCell;
}

#pragma mark - CollectionView Delegate Methods
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    id selectedEmoticon = [XAppDelegate.emoticonsArray objectAtIndex:indexPath.row];
    if ([XAppDelegate.chatMessageDelegate respondsToSelector:@selector(emoticonSelected:)]) {
        [XAppDelegate.chatMessageDelegate emoticonSelected:[selectedEmoticon valueForKey:@"code"]];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
