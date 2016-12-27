//
//  TCSipAPI.m
//  individual
//
//  Created by 王帅锋 on 16/12/22.
//  Copyright © 2016年 杭州部落公社科技有限公司. All rights reserved.
//

#import "TCSipAPI.h"
#import "TCBuluoApi.h"


@interface TCSipAPI (){
    LinphoneProxyConfig *new_config;
    LinphoneAccountCreator *account_creator;
    size_t number_of_configs_before;
    
}

@property (assign, nonatomic) BOOL logined;

@end

@implementation TCSipAPI

+ (instancetype)api {
    static TCSipAPI *api = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        api = [[TCSipAPI alloc] init];
    });
    return api;
}

- (BOOL)isLogin {
    return _logined;
}

- (instancetype)init {
    if (self = [super init]) {
        self.logined = NO;
        LinphoneManager *instance = [LinphoneManager instance];
        [instance lpConfigBoolForKey:@"backgroundmode_preference"];
        [instance lpConfigBoolForKey:@"start_at_boot_preference"];
        
        [LinphoneManager.instance startLinphoneCore];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(registrationUpdateEvent:)
                                                   name:kLinphoneRegistrationUpdate
                                                 object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(configuringUpdate:)
                                                   name:kLinphoneConfiguringStateUpdate
                                                 object:nil];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(callUpdate:)
                                                   name:kLinphoneCallUpdate
                                                 object:nil];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(callUpdateEvent:)
                                                   name:kLinphoneCallUpdate
                                                 object:nil];
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(coreUpdateEvent:)
                                                   name:kLinphoneCoreUpdate
                                                 object:nil];
        [self loadAssistantConfig:@"assistant_external_sip.rc"];
        new_config = NULL;
        number_of_configs_before = bctbx_list_size(linphone_core_get_proxy_config_list(LC));
        
    }
    return self;
}

- (void)callUpdate:(NSNotification *)notif {

    LinphoneCall *call = (LinphoneCall *)[[notif.userInfo objectForKey:@"call"] pointerValue];
    LinphoneCallState state = (LinphoneCallState)[[notif.userInfo objectForKey:@"state"] intValue];
    NSString *message = [notif.userInfo objectForKey:@"message"];
    
    switch (state) {
        case LinphoneCallIncomingReceived:
        case LinphoneCallIncomingEarlyMedia: {
            //打进来的
            break;
        }
        case LinphoneCallOutgoingInit: {
            //打出去
            break;
        }
        case LinphoneCallPausedByRemote:
            break;
        case LinphoneCallConnected:
            break;
        case LinphoneCallStreamsRunning: {
            [NSThread sleepForTimeInterval:0.5];
            linphone_call_send_dtmf(linphone_core_get_current_call(LC), '#');
            linphone_core_play_dtmf(LC, '#', 100);

            [[NSNotificationCenter defaultCenter] postNotificationName:@"opend" object:nil];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"closed" object:nil];
            });
//
            
            break;
        }
        case LinphoneCallUpdatedByRemote: {
            const LinphoneCallParams *current = linphone_call_get_current_params(call);
            const LinphoneCallParams *remote = linphone_call_get_remote_params(call);
            
            if (linphone_call_params_video_enabled(current) && !linphone_call_params_video_enabled(remote)) {
            }
            break;
        }
        case LinphoneCallError: {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openFailed" object:nil];
            NSRange r = [message rangeOfString:@"text="];
            if (r.length > 0) {
                NSString *err = [message substringFromIndex:r.location+r.length];
                [MBProgressHUD showHUDWithMessage:err];
            }else {
                [MBProgressHUD showHUDWithMessage:message];
            }
            
            TCLog(@"%@",message);
            break;
        }
        case LinphoneCallEnd: {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"end" object:nil];
            
            const MSList *calls = linphone_core_get_calls(LC);
            if (calls == NULL) {

            } else {
                linphone_core_resume_call(LC, (LinphoneCall *)calls->data);
            }
            break;
        }
        case LinphoneCallEarlyUpdatedByRemote:
            break;
        case LinphoneCallEarlyUpdating:
            break;
        case LinphoneCallIdle:
            break;
        case LinphoneCallOutgoingEarlyMedia:
            break;
        case LinphoneCallOutgoingProgress:
            break;
        case LinphoneCallOutgoingRinging:
            break;
        case LinphoneCallPaused:
            break;
        case LinphoneCallPausing:
            break;
        case LinphoneCallRefered:
            break;
        case LinphoneCallReleased:
            break;
        case LinphoneCallResuming:
            break;
        case LinphoneCallUpdating:
            break;
    }
}


