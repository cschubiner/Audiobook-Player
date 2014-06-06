//
//  FolderCellTableViewCell.h
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import <UIKit/UIKit.h>
#import "Song.h"

@interface FolderCellTableViewCell : UITableViewCell


-(void)updateProgress;


@property (nonatomic, weak) Song * song;
@end
