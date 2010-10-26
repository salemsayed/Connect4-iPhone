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
#include "Connect4AppDelegate.h"

// HelloWorld implementation
@implementation HelloWorld
@synthesize turnArrow;

int board[6][7] = { {0, 0, 0, 0, 0, 0, 0},
	
	{0, 0, 0, 0, 0, 0, 0},
	
	{0, 0, 0, 0, 0, 0, 0},
	
	{0, 0, 0, 0, 0, 0, 0},
	
	{0, 0, 0, 0, 0, 0, 0},
	
	{0, 0, 0, 0, 0, 0, 0}};

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
		
		CCLabel *player1Label = [CCLabel labelWithString:@"Player 1" fontName:@"Arial" fontSize:10];
		player1Label.color = ccc3(0, 0, 0);
		player1Label.position = ccp(45, 260);
		
		[self addChild:player1Label];
		
		CCSprite *player1Chip = [CCSprite spriteWithFile:@"redChip.png"];
		player1Chip.position = ccp(80, 260);
		player1Chip.scale = .5f;
		
		[self addChild:player1Chip];
		
		CCLabel *player2Label = [CCLabel labelWithString:@"Player 2" fontName:@"Arial" fontSize:10];
		player2Label.color = ccc3(0, 0, 0);
		player2Label.position = ccp(45, 240);
		
		[self addChild:player2Label];
		
		CCSprite *player2Chip = [CCSprite spriteWithFile:@"greenChip.png"];
		player2Chip.position = ccp(80, 240);
		player2Chip.scale = .5f;
		
		[self addChild:player2Chip];
		
		turnArrow = [CCSprite spriteWithFile:@"turnArrow.png"];
		turnArrow.position = ccp(15, 260);
		
		[self addChild:turnArrow];
		
		turn = 1;
		win = 0;
		gameEnd = FALSE;
		isAnimating = FALSE;
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
														 priority:0
												  swallowsTouches:YES];
		
		chips		  = [[NSMutableArray alloc] init];
		winningComboX = [[NSMutableArray alloc] init];
		winningComboY = [[NSMutableArray alloc] init];
		
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
	
	if (gameEnd || isAnimating) {
		return;
	}
	int row = 0;
	int col = 0;
	NSMutableArray *chipToDelete = [[NSMutableArray alloc] init];
	CGPoint location = [touch locationInView: [touch view]];
	CGPoint convertedLocation = [[CCDirector sharedDirector] convertToGL:location];

	BOOL flag = FALSE;

	for (CCSprite *sprite in chips) {
		CGRect chipRect = CGRectMake(
									 sprite.position.x - (sprite.contentSize.width/2), 
									 sprite.position.y - (sprite.contentSize.height/2), 
									 sprite.contentSize.width, 
									 sprite.contentSize.height);
		if (CGRectContainsPoint(chipRect, convertedLocation)) {		
			
			flag = TRUE;
			
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
	if (!flag) {
		return;
	}
	//Traverse rows
	flag = FALSE;
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
				[self checkIfWin:row withCol:col withPlayer:turn];
				turn++;
			}else {
				newChip = [CCSprite spriteWithFile:@"greenChip.png"];
				[self checkIfWin:row withCol:col withPlayer:turn];
				turn--;
			}
			
			newChip.position = ccp(sprite.position.x, 340);
			newChip.tag = (row * 10) + col;
			
			[self addChild:newChip];

			id actionMove = [CCMoveTo actionWithDuration:1 position:ccp(sprite.position.x, sprite.position.y)];
			id actionMoveDone = [CCCallFuncND actionWithTarget:self
													  selector:@selector(spriteMoveFinished:data:) 
													data:[chipToDelete objectAtIndex:0] ];
			id actionPostMove = [CCCallFuncN actionWithTarget:self selector:@selector(highlightWinningPieces:)];
			id actionChangeTurnArrow = [CCCallFuncN actionWithTarget:self selector:@selector(changeTurnArrow:)];
			id actionAnnounceWinner = [CCCallFunc actionWithTarget:self selector:@selector(announceWinner)];
			isAnimating = TRUE;
			[newChip runAction:[CCSequence actions:actionMove, actionMoveDone, 
								actionPostMove, actionChangeTurnArrow, actionAnnounceWinner, nil]];
			//newChip.rotation = 30;
			
		}
	}
	[chips replaceObjectAtIndex:[chips indexOfObject:[chipToDelete objectAtIndex:0]] withObject:newChip];
	
	[chipToDelete release];
	 
}
-(void) announceWinner {
	if (gameEnd) {
		Connect4AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
		[delegate declareWinner];
	}	
}


-(void) changeTurnArrow:(id)sender {
	if (!gameEnd) {
		if (turn == 2) {
			[turnArrow runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(15, 240)]];	
		}else {
			[turnArrow runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(15, 260)]];
		}
	}
}

