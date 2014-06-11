#import "PeopleViewController.h"
#import "CaptureImagesViewController.h"
#import <notify.h>
#import "BOZPongRefreshControl.h"

@implementation PeopleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.faceRecognizer = [[CustomFaceRecognizer alloc] init];
    
    NSDictionary *prefs = [NSDictionary
                           dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.efrederickson.appellancysettings.plist"];
    
    if ([prefs objectForKey:@"showDenyEntry"] != nil)
        self.showDenyEntry = [[prefs objectForKey:@"showDenyEntry"] boolValue];
    else
        self.showDenyEntry = NO;
}

- (void)viewDidLayoutSubviews
{
    self.pongRefreshControl = [BOZPongRefreshControl attachToTableView:self.tableView
                                                     withRefreshTarget:self
                                                      andRefreshAction:@selector(refreshTriggered)];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.pongRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.pongRefreshControl scrollViewDidEndDragging];
}

- (void)refreshTriggered
{
    [self.pongRefreshControl performSelector:@selector(finishedLoading) withObject:nil afterDelay:4];
    //[self.pongRefreshControl finishedLoading];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.people = [self fixPeople:[self.faceRecognizer getAllPeople]];
    [self.tableView reloadData];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                            target:self
                                                            action:@selector(barItemTap)];
    [self.navigationItem setRightBarButtonItem:item animated:YES];
    
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                          target:self
                                                                          action:@selector(resetDatabase)];
    [self.navigationItem setLeftBarButtonItem:item2 animated:YES];
}

-(void) resetDatabase
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Appellancy" message:NSLocalizedString(@"RESET_DB_PROMPT", @"") delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alert addButtonWithTitle:@"OK"];
    alert.tag = 2;
    [alert show];
}

-(NSMutableArray*) fixPeople:(NSMutableArray*)input
{
    if (self.showDenyEntry)
        return input;
    
    for (NSDictionary *item in input)
    {
        if ([[item objectForKey:@"id"] intValue] == 1)//&& [[item objectForKey:@"name"] isEqualToString:@"Deny"])
        {
            [input removeObject:item];
            return input;
        }
    }
    return input;
}

-(void) retrainRecognizer
{
    UIAlertView *alert;
    
    alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TRAINING_RECOGNIZER", @"") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alert show];
    
    [self.faceRecognizer trainModel];
    
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)barItemTap
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Appellancy" message:[NSString stringWithFormat:@"%@: ", NSLocalizedString(@"PERSON_NAME", @"")] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    [alert addButtonWithTitle:@"OK"];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 1;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // buttonIndex == 0 :: cancel
    if (alertView.tag == 1)
    {
        if (buttonIndex == 1) {
        
            UITextField *textfield = [alertView textFieldAtIndex:0];
            NSString *name = textfield.text;
            /*int pid = */
            [self.faceRecognizer newPersonWithName:name];
        
            self.faceRecognizer = nil;
            self.faceRecognizer = [[CustomFaceRecognizer alloc] init];
            self.people = [self fixPeople:[self.faceRecognizer getAllPeople]];
            [self.tableView reloadData];
            // Reload SpringBoard part
            notify_post("com.efrederickson.appellancy/reloadRecognizer");
        }
    }
    else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            
            system("rm /var/mobile/Library/Appellancy/recognition-data.sqlite");
                
            // Reload SpringBoard part
            notify_post("com.efrederickson.appellancy/reloadRecognizer");
                
            exit(0);
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.people count];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSInteger row = [indexPath row];
        
        int person = [[[self.people objectAtIndex:row] objectForKey:@"id"] intValue];
        
        if (person == 1) // "Deny" entry
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Appellancy" message:NSLocalizedString(@"CANNOT_DELETE_DENY", @"") delegate:nil cancelButtonTitle:@"OK, I understand." otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        
        [self.faceRecognizer forgetAllFacesForPersonID:person];
        [self.faceRecognizer removePerson:person];
        
        // Reload SpringBoard part
        notify_post("com.efrederickson.appellancy/reloadRecognizer");
        
        self.faceRecognizer = nil;
        self.faceRecognizer = [[CustomFaceRecognizer alloc] init];
        self.people = [self fixPeople:[self.faceRecognizer getAllPeople]];
        [self.tableView reloadData];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    static NSString *CellIdentifier = @"PersonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *person = [self.people objectAtIndex:row];
    cell.textLabel.text = [person objectForKey:@"name"];
    
    int count = [self.faceRecognizer imageCountForPerson:[[person objectForKey:@"id"] intValue]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d %@)", cell.textLabel.text, count, NSLocalizedString(@"SAVED_IMAGES", @"")];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    self.selectedPerson = [self.people objectAtIndex:row];
    
    [self performSegueWithIdentifier:@"CaptureImages" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CaptureImagesViewController *destination = segue.destinationViewController;
    
    if (self.selectedPerson) {
        destination.personID = [self.selectedPerson objectForKey:@"id"];
        destination.personName = [self.selectedPerson objectForKey:@"name"];
    }
}

@end
