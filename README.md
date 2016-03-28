# iOS, GCM Starter Kit #

This kit covers an app published on iOS platform and uses GCM for push notifications.

[TOC]

# Get Started #

## Download ##

[Download](downloads/iOSGcmExample.zip) the starter kit from here. This starter kit contains a working sample of code that takes all permissions from users, and sends appropriate API calls at appropriate times.

If you already have an app, chances are most of the steps would have been already done. However, it is advised to go through the document and remove any inconsistencies.

The code snippets mentioned here can be found in the starter kit. Should you have any difficulty understaning the flow, the starter kit code should help you out.

### Libraries ###

If you just want to download the libraries for Octomatic API, choose your language below:

- [Objective C API](downloads/OctoAPI_ObjC.zip)
- [Swift API](downloads/OctoAPI_swift.zip)

## Setup Capabilities ##

### GeoLocation ###

---

In order to be able to use geolocation while app is running in foreground, you need to do the following steps:

#### Provide an explanation for why location is being used ####

Create a key named `NSLocationWhenInUseUsageDescription` in `Info.plist`. The string value of this key should be the description. By default, the description reads "*We use geolocation to provide better recommendations*". You may change to a suitable text, if necessary.

```
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use geolocation to provide better recommendations</string>
```

#### Link to CoreLocation framework ####

Go to `Build Phases > Link Binary with Libraries`. Click on the `+` sign and select `CoreLocation.framework` from the list that comes.

### Push Notification ###

---

In order to enable push notification on your app, you need to do the following:

#### Enable Push Notifications ####

Select your build target and go to `Capabilities` tab. Turn on `Push Notifications`.

#### Get the GCM config file ####

You would require a `GoogleServices-Info.plist` file for your project. In order to generate this file, you need to provide a valid APNs certificate and some additional information to get a configuration file and finish setting up your project. If you don't already have an APNs certificate, see [Provisioning APNs SSL Certificates](https://developers.google.com/cloud-messaging/ios/certs#create_the_ssl_certificate). When prompted, provide the Bundle ID associated with your APNs certificate.

