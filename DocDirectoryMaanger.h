//
//  DocDirectoryMaanger.h
//  MediaPicker
//
//  Created by Atul on 17/02/17.
//  Copyright © 2017 Atul Gawali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SituationCaptureType){
    MediaCaptureTypeVideo = 1,
    MediaCaptureTypeImage,
    MediaCaptureTypeAudio
};
@interface DocDirectoryMaanger : NSObject
#pragma mark - Public Methode

/**
 +sharedManager returns a global instance of RecordedVideoManager.
 */
+(instancetype)sharedManager;

/**
 +resetSharedInstance resets a global instance of RecordedVideoManager.
 */
+ (void)resetSharedInstance;

-(NSString *)documentsPathWithFolderName;

-(NSString *)saveSituationCapture:(NSData *)mediData withSituationCaptureType:(NSInteger)captureType;

-(UIImage *)getImageFromDocdirectory:(NSString *)imageName;

-(NSString *)getPathForMediaFile:(NSString *)videoFileName;

- (NSArray *)getAllDownloadFileName;
@end
