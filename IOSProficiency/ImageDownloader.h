//
//  ImageDownloader.h
//  IOSProficiency
//
//  Created by Shakir Zareen on 12/01/2015.
//  Copyright (c) 2015 Shakir Zareen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageDownloader : NSObject
{
    @private
    NSIndexPath *theIndexPath;      //this will hold the indexpath of the cell. it will be sent in the NSNotification that will be posted
    NSMutableData *receivedData;    //to hold the data received from NSURLConnection
    NSURLConnection *theConnection; //the NSURLConnection that will download the image

}

-(void)startDownloadingImageForIndexPath:(NSIndexPath*)iPath fromURLString:(NSString*)theURL;
@end
