//
//  ViewController.m
//  MTRuntimeTestDemo
//
//  Created by Ryan on 16/3/23.
//  Copyright © 2016年 Ryan. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "MTCustomClass.h"

@interface ViewController ()
{
//    IMP cFuncPointer;
//    IMP cFuncPointer1;
//    IMP cFuncPointer2;
}

@property (nonatomic, assign) float myFloat;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.myFloat = 10.2;
    
    
    /*
     *  testExampleCode
     */
    
    [self getClassAllMethods];
    
    [self getClassAllPropertyNames];
    
    [self getInstanceVar];
    
//    [self getVarType];
    
    [self methodExchange];
    
    [self methodSetImplementation];
}

- (void)logFuncOne
{
    NSLog(@"funcOne");
}
- (void)logFuncTwo
{
    NSLog(@"funcTwo");
}
#pragma mark - 获取一个类的所有方法
- (void)getClassAllMethods
{
    u_int count;
    Method *methods = class_copyMethodList([ViewController class], &count);
    for (int i = 0 ; i < count; i ++) {
        SEL className = method_getName(methods[i]);
        NSString *nameClass = [NSString stringWithCString:sel_getName(className) encoding:NSUTF8StringEncoding];
        NSLog(@"nameClass:%@",nameClass);
    }
}

#pragma mark - 获取一个类的所有属性
- (void)getClassAllPropertyNames
{
    u_int count;
    objc_property_t *properties = class_copyPropertyList([ViewController class], &count);
    for (int m = 0; m < count; m ++) {
        
        const char *propertiesName = property_getName(properties[m]);
        NSString *propertyName = [NSString stringWithCString:propertiesName encoding:NSUTF8StringEncoding];
        NSLog(@"propertyName:%@",propertyName);
    }
}

#pragma mark - 获取类的属性变量
- (void)getInstanceVar
{
    Ivar ivar = class_getInstanceVariable([ViewController class], "myFloat");
    id myFloatValue = object_getIvar(self, ivar);
    NSLog(@"myFloatValue:%@",myFloatValue);
}

#pragma mark - 判断类的某个属性的类型
- (void)getVarType
{
    MTCustomClass *customClass = [[MTCustomClass alloc] init];
    Ivar ivar = class_getInstanceVariable(object_getClass(customClass), "nameString");
    const char* typeEncoding = ivar_getTypeEncoding(ivar);
    NSString *stringType =  [NSString stringWithCString:typeEncoding encoding:NSUTF8StringEncoding];
    if ([stringType hasPrefix:@"@"]) {
        // handle class case
        NSLog(@"handle class case");
    } else if ([stringType hasPrefix:@"i"]) {
        // handle int case
        NSLog(@"handle int case");
    } else if ([stringType hasPrefix:@"f"]) {
        // handle float case
        NSLog(@"handle float case");
    } else
    {
        
    }
}

#pragma mark - 通过属性的值来获取其属性的名字（反射机制）
- (NSString *)nameOfInstance:(id)instance
{
    unsigned int numIvars = 0;
    NSString *key = nil;
    //Describes the instance variables declared by a class.
    Ivar *ivars = class_copyIvarList([MTCustomClass class], &numIvars);
    for (int n = 0 ; n < numIvars; n ++) {
        Ivar thisIvar = ivars[n];
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType =  [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        //不是class就跳过
        if (![stringType hasPrefix:@"@"]) {
            continue;
    }
        //Reads the value of an instance variable in an object. object_getIvar这个方法中，当遇到非objective-c对象时，并直接crash
        if ((object_getIvar([MTCustomClass class], thisIvar) == instance)) {
            // Returns the name of an instance variable.
            key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
            break;
        }
    }
    free(ivars);
    return key;
}

#pragma mark - 系统类的方法实现部分替换
- (void)methodExchange
{
    Method m1 = class_getInstanceMethod([NSString class], @selector(lowercaseString));
    Method m2 = class_getInstanceMethod([NSString class], @selector(uppercaseString));
    method_exchangeImplementations(m1, m2);
    NSLog(@"%@", [@"sssAAAAss"lowercaseString]);
    NSLog(@"%@", [@"sssAAAAss"uppercaseString]);
}

#pragma mark - 自定义类的方法实现部分替换
- (void)methodSetImplementation
{
    Method method = class_getInstanceMethod([ViewController class], @selector(logFuncOne));
    IMP originalImp = method_getImplementation(method);
    Method m1 = class_getInstanceMethod([ViewController class], @selector(logFuncTwo));
    method_setImplementation(m1, originalImp);
}

#pragma mark - 覆盖系统方法
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