- (void)callUpdateEvent:(NSNotification *)notif {
    LinphoneCall *call = [[notif.userInfo objectForKey:@"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey:@"state"] intValue];
    [self callUpdate:call state:state];
}

- (void)callUpdate:(LinphoneCall *)call state:(LinphoneCallState)state {
    BOOL callInProgress = (linphone_core_get_calls_nb(LC) > 0);
    
    
    if (linphone_core_video_capture_enabled(LC) && linphone_core_get_video_policy(LC)->automatically_initiate) {
        
    } else {
        
    }
    
    if (LinphoneManager.instance.nextCallIsTransfer) {
        
    } else if (linphone_core_get_calls_nb(LC) > 0) {
        
    }
}



- (void)coreUpdateEvent:(NSNotification *)notif {
    
}


- (void)registrationUpdateEvent:(NSNotification *)notif {
    NSString *message = [notif.userInfo objectForKey:@"message"];
    [self registrationUpdate:[[notif.userInfo objectForKey:@"state"] intValue]
                    forProxy:[[notif.userInfo objectForKeyedSubscript:@"cfg"] pointerValue]
                     message:message];
}


- (void)registrationUpdate:(LinphoneRegistrationState)state
                  forProxy:(LinphoneProxyConfig *)proxy
                   message:(NSString *)message {
    if (proxy != new_config) {
        return;
    }
    
    switch (state) {
        case LinphoneRegistrationOk: {
            _logined = YES;
            [LinphoneManager.instance
             lpConfigSetInt:[NSDate new].timeIntervalSince1970 +
             [LinphoneManager.instance lpConfigIntForKey:@"link_account_popup_time" withDefault:84200]
             forKey:@"must_link_account_time"];
           
            break;
        }
        case LinphoneRegistrationNone:
        case LinphoneRegistrationCleared: {
            //            _waitView.hidden = true;
            break;
        }
        case LinphoneRegistrationFailed: {
            TCLog(@"SIP注册失败");
            break;
        }
        case LinphoneRegistrationProgress: {
            break;
        }
        default:
            break;
    }
}

- (void)configuringUpdate:(NSNotification *)notif {
    LinphoneConfiguringState status = (LinphoneConfiguringState)[[notif.userInfo valueForKey:@"state"] integerValue];
    
    switch (status) {
        case LinphoneConfiguringSuccessful:
            // we successfully loaded a remote provisioned config, go to dialer
            [LinphoneManager.instance lpConfigSetInt:[NSDate new].timeIntervalSince1970
                                              forKey:@"must_link_account_time"];
            if (number_of_configs_before < bctbx_list_size(linphone_core_get_proxy_config_list(LC))) {
                TCLog(@"A proxy config was set up with the remote provisioning, skip assistant");
            }
            
            [self fillDefaultValues];
            
            break;
        case LinphoneConfiguringFailed: {
            break;
        }
            
        case LinphoneConfiguringSkipped:
        default:
            break;
    }
}

- (void)fillDefaultValues {
    
    LinphoneProxyConfig *default_conf = linphone_core_create_proxy_config(LC);
    const char *identity = linphone_proxy_config_get_identity(default_conf);
    if (identity) {
        LinphoneAddress *default_addr = linphone_core_interpret_url(LC, identity);
        if (default_addr) {
            const char *domain = linphone_address_get_domain(default_addr);
            const char *username = linphone_address_get_username(default_addr);
            if (domain && strlen(domain) > 0) {
            }
            if (username && strlen(username) > 0 && username[0] != '?') {
            }
        }
    }
    
    
    linphone_proxy_config_destroy(default_conf);
}

- (void)login {
    
//    TCUserSipInfo *sipInfo = [[TCBuluoApi api] currentUserSession].userSensitiveInfo.sip;
//    if (sipInfo) {
//        linphone_account_creator_set_username(account_creator, sipInfo.user.UTF8String);
//        linphone_account_creator_set_password(account_creator, sipInfo.password.UTF8String);
//        linphone_account_creator_set_domain(account_creator, sipInfo.domain.UTF8String);
//        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [LinphoneManager.instance lpConfigSetInt:1 forKey:@"transient_provisioning" inSection:@"misc"];
//        [self configureProxyConfig];
//        //    });
//    }
    
}

- (void)configureProxyConfig {
    LinphoneManager *lm = LinphoneManager.instance;
    
    if (!linphone_core_is_network_reachable(LC)) {
        UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Network Error", nil)
                                                                         message:NSLocalizedString(@"There is no network connection available, enable "
                                                                                                   @"WIFI or WWAN prior to configure an account",
                                                                                                   nil)
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [errView addAction:defaultAction];
        return;
    }
    
    // remove previous proxy config, if any
    if (new_config != NULL) {
        const LinphoneAuthInfo *auth = linphone_proxy_config_find_auth_info(new_config);
        linphone_core_remove_proxy_config(LC, new_config);
        if (auth) {
            linphone_core_remove_auth_info(LC, auth);
        }
    }

    linphone_account_creator_set_transport(account_creator,
                                           linphone_transport_parse(@"UDP".lowercaseString.UTF8String));
    // }
    
    new_config = linphone_account_creator_configure(account_creator);
    
    if (new_config) {
        [lm configurePushTokenForProxyConfig:new_config];
        linphone_core_set_default_proxy_config(LC, new_config);
    } else {
        UIAlertController *errView = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Assistant error", nil)
                                                                         message:NSLocalizedString(@"Could not configure your account, please check parameters or try again later",
                                                                                                   nil)
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [errView addAction:defaultAction];
        return;
    }
}


- (void)loadAssistantConfig:(NSString *)rcFilename {
    NSString *fullPath = [@"file://" stringByAppendingString:[LinphoneManager bundleFile:rcFilename]];
    linphone_core_set_provisioning_uri(LC, fullPath.UTF8String);
    [LinphoneManager.instance lpConfigSetInt:1 forKey:@"transient_provisioning" inSection:@"misc"];
    
    [self resetLiblinphone];
}

- (void)resetLiblinphone {
    if (account_creator) {
        linphone_account_creator_unref(account_creator);
        account_creator = NULL;
    }
    [LinphoneManager.instance resetLinphoneCore];
    account_creator = linphone_account_creator_new(
                                                   LC, [LinphoneManager.instance lpConfigStringForKey:@"xmlrpc_url" inSection:@"assistant" withDefault:@""]
                                                   .UTF8String);
    linphone_account_creator_set_user_data(account_creator, (__bridge void *)(self));
    linphone_account_creator_cbs_set_is_account_used(linphone_account_creator_get_callbacks(account_creator),assistant_is_account_used);
    linphone_account_creator_cbs_set_create_account(linphone_account_creator_get_callbacks(account_creator),
                                                    assistant_create_account);
    linphone_account_creator_cbs_set_activate_account(linphone_account_creator_get_callbacks(account_creator),
                                                      assistant_activate_account);
    linphone_account_creator_cbs_set_is_account_activated(linphone_account_creator_get_callbacks(account_creator),
                                                          assistant_is_account_activated);
    linphone_account_creator_cbs_set_recover_phone_account(linphone_account_creator_get_callbacks(account_creator),
                                                           assistant_recover_phone_account);
    linphone_account_creator_cbs_set_is_account_linked(linphone_account_creator_get_callbacks(account_creator),
                                                       assistant_is_account_linked);
    
}

#pragma mark - Account creator callbacks

void assistant_is_account_used(LinphoneAccountCreator *creator, LinphoneAccountCreatorStatus status, const char *resp) {
    NSLog(@"assistant_is_account_used");
}

void assistant_create_account(LinphoneAccountCreator *creator, LinphoneAccountCreatorStatus status, const char *resp) {
    NSLog(@"assistant_create_account");
}

void assistant_recover_phone_account(LinphoneAccountCreator *creator, LinphoneAccountCreatorStatus status,
                                     const char *resp) {
    NSLog(@"assistant_recover_phone_account");
}

void assistant_activate_account(LinphoneAccountCreator *creator, LinphoneAccountCreatorStatus status,
                                const char *resp) {
    NSLog(@"assistant_activate_account");
}

void assistant_is_account_activated(LinphoneAccountCreator *creator, LinphoneAccountCreatorStatus status,
                                    const char *resp) {
    NSLog(@"assistant_is_account_activated");
}

void assistant_is_account_linked(LinphoneAccountCreator *creator, LinphoneAccountCreatorStatus status,
                                 const char *resp) {
    NSLog(@"assistant_is_account_linked");
}


@end
