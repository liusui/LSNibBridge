//
//  LSNibBridge.h
//  Pods
//
//  Created by liusui on 3/17/16.
//
//

#import <UIKit/UIKit.h>

@protocol LSNibBridge <NSObject>

@optional
/** 当你的Nib是从pod库中取得的时候，你应当实现该方法并且返回那个pod库的名字（文件夹名） */
- (nullable NSString *) LS_bundleOfURLForResourceWithFloderName;

/** 在生成View之前的操作 */
- (void)LS_willInitViewWithNibBridge;
/** 在生成View之后的操作 */
- (void)LS_didInitViewWithNibBridge;

@end

@interface UIView (LSNibConvention)

+ (nonnull instancetype)LS_instantiateFromNib;

@end
