//
//  PhotoListTableCell.h
//  TagTheBus
//
//  Created by Rost on 25.10.16.
//  Copyright © 2016 Rost Gress. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *photoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *photoDateLabel;

@end
