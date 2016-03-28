//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "OctoAPI.h"

@implementation ViewController

UILabel* myLabel;

- (void)viewDidLoad {
  [super viewDidLoad];
    
    

    /*
     Create Buttons for various calls
     */
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(appLogoutBtnHandler:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"App Logout" forState:UIControlStateNormal];
    UIColor *color = [UIColor colorWithRed:14.0/255.0 green:114.0/255.0 blue:199.0/255.0 alpha:1];
    [button setBackgroundColor:color];
    button.frame = CGRectMake(10, 100, 200, 50);
    [self.view addSubview:button];
    
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
     [button2 addTarget:self
               action:@selector(appLoginBtnHandler:)
     forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"App Login" forState:UIControlStateNormal];
    [button2 setBackgroundColor:[UIColor colorWithRed:119.0/255.0 green:114.0/255.0 blue:199.0/255.0 alpha:1]];
    button2.frame = CGRectMake(10, 200, 200, 50);
    [self.view addSubview:button2];
    
        UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
     [button3 addTarget:self
               action:@selector(pageViewBtnHandler:)
     forControlEvents:UIControlEventTouchUpInside];
    [button3 setTitle:@"Page View" forState:UIControlStateNormal];
    [button3 setBackgroundColor:[UIColor colorWithRed:119.0/255.0 green:9.0/255.0 blue:199.0/255.0 alpha:1]];
    button3.frame = CGRectMake(10, 300, 200, 50);
    [self.view addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
     [button4 addTarget:self
               action:@selector(productPageViewBtnHandler:)
     forControlEvents:UIControlEventTouchUpInside];
    [button4 setTitle:@"Product Page View" forState:UIControlStateNormal];
    [button4 setBackgroundColor:[UIColor colorWithRed:119.0/255.0 green:114.0/255.0 blue:1.0/255.0 alpha:1]];
    button4.frame = CGRectMake(10, 400, 200, 50);
    [self.view addSubview:button4];

    
    
    
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(updateRegistrationStatus:)
                                               name:appDelegate.registrationKey
                                             object:nil];
    /*
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(showReceivedMessage:)
                                               name:appDelegate.messageKey
                                             object:nil];
     */
  _registrationProgressing.hidesWhenStopped = YES;
  [_registrationProgressing startAnimating];
    
    myLabel =  [[UILabel alloc] initWithFrame: CGRectMake(10, 455, 300, 100)];
    myLabel.text = @"Responses show here...";
    myLabel.numberOfLines = 3;
    [self.view addSubview:myLabel];
    

    
}

- (void) appLogoutBtnHandler: (UIButton*)sender {
    OctoAPI *api = [[OctoAPI alloc] init];
    [api sendAppLogoutCall:2  onCompletion: ^(NSString* response){
        NSLog(@"Got response from App.Logout %@", response);
        dispatch_async(dispatch_get_main_queue(), ^{
            [myLabel setText:response];
        });
        
    }];
}

- (void) appLoginBtnHandler: (UIButton*)sender {
    OctoAPI *api = [[OctoAPI alloc] init];
    [api sendAppLoginCall:2  onCompletion: ^(NSString* response){
        NSLog(@"Got response from App.Login %@", response);
        dispatch_async(dispatch_get_main_queue(), ^{
            [myLabel setText:response];
        });
    }];
}

- (void) pageViewBtnHandler: (UIButton*)sender {
    OctoAPI *api = [[OctoAPI alloc] init];
    [api sendPageViewCall:2 routeUrl: @"Home#Index"
               categories:@[@"Aldo", @"Women"]
                     tags:@[@"Red", @"Handbag", @"Leather"]
             onCompletion: ^(NSString* response){
                 NSLog(@"Got response from Page.View %@", response);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [myLabel setText:response];
                 });
             }];
}

- (void) productPageViewBtnHandler: (UIButton*)sender {
    OctoAPI *api = [[OctoAPI alloc] init];
    [api sendProductPageViewCall:2
                        routeUrl:@"Home#Deals"
                       productId:88
                     productName:@"SmartPhone"
                           price:899.9
                      categories:@[@"Electronics", @"Mobile"]
                            tags:@[@"Delhi", @"Motorola"]
                    onCompletion: ^(NSString* response){
                        NSLog(@"Got response from Productpage.view %@", response);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [myLabel setText:response];
                        });
                    }
     ];
}
- (void) updateRegistrationStatus:(NSNotification *) notification {
  [_registrationProgressing stopAnimating];
  if ([notification.userInfo objectForKey:@"error"]) {
    _registeringLabel.text = @"Error registering!";
    [self showAlert:@"Error registering with GCM" withMessage:notification.userInfo[@"error"]];
  } else {
    _registeringLabel.text = @"Registered!";
    NSString *message = @"Check the xcode debug console for the registration token that you can"
        " use with the demo server to send notifications to your device";
    [self showAlert:@"Registration Successful" withMessage:message];
  };
}

- (void) showReceivedMessage:(NSNotification *) notification {
  NSString *message = notification.userInfo[@"aps"][@"alert"];
  [self showAlert:@"Message received" withMessage:message];
}

- (void)showAlert:(NSString *)title withMessage:(NSString *) message{
  if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
    // iOS 7.1 or earlier
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];
  } else {
    //iOS 8 or later
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:nil];

    [alert addAction:dismissAction];
    [self presentViewController:alert animated:YES completion:nil];
  }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
