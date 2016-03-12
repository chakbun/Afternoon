//
//  AftImageAblumController.m
//  Afternoon
//
//  Created by Jaben on 15/10/25.
//  Copyright © 2015年 After. All rights reserved.
//

#import "AftAlbumController.h"
#import <BmobSDK/Bmob.h>
#import <BmobSDK/BmobProFile.h>
#import "UIImageView+WebCache.h"
#import "AftAlbum.h"
#import "AftAlbumCell.h"
#import "AppConstants.h"
#import "UIColor+JRColor.h"

@interface AftAlbumController ()<UITableViewDataSource,UITableViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *albumTableView;

@property (nonatomic, strong) NSMutableArray *albumArray;

@property (nonatomic, strong) NSMutableDictionary *cellHeightDictionary;

@end

@implementation AftAlbumController

- (void)viewDidLoad {
    
    [super viewDidLoad];
        
    self.albumArray = [NSMutableArray array];
    self.cellHeightDictionary = [NSMutableDictionary dictionary];
    
    __weak __typeof(self) weakSelf = self;

    BmobQuery *bquery = [BmobQuery queryWithClassName:@"table_album"];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        
        for(BmobObject *obj in array) {
            
            AftAlbum *album = [AftAlbum new];

            BmobFile *imageFile = [obj objectForKey:@"originImage"];

            album.imageURL = imageFile.url;
            album.author = [obj objectForKey:@"author"];
            album.title = [obj objectForKey:@"title"];
            album.intro = [obj objectForKey:@"intro"];
            
            [weakSelf.albumArray addObject:album];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [weakSelf.albumTableView reloadData];
        });
    }];
    
    self.albumTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.albumTableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (NSString *)keyFromIndexPath:(NSIndexPath *)indexPath {
    return [NSString stringWithFormat:@"key_%i_%i",(int)indexPath.section,(int)indexPath.row];
}

- (NSAttributedString *)attributestringWithTitle:(NSString *)title author:(NSString *)author {

    
    NSMutableAttributedString *attributeTitleString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",title,author]];
    
    NSRange titleRange = NSMakeRange(0, title.length);
    NSRange authorRange = NSMakeRange(title.length+1, author.length);
    
    //回复评论
    [attributeTitleString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:titleRange];
    
    [attributeTitleString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:authorRange];
    [attributeTitleString addAttribute:NSForegroundColorAttributeName value:[UIColor color4SimpleWithRed:111 green:113 blue:121 alpha:1.0] range:authorRange];

    return attributeTitleString;
}

#pragma mark - TabelView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumber *heightNumber = self.cellHeightDictionary[[self keyFromIndexPath:indexPath]];
    if (heightNumber) {
        return [heightNumber floatValue];
    }
    return 180;
}

#pragma mark - TabelView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AftAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID_ABLUM forIndexPath:indexPath];
    
    AftAlbum *album = self.albumArray[indexPath.row];
    

    __weak __typeof(self) weakSelf = self;
    
    CGFloat introHeight = [album.intro boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - (MARGINS * 2), MAXFLOAT) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0]} context:nil].size.height;
    
    introHeight = MAX(16, introHeight);
    
    cell.introLabelHeightConstraint.constant = introHeight;
    [cell.introLabel sizeToFit];
    
    [cell.albumImageView sd_setImageWithURL:[NSURL URLWithString:album.imageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        if (!weakSelf.cellHeightDictionary[[weakSelf keyFromIndexPath:indexPath]]) {
            
            CGFloat showHeight = (SCREEN_WIDTH - (MARGINS * 2)) * image.size.height / image.size.width;
            CGFloat cellHeight = MARGINS + 22 + MARGINS + introHeight + MARGINS + showHeight + 20;
            weakSelf.cellHeightDictionary[[weakSelf keyFromIndexPath:indexPath]] = @(cellHeight);
            [weakSelf.albumTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
    }];
    
    cell.albumTitleLabel.attributedText = [self attributestringWithTitle:album.title author:album.author];
    
    cell.introLabel.text = album.intro;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end