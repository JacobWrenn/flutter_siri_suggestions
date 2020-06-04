#import "FlutterSiriSuggestionsPlugin.h"
#import <CoreSpotlight/CoreSpotlight.h>
#import <Intents/Intents.h>
@import CoreSpotlight;
@import MobileCoreServices;


@implementation FlutterSiriSuggestionsPlugin {
    FlutterMethodChannel *_channel;
    
}

NSString *kPluginName = @"flutter_siri_suggestions";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:kPluginName
                                     binaryMessenger:[registrar messenger]];
    FlutterSiriSuggestionsPlugin* instance = [[FlutterSiriSuggestionsPlugin alloc] initWithChannel:channel];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if([@"becomeCurrent" isEqualToString:call.method]) {
        return [self becomeCurrent:call result:result];
    }
    
    result(FlutterMethodNotImplemented);
    
}


- (void)becomeCurrent:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    NSDictionary *arguments = call.arguments;
    
    
    NSString *title = [arguments objectForKey:@"title"];
    NSNumber *isEligibleForSearch = [arguments objectForKey:@"isEligibleForSearch"];
    NSString *persistentIdentifier = [arguments objectForKey:@"persistentIdentifier"];
    NSNumber *isEligibleForPrediction = [arguments objectForKey:@"isEligibleForPrediction"];
    NSString *contentDescription = [arguments objectForKey:@"contentDescription"];
    NSString *suggestedInvocationPhrase = [arguments objectForKey:@"suggestedInvocationPhrase"];
    NSDictionary *userInfo = [arguments objectForKey:@"userInfo"];
    
    if (@available(iOS 9.0, *)) {
        
        NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:kPluginName];
        
        [activity setEligibleForSearch:[isEligibleForSearch boolValue]];
        [activity setUserInfo:userInfo];

        if (@available(iOS 12.0, *)) {
            [activity setPersistentIdentifier:persistentIdentifier];
            [activity setEligibleForPrediction:[isEligibleForPrediction boolValue]];
        }
        
        CSSearchableItemAttributeSet *attributes = [[CSSearchableItemAttributeSet alloc] initWithItemContentType: (NSString *)kUTTypeItem];
        
        
        activity.title = title;
        attributes.contentDescription = contentDescription;
        
        if (@available(iOS 12.0, *)) {
            
            // SIMULATOR HAS NOT RESPOND SELECTOR
            #if !(TARGET_IPHONE_SIMULATOR)
            activity.suggestedInvocationPhrase = suggestedInvocationPhrase;
            #endif
            
        }
        activity.contentAttributeSet = attributes;

        UIViewController* viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        
        viewController.userActivity = activity;
        
        [activity becomeCurrent];
    }
    
    result(nil);
}

- (void)onAwake:(NSUserActivity*) userActivity {
    [_channel invokeMethod:@"onLaunch" arguments:[userActivity userInfo]];
}

#pragma mark -

- (instancetype)initWithChannel:(FlutterMethodChannel*)channel {
    self = [super init];
    if(self) {
        _channel = channel;
    }
    return self;
}

#pragma mark - Application


- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
    return true;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
    if ([[userActivity activityType] isEqualToString:kPluginName]) {
        [self onAwake:userActivity];
        return true;
    }
    return false;
    
    
}



@end
