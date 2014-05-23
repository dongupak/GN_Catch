//
//  Logo.h
//  GNCatch
//
//  Created by DongGyu Park( @dongupak ) on 11. 9. 8..
//  Copyright 2011 DongGyu Park. ( http://Cocos2dDev.com/ )All rights reserved.
//
//  2011 경남 모바일 앱 공모전"에서 최우수 수상앱
//
#import <Foundation/Foundation.h>
#import "cocos2d.h"

// 게임에서 사용할 로고 스프라이트 
@interface Logo : CCSprite {
    BOOL isAlive;
}

@property BOOL isAlive;

- (void) logoAction;
- (BOOL) isOutsideWindow:(CGSize) windowSize;
- (void) pop;
- (void) finishedPopSequence;

@end
