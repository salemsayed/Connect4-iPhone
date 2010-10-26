//
//  MenuScene.h
//  Connect4
//
//  Created by Salem Sayed on 10/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


@interface MenuScene : CCColorLayer {

	CCLabel *welcome;
}

@property (nonatomic, retain) CCLabel *welcome;
+(id) scene;


@end
