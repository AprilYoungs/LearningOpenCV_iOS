//
//  KMPickerController.m
//  KMHealth-iPhone
//
//  Created by Young on 8/9/18.
//  Copyright © 2018 KM. All rights reserved.
//

#import "KMPickerController.h"

@interface KMPickerController ()
<UIPickerViewDelegate,
UIPickerViewDataSource,
UIPopoverPresentationControllerDelegate>
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) SelectBlock callback;
@end

@implementation KMPickerController

+ (instancetype)pickerViewWithSourceView:(UIView *)sourceView andDataArr:(NSArray *)dataArr callback:(SelectBlock)callback
{
    KMPickerController *picker = [[KMPickerController alloc] initWith:sourceView];
    picker.dataArr = dataArr;
    picker.callback = callback;
    
    
    return picker;
}

- (instancetype)initWith:(UIView *)sourceView
{
    self = [super init];
    if (self)
    {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width-80, 150);
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.popoverPresentationController.delegate = self;
        self.popoverPresentationController.sourceView = sourceView;
        self.popoverPresentationController.sourceRect = CGRectMake(sourceView.bounds.size.width/2, 0, 0, 0);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self render];
    
    [self.pickerView selectRow:self.defaultIndex inComponent:0 animated:NO];
}

- (void)render
{
    self.pickerView = [[UIPickerView alloc] init];
    [self.view addSubview:self.pickerView];
    
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
}

//MARK: - PickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dataArr.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    UIColor *color = self.attColor == nil? [UIColor blackColor]: self.attColor;
    
    NSAttributedString* attstr = [[NSAttributedString alloc] initWithString:self.dataArr[row] attributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    return attstr;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.callback)
    {
        self.callback(row);
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    popoverPresentationController.backgroundColor = [UIColor whiteColor];
    popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}
- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    self.callback = nil;
    NSLog(@"PICKER VIEW CONTROLLER DISMISS");
}

@end
