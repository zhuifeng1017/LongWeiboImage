//
//  GUCustomerPhotoViewController.m
//  GoU
//
//
//

#import "GUCustomerPhotoViewController.h"

#define kThumbnailSize 75
#define kThumbnailSpacing 4
#define kCaptionPadding 3
#define kToolbarHeight 40


@interface GUCustomerPhotoViewController (Private)

// general
- (void)buildViews;
- (void)destroyViews;
- (void)layoutViews;
- (void)moveScrollerToCurrentIndexWithAnimation:(BOOL)animation;
- (void)updateTitle;
- (void)updateButtons;
- (void)layoutButtons;
- (void)updateScrollSize;
- (void)resizeImageViewsWithRect:(CGRect)rect;
- (void)resetImageViewZoomLevels;

- (void)enterFullscreen;
- (void)exitFullscreen;
- (void)enableApp;
- (void)disableApp;

- (void)positionInnerContainer;
- (void)positionScroller;
- (void)positionToolbar;

@end



@implementation GUCustomerPhotoViewController
@synthesize currentIndex = _currentIndex;
@synthesize toolBar = _toolbar;
@synthesize startingIndex = _startingIndex;
@synthesize imageArr,realUrlarr;
#pragma mark - Public Methods


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if((self = [super initWithNibName:nil bundle:nil])) {
        
		// init gallery id with our memory address
		
        
        // configure view controller
		self.hidesBottomBarWhenPushed		= YES;
        
        // set defaults
		_prevStatusStyle					= UIStatusBarStyleDefault;
		
		// create storage objects
		_currentIndex						= 0;
        _startingIndex                      = 2;
		//_photoLoaders						= [[NSMutableDictionary alloc] init];
        imageArr                            = [[NSMutableArray alloc] init];
        realUrlarr                          = [[NSMutableArray alloc] init];
		_photoViews							= [[NSMutableArray alloc] init];
		_barItems							= [[NSMutableArray alloc] init];
        /*
         // debugging:
         _container.layer.borderColor = [[UIColor yellowColor] CGColor];
         _container.layer.borderWidth = 1.0;
         
         _innerContainer.layer.borderColor = [[UIColor greenColor] CGColor];
         _innerContainer.layer.borderWidth = 1.0;
         
         _scroller.layer.borderColor = [[UIColor redColor] CGColor];
         _scroller.layer.borderWidth = 2.0;
         */
	}
	return self;
}

