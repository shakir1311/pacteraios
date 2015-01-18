//
//  ImageDownloader.m
//  IOSProficiency
//
//  Created by Shakir Zareen on 12/01/2015.
//  Copyright (c) 2015 Shakir Zareen. All rights reserved.
//

#import "ImageDownloader.h"

@implementation ImageDownloader

-(void)startDownloadingImageForIndexPath:(NSIndexPath*)iPath fromURLString:(NSString*)theURL
{
    theIndexPath = iPath;
    receivedData = [[NSMutableData alloc] init];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:theURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5.0];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    theConnection = conn;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    receivedData = nil;
    theConnection = nil;
    
    UIImage *image = [UIImage imageNamed:@"noimage.png"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:theIndexPath,image, nil] forKeys:[NSArray arrayWithObjects:@"iPath",@"image", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"displayDownloadedImage" object:self userInfo:dict];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *image=nil;
    if ( receivedData == nil )
    {
        image = [UIImage imageNamed:@"noimage.png"];
    }
    else
    {
        image = [[UIImage alloc] initWithData:receivedData];
    }
    
    if ( image == nil )
    {
        image = [UIImage imageNamed:@"noimage.png"];
    }
    
    receivedData = nil;
    theConnection = nil;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:theIndexPath,image, nil] forKeys:[NSArray arrayWithObjects:@"iPath",@"image", nil]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"displayDownloadedImage" object:self userInfo:dict];
    
    
    
}
@end
