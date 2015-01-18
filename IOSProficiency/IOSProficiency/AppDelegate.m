//
//  AppDelegate.m
//  IOSProficiency
//
//  Created by Shakir Zareen on 06/01/2015.
//  Copyright (c) 2015 Shakir Zareen. All rights reserved.
//


////****************Note: Using Non ARC code is painfully difficult with this version on XCode
////**************** In simple terms in NON ARC we have to release/retain the object.
////**************** This will decrease/increase retaincount. When retain count = 0 the object
////**************** is Garbage collected. THis can easily lead to memory leakage/null reference
////**************** /orphan objects. ARC takes care of that problem by proactively looking into the
////**************** refrecnes to an object and if (decided by utilizing complex algo) the object is no longer
////**************** needed then it is garbage collected and memory is freed up

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    //////////////////////////////////////////
    //So here we will create all the interface objects by code. More effort vould be done to
    //support various screen sizes and orientations. But you know good programmers are lazy ;)
    //
    /////////////////////////////////////////
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
    
    
    //This is the main trick part which makes the image load in background
    //We had following objectives:
    //  - Load Image in BG
    //  - Once loaded show in the respective cell
    //  - Once commpleted release the associated Imagedownloader
    //  - Keep memory usage as low as possible
    //So this notification object will contain the image, indexpath and reference to the
    //sending imagedownloader object
    //
    //Note that this could have been donw in various other methods. But this one seemed most appealing to
    //me as it is straightforward and easier to debug
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(displayDownloadedImage:)
                                                 name:@"displayDownloadedImage" object:nil];

    return YES;
}

//This is the function that will be called once we receive a response from
//the imagedownloader object. We may receive an image, error or null (which is taken care of while returning from imagedownloader
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
    //This part is not in best shape but works. SO effectively we do following
    //  check the size of string (in UI points) and then allocate that much space for the
    //  UILabel (that will display the string). However we also need to take care of the cases
    //  when the string is too short. So we take MAX value out of the string height anf the UIImage height
    
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
    // We are going to custom create two UILabels and One UIImageView. Since we dont want the
    // defautl layout of UITableViewCell. This could have been done in a perfect way - maybe -
    // by adjusting the frames of existing titlelabel, detaillable and imageview. But I prefered
    // doing from scratch for a better understanding
    static NSString *MyIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    
        
        
    }
    
//We want to empty the contentview before shafting in more subviews. Otherwise the cell will become an endless pile of unutilized UILabels and UIImageViews
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
//This is where we will Asycnhronouly download the image
        ImageDownloader *iDownloader = [[ImageDownloader alloc] init];
        [iDownloader startDownloadingImageForIndexPath:indexPath fromURLString:objImageHRef];
    }
    return cell;
}

-(CGRect)getSizeForString:(NSString*)str
{
    //Copied code from internet. It works somehow with 90% accuracy
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
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
    //Disable UserInteraction, show the activityindicator and start animation and bring it to front as well
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
    //reverse what we did in start animating
    [activityIndicatorView setHidden:true];
    [activityIndicatorView stopAnimating];
    [cntrl.view setUserInteractionEnabled:true];
    [cntrl.view setAlpha:1.0];
    
}



-(IBAction)refreshAction:(id)sender
{
    //This part will call the actual feed to start loading
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