[Get the configuration file for GCM](https://developers.google.com/mobile/add?platform=ios&cntapi=gcm&cntapp=Default%20Demo%20App&cnturl=https:%2F%2Fdevelopers.google.com%2Fcloud-messaging%2Fios%2Fstart%3Fconfigured%3Dtrue&cntlbl=Continue%20with%20Try%20Cloud%20Messaging).

After you complete the configuration process, take note of the API server key on the download page, you will need it later. Download the GoogleServices-Info.plist file to add to your project.

#### Add the configuration file to your project ####

Drag the `GoogleService-Info.plist` file you just downloaded into the root of your Xcode project and add it to all targets.
In Xcode, replace the bundle identifier for the GcmExample and GcmExampleSwift targets with the value associated with your APNs certificate. This must be the same value used in the Get a configuration file step.


For more detailed instructions, please follow the [GCM iOS guide](https://developers.google.com/cloud-messaging/ios/start).

## Setup Octomatic Enterprise API ##

The Octomatic Enterprise API contains following files

- Swift
	- `OctoAPI.swift`
- Objective C
	- `OctoAPI.h`
	- `OctoAPI.m`

Copy these files to your corresponding project's source directory.

### Add API Keys ###

Once copied, you would require to add appropriate API Key and server key at the right places.

**Objective C**

Open `OctoAPI.m` and you should see something like below. Update the `APIKEY` with your Octomatic's Enterprise API Key. You should also update `SERVER_API_KEY` with the GCM server api key.

```

/*
 SET YOUR API KEY HERE
 You must manually set the API Key here
 */
NSString *APIKEY = @"";


/*
SET YOUR GCM SERVER API KEY HERE
 You must set the GCM SERVER API KEY so that push notifications can happen
 */
NSString *SERVER_API_KEY = @"";

```

**Swift**

Open `OctoAPI.swift` and update `APIKEY` with your Octomatic's Enterprise API Key. You should also update `SERVER_API_KEY` with the GCM server api key.

```

/*
Update your API KEY here.
*/
var APIKEY = ""
    
/*
SET YOUR GCM SERVER API KEY HERE
 You must set the GCM SERVER API KEY so that push notifications can happen
 */
var SERVER_API_KEY = ""

```

### Update the API Endpoint (Optional) ###

By default, the API Endpoint points to production environment. Optionally, you can change this to sandbox endpoint for development purposes. If you need to do so, do it where `BASEURL` is defined.

**Objective C**

```

NSString *BASEURL = @"http://192.168.0.109:8000";

```

**Swift**

```

var BASEURL = "http://192.168.0.109:8000"

```

Modifying the API files any further should not be necessary. However, if you feel any need to do so, please contact us at api@octo.ai beforehand.

## Code Implementation ##

The following section will detail about the actual code implementation and is divided into following parts

- Initialising Octomatic API and handling callback
- Registering Client app with GCM servers
- Updating user's registrationToken to Octomatic
- Updating user's location
- Sending out API calls
- Handling remote notifications

### Initialising Octomatic API and handling callback ###

In order to initialize Octomatic API import the API files, and initialize the client. The calls are made using `NSUrlSession` and are executed async. A callback can be associated with the request which gets executed with the response value. The response value is a string which contains the eventId of the API call. This eventId can always be used from the dashboard to trace an event.

In the following example, an `app.init` call is made for a user with ID as 2. In the callback, the response is logged to console.

**Objective C**

```

#import "OctoAPI.h"


// somewhere in the code
OctoAPI *api = [[OctoAPI alloc] init];

NSInteger userId = 2;
[api sendAppInitCall:userId
        onCompletion: ^(NSString* response){
            NSLog(@"Got response from App.Init %@",
            response);
    	  }];

```

**Swift**

```

let api = OctoAPI()
let userId = 2
    
api.sendAppInitCall(userId) { (result) -> Void in
    print(result)
}

```

### Registering your app client with GCM ###

- Follow the [GCM guide for iOS installation](https://developers.google.com/instance-id/guides/ios-implementation#set_up_your_cocoapods_dependencies) for a detailed, step by step guide to register client with GCM and get user's registrationToken.
- For a detailed working implementation, please take a look at the corresponding `AppDelegate` file.

### Updating user's registrationToken to Octomatic ###

In the `registrationHandler` part of the GCM code, implement the `updatePushToken` call. Following are the code samples.

**Objective C (AppDelegate.m)**

```
GCMConfig *gcmConfig = [GCMConfig defaultConfig];
  gcmConfig.receiverDelegate = self;
  [[GCMService sharedInstance] startWithConfig:gcmConfig];
  // [END start_gcm_service]
  __weak typeof(self) weakSelf = self;
  // Handler for registration token request
  _registrationHandler = ^(NSString *registrationToken, NSError *error){
    if (registrationToken != nil) {
      weakSelf.registrationToken = registrationToken;
      NSLog(@"Registration Token: %@", registrationToken);
      [weakSelf subscribeToTopic];
      NSDictionary *userInfo = @{@"registrationToken":registrationToken};
      [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                          object:nil
                                                        userInfo:userInfo];
        // update the token to Octo
        OctoAPI *api = [[OctoAPI alloc] init];
        [api updatePushToken:2 pushToken:registrationToken  onCompletion: ^(NSString* response){
            NSLog(@"Got response from Push Token %@", response);
        }];
        
    } else {
      NSLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
      NSDictionary *userInfo = @{@"error":error.localizedDescription};
      [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                          object:nil
                                                        userInfo:userInfo];
    }
  };
```

**Swift (AppDelegate.swift)**

```
func registrationHandler(registrationToken: String!, error: NSError!) {
if (registrationToken != nil) {


    // Push TO Octo
  let api = OctoAPI()
    let userId = 4
    api.sendPushToken(userId, pushToken: registrationToken) { (result) -> Void in
        print("Push Token Response", result)
    }
    
    
  self.registrationToken = registrationToken
  print("Registration Token: \(registrationToken)")
  self.subscribeToTopic()
  let userInfo = ["registrationToken": registrationToken]
  NSNotificationCenter.defaultCenter().postNotificationName(
    self.registrationKey, object: nil, userInfo: userInfo)
} else {
  print("Registration to GCM failed with error: \(error.localizedDescription)")
  let userInfo = ["error": error.localizedDescription]
  NSNotificationCenter.defaultCenter().postNotificationName(
    self.registrationKey, object: nil, userInfo: userInfo)
}
}
```

### Updating user's location ###

#### Objective C ####

Include the CoreLocation framework in `AppDelegate.h` header file. Also add a property `locationManager` to AppDelegate interface

```

#import <Google/CloudMessaging.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate>

@property(nonatomic, strong) UIWindow *window;
@property(nonatomic, readonly, strong) NSString *registrationKey;
@property(nonatomic, readonly, strong) NSString *messageKey;
@property(nonatomic, readonly, strong) NSString *gcmSenderID;
@property(nonatomic, readonly, strong) NSDictionary *registrationOptions;

@property (nonatomic, retain) CLLocationManager *locationManager;

@end

```

Requesting Geolocation from user should be done when the app finishes launching. Typically, this could be in `AppDelegate.m`'s `didFinishLaunchingWithOptions` function.

```

- (BOOL)application:(UIApplication *)application
      didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Get geolocation permissions from user
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Disabled");
        // location services is disabled, alert user
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DisabledTitle", @"DisabledTitle")
                                                                        message:NSLocalizedString(@"DisabledMessage", @"DisabledMessage")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"OKButtonTitle", @"OKButtonTitle")
                                                              otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
    else
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
        NSLog(@"Not Disabled");
    }
}

```

Once the permissions to get geolocation from user is available, then add a delegate method that would update the location to Octomatic's API. Not that this does not necessarily mean an API call. It just means that the next API call happening would include the updated location of the user.

This should typically reside in `AppDelegate.m`

```

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [OctoAPI updateLocation:locations];
}

```

#### Swift ####

Import the required framework in `ViewController.swift` and add it's delegate

```

import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

	var locationManager: CLLocationManager!
	
	// ...
}

```

Ask for authorization when the view loads

```

override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    
}

```

Update Octo API about new locations when they happen. This does not necessarily mean making an API call to Octomatic's endpoint. It only means that the next API call will happen with the new location that is available.

```

func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    OctoAPI.updateLocation(locations)
}
    
func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("didFailWithError: \(error.description)")
    
}
func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == .AuthorizedWhenInUse {
        locationManager.startUpdatingLocation()
    }
    if status == .AuthorizedAlways {
        if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
            if CLLocationManager.isRangingAvailable() {
                // do stuff
            }
        }
    }
}

```

### Sending out API calls ###

#### app.init ####
---

This call should be made everytime the app comes to foreground. Place the code inside `applicationDidBecomeActive` function in `appdelegate` file. There could be potentially more stuff inside it. Make sure to add it to the last of all the other things happening.

**Objective C (AppDelegate.m)**

```

// [START connect_gcm_service]
- (void)applicationDidBecomeActive:(UIApplication *)application {

	// Authenticate the user
	NSInteger userId = 2;

	// Send app.init call to Octomatic
    OctoAPI *api = [[OctoAPI alloc] init];
    [api sendAppInitCall:userId onCompletion: ^(NSString* response){
        NSLog(@"Got response from App.Init %@", response);
    }];
    
}

```

**Swift (AppDelegate.swift)**

```

func applicationDidBecomeActive( application: UIApplication) {

	// authenticate the user
	let userId = 2

	// send App Init API Call to Octo
	let api = OctoAPI()
	api.sendAppInitCall(userId) { (result) -> Void in
	    print("App.Init result", result)
	}
}

```

#### app.login ####
---

This call should be made everytime an un-authenticated user authenticates themselves and logs into the system. Place this at your login callback function.

In the starter kit, these calls are placed in `ViewController` files. They are triggered by corresponding button actions.

**Objective C**

```

// user who just logged in
NSInteger userId = 2;

OctoAPI *api = [[OctoAPI alloc] init];
[api sendAppLoginCall:userId  onCompletion: ^(NSString* response){
    NSLog(@"Got response from App.Login %@", response);
    
    // Possibly store this response for tracing it
}];

```

**Swift**

```

// authenticate the user

let userId = 2

let api = OctoAPI()
api.sendAppLoginCall(userId) { (result) -> Void in
    // do something with the response.
    // possibly store it for tracing/debugging purposes
    print(result)
}

```

#### app.logout ####
---

This call should be made everytime a user chooses to logout from the system. Place this call just before the logout action happens.

In the starter kit, these calls are placed in `ViewController` files. They are triggered by corresponding button actions.

**Objective C**

```

// user who is logging out
NSInteger userId = 2;

OctoAPI *api = [[OctoAPI alloc] init];
[api sendAppLogoutCall:userId  onCompletion: ^(NSString* response){
    NSLog(@"Got response from App.Logout %@", response);
    
	// Possibly store this response for tracing it
}]

```

**Swift**

```

let userId = 2

let api = OctoAPI()
api.sendAppLogoutCall(userId) { (result) -> Void in
    // do something with the response.
    // possibly store it for tracing/debugging purposes
    print(result)
}

```

#### page.view ####
---

This call should be send upon every page view call happening. A pageview is said to happen when a user is browsing any page that is **not a product page**. Product pages are handled separately by a `productpage.view` call.

In the starter kit, these calls are placed in `ViewController` files. They are triggered by corresponding button actions.

**Objective C**

```

// authenticated user who is viewing the page
NSInteger userId = 2;

// Symbolic URL (or other unique identifier)
// for the page being viewed
NSString *routeUrl = @"Home#Index";

// Categories this page belongs to
NSArray *categories = @[@"Aldo", @"Women"];

// Tags that belong to the page
NSArray *tags = @[@"Red", @"Handbag", @"Leather"];

OctoAPI *api = [[OctoAPI alloc] init];
[api sendPageViewCall:userId
				routeUrl:routeUrl
           categories:categories
                 tags:tags
         onCompletion: ^(NSString* response){
             NSLog(@"Got response from Page.View %@", response);
     }];

```

**Swift**

``` 

// Symbolic URL (or other unique identifier)
// for the page being viewed
let routeUrl = "/Home"

// Categories this page belongs to
let categories = ["something", "something else"]

// Tags that belong to the page
let tags = ["cat1", "cat2"]

// authenticated user who is viewing the page
let userId = 2

let api = OctoAPI() 
api.sendPageViewCall(userId, routeUrl: routeUrl,
    categories: categories, tags: tags) { (result) -> Void in
        self.showAPIResult(result)
}

```

#### productpage.view ####
---

This call should be sent on every product pageview. This call differs from the `page.view` call.

In the starter kit, these calls are placed in `ViewController` files. They are triggered by corresponding button actions.

**Objective C**

```

// authenticated user who is viewing the page
NSInteger userId = 2;

// Symbolic URL (or other unique identifier)
// for the page being viewed
NSString *routeUrl = @"Home#Index";

// id of the product
NSInteger pid = 8263243

// name of the product
NSString* name = @"SmartPhone Series S10";

// price of the product
double price = 899.99;

// Categories this page belongs to
NSArray *categories = @[@"Aldo", @"Women"];

// Tags that belong to the page
NSArray *tags = @[@"Red", @"Handbag", @"Leather"];

OctoAPI *api = [[OctoAPI alloc] init];
    [api sendProductPageViewCall:userId
                        routeUrl:routeUrl
                       productId:pid
                     productName:name
                           price:price
                      categories:categories
                            tags:tags
                    onCompletion: ^(NSString* response){
                        NSLog(@"Got response from Productpage.view %@",
                        response);
                    }
     ];

```

**Swift**

```

// authenticated user who is viewing this product
let userId = 4

// Symbolic URL (or other unique identifier)
// for the page being viewed
let routeUrl = "/Home/Phone"

// name of the product being viewed
let productName = "Smartphone Series S02"

// price of the product
let price = 999.00

// ID of the product
let productId = 635373

// categories this product belongs to
let categories = ["electronics", "phones"]

// tags that belong to this product
let tags = ["selfie", "cheap"]

let api = OctoAPI() 
api.sendProductPageViewCall(userId, routeUrl: routeUrl,
    productId: productId, price: price, productName: productName,
    categories: categories, tags: tags) { (result) -> Void in
        print(result)
}

```

### Registering for remote notifications ###

**Objective C (AppDelegate.m)**

Put the following inside `didFinishLaunchingWithOptions` so as to ask permissions about push notifications.

```
  NSError* configureError;
  [[GGLContext sharedInstance] configureWithError:&configureError];
  NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
  _gcmSenderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];
  // Register for remote notifications
  if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
    // iOS 7.1 or earlier
    UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge);
    [application registerForRemoteNotificationTypes:allNotificationTypes];
  } else {
    // iOS 8 or later
    // [END_EXCLUDE]
    UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
  }
```

The following functions check the status of push notifications permissions and appropriately handle the situation. If it is a success asking for permissions, GCM updates the registrationToken for user. In case of error, just a message is displayed.

```
- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
// [END receive_apns_token]
  // [START get_gcm_reg_token]
  // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
  GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
  instanceIDConfig.delegate = self;
  // Start the GGLInstanceID shared instance with the that config and request a registration
  // token to enable reception of notifications
  [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
  _registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                           kGGLInstanceIDAPNSServerTypeSandboxOption:@YES};
  [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                      scope:kGGLInstanceIDScopeGCM
                                                    options:_registrationOptions
                                                    handler:_registrationHandler];
  // [END get_gcm_reg_token]
}

// [START receive_apns_token_error]
- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"Registration for remote notification failed with error: %@", error.localizedDescription);
// [END receive_apns_token_error]
  NSDictionary *userInfo = @{@"error" :error.localizedDescription};
  [[NSNotificationCenter defaultCenter] postNotificationName:_registrationKey
                                                      object:nil
                                                    userInfo:userInfo];
}
```

**Swift (AppDelegate.swift)**

```
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions:
      [NSObject: AnyObject]?) -> Bool {
    // [START_EXCLUDE]
    // Configure the Google context: parses the GoogleService-Info.plist, and initializes
    // the services that have entries in the file
    var configureError:NSError?
    GGLContext.sharedInstance().configureWithError(&configureError)
    assert(configureError == nil, "Error configuring Google services: \(configureError)")
    gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
    // [END_EXCLUDE]
    // Register for remote notifications
    if #available(iOS 8.0, *) {
      let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
      application.registerUserNotificationSettings(settings)
      application.registerForRemoteNotifications()
    } else {
      // Fallback
      let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
      application.registerForRemoteNotificationTypes(types)
    }

  // [END register_for_remote_notifications]
  // [START start_gcm_service]
    let gcmConfig = GCMConfig.defaultConfig()
    gcmConfig.receiverDelegate = self
    GCMService.sharedInstance().startWithConfig(gcmConfig)
  // [END start_gcm_service]
    return true
  }
```

Similarly, check the status of permissions and update the GCM or handle the error accordingly.

```
  func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
      deviceToken: NSData ) {
  // [END receive_apns_token]
        // [START get_gcm_reg_token]
        // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
          kGGLInstanceIDAPNSServerTypeSandboxOption:true]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
          scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
        // [END get_gcm_reg_token]
  }

  // [START receive_apns_token_error]
  func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
      error: NSError ) {
    print("Registration for remote notification failed with error: \(error.localizedDescription)")
  // [END receive_apns_token_error]
    let userInfo = ["error": error.localizedDescription]
    NSNotificationCenter.defaultCenter().postNotificationName(
        registrationKey, object: nil, userInfo: userInfo)
  }
```

### Handling remote notifications ###

In order to inform the user about an incoming remote notification, the appropriate `didReceiveRemoteNotification` call needs to be worked upon. Here is how you can do it:

**Objective C (AppDelegate.m)**

```
- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo {
  // This works only if the app started the GCM service
  [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
  // Handle the received message
  // [START_EXCLUDE]
  [[NSNotificationCenter defaultCenter] postNotificationName:_messageKey
                                                      object:nil
                                                    userInfo:userInfo];
  // [END_EXCLUDE]
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
  // This works only if the app started the GCM service
  [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
  // Handle the received message
  // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
  // [START_EXCLUDE]
  [[NSNotificationCenter defaultCenter] postNotificationName:_messageKey
                                                      object:nil
                                                    userInfo:userInfo];
  handler(UIBackgroundFetchResultNewData);
  // [END_EXCLUDE]
    NSLog(@"Done with notification stuff.");
}
```

**Swift (AppDelegate.swift)**

```
  func application( application: UIApplication,
    didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
      print("Notification received: \(userInfo)")
      // This works only if the app started the GCM service
      GCMService.sharedInstance().appDidReceiveMessage(userInfo);
      // Handle the received message
      // [START_EXCLUDE]
      NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
          userInfo: userInfo)
      // [END_EXCLUDE]
  }
  
  func application( application: UIApplication,
    didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
    fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
      print("Notification received: \(userInfo)")
      // This works only if the app started the GCM service
      GCMService.sharedInstance().appDidReceiveMessage(userInfo);

      // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
      // [START_EXCLUDE]
      NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
        userInfo: userInfo)
      handler(UIBackgroundFetchResult.NoData);
      // [END_EXCLUDE]
  }
```