-(void) checkIfWin:(int)row withCol:(int)col withPlayer:(int)pl
{
	for (int k = 1; k < 9; k++) {
		//This will count the number of pieces in both directions. for an example
		//--> and <-- starting from the piece just inserted to both directions.
		//The value of win will indicate if there is a winning situation or not.
		win = 0;
		[self checkWinnerRow:row withCol:col withDirection:k withPlayer:pl];
		k++;
		[self checkWinnerRow:row withCol:col withDirection:k withPlayer:pl];
		if (win > 4) {
			gameEnd = TRUE;
			Connect4AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
			if (turn == 1) {
				//player 1 won
				NSString *winningPlayer = [[NSString alloc] init];
				winningPlayer = @"Player 1 Wins!";
				delegate.winner = winningPlayer;
				[winningPlayer release];
				
			}else {
				NSString *winningPlayer = [[NSString alloc] init];
				winningPlayer = @"Player 2 Wins!";
				delegate.winner = winningPlayer;
				[winningPlayer release];
			}

			return;
		}
	}
}

-(void) highlightWinningPieces:(id) sender
{
	if (gameEnd) {
		int row = 0;
		int col = 0;
		for (int k = 1; k < win; k++) {
			row = [[winningComboX objectAtIndex:[winningComboX count] - k - 1] intValue];
			col = [[winningComboY objectAtIndex:[winningComboY count] - k - 1] intValue];
			for (CCSprite *sprite in chips) {
				if (sprite.tag == ((row * 10) + col)){
					[sprite setTexture:[[CCTextureCache sharedTextureCache] addImage:@"goldChip.png"]];
				}
			}
		}	
	}	
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
											ycent  + redChipSprite.contentSize.height / 2);
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
	isAnimating = FALSE;
}

-(void) checkWinnerRow:(int)x withCol: (int)y withDirection: (int)dir withPlayer: (int)pl
{	
	//Base case
	if ((board[x][y] != 11 && board[x][y] != 12) || x > 5 || y > 6 || x < 0 || y < 0) {
		return ;
	}else {
		switch (dir) {
			case 1:
				if (pl == 1 && board[x][y] == 11) {		
					//NSLog(@"case 1");

					//Adding the current chip to array that has the *probable* winning chips
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
					//Recursive call
					win++;
					
					[self checkWinnerRow:x withCol:y+1 withDirection:1 withPlayer:1];
				}else if (pl == 2 && board[x][y] == 12) {	
					
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x withCol:y+1 withDirection:1 withPlayer:2];
				}
				break;				
			case 2:
				if (pl == 1 && board[x][y] == 11) {		
					//nslog(@"case 3");
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x withCol:y-1 withDirection:2 withPlayer:1];
				}else if (pl == 2 && board[x][y] == 12) {	
					
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x withCol:y-1 withDirection:2 withPlayer:2];
				}				
				break;
			case 3:
				if (pl == 1 && board[x][y] == 11) {
					//NSlog(@"case 3");
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x+1 withCol:y withDirection:3 withPlayer:1];

				}else if (pl == 2 && board[x][y] == 12) {
					
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x+1 withCol:y withDirection:3 withPlayer:2];
				}				
				break;
			case 4:
				if (pl == 1 && board[x][y] == 11 ) {
					//cout << "Case 4" << endl;
					//NSlog(@"case 4");
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x-1 withCol:y withDirection:4 withPlayer:1];

				}else if (pl == 2 && board[x][y] == 12 ) {
					
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x-1 withCol:y withDirection:4 withPlayer:2];
				}				
				break;
			case 5:
				if (pl == 1 && board[x][y] == 11 ) {
					//cout << "Case 5" << endl;
					//NSlog(@"case 5");
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x+1 withCol:y+1 withDirection:5 withPlayer:1];

				}else if (pl == 2 && board[x][y] == 12 ) {
					
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x+1 withCol:y+1 withDirection:5 withPlayer:2];
				}				
				break;
			case 6:
				if (pl == 1 && board[x][y] == 11 ) {
					//cout << "Case 6" << endl;
					//NSlog(@"case 6");
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x-1 withCol:y-1 withDirection:6 withPlayer:1];

				}else if (pl == 2 && board[x][y] == 12 ) {
					
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x-1 withCol:y-1 withDirection:6 withPlayer:2];
				}
				break;
			case 7:
				if (pl == 1 && board[x][y] == 11 ) {
					//cout << "Case 7" << endl;
					//NSlog(@"case 7");
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x+1 withCol:y-1 withDirection:7 withPlayer:1];

				}else if (pl == 2 && board[x][y] == 12 ) {
					
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x+1 withCol:y-1 withDirection:7 withPlayer:2];
				}
				break;
			case 8:
				if (pl == 1 && board[x][y] == 11 ) {
					//cout << "Case 8" << endl;
					//NSlog(@"case 8");
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x-1 withCol:y+1 withDirection:8 withPlayer:1];

				}else if (pl == 2 && board[x][y] == 12 ) {
					
					NSNumber *rowNum = [[NSNumber alloc] initWithInt:x];
					NSNumber *colNum = [[NSNumber alloc] initWithInt:y];
					
					[winningComboX addObject:rowNum];
					[winningComboY addObject:colNum];
					
					[rowNum release];
					[colNum release];
					
										win++;
					[self checkWinnerRow:x-1 withCol:y+1 withDirection:8 withPlayer:2];
				}				
				break;		
			default:
				break;
		}
	}
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[chips release];
	chips = nil;
	[winningComboX release];
	winningComboX = nil;
	[winningComboY release];
	winningComboY = nil;
	[turnArrow release];
	turnArrow = nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
