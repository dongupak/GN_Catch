//
//  MenuScene.h
//  GNCatch
//
//  Created by DongGyu Park( @dongupak ) on 11. 9. 8..
//  Copyright 2011 DongGyu Park. ( http://Cocos2dDev.com/ )All rights reserved.
//
//  2011 경남 모바일 앱 공모전"에서 최우수 수상앱
//

#import "cocos2d.h"
#import "SimpleAudioEngine.h"
#import "SceneManager.h"
#import "GNCatchAppDelegate.h"

@interface MenuLayer : CCLayer {
	SimpleAudioEngine *sae;
	
    CCMenuItem *startMenuItem;
    CCMenuItem *howtoMenuItem;
    CCMenuItem *logoIntroMenuItem;
    
	CCMenuItem *creditMenuItem;
}

@property (nonatomic, retain) CCMenuItem *startMenuItem;
@property (nonatomic, retain) CCMenuItem *howtoMenuItem;
@property (nonatomic, retain) CCMenuItem *logoIntroMenuItem;

@property (nonatomic, retain) CCMenuItem *creditMenuItem;

- (void) setBackgroundAndTitles;
- (void) goCreditScene: (id) sender;
- (void) howtoMenuCallback: (id) sender;
- (void) logoIntroCallback: (id) sender ;
- (void) newGameMenuCallback: (id) sender;

- (void) menuMoveUpDown:(id)sender withOffset:(int)offset;
- (void) menuMove1:(id)sender;
- (void) menuMove2:(id)sender;
@end
