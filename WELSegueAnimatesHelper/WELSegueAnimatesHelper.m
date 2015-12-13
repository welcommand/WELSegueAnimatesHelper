
//
//  WELSegueAnimatesHelper.m
//  LinApp
//
//  Created by WELCommand on 15/10/30.
//  Copyright © 2015年 WELCommand. All rights reserved.
//

#import "WELSegueAnimatesHelper.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

static NSString *animatesKey = @"WELAnimates";

@implementation WELSegueAnimatesHelper


-(id)wsl_initWithCoder:(id)x { return nil; }

-(id)wsl_segueWithDestinationViewController:(id)x{ return nil; }



id wsl_initWithCoder(id self, SEL _cmd, NSCoder *coder) {
    
    id obj = [self wsl_initWithCoder:coder];
    
    BOOL animates = YES;
    if([coder containsValueForKey:@"UIAnimates"]) {
        animates = [coder decodeBoolForKey:@"UIAnimates"];
    }
    
    setUIAnimates(self, animates);
    
    return obj;
}



void setUIAnimates(id self, BOOL animates) {
    objc_setAssociatedObject(self,  (__bridge const void *)(animatesKey), @(animates), OBJC_ASSOCIATION_COPY);
}

BOOL UIAnimates(id self) {
    return [objc_getAssociatedObject(self, (__bridge const void *)(animatesKey)) boolValue];
}


id wsl_segueWithDestinationViewController(id self, SEL _cmd, id s) {
    id segue = [self wsl_segueWithDestinationViewController:s];
    setUIAnimates(segue, UIAnimates(self));
    objc_removeAssociatedObjects(self);
    
    return segue;
}


+(void)load {
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) return;
    
    class_addMethod(NSClassFromString(@"UIStoryboardSegueTemplate"), NSSelectorFromString(@"wsl_initWithCoder:"), (IMP)wsl_initWithCoder, "@12@0:4@8");
    Method m1 = class_getInstanceMethod(NSClassFromString(@"UIStoryboardSegueTemplate"),NSSelectorFromString(@"wsl_initWithCoder:"));
    Method m2 = class_getInstanceMethod(NSClassFromString(@"UIStoryboardSegueTemplate"), NSSelectorFromString(@"initWithCoder:"));
    method_exchangeImplementations(m1, m2);
    
    class_addMethod(NSClassFromString(@"UIStoryboardSegueTemplate"), NSSelectorFromString(@"wsl_segueWithDestinationViewController:"), (IMP)wsl_segueWithDestinationViewController, "@24@0:8@16");
    m1 = class_getInstanceMethod(NSClassFromString(@"UIStoryboardSegueTemplate"),NSSelectorFromString(@"wsl_segueWithDestinationViewController:"));
    m2 = class_getInstanceMethod(NSClassFromString(@"UIStoryboardSegueTemplate"), NSSelectorFromString(@"segueWithDestinationViewController:"));
    method_exchangeImplementations(m1, m2);
    
    m1 = class_getInstanceMethod([self class],NSSelectorFromString(@"WELPushPerform"));
    m2 = class_getInstanceMethod(NSClassFromString(@"UIStoryboardPushSegue"), NSSelectorFromString(@"perform"));
    method_exchangeImplementations(m1, m2);
    
    m1 = class_getInstanceMethod([self class],NSSelectorFromString(@"WELModalPerform"));
    m2 = class_getInstanceMethod(NSClassFromString(@"UIStoryboardModalSegue"), NSSelectorFromString(@"perform"));
    method_exchangeImplementations(m1, m2);
}


-(void)WELPushPerform {
    BOOL animates = UIAnimates(self);
    [((UIStoryboardSegue *)self).sourceViewController.navigationController pushViewController:((UIStoryboardSegue *)self).destinationViewController animated:animates];
    objc_removeAssociatedObjects(self);
}

-(void)WELModalPerform {
    BOOL animates = UIAnimates(self);
    [((UIStoryboardSegue *)self).sourceViewController presentViewController:((UIStoryboardSegue *)self).destinationViewController animated:animates completion:nil];
    objc_removeAssociatedObjects(self);
}

@end
