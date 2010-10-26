//
//  WinnerScene.m
//  Connect4
//
//  Created by Salem Sayed on 10/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WinnerScene.h"
#import "Connect4AppDelegate.h"

@implementation WinnerScene
@synthesize winner;

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	WinnerScene *layer = [WinnerScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
		
		Connect4AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		winner = [CCLabel labelWithString:delegate.winner fontName:@"Arial" fontSize:30];
		winner.color = ccc3(0, 0, 0);
		winner.position = ccp(winSize.width/2, winSize.height/2);
		
		[self addChild:winner];
		
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[winner release];
	winner = nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
