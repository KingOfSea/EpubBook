
#import <Foundation/Foundation.h>

@interface NSNotificationCenter (Add)

+ (void)postNotificationName:(NSString *)aName;
+ (void)postNotificationName:(NSString *)aName object:(id)anObject;
+ (void)postNotificationName:(NSString *)aName userInfo:(NSDictionary *)aUserInfo;
+ (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

+ (id <NSObject>)addObserverForName:(NSString *)name usingBlock:(void (^)(NSNotification *note))block;
+ (id <NSObject>)addObserverForName:(NSString *)name queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block;
+ (id <NSObject>)addObserverForName:(NSString *)name object:(id)obj queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification *note))block;

+ (void)removeObserver:(id)observer name:(NSString *)aName;
+ (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject;

@end
