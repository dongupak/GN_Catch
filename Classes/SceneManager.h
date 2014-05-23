//
//  SceneManager.h
//  GNCatch
//
//  Created by DongGyu Park( @dongupak ) on 11. 9. 8..
//  Copyright 2011 DongGyu Park. ( http://Cocos2dDev.com/ )All rights reserved.
//
//  2011 경남 모바일 앱 공모전"에서 최우수 수상앱
//
#import <Foundation/Foundation.h>

#import "MenuLayer.h"
#import "GameLayer.h"
#import "GameOverLayer.h"
#import "HowtoLayer.h"
#import "CreditLayer.h"
#import "LogoIntroLayer.h"

// SceneManager 클래스로 Menu, Game, GameOver, Credit Layer로의 
// 전환을 담당하는 역할을 한다
@interface SceneManager : NSObject {
}

// goXXX의 경우 정적 메소드임. 
+(void) goMenu;
+(void) goGame;
+(void) goGameOver;
+(void) goCredit;
+(void) goHowto;
+(void) goLogoIntro;

@end
