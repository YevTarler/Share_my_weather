
#import "WeatherPhotoUpload.h"
#import "WeatherPhotoUploadStore.h"

@protocol NewMapViewController;
@interface NewMapViewController : UITableViewController 


@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *description;
@property (nonatomic,strong) CLLocation *location;
@property (nonatomic, strong) UIImage *photo;

@property (nonatomic,strong) WeatherPhotoUpload *WeatherPhotoUpload;
@end
