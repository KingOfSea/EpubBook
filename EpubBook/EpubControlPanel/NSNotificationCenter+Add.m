

#import "NSNotificationCenter+Add.h"

@implementation NSNotificationCenter (Add)

+ (void)postNotificationName:(NSString *)aName{
    [self postNotificationName:aName object:nil userInfo:nil];
}

+ (void)postNotificationName:(NSString *)aName object:(id)anObject{
    [self postNotificationName:aName object:anObject userInfo:nil];
}

+ (void)postNotificationName:(NSString *)aName userInfo:(NSDictionary *)aUserInfo{
    [self postNotificationName:aName object:nil userInfo:aUserInfo];
}

+ (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo{
    [[self defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
}

+ (id<NSObject>)addObserverForName:(NSString *)name usingBlock:(void (^)(NSNotification *))block{
    return [self addObserverForName:name object:nil queue:[NSOperationQueue mainQueue] usingBlock:block];
}

+ (id<NSObject>)addObserverForName:(NSString *)name queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *))block{
    return [self addObserverForName:name object:nil queue:queue usingBlock:block];
}

+ (id<NSObject>)addObserverForName:(NSString *)name object:(id)obj queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *))block{
    return [[self defaultCenter] addObserverForName:name object:obj queue:queue usingBlock:block];
}

+ (void)removeObserver:(id)observer name:(NSString *)aName{
    [self removeObserver:observer name:aName object:nil];
}

+ (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject{
    [[self defaultCenter]removeObserver:observer name:aName object:anObject];
}


@end
