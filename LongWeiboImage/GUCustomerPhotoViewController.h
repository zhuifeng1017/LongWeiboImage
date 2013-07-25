//
//  GUCustomerPhotoViewController.h
//  GoU
//
//
//
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FGalleryPhotoView.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageDestination.h>
@protocol GUCustomerPhotoViewController;

@interface GUCustomerPhotoViewController : UIViewController <UIScrollViewDelegate,UIActionSheetDelegate,FGalleryPhotoViewDelegate> {
	
	BOOL _isActive;
	BOOL _isFullscreen;
	BOOL _isScrolling;
	BOOL _isThumbViewShowing;
	UIStatusBarStyle _prevStatusStyle;
	CGFloat _prevNextButtonSize;
	CGRect _scrollerRect;
	NSInteger _currentIndex;
	
	UIView *_container; // used as view for the controller
	UIView *_innerContainer; // sized and placed to be fullscreen within the container
	UIToolbar *_toolbar;
	UIScrollView *_scroller;
	//NSMutableDictionary *_photoLoaders;
    NSMutableArray *imageArr;
	NSMutableArray *_barItems;
	NSMutableArray *_photoViews;
    NSMutableArray *realUrlarr;
	int offset_x;
    
	UIBarButtonItem *_nextButton;
	UIBarButtonItem *_prevButton;
    UIBarButtonItem *_shareButton;
    BOOL tag;
}


- (void)next;
- (void)previous;
- (void)gotoImageByIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)reloadGallery;
//- (FGalleryPhoto*)currentPhoto;

@property NSInteger currentIndex;
@property NSInteger startingIndex;
@property (nonatomic,readonly) UIToolbar *toolBar;
@property (nonatomic,retain) NSMutableArray *imageArr;
@property (nonatomic,retain) NSMutableArray *realUrlarr;

@end
