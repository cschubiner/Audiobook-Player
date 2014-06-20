//
//  FolderCellTableViewCell.m
//  AudiobookPlayer
//
//  Created by Clay Schubiner on 5/29/14.
//
//

#import "ProgressCellTableViewCell.h"

@interface ProgressCellTableViewCell ()

@property (nonatomic, strong) UIView * progressView;
@property (nonatomic, strong) NSNumber * lastPosition;

@end

@implementation ProgressCellTableViewCell

-(void)setIsDirectory:(BOOL)isDirectory {
	if (isDirectory) {
		[self.progressView setBackgroundColor:[UIColor colorWithRed:0.0 green:1.0 blue:.5 alpha:.25]];
	}
}


-(void)updateProgress {
	if (self.isDirectory && timer) {
		[timer invalidate];
		timer = nil;
	}
    
	if (!self.song) {
		//		[self.progressView setBackgroundColor:[UIColor colorWithRed:0.0 green:.2 blue:.2 alpha:.30]];
		//        [self.progressView setFrame:self.frame];
		return;
	}
    
	BOOL isPlaying = self.lastPosition.doubleValue + .000001 < self.song.currentPosition.doubleValue;
	//	isPlaying = self.song.isLastPlayed.boolValue;
    
	originalFrame = self.frame;
    
	if (isPlaying)
		[self.progressView setBackgroundColor:[UIColor colorWithRed:0.7 green:.5 blue:1.0 alpha:.30]];
	else
		[self.progressView setBackgroundColor:[UIColor colorWithRed:0.0 green:.5 blue:1.0 alpha:.30]];
    
    if ([self.song.currentPosition isEqualToNumber:[NSNumber numberWithInt:0]]) {
		[self.progressView setFrame:CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, 0, self.progressView.frame.size.height)];
    }
    else if (isPlaying) {
		double progress = self.song.currentPosition.doubleValue / self.song.duration.doubleValue;
		if (isnan(progress))
			progress = 0;
        
		[self.progressView setFrame:CGRectMake(self.progressView.frame.origin.x, self.progressView.frame.origin.y, originalFrame.size.width * progress, self.progressView.frame.size.height)];
		self.lastPosition = self.song.currentPosition;
	}
    
	[self bringSubviewToFront:self.progressView];
    
}

CGRect originalFrame;
NSTimer* timer;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
	if (self) {
		originalFrame = self.frame;
		self.progressView = [[UIView alloc]initWithFrame:self.frame];
		[self.progressView setBackgroundColor:[UIColor colorWithRed:0.0 green:.2 blue:.2 alpha:.30]];
		[self addSubview:self.progressView];
        
		timer = [NSTimer scheduledTimerWithTimeInterval:1.3
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
	self.lastPosition = [NSNumber numberWithDouble:0];
	[self updateProgress];
    
	// Configure the view for the selected state
}


@end
