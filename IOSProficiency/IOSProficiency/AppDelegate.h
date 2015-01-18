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
    UIViewController *cntrl;
    UINavigationBar *navBar;
    UINavigationItem *navItem;
    UIBarButtonItem *refreshButton;
    UITableView *tblView;
    NSMutableData *receivedData;
    NSURLConnection *theConnection;
    UIActivityIndicatorView *activityIndicatorView;
    NSArray *allRows;
}
@property (strong, nonatomic) UIWindow *window;




@end

