//
//  HelloWorldLayer.h
//  Connect4
//
//  Created by Salem Sayed on 10/25/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorld Layer
@interface HelloWorld : CCColorLayer
{
	NSMutableArray *chips, *winningComboX, *winningComboY;
	int turn, win;
	BOOL gameEnd;
}
// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
-(void) drawBoard;
-(void) checkIfWin:(int)row withCol: (int)col withPlayer: (int)pl;
-(void) spriteMoveFinished:(id)sender data: (id)toRemove;
-(void) checkWinnerRow:(int)x withCol: (int)y withDirection: (int)dir withPlayer: (int)pl;
-(void) highlightWinningPieces:(id)sender;

@end
