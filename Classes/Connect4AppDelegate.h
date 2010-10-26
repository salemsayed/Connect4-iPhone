//
//  Connect4AppDelegate.h
//  Connect4
//
//  Created by Salem Sayed on 10/25/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Connect4AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow *window;
	NSString *winner;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) NSString *winner;

-(void) startNewGame;
-(void) declareWinner;

@end
