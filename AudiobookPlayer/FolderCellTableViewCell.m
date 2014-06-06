//
//  FolderCellTableViewCell.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import "FolderCellTableViewCell.h"

@interface FolderCellTableViewCell ()

@property (nonatomic, strong) UIView * progressView;

@end

@implementation FolderCellTableViewCell

-(void)updateProgress {
    if (!self.song) return;
    double progress = self.song.currentPosition.doubleValue / self.song.duration.doubleValue;
	[self.progressView setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width * progress, self.frame.size.height)];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
	if (self) {
		self.progressView = [[UIView alloc]initWithFrame:self.frame];
		[self.progressView setBackgroundColor:[UIColor colorWithRed:0.0 green:.5 blue:1.0 alpha:.30]];
		[self setBackgroundView:self.progressView];
		[self addSubview:self.progressView];
        
		[NSTimer scheduledTimerWithTimeInterval:2.0
                                         target:self
                                       selector:@selector(updateProgress)
                                       userInfo:nil
                                        repeats:YES];
        
        //		[self.backgroundView addSubview:self.progressView];
        //		[self.backgroundView bringSubviewToFront:self.progressView];
	}
    
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
    
    //        [self addSubview:self.progressView];
	[self bringSubviewToFront:self.progressView];
    
	// Configure the view for the selected state
}


@end
