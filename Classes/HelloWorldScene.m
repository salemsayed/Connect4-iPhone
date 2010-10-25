//
//  HelloWorldLayer.m
//  Connect4
//
//  Created by Salem Sayed on 10/25/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

// Import the interfaces
#import "HelloWorldScene.h"
#import "CCTouchDispatcher.h" //For targeted touch interaction

// HelloWorld implementation
@implementation HelloWorld

/*
int board[6][7] = { {11, 11, 11, 11, 11, 11, 11},
	
	{11, 11, 11, 12, 11, 11, 11},
	
	{11, 12, 12, 11, 11, 11, 11},
	
	{12, 11, 11, 11, 11, 11, 11},
	
	{11, 11, 11, 11, 11, 12, 0},
	
	{11, 11, 11, 11, 11, 11, 11}};
*/
int board[6][7] = {0};

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
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
		turn = 1;
		
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
														 priority:0
												  swallowsTouches:YES];
		
		chips = [[NSMutableArray alloc] init];
		
		CCSprite *boardSprite = [CCSprite spriteWithFile:@"board.png"];
		boardSprite.position = ccp(100 + boardSprite.contentSize.width / 2, boardSprite.contentSize.height / 2);
		
		[self addChild:boardSprite];
		[self drawBoard];
	}
	return self;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	int row = 0;
	int col = 0;
	NSMutableArray *chipToDelete = [[NSMutableArray alloc] init];
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];
	
	for (CCSprite *sprite in chips) {
		CGRect chipRect = CGRectMake(
									 sprite.position.x - (sprite.contentSize.width/2), 
									 sprite.position.y - (sprite.contentSize.height/2), 
									 sprite.contentSize.width, 
									 sprite.contentSize.height);
		if (CGRectContainsPoint(chipRect, convertedLocation)) {			

			NSString *rowAndCol = [NSString stringWithFormat:@"%d", sprite.tag];
			if ([rowAndCol length] == 1) {
				row = 0;
				col = [rowAndCol intValue];
			}else {
				row = [[NSString stringWithFormat:@"%c",[rowAndCol characterAtIndex:0]] intValue];
				col = [[NSString stringWithFormat:@"%c",[rowAndCol characterAtIndex:1]] intValue];
			}			
		}
	}
	//Traverse rows
	BOOL flag = FALSE;
	for (int i = 5; i >= 0; i--) {
		if (board[i][col] != 11 && board[i][col] != 12) {
			if (turn == 1) {
				board[i][col] = 11;
				row = i;
				flag = TRUE;
				break;
			}
			else {
				board[i][col] = 12;
				row = i;
				flag = TRUE;
				break;
			}			
		}
	}
	
	if (!flag) {
		return;
	}
	CCSprite *newChip;
	
	//Find the sprite to be removed and make the animation of insertion
	for (CCSprite *sprite in chips) {
		if (sprite.tag == ((row * 10) + col)) {
			
			[chipToDelete addObject:sprite];
			
			if (turn == 1) {
				newChip = [CCSprite spriteWithFile:@"redChip.png"];
				turn++;
			}else {
				newChip = [CCSprite spriteWithFile:@"greenChip.png"];
				turn--;
			}
			
			newChip.position = ccp(sprite.position.x, 340);
			newChip.tag = (row * 10) + col;
			
			[self addChild:newChip];

			id actionMove = [CCMoveTo actionWithDuration:1 position:ccp(sprite.position.x, sprite.position.y)];
			id actionMoveDone = [CCCallFuncND actionWithTarget:self
													  selector:@selector(spriteMoveFinished:data:) 
													data:[chipToDelete objectAtIndex:0] ];
			[newChip runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
			//newChip.rotation = 30;

		}
	}
	[chips replaceObjectAtIndex:[chips indexOfObject:[chipToDelete objectAtIndex:0]] withObject:newChip];
	
	[chipToDelete release];
	 
}

-(void) drawBoard 
{
	int xcent = 120;
	int	ycent = 230;
	for (int i = 0; i < 6; i++) {
		for (int j = 0; j < 7; j++) {
			if (board[i][j] == 11) {
				//Chip is present and belongs to player 1	
				CCSprite *redChipSprite = [CCSprite spriteWithFile:@"redChip.png"];
				redChipSprite.position = ccp(xcent + redChipSprite.contentSize.width / 2, 
											   ycent + redChipSprite.contentSize.height / 2);
				redChipSprite.tag = ( i * 10 ) + j;
				[chips addObject:redChipSprite];
				
				[self addChild:redChipSprite];
				xcent += 45;

			} else if (board[i][j] == 12) {
				//Chip is present and belongs to player 2
				CCSprite *greenChipSprite = [CCSprite spriteWithFile:@"greenChip.png"];
				greenChipSprite.position = ccp(xcent + greenChipSprite.contentSize.width / 2, 
											   ycent + greenChipSprite.contentSize.height / 2);
				greenChipSprite.tag = ( i * 10 ) + j;
				[chips addObject:greenChipSprite];
				
				[self addChild:greenChipSprite];
				xcent += 45;

			}else {
				//Empty slot
				CCSprite *whiteChipSprite = [CCSprite spriteWithFile:@"whiteChip.png"];
				whiteChipSprite.position = ccp(xcent + whiteChipSprite.contentSize.width / 2, 
											   ycent + whiteChipSprite.contentSize.height / 2);
				whiteChipSprite.tag = ( i * 10 ) + j;
				[chips addObject:whiteChipSprite];
				
				[self addChild:whiteChipSprite];
				xcent += 45;
			}
			
		}
		ycent -= 40;
		xcent = 120;
	}
	
}

-(void)spriteMoveFinished:(id)sender data: (id)toRemove {
	CCSprite *sprite = (CCSprite *)toRemove;
	[self removeChild:sprite cleanup:YES];
}



// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[chips release];
	chips = nil;
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