- (void)loadView
{
    // create public objects first so they're available for custom configuration right away. positioning comes later.
    _container							= [[UIView alloc] initWithFrame:CGRectZero];
    _innerContainer						= [[UIView alloc] initWithFrame:CGRectZero];
    _scroller							= [[UIScrollView alloc] initWithFrame:CGRectZero];
    _toolbar							= [[UIToolbar alloc] initWithFrame:CGRectZero];
    
    _toolbar.barStyle					= UIBarStyleDefault;
    _container.backgroundColor			= [UIColor blackColor];
    
    // listen for container frame changes so we can properly update the layout during auto-rotation or going in and out of fullscreen
    [_container addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
    // setup scroller
    _scroller.delegate							= self;
    _scroller.pagingEnabled						= YES;
    _scroller.showsVerticalScrollIndicator		= NO;
    _scroller.showsHorizontalScrollIndicator	= NO;
    
    tag = NO;
    
    // make things flexible
    _container.autoresizesSubviews				= NO;
    _innerContainer.autoresizesSubviews			= NO;
    _scroller.autoresizesSubviews				= NO;
    _container.autoresizingMask					= UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // setup thumbs view
    
	self.view                                   = _container;
	
	// add items to their containers
	[_container addSubview:_innerContainer];
	[_innerContainer addSubview:_scroller];
	[_innerContainer addSubview:_toolbar];
	
    
	
	// create buttons for toolbar
	UIImage *leftIcon = [UIImage imageNamed:@"photo-gallery-left.png"];
	UIImage *rightIcon = [UIImage imageNamed:@"photo-gallery-right.png"];
	_nextButton = [[UIBarButtonItem alloc] initWithImage:rightIcon style:UIBarButtonItemStylePlain target:self action:@selector(next)];
	_prevButton = [[UIBarButtonItem alloc] initWithImage:leftIcon style:UIBarButtonItemStylePlain target:self action:@selector(previous)];
	
	// add prev next to front of the array
	[_barItems insertObject:_nextButton atIndex:0];
	[_barItems insertObject:_prevButton atIndex:0];
	
	_prevNextButtonSize = leftIcon.size.width;
	
	// set buttons on the toolbar.
	[_toolbar setItems:_barItems animated:NO];
    
    // build stuff
    [self reloadGallery];
    UIBarButtonItem  *backButton=[[UIBarButtonItem alloc] init];
	backButton.title=@"返回";
	self.navigationItem.backBarButtonItem=backButton;
}

- (void)viewDidUnload {
    
    [self destroyViews];
    
     _barItems = nil;
     _nextButton = nil;
     _prevButton = nil;
     _container = nil;
     _innerContainer = nil;
     _scroller = nil;
     _toolbar = nil;
    // remove KVO listener
	[_container removeObserver:self forKeyPath:@"frame"];
	// Cancel all photo loaders in progress
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    _container = nil;
    _innerContainer = nil;
    _toolbar = nil;
    _scroller = nil;
	[_barItems removeAllObjects];
	_barItems = nil;
	[_photoViews removeAllObjects];
    _photoViews = nil;
    _nextButton = nil;
    _prevButton = nil;
    [super viewDidUnload];
}


- (void)destroyViews {
    // remove previous photo views
    for (UIView *view in _photoViews) {
        [view removeFromSuperview];
    }
    [_photoViews removeAllObjects];
    
}


- (void)reloadGallery
{
    _currentIndex = _startingIndex;
    // remove the old
    [self destroyViews];
    
    // build the new
    if ([realUrlarr count] > 0) {
        // create the image views for each photo
        [self buildViews];
        // start on first image
        [self gotoImageByIndex:_currentIndex animated:NO];
        
        // layout
        [self layoutViews];
    }
}

- (UIImage*)currentPhoto
{
    // return [_photoLoaders objectForKey:[NSString stringWithFormat:@"%i", _currentIndex]];
    return [imageArr objectAtIndex:_currentIndex];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
    //_isActive = YES;
	//[self layoutViews];
	
	// update status bar to be see-through
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
	
	// init with next on first run.
	//if( _currentIndex == -1 ) [self next];
	//else [self gotoImageByIndex:_currentIndex animated:NO];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
	_isActive = NO;
    
	[[UIApplication sharedApplication] setStatusBarStyle:_prevStatusStyle animated:animated];
}


- (void)resizeImageViewsWithRect:(CGRect)rect
{
	// resize all the image views
	NSUInteger i, count = [_photoViews count];
	float dx = 0;
	for (i = 0; i < count; i++) {
		FGalleryPhotoView * photoView = [_photoViews objectAtIndex:i];
		photoView.frame = CGRectMake(dx, 0, rect.size.width, rect.size.height );
		dx += rect.size.width;
	}
}


- (void)resetImageViewZoomLevels
{
	// resize all the image views
	NSUInteger i, count = [_photoViews count];
	for (i = 0; i < count; i++) {
		FGalleryPhotoView * photoView = [_photoViews objectAtIndex:i];
		[photoView resetZoom];
	}
}



- (void)next
{
	NSUInteger numberOfPhotos = [realUrlarr count];
	NSUInteger nextIndex = _currentIndex+1;
	
	// don't continue if we're out of images.
	if( nextIndex <= numberOfPhotos )
	{
		//[self gotoImageByIndex:nextIndex animated:YES];
        _currentIndex = nextIndex;
        [self moveScrollerToCurrentIndexWithAnimation:YES];
	}
    tag = NO;
}



- (void)previous
{
	NSUInteger prevIndex = _currentIndex-1;
    _currentIndex = prevIndex;
	//[self gotoImageByIndex:prevIndex animated:YES];
    [self moveScrollerToCurrentIndexWithAnimation:YES];
    tag = NO;
}



- (void)gotoImageByIndex:(NSUInteger)index animated:(BOOL)animated
{
	NSUInteger numPhotos = [realUrlarr count];
	
	// constrain index within our limits
    if( index >= numPhotos ) index = numPhotos - 1;
	
	
	if( numPhotos == 0 ) {
		
		// no photos!
		_currentIndex = -1;
	}
	else {
		
		// clear the fullsize image in the old photo
		//[self unloadFullsizeImageWithIndex:_currentIndex];
		
		_currentIndex = index;
        FGalleryPhotoView * photoView = [_photoViews objectAtIndex:_currentIndex];
        if (photoView.imageView.image == nil) {
            NSString *fullPhotoPath = [realUrlarr objectAtIndex:_currentIndex];
            photoView.imageView.image = [UIImage imageWithContentsOfFile:fullPhotoPath];

        }
        //photoView.imageView.image = [realUrlarr objectAtIndex:_currentIndex];
		[self moveScrollerToCurrentIndexWithAnimation:animated];
		[self updateTitle];
		
	}
	[self updateButtons];
}

- (void)getImage
{
    /* dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
    NSURL *url = [realUrlarr objectAtIndex:_currentIndex];
    FGalleryPhotoView * photoView = [_photoViews objectAtIndex:_currentIndex];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(photoView.frame.origin.x, photoView.frame.origin.y, photoView.frame.size.width/2.0, photoView.frame.size.height/2.0)];
    [activityIndicatorView startAnimating];
    [photoView addSubview:activityIndicatorView];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:url
             resultBlock:^(ALAsset *asset) {
                 if (asset != nil) {
                     ALAssetRepresentation *image_representation = [asset defaultRepresentation];
                     UIImage *image = [UIImage imageWithCGImage:image_representation.fullResolutionImage];
                     dispatch_async(dispatch_get_main_queue(), ^{
                          photoView.imageView.image = image;
                     });
                    
                 }else{
                   //TODO：图片在相册中被删除处理
                 }
                 [activityIndicatorView removeFromSuperview];
                 // create a buffer to hold image data
                }
            failureBlock:^(NSError *error) {
                [activityIndicatorView removeFromSuperview];
                NSLog(@"couldn't get asset: %@", error);
            }];
         });*/
    
    
    NSString *fullPhotoPath = [realUrlarr objectAtIndex:_currentIndex];
    FGalleryPhotoView * photoView = [_photoViews objectAtIndex:_currentIndex];
    photoView.imageView.image = [UIImage imageWithContentsOfFile:fullPhotoPath];
}


- (void)layoutViews
{
	[self positionInnerContainer];
	[self positionScroller];
	[self positionToolbar];
	[self updateScrollSize];
	[self resizeImageViewsWithRect:_scroller.frame];
	[self layoutButtons];
	[self moveScrollerToCurrentIndexWithAnimation:NO];
}



#pragma mark - Private Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if([keyPath isEqualToString:@"frame"])
	{
		[self layoutViews];
	}
}


