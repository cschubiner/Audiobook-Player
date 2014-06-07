//
//  FolderCellTableViewCell.h
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import "Song.h"
#import <UIKit/UIKit.h>

@interface FolderCellTableViewCell : UITableViewCell


-(void)updateProgress;


@property (nonatomic, strong) Song * song;
@property (nonatomic) BOOL isDirectory;

@end
