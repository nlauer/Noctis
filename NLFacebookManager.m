//
//  NLFacebookManager.m
//  Noctis
//
//  Created by Nick Lauer on 12-07-21.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NLFacebookManager.h"

#define MY_APP_ID @"295403300558542"

@implementation NLFacebookManager {
    FacebookBlockAfterLogin block_;
}
@synthesize facebook = _facebook;

static NLFacebookManager *sharedInstance = NULL;

+ (NLFacebookManager *)sharedInstance
{
    @synchronized(self) {
        if (sharedInstance == NULL) {
            sharedInstance = [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _facebook = [[Facebook alloc] initWithAppId:MY_APP_ID andDelegate:self];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            _facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            _facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
    }
    
    return self;
}

- (BOOL)isSignedInWithFacebook
{
    return [_facebook isSessionValid];
}

- (void)signInWithFacebook
{
    if (![_facebook isSessionValid]) {
        NSArray *params = [NSArray arrayWithObjects:@"read_stream", @"friends_likes",nil];
        [_facebook authorize:params];
    }
}

- (void)performBlockAfterFBLogin:(FacebookBlockAfterLogin)block
{
    if (![_facebook isSessionValid]) {
        block_ = block;
        [self signInWithFacebook];
    } else {
        block();
    }
}

#pragma mark -
#pragma mark FBSessionDelegate
- (void)fbDidLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    if (block_) {
        block_();
    }
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
    NSLog(@"Login Cancelled");
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please Sign In" 
                                                        message:@"This action requires Facebook Login"
                                                       delegate:nil 
                                              cancelButtonTitle:@"Okay" 
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)fbSessionInvalidated
{
    
}

- (void)fbDidLogout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    NSLog(@"token extended");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

@end
