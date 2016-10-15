//
//  HOLockView.h
//  Gesture Unlock
//
//  Created by Phoenix on 10/14/16.
//  Copyright © 2016 Phoenix. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HOLockView;
@protocol HOLockViewDelegate <NSObject>

- (BOOL)lockView:(HOLockView *)lockView withPasswd:(NSString *)passwd;

@end
@interface HOLockView : UIView

/** delegate */
@property (weak, nonatomic) id<HOLockViewDelegate> delegate;

@end
