#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Cloud : CCSprite {
	BOOL direction;
	float spd;
}
-(id)initWithFile:(NSString *)filename;
-(void)move;
-(void)setting:(BOOL)d;
-(BOOL)getDirection;
@end
