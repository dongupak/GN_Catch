//
//  GameOverScene.m
//  GNCatch
//
//  Created by DongGyu Park( @dongupak ) on 11. 9. 8..
//  Copyright 2011 DongGyu Park. ( http://Cocos2dDev.com/ )All rights reserved.
//
//  2011 경남 모바일 앱 공모전"에서 최우수 수상앱
//

#import "GameOverLayer.h"
#import "GameLayer.h"
#import "GNCatchAppDelegate.h"

@implementation GameOverLayer

enum {
    kTagBackground = 0,
    kTagScoreLabel,
    kTagMenu,
};

- (id) init {
	if( (self=[super init]) ) {
        // 배경 이미지를 표시하기 위해 Sprite를 이용합니다.
        CCSprite *bgSprite = [CCSprite spriteWithFile:@"bg_gameover.png"];
        bgSprite.anchorPoint = CGPointZero;
        [bgSprite setPosition: ccp(0, 0)];
        [self addChild:bgSprite z:kTagBackground tag:kTagBackground];
		
        // 게임오버 레이어의 타이틀..
//        CCSprite *gameOverTitle = [CCSprite spriteWithFile:@"title_gameover.png"];
//        gameOverTitle.anchorPoint = CGPointZero;
//        [gameOverTitle setPosition: ccp(10, 320)];
//        [self addChild:gameOverTitle z:300 tag:kTagBackground];
		
        GNCatchAppDelegate *appDelegate = (GNCatchAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *scoreString = [NSString stringWithFormat:@" %5d", appDelegate.gameScore];
        CCLabel* label = [[CCLabel alloc] initWithString:scoreString
                                                fontName:@"Arial" 
                                                fontSize:40];
        label.color = ccc3(0, 0, 0);
        label.anchorPoint = CGPointZero;
        label.position = ccp(65, 165);
        [self addChild:label z:1000 tag:kTagScoreLabel];

		// 음악설정
		music=[SimpleAudioEngine sharedEngine];
        
        // 메뉴 버튼을 만듭니다.
        // itemFromNormalImage는 버튼이 눌려지기 전에 보여지는 이미지이고, 
        // selectedImage는 버튼이 눌려졌을 때 보여지는 이미지입니다.
        // target을 self로 한 것은 버튼이 눌려졌을 때 발생하는 터치 이벤트를 GameScene에서 
        // 처리를 하겠다는 것입니다.
        // @selector를 이용하여 버튼이 눌려졌을 때 어떤 메소드에서 처리를 할 것인지 결정합니다.
        CCMenuItem *closeMenuItem = [CCMenuItemImage itemFromNormalImage:@"btn_menu.png" 
                                                        selectedImage:@"btn_menu_s.png" 
                                                                  target:self 
                                                                selector:@selector(closeMenuCallback:)];
		
//		CCMenuItem *ScoreMenuItem = [CCMenuItemImage itemFromNormalImage:@"btn_ranking.png" 
//                                                    selectedImage:@"btn_ranking_s.png" 
//                                                                  target:self 
//                                                                selector:@selector(ScoreMenuCallback:)];
        
        // 위에서 만들어 메뉴 아이템들을 CCMenu에 넣습니다.  
        // CCMenu는 각각의 메뉴 버튼이 눌려졌을 때 발생하는 터치 이벤트를 핸들링하고,
        // 메뉴 버튼들이 어떻게 표시될 것인 지 레이아웃 처리를 담당합니다.
        CCMenu *menu1 = [CCMenu menuWithItems: closeMenuItem, nil];
//		CCMenu *menu2 = [CCMenu menuWithItems: ScoreMenuItem, nil];
        
        // 메뉴의 위치를 화면 가운데 아래로 정하겠습니다. cocos2D의 좌표계는 Cocoa와 정반대입니다.
        // Cocoa의 (0, 0)의 위치는 왼쪽 위인 것에 반해, cocos2D의 (0, 0)는 왼쪽 아래입니다.
        menu1.position = CGPointMake(80, 40);
//		menu2.position = CGPointMake(240, 40);
        
        // 만들어진 메뉴를 배경 sprite 위에 표시합니다.
        [self addChild:menu1 z:kTagMenu tag:kTagMenu];
//		[self addChild:menu2 z:kTagMenu tag:kTagMenu];
    }	
    
	return self;
}

- (void) closeMenuCallback: (id) sender {
    // 더 이상 사용되지않는 그래픽 캐시를 지웁니다.
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	[music playEffect:@"GN_jjan.m4a"];
	[SceneManager goMenu];
}

@end
