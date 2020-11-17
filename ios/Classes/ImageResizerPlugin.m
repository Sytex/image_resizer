#import "ImageResizerPlugin.h"
#import <image_resizer/image_resizer-Swift.h>

@implementation ImageResizerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftImageResizerPlugin registerWithRegistrar:registrar];
}
@end
