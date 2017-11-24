//
//  LSNibBridge.m
//  Pods
//
//  Created by liusui on 3/17/16.
//
//

#import "LSNibBridge.h"
#import <objc/runtime.h>

@interface UIView (LSNibBridge)
- (nullable instancetype)initHackWithCoder:(NSCoder *)aDecoder;
@end

@implementation UIView (LSNibBridge)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalSelector = @selector(initWithCoder:);
        SEL swizzledSelector = @selector(initHackWithCoder:);
        Method originalMethod = class_getInstanceMethod(UIView.class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        if (class_addMethod(UIView.class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
            class_replaceMethod(UIView.class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (nullable instancetype)initHackWithCoder:(NSCoder *)aDecoder
{
    self = [self initHackWithCoder:aDecoder];
    if (self) {
        [self LS_setupViewFromNib];
    }
    return self;
}

#pragma mark - Private Methods

- (void)LS_setupViewFromNib
{
    if ([self conformsToProtocol:@protocol(LSNibBridge)] && self.subviews.count == 0) {
        if ([self respondsToSelector:@selector(LS_willInitViewWithNibBridge)]) {
            [self performSelector:@selector(LS_willInitViewWithNibBridge)];
        }
        UIView *view = [self LS_instantiateSubviewFromNib];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1 constant:0]
                               ]];
        if ([self respondsToSelector:@selector(LS_didInitViewWithNibBridge)]) {
            [self performSelector:@selector(LS_didInitViewWithNibBridge)];
        }
    }
}

- (UIView *)LS_instantiateSubviewFromNib
{
    Class cls = [self class];
    NSBundle * bundle;
    if ([self respondsToSelector:@selector(LS_bundleOfURLForResourceWithFloderName)]) {
        NSString * floderName = [self performSelector:@selector(LS_bundleOfURLForResourceWithFloderName)];
        bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:self.class] URLForResource:floderName withExtension:@"bundle"]];
    }
    else {
        bundle = [NSBundle bundleForClass:cls];
    }
    
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(cls) bundle:bundle];
    NSArray *views = [nib instantiateWithOwner:self options:nil];
    NSUInteger index = [views indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj isKindOfClass:[UIView class]];
    }];
    return (index == NSNotFound) ? nil : views[index];
}

@end

@implementation UIView (LSNibConvention)

#pragma mark - Public Methods

+ (instancetype)LS_instantiateFromNib
{
    id view = [[self class] new];
    if (view) {
        ((UIView *)view).translatesAutoresizingMaskIntoConstraints = NO;
        [view LS_setupViewFromNib];
    }
    return view;
}

@end
