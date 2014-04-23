//
//  CapturePhotoViewController.m
//  FunCamera
//
//  Created by alan on 23/4/14.
//  Copyright (c) 2014 alan. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CapturePhotoViewController.h"

@interface CapturePhotoViewController (){
    GPUImageStillCamera *stillCamera;
    GPUImageOutput<GPUImageInput> *filter, *secondFilter, *terminalFilter;
    UISlider *filterSettingsSlider;
    UIButton *photoCaptureButton;
    
    GPUImagePicture *memoryPressurePicture1, *memoryPressurePicture2;
}

@end

@implementation CapturePhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
	CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];
    
    // Yes, I know I'm a caveman for doing all this by hand
//	GPUImageView *primaryView = [[GPUImageView alloc] initWithFrame:mainScreenFrame];
//	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
//    filterSettingsSlider = [[UISlider alloc] initWithFrame:CGRectMake(25.0, mainScreenFrame.size.height - 50.0, mainScreenFrame.size.width - 50.0, 40.0)];
//    [filterSettingsSlider addTarget:self action:@selector(updateSliderValue:) forControlEvents:UIControlEventValueChanged];
//	filterSettingsSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    filterSettingsSlider.minimumValue = 0.0;
//    filterSettingsSlider.maximumValue = 3.0;
//    filterSettingsSlider.value = 1.0;
//    
//    [self.view addSubview:filterSettingsSlider];
//    
//    photoCaptureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    photoCaptureButton.frame = CGRectMake(round(mainScreenFrame.size.width / 2.0 - 150.0 / 2.0), mainScreenFrame.size.height - 90.0, 150.0, 40.0);
//    [photoCaptureButton setTitle:@"Capture Photo" forState:UIControlStateNormal];
//	photoCaptureButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    [photoCaptureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
//    [photoCaptureButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
//    
//    [self.view addSubview:photoCaptureButton];
    
//	self.view = primaryView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GPUImageView *primaryView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    
    filterSettingsSlider = [[UISlider alloc] initWithFrame:CGRectMake(25.0, 568 - 50.0, 320 - 50.0, 40.0)];
    [filterSettingsSlider addTarget:self action:@selector(updateSliderValue:) forControlEvents:UIControlEventValueChanged];
	filterSettingsSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    filterSettingsSlider.minimumValue = 0.0;
    filterSettingsSlider.maximumValue = 3.0;
    filterSettingsSlider.value = 1.0;
    
    [primaryView addSubview:filterSettingsSlider];
    
    photoCaptureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    photoCaptureButton.frame = CGRectMake(round(320 / 2.0 - 150.0 / 2.0), 568 - 90.0, 150.0, 40.0);
    [photoCaptureButton setTitle:@"Capture Photo" forState:UIControlStateNormal];
	photoCaptureButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [photoCaptureButton addTarget:self action:@selector(takePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [photoCaptureButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    [primaryView addSubview:photoCaptureButton];
    
    self.view = primaryView;
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    // Do any additional setup after loading the view from its nib.
    stillCamera = [[GPUImageStillCamera alloc] init];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    filter = [[GPUImageSketchFilter alloc] init];
    
    [stillCamera addTarget:filter];
    GPUImageView *filterView = (GPUImageView *)self.view;
    filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    //    [filter addTarget:filterView];
    [filter addTarget:filterView];
    
    [stillCamera startCameraCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)updateSliderValue:(id)sender
{
    [(GPUImagePixellateFilter *)filter setFractionalWidthOfAPixel:[(UISlider *)sender value]];
    [(GPUImageGammaFilter *)filter setGamma:[(UISlider *)sender value]];
}


- (IBAction)takePhoto:(id)sender;
{
    [photoCaptureButton setEnabled:NO];
    
    [stillCamera capturePhotoAsJPEGProcessedUpToFilter:filter withCompletionHandler:^(NSData *processedJPEG, NSError *error){
        
        // Save to assets library
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        NSMutableDictionary* myMetadataDictionary = [stillCamera.currentCaptureMetadata mutableCopy];
//        myMetadataDictionary[(NSString *)kCGImagePropertyOrientation] = orientation
        [myMetadataDictionary setObject:[NSNumber numberWithInt:UIImageOrientationUp] forKey:@"Orientation"];
//        myMetadataDictionary[@"Orientation"] = UIImageOrientationUp;
        
        [library writeImageDataToSavedPhotosAlbum:processedJPEG metadata:myMetadataDictionary completionBlock:^(NSURL *assetURL, NSError *error2)
         {
             if (error2) {
                 NSLog(@"ERROR: the image failed to be written");
             }
             else {
                 NSLog(@"PHOTO SAVED - assetURL: %@", assetURL);
             }
			 
             runOnMainQueueWithoutDeadlocking(^{
                 [photoCaptureButton setEnabled:YES];
             });
         }];
    }];
}

@end
