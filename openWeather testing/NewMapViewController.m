
#import "NewMapViewController.h"


@interface NewMapViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextView *describtionTextView;
@property (nonatomic, weak) IBOutlet UILabel *photoLabel;

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *awardTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (nonatomic, strong) IBOutlet UILabel *characterCountLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end

@implementation NewMapViewController

static NSString* placeHolder = @"Hey :) tell me your thoughts about this photo" ;


- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		self.name = @"";
	}
	return self;
}

- (IBAction)cancelPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillLayoutSubviews {
    self.thumbnailImageView.image = _photo;
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.thumbnailImageView.image = _photo;
    [self.tableView reloadData];
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	gestureRecognizer.cancelsTouchesInView = NO;
	[self.navigationController.view addGestureRecognizer:gestureRecognizer];

}
-(void)viewWillAppear:(BOOL)animated {
    self.thumbnailImageView.image = _photo;
    [self.tableView reloadData];
}
- (void)hideKeyboard
{
	// This trick dismissed the keyboard, no matter which text field or text
	// view is currently active.
	[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}


#pragma mark - Segues



- (IBAction)pickedAwardType:(UIStoryboardSegue *)segue
{
	// This handles the unwind segue from the Award Type picker screen.

//	AwardTypeViewController *controller = segue.sourceViewController;
//	self.awardType = controller.awardType;
 
}

#pragma mark - Table View
//
//- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	// This makes the "Add Photo" row taller when the user picked a photo.
//
//	if (indexPath.section == 1) {
//		return 88.0f;
//	} else if (indexPath.section == 2 && indexPath.row == 0) {
//		return self.photoImageView.hidden ? 44.0f : 280.0f;
//	} else {
//		return 44.0f;
//	}
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// If the row has a text view but the user tapped outside the actual text
	// view (it's a bit smaller than the row), we still show the keyboard.
	if (indexPath.section == 0) {
		[self.nameTextField becomeFirstResponder];
	} else if (indexPath.section == 1) {
		[self.nameTextField becomeFirstResponder];
	}
}



#pragma mark - UITextViewDelegate delegate methods

- (void)textViewDidChange:(UITextView *)textView
{
	NSInteger remainingCharacters = 80 - textView.text.length;
	BOOL postEnabled = (remainingCharacters >= 0);
	
	self.characterCountLabel.textColor = [UIColor colorWithRed:(postEnabled ? 0.0 : 255.0) green:0.0 blue:0.0 alpha:0.5];
	
	self.characterCountLabel.text = [NSString stringWithFormat:@"%li", (long)remainingCharacters];
	
	self.navigationItem.rightBarButtonItem.enabled = postEnabled;
}


#pragma mark - Photo Picker

- (void)choosePhotoFromLibrary
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePicker.delegate = self;
	imagePicker.allowsEditing = NO;
	imagePicker.view.tintColor = self.view.tintColor;
	[self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.photo = info[UIImagePickerControllerOriginalImage];

	[self showPhoto];
	[self.tableView reloadData];

	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPhoto
{
	if (self.photo != nil) {
		self.photoImageView.image = self.photo;
		self.photoImageView.hidden = NO;
		self.photoLabel.hidden = YES;
	}
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Send"]) {
        //self.location =
        self.description = self.describtionTextView.text;
        self.name = self.nameTextField.text;
        
        
        self.WeatherPhotoUpload = [[WeatherPhotoUpload alloc]initWithName:self.nameTextField.text Image:self.photo ImageDescription:self.describtionTextView.text];
        NSLog(@"about to pop!");
        //[self.navigationController popViewControllerAnimated:YES];
        //[segue perform];
    }
}

@end
