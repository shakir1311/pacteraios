//
//  AppDelegate.m
//  IOSProficiency
//
//  Created by Shakir Zareen on 06/01/2015.
//  Copyright (c) 2015 Shakir Zareen. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
    CGFloat navBarHeight = 64;
    
    self.window = [[UIWindow alloc] initWithFrame:mainScreenBounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    cntrl = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, mainScreenBounds.size.width, navBarHeight)];
    navBar.backgroundColor = [UIColor whiteColor];
    
    navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Click refresh to load data";
    
    refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction:)];
    navItem.rightBarButtonItem = refreshButton;
    
    [navBar setItems:[NSArray arrayWithObject:navItem]];
    
    [[cntrl view] addSubview:navBar];
    
    tblView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, mainScreenBounds.size.width, mainScreenBounds.size.height - navBarHeight - 20) style:UITableViewStylePlain];
    
    [tblView setDataSource:self];
    [tblView setDelegate:self];
    
    [tblView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [[cntrl view] addSubview:tblView];
    
    self.window.rootViewController = cntrl;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayDownloadedImage:)
                                                 name:@"displayDownloadedImage" object:nil];

    return YES;
}

-(void)displayDownloadedImage:(NSNotification *)notification
{
    NSDictionary *dict = (NSDictionary*)[notification userInfo];
    
    NSIndexPath *iPath = [dict objectForKey:@"iPath"];
    UIImage *image = [dict objectForKey:@"image"];
    
    UIImageView *imgView = (UIImageView*)[[[tblView cellForRowAtIndexPath:iPath] contentView] viewWithTag:30];
    imgView.image = image;
    
    ImageDownloader *iDownloader = notification.object;
    iDownloader = nil;

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id objDescription = [[allRows objectAtIndex:indexPath.row] objectForKey:@"description"];
    if ( [objDescription isKindOfClass:[NSNull class] ])
    {
        return 90.0;
    }
    else
    {
        
        return MAX([self getSizeForString:objDescription].size.height+20.0 + 25.0, 90.0);
    }
    return 10.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    
        
        
    }
    
    for ( UIView *vv in cell.contentView.subviews)
    {
        [vv removeFromSuperview];
    }
    
    UILabel *titleLabel;
    id objTitle = [[allRows objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    if ( [objTitle isKindOfClass:[NSNull class]])
    {
        
    }
    else
    {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, 220.0, 15.0)];
        titleLabel.tag = 10;
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        titleLabel.textColor = [UIColor blueColor];
        
        [cell.contentView addSubview:titleLabel];
        titleLabel.text = objTitle;
    }
    
    UILabel *descriptionLabel;
    CGRect descriptionRect;
    id objDescription = [[allRows objectAtIndex:indexPath.row] objectForKey:@"description"];
    if ( [objDescription isKindOfClass:[NSNull class] ])
    {
        
    }
    else
    {
        descriptionRect = [self getSizeForString:objDescription];
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 25.0, 220, descriptionRect.size.height + 20.0)];
        descriptionLabel.tag = 20;
        descriptionLabel.font = [UIFont systemFontOfSize:14.0];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.numberOfLines = 10;
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descriptionLabel.text = objDescription;
        
        [cell.contentView addSubview:descriptionLabel];
    }
    
    
    
    cell.imageView.image = nil;
    UIImageView *imageView;
    
    
    id objImageHRef = [[allRows objectAtIndex:indexPath.row] objectForKey:@"imageHref"];
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(230.0, 5.0, 80.0, 80.0)];
    imageView.tag = 30;
    imageView.contentMode = UIViewContentModeScaleToFill;
    [cell.contentView addSubview:imageView];
    if ( [objImageHRef isKindOfClass:[NSNull class]])
    {
        imageView.image = [UIImage imageNamed:@"noimage.png"];
    }
    else
    {
        
        imageView.image = [UIImage imageNamed:@"loading.png"];
        
        ImageDownloader *iDownloader = [[ImageDownloader alloc] init];
        [iDownloader startDownloadingImageForIndexPath:indexPath fromURLString:objImageHRef];
    }
    NSLog(@"%@",@"cell created");
    //NSLog(@"%@",[[[allRows objectAtIndex:indexPath.row] objectForKey:@"title"] class]);
    return cell;
}

-(CGRect)getSizeForString:(NSString*)str
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
    // NSString class method: boundingRectWithSize:options:attributes:context is
    // available only on ios7.0 sdk.
    return [str boundingRectWithSize:CGSizeMake(220, CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return allRows.count;
}

-(void)startAnimating
{
    if ( activityIndicatorView == nil )
    {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
        activityIndicatorView.center = cntrl.view.center;
        [cntrl.view addSubview:activityIndicatorView];
        
    }
    [cntrl.view bringSubviewToFront:activityIndicatorView];
    [activityIndicatorView setHidden:false];
    [activityIndicatorView startAnimating];
    [cntrl.view setUserInteractionEnabled:false];
    [cntrl.view setAlpha:0.5];
    
}

-(void)stopAnimating
{
    
    [activityIndicatorView setHidden:true];
    [activityIndicatorView stopAnimating];
    [cntrl.view setUserInteractionEnabled:true];
    [cntrl.view setAlpha:1.0];
    
}



-(IBAction)refreshAction:(id)sender
{
    [self startAnimating];
    [self loadDataFromURL];
}

-(void)loadDataFromURL
{
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/746330/facts.json"]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    receivedData = [NSMutableData dataWithCapacity: 0];
    theConnection =[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (!theConnection) {
        [self stopAnimating];
        receivedData = nil;
        [self showErrorMessageWithTitle:@"Error" andErrorMessage:@"Could not connect to URL"];
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self stopAnimating];
    theConnection = nil;
    receivedData = nil;
    
    [self showErrorMessageWithTitle:@"Error" andErrorMessage:@"Could not load data from URL"];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self stopAnimating];
    [self parseJSONfromData:receivedData];
    theConnection = nil;
    receivedData = nil;
}

-(void)parseJSONfromData:(NSMutableData*)mData
{
    NSError *error = nil;
    NSString *stringData = [[NSString alloc] initWithData:mData encoding:NSASCIIStringEncoding];
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:[stringData dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    if ( !error )
    {
        navItem.title = [dictionary objectForKey:@"title"];

        allRows = [dictionary objectForKey:@"rows"];

        [tblView reloadData];
    }
    
    
}

-(void)showErrorMessageWithTitle:(NSString*)errorTitle andErrorMessage:(NSString*)errorMessage
{
    UIAlertView *v = [[UIAlertView alloc] initWithTitle:errorTitle message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    navItem.title = @"Click refresh to load data";
    [v show];
}



@end
