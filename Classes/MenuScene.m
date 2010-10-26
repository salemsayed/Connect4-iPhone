//
//  MenuScene.m
//  Connect4
//
//  Created by Salem Sayed on 10/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuScene.h"
#import "Connect4AppDelegate.h"


@implementation MenuScene
@synthesize welcome;

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MenuScene *layer = [MenuScene node];
	
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
	
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		self.welcome = [CCLabel labelWithString:@"Welcome to Connect 4" fontName:@"Arial" fontSize:32];
		welcome.color = ccc3(0,0,0);
		welcome.position = ccp(winSize.width/2, 250);
		
		[self addChild:welcome];
		
		// Create some menu items
		CCMenuItemImage * menuItem1 = [CCMenuItemImage itemFromNormalImage:@"newGame.png"
															 selectedImage: @"newGame_selected.png"
																	target:self
																  selector:@selector(newGame:)];
		
		// Create a menu and add your menu items to it
		CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, nil];
		
		// Arrange the menu items vertically
		[myMenu alignItemsVertically];
		
		// add the menu to your scene
		[self addChild:myMenu];
		
	}
	return self;
}

- (void) newGame: (CCMenuItem  *) menuItem 
{
	Connect4AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	[delegate startNewGame];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[welcome release];
	welcome = nil;
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
