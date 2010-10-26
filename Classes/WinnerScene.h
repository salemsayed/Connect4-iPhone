//
//  WinnerScene.h
//  Connect4
//
//  Created by Salem Sayed on 10/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface WinnerScene : CCColorLayer {
	CCLabel *winner;
}
@property (nonatomic, retain) CCLabel *winner;

+(id) scene;
@end
