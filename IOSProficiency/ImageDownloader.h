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
    NSIndexPath *theIndexPath;
    NSMutableData *receivedData;
    NSURLConnection *theConnection;

}

-(void)startDownloadingImageForIndexPath:(NSIndexPath*)iPath fromURLString:(NSString*)theURL;
@end