- (void)positionInnerContainer
{
	CGRect screenFrame = [[UIScreen mainScreen] bounds];
	CGRect innerContainerRect;
	
	if( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
	{//portrait
		innerContainerRect = CGRectMake( 0, _container.frame.size.height - screenFrame.size.height, _container.frame.size.width, screenFrame.size.height );
	}
	else
	{// landscape
		innerContainerRect = CGRectMake( 0, _container.frame.size.height - screenFrame.size.width, _container.frame.size.width, screenFrame.size.width );
	}
	
	_innerContainer.frame = innerContainerRect;
}


- (void)positionScroller
{
	CGRect screenFrame = [[UIScreen mainScreen] bounds];
	CGRect scrollerRect;
	
	if( self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
	{//portrait
		scrollerRect = CGRectMake( 0, 0, screenFrame.size.width, screenFrame.size.height );
	}
	else
	{//landscape
		scrollerRect = CGRectMake( 0, 0, screenFrame.size.height, screenFrame.size.width );
	}
    NSLog(@"%f,%f",_scroller.frame.size.width,screenFrame.size.width);
        tag = YES;
    
	_scroller.frame = scrollerRect;
}


- (void)positionToolbar
{
	_toolbar.frame = CGRectMake( 0, _scroller.frame.size.height-kToolbarHeight, _scroller.frame.size.width, kToolbarHeight );
}




- (void)enterFullscreen
{
    FGalleryPhotoView * photoView = [_photoViews objectAtIndex:_currentIndex];
    if (photoView.imageView.image == nil) {
        return;
    }
	_isFullscreen = YES;
	
	[self disableApp];
	
	UIApplication* application = [UIApplication sharedApplication];
	if ([application respondsToSelector: @selector(setStatusBarHidden:withAnimation:)]) {
		[[UIApplication sharedApplication] setStatusBarHidden: YES withAnimation: UIStatusBarAnimationFade]; // 3.2+
	} else {
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		[[UIApplication sharedApplication] setStatusBarHidden: YES animated:YES]; // 2.0 - 3.2
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
	}
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[UIView beginAnimations:@"galleryOut" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(enableApp)];
	_toolbar.alpha = 0.0;
	[UIView commitAnimations];
    
}



- (void)exitFullscreen
{
	_isFullscreen = NO;
    
	[self disableApp];
    
	UIApplication* application = [UIApplication sharedApplication];
	if ([application respondsToSelector: @selector(setStatusBarHidden:withAnimation:)]) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade]; // 3.2+
	} else {
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
		[[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO]; // 2.0 - 3.2
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
	}
    
	[self.navigationController setNavigationBarHidden:NO animated:YES];
    
	[UIView beginAnimations:@"galleryIn" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(enableApp)];
	_toolbar.alpha = 1.0;
	[UIView commitAnimations];
}



- (void)enableApp
{
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
}


- (void)disableApp
{
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}


- (void)didTapPhotoView:(FGalleryPhotoView*)photoView
{
	// don't change when scrolling
	if( _isScrolling) return;
	
	// toggle fullscreen.
	if( _isFullscreen == NO ) {
		
		[self enterFullscreen];
	}
	else {
		
		[self exitFullscreen];
	}
    
}


- (void)updateScrollSize
{
	float contentWidth = _scroller.frame.size.width * [realUrlarr count];
	[_scroller setContentSize:CGSizeMake(contentWidth, _scroller.frame.size.height)];
}


- (void)updateTitle
{
	[self setTitle:[NSString stringWithFormat:@"第%i张 (共%i张)", _currentIndex+1, [realUrlarr count]]];
}


- (void)updateButtons
{
	_prevButton.enabled = ( _currentIndex <= 0 ) ? NO : YES;
	_nextButton.enabled = ( _currentIndex >= [realUrlarr count]-1 ) ? NO : YES;
}


- (void)layoutButtons
{
	NSUInteger buttonWidth = roundf( _toolbar.frame.size.width / [_barItems count] - _prevNextButtonSize * .5);
	
	// loop through all the button items and give them the same width
	NSUInteger i, count = [_barItems count];
	for (i = 0; i < count; i++) {
		UIBarButtonItem *btn = [_barItems objectAtIndex:i];
		btn.width = buttonWidth;
	}
	[_toolbar setNeedsLayout];
}


- (void)moveScrollerToCurrentIndexWithAnimation:(BOOL)animation
{
	int xp = _scroller.frame.size.width * _currentIndex;
	[_scroller scrollRectToVisible:CGRectMake(xp, 0, _scroller.frame.size.width, _scroller.frame.size.height) animated:animation];
	_isScrolling = NO;
}


// creates all the image views for this gallery
- (void)buildViews
{
	NSUInteger i, count = [realUrlarr count];
	for (i = 0; i < count; i++) {
		FGalleryPhotoView *photoView = [[FGalleryPhotoView alloc] initWithFrame:CGRectZero];
		photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		photoView.autoresizesSubviews = YES;
        photoView.photoDelegate = self;
        //photoView.imageView.image = [imageArr objectAtIndex:i];
		[_scroller addSubview:photoView];
		[_photoViews addObject:photoView];
	}
}

#pragma mark - UIScrollView Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    offset_x = scrollView.contentOffset.x;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
	CGFloat pageWidth = scrollView.frame.size.width;
    
    if (tag) {
        [scrollView setContentOffset:CGPointMake(pageWidth *_currentIndex, 0)];
        tag = NO;
    }
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = round(fractionalPage);
	if (page != _currentIndex) {
		_currentIndex = page;
        FGalleryPhotoView * photoView = [_photoViews objectAtIndex:_currentIndex];
        
        NSString *fullPhotoPath = [realUrlarr objectAtIndex:_currentIndex];
        photoView.imageView.image = [UIImage imageWithContentsOfFile:fullPhotoPath];
        [self updateTitle];
        [self updateButtons];
	}else{
        FGalleryPhotoView * photoView = [_photoViews objectAtIndex:_currentIndex];
        
        NSString *fullPhotoPath = [realUrlarr objectAtIndex:_currentIndex];
        photoView.imageView.image = [UIImage imageWithContentsOfFile:fullPhotoPath];
        [self updateTitle];
        [self updateButtons];
    }
}


#pragma mark - Memory Management Methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	
	NSLog(@"[FGalleryViewController] didReceiveMemoryWarning! clearing out cached images...");
	// unload fullsize and thumbnail images for all our images except at the current index.
	NSUInteger i, count = [realUrlarr count];
	for (i = 0; i < count; i++)
	{
		if( i != _currentIndex )
		{
            // unload main image thumb
			FGalleryPhotoView *photoView = [_photoViews objectAtIndex:i];
			photoView.imageView.image = nil;
		}
	}
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait ) {
        
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
    }

    

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
	return ( interfaceOrientation != UIDeviceOrientationPortraitUpsideDown );
}

@end
