//
//  NLPopularResultsViewController.m
//  Noctis
//
//  Created by Nick Lauer on 12-08-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLPopularResultsViewController.h"

#import "NLUtils.h"

@interface NLPopularResultsViewController ()

@end

@implementation NLPopularResultsViewController {
    BOOL isPastFirstRun_;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:[NLUtils getContainerTopInnerFrame]];
    [self.view setClipsToBounds:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark -
#pragma mark Getting Search Results

- (void)receiveYoutubeLinksFromFBLikes:(NSArray *)links
{
    [self finishLoading];
    self.youtubeLinksArray = [NSMutableArray arrayWithArray:links];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -
#pragma mark ChooserViewController Methods

- (UIImage *)getPlaceholderImage
{
    return [UIImage imageNamed:@"popular_songs"];
}

- (NSString *)getNavigationTitle
{
    return @"Popular Songs";
}

- (void)movedToMainView
{
    if (!isPastFirstRun_) {
        [self startLoading];
        [[NLYoutubeLinksFromFBLikesFactory sharedInstance] createYoutubeLinksForMostPopularVideos:self];
        isPastFirstRun_ = YES;
    }
}

- (void)removedFromMainView
{
    [self finishLoading];
}

@end
