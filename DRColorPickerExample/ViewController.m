//
//  ViewController.m
//  DRColorPickerExample
//
//  Created by Jeff on 8/29/14.
//  Copyright (c) 2014 Digital Ruby, LLC. All rights reserved.
//
/*
 The MIT License (MIT)

 Copyright (c) <year> <copyright holders>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "ViewController.h"
#import "DRColorPicker.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) DRColorPickerColor* color;
@property (nonatomic, weak) DRColorPickerViewController* colorPickerVC;
@property (weak, nonatomic) IBOutlet UIButton* colorPickerButton;

@end

@implementation ViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.color = [[DRColorPickerColor alloc] initWithColor:UIColor.blueColor];
    self.view.backgroundColor = UIColor.blueColor;
    self.colorPickerButton.backgroundColor = UIColor.whiteColor;
    self.colorPickerButton.layer.cornerRadius = 4.0f;
    self.colorPickerButton.center = CGPointMake(self.view.bounds.size.width * 0.5f, self.view.bounds.size.height * 0.5f);
    self.colorPickerButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
}

- (IBAction)showColorPickerButtonTapped:(id)sender
{
    // Setup the color picker - this only has to be done once, but can be called again and again if the values need to change while the app runs
    DRColorPickerBackgroundColor = [UIColor lightGrayColor];
    DRColorPickerBorderColor = [UIColor blackColor];
    DRColorPickerFont = [UIFont systemFontOfSize:16.0f];
    DRColorPickerLabelColor = [UIColor blackColor];
    DRColorPickerStoreMaxColors = 200;

    // create the color picker
    DRColorPickerViewController* vc = [DRColorPickerViewController newColorPickerWithColor:self.color];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.rootViewController.showAlphaSlider = YES; // default is YES, set to NO to hide the alpha slider

    NSInteger theme = 0; // 0 = default, 1 = dark, 2 = light

    // in addition to the default images, you can set the images for a light or dark navigation bar / toolbar theme, these are built-in to the color picker bundle
    if (theme == 0)
    {
        // setting these to nil tells it to use the built-in default images
        vc.rootViewController.addToFavoritesImage = nil;
        vc.rootViewController.favoritesImage = nil;
        vc.rootViewController.hueImage = nil;
        vc.rootViewController.wheelImage = nil;
        vc.rootViewController.importImage = nil;
    }
    else if (theme == 1)
    {
        vc.rootViewController.addToFavoritesImage = [UIImage imageNamed:@"DRColorPicker.bundle/images/dark/drcolorpicker-addtofavorites-dark.png"];
        vc.rootViewController.favoritesImage = [UIImage imageNamed:@"DRColorPicker.bundle/images/dark/drcolorpicker-favorites-dark.png"];
        vc.rootViewController.hueImage = [UIImage imageNamed:@"DRColorPicker.bundle/images/dark/drcolorpicker-hue-v3-dark.png"];
        vc.rootViewController.wheelImage = [UIImage imageNamed:@"DRColorPicker.bundle/images/dark/drcolorpicker-wheel-dark.png"];
        vc.rootViewController.importImage = [UIImage imageNamed:@"DRColorPicker.bundle/images/dark/drcolorpicker-import-dark.png"];
    }
    else if (theme == 2)
    {
        vc.rootViewController.addToFavoritesImage = [UIImage imageNamed:@"DRColorPicker.bundle/images/light/drcolorpicker-addtofavorites-light.png"];
        vc.rootViewController.favoritesImage = [UIImage imageNamed:@"DRColorPicker.bundle/images/light/drcolorpicker-favorites-light.png"];
        vc.rootViewController.hueImage = [UIImage imageNamed:@"DRColorPicker.bundle/images/light/drcolorpicker-hue-v3-light.png"];
        vc.rootViewController.wheelImage = [UIImage imageNamed:@"DRColorPicker.bundle/images/light/drcolorpicker-wheel-light.png"];
        vc.rootViewController.importImage = [UIImage imageNamed:@"DRColorPicker.bundle/images/light/drcolorpicker-import-light.png"];
    }

    // assign a weak reference to the color picker, need this for UIImagePickerController delegate
    self.colorPickerVC = vc;

    // make an import block, this allows using images as colors, this import block uses the UIImagePickerController,
    // but in You Doodle for iOS, I have a more complex import that allows importing from many different sources
    vc.rootViewController.importBlock = ^(UINavigationController* navVC, DRColorPickerHomeViewController* rootVC, NSString* title)
    {
        UIImagePickerController* p = [[UIImagePickerController alloc] init];
        p.delegate = self;
        p.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.colorPickerVC presentViewController:p animated:YES completion:nil];
    };

    // dismiss the color picker
    vc.rootViewController.dismissBlock = ^(BOOL cancel)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    };

    // a color was selected, do something with it, but do NOT dismiss the color picker, that happens in the dismissBlock
    vc.rootViewController.colorSelectedBlock = ^(DRColorPickerColor* color, DRColorPickerBaseViewController* vc)
    {
        self.color = color;
        if (color.rgbColor == nil)
        {
            self.view.backgroundColor = [UIColor colorWithPatternImage:color.image];
        }
        else
        {
            self.view.backgroundColor = color.rgbColor;
        }
    };

    // finally, present the color picker
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    // get the image
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    if(!img) img = [info objectForKey:UIImagePickerControllerOriginalImage];

    // tell the color picker to finish importing
    [self.colorPickerVC.rootViewController finishImport:img];

    // dismiss the image picker
    [self.colorPickerVC dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    // image picker cancel, just dismiss it
    [self.colorPickerVC dismissViewControllerAnimated:YES completion:nil];
}

@end