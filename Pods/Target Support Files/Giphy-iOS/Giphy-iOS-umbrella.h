#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AXCGiphy.h"
#import "AXCGiphyImage.h"
#import "AXCGiphyImageDownsampled.h"
#import "AXCGiphyImageFixed.h"
#import "AXCGiphyImageOriginal.h"

FOUNDATION_EXPORT double Giphy_iOSVersionNumber;
FOUNDATION_EXPORT const unsigned char Giphy_iOSVersionString[];

