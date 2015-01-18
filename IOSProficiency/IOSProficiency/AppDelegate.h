//
//  AppDelegate.h
//  IOSProficiency
//
//  Created by Shakir Zareen on 06/01/2015.
//  Copyright (c) 2015 Shakir Zareen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CJSONDeserializer.h"

#import "ImageDownloader.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,UITableViewDataSource,UITableViewDelegate>
{
    @private
    UIViewController *cntrl;                            //the only viewcontroller in the app. We could have user a UINavigationViewController but that will be overkill for the task
    UINavigationBar *navBar;                            //we want to show a NAV bar on top (with refresh button and the Title)
    UINavigationItem *navItem;                          //to hold title and refresh button
    UIBarButtonItem *refreshButton;                     //the refresh button
    UITableView *tblView;                               //the only tableview
    NSMutableData *receivedData;                        //NSURConnection related objects needed to download the actual feed from the URL
    NSURLConnection *theConnection;                     //same as above
    UIActivityIndicatorView *activityIndicatorView;     //we will disable the whole UIView, show the progressindicator. So the user will not be able to interact untill the feed loading part is completed
    NSArray *allRows;                                   //All Feed data. This array will contain NSDictionary objects and the JSON parser will fill in this array
}
@property (strong, nonatomic) UIWindow *window;




@end

