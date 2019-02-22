//
//  ImageEditController.m
//  ImageProcess
//
//  Created by Young on 11/1/18.
//  Copyright © 2018 Young. All rights reserved.
//

#import "ImageEditController.h"
#import "KMPickerController.h"
#import <Photos/Photos.h>
#import "CVTool.hh"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"

@interface ImageEditController ()
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) UIImage *originalImage;

@property (strong, nonatomic) FLAnimatedImageView *imageView;

@property (weak, nonatomic) UIButton *pickerBtn;

@property (strong, nonatomic) NSArray<NSString *> *filters;
@end

@implementation ImageEditController

-(NSArray<NSString *> *)filters
{
    if (_filters)
        return _filters;
    _filters = @[@"Original", @"Canny", @"Canny white", @"Reverse", @"GaussianBlur", @"Sobel", @"K-means"];
    return _filters;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Editor";
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController setToolbarHidden:NO];
    
    [self setupUI];
    [self showImagePicker];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *pickerBtn = [[UIButton alloc] init];
    [pickerBtn setImage:[UIImage imageNamed:@"choose_img"] forState:UIControlStateNormal];
    [pickerBtn addTarget:self action:@selector(showImagePicker) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:pickerBtn];
    self.pickerBtn = pickerBtn;
    
    /** set bottom tools */
    UIButton *pickBtn = [[UIButton alloc] initWithFrame:{{0,0},{10,10}}];
    [pickBtn setImage:[UIImage imageNamed:@"filter_black"] forState:UIControlStateNormal];
    [pickBtn addTarget:self action:@selector(pickFilter) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *pickItem = [[UIBarButtonItem alloc] initWithCustomView:pickBtn];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(saveCurrentImage)];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self setToolbarItems:@[pickItem, flexItem,saveItem]];
    self.navigationController.toolbar.tintColor = [UIColor blackColor];
    
    
    /** set canvas */
    self.imageView = [[FLAnimatedImageView alloc] initWithImage:self.originalImage];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
}

- (void)showImagePicker
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.tintColor = [UIColor blackColor];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
    
    /** show the image picker with a bubble */
    picker.modalPresentationStyle = UIModalPresentationPopover;
    picker.popoverPresentationController.delegate = self;
    picker.popoverPresentationController.sourceView = self.pickerBtn;
    picker.popoverPresentationController.sourceRect = CGRectMake(16, 32, 0, 0);
}

- (void)pickFilter
{
    KMPickerController *pickerView = [KMPickerController pickerViewWithSourceView:self.navigationController.toolbar andDataArr:self.filters callback:^(NSUInteger index) {
        
        //TODO: add filters
        dispatch_async(dispatch_queue_create(NULL, 0), ^{
            [self processImageWithIndex:index];
        });
        
    }];
    
    pickerView.attColor = [UIColor blackColor];
    
    [self presentViewController:pickerView animated:YES completion:nil];
}


/**
 process image with specific filter

 @param index the index of filters list
 */
- (void)processImageWithIndex:(NSInteger)index
{
    // Create a UIImage from the sample buffer data
    UIImage *image = self.originalImage;
    /** original is the first place */
    index -= 1;
    switch (index) {
        case 0:
            image = [CVTool processImage:image cvEffect:kCVCanny];
            break;
        case 1:
            image = [CVTool processImage:image cvEffect:kCVCannyWhite];
            break;
        case 2:
            image = [CVTool processImage:image cvEffect:kCVReverse];
            break;
        case 3:
            image = [CVTool processImage:image cvEffect:kCVGaussianBlur];
            break;
        case 4:
            image = [CVTool processImage:image cvEffect:kCVSobel];
            break;
        case 5:
            image = [CVTool processImage:image cvEffect:kCVK_Means];
            break;
        default:
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
    });
}

- (void)saveCurrentImage
{
    /** stop session, pause view */
    UIImage *image = self.imageView.image;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        __unused PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success = %d, error = %@", success, error);
        NSString *message = success? @"Save success!": error.domain;
        [self showAlertWithTitle:message content:nil conformStr:@"OK" conformAction:nil];
    }];
}

//MARK: - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    
    NSURL *pathUrl = info[@"UIImagePickerControllerImageURL"];
    
    if ([pathUrl.absoluteString hasSuffix:@".gif"])
    {
        NSData *gifData = [NSData dataWithContentsOfURL:pathUrl];
        FLAnimatedImage *gifImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
        self.imageView.animatedImage = gifImage;
    }
    else
    {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        self.originalImage = image;
        self.imageView.image = image;
    }
    
    
    [picker dismissViewControllerAnimated:NO completion:nil];
}

//MARK: - UIPopoverPresentationControllerDelegate
- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    popoverPresentationController.backgroundColor = [UIColor whiteColor];
    popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    NSLog(@"PICKER VIEW CONTROLLER DISMISS");
}


@end
