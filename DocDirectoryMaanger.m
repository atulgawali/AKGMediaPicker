//
//  DocDirectoryMaanger.m
//  MediaPicker
//
//  Created by Atul on 17/02/17.
//  Copyright © 2017 Atul Gawali. All rights reserved.
//

#import "DocDirectoryMaanger.h"

static DocDirectoryMaanger *sharedDocDirectoryMaanger = nil;

@implementation DocDirectoryMaanger

+(instancetype)sharedManager
{
    //For reseting shared instance
    if (sharedDocDirectoryMaanger == nil) {
        sharedDocDirectoryMaanger = [[self alloc] init];
    }
    return sharedDocDirectoryMaanger;
}
+ (void)resetSharedInstance {
    sharedDocDirectoryMaanger = nil;
}
-(id)init{
    if (self = [super init]) {
        // [self setupMethode];
    }
    return self;
}

-(NSString *)documentsPathWithFolderName
{
    NSError *error;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory=[path objectAtIndex:0];
    NSString *newPath = [documentsDirectory stringByAppendingPathComponent:@"/recordedMovement"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:newPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    return newPath;
}

-(NSString *)saveSituationCapture:(NSData *)mediData withSituationCaptureType:(NSInteger)captureType{
    NSString *savePath = [self documentsPathWithFolderName];
    NSString *fileName;
    switch (captureType) {
        case MediaCaptureTypeVideo:
            fileName = [NSString stringWithFormat:@"%@.%s",[self generateUUID],"mp4"];
            break;
        case MediaCaptureTypeImage:
            fileName = [NSString stringWithFormat:@"%@.%s",[self generateUUID],"png"];
            break;
        case MediaCaptureTypeAudio:
            fileName = [NSString stringWithFormat:@"%@.%s",[self generateUUID],"caf"];
            break;
        default:
            break;
    }
    NSString *savedImagePath = [savePath stringByAppendingPathComponent:fileName];
    
    [mediData writeToFile:savedImagePath atomically:YES];
    [self clearTmpDirectory];
    return fileName;
    
}
- (NSArray *)getAllDownloadFileName
{
    NSString *savePath = [self documentsPathWithFolderName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // all files in the path
    
    return [fileManager contentsOfDirectoryAtPath:savePath error:nil];
}

- (void)clearTmpDirectory
{
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}

-(NSString *)getPathForMediaFile:(NSString *)filename{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [self documentsPathWithFolderName], filename];
    return filePath;
}


-(UIImage *)getImageFromDocdirectory:(NSString *)imageName{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [self documentsPathWithFolderName], imageName];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    return [UIImage imageWithData:imageData];
}
-(NSString *)generateUUID{
    return @"atul";
    NSString *result = nil;
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    if (uuid)
    {
        result = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
    }
    return result;
}

@end
