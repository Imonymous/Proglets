//
//  TableViewController.m
//  Proglets
//
//  Created by MusicUser on 3/16/14.
//  Copyright (c) 2014 GTCMT. All rights reserved.
//

#import "TableViewController.h"
#import "AppDelegate.h"

@interface TableViewController ()

@end

@implementation TableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Return the number of rows in the section. This is the number of posts we have.
    return [appDelegate totalPosts];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    ProgletView *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil ) {
        cell = [[[ProgletView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
    }
    
    // Configure the cell...
    
    switch ( indexPath.section ) {
        case 0: {

            [cell loadFiles:(indexPath.row + 1)];
            
            break;
        }
    }
    
    return cell;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.hidesBackButton = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = NO;
}

- (IBAction)refresh:(id)sender
{
    [self.tableView reloadData];
}

- (IBAction)clearAll:(id)sender
{
    NSFileManager *filemgr;
    NSArray *filelist;
    int count;
    
    NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[documentsFolders objectAtIndex:0] stringByAppendingPathComponent:@""];
    
    filemgr =[NSFileManager defaultManager];
    filelist = [filemgr contentsOfDirectoryAtPath:path error:NULL];
    count = [filelist count];
    
    // Whenever files need to be cleared
    NSString *pathToFile;
    NSError *error;
    int i;

    for (i = 0; i < count; i++)
    {
        NSLog(@"%@", filelist[i]);
        pathToFile = [[documentsFolders objectAtIndex:0] stringByAppendingPathComponent:filelist[i]];
        [[NSFileManager defaultManager] removeItemAtPath: pathToFile error: &error];
        pathToFile = nil;
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate setTotalPosts:0];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath;
{
    return 300;
}

- (IBAction)addNewPost:(id)sender
{
    // Create a New Folder for New Post
    
    NSFileManager *filemgr;
    NSArray *dirPaths;
    NSArray *filelist;
    NSString *docsDir;
    NSString *newDir;
    
    filemgr =[NSFileManager defaultManager];
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    
    docsDir = dirPaths[0];
    
    filelist = [filemgr contentsOfDirectoryAtPath:docsDir error:NULL];
    int posts = [filelist count];
    
    NSString *folder = [NSString stringWithFormat:@"%d", posts+1];
    
    newDir = [docsDir stringByAppendingPathComponent:folder];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([filemgr createDirectoryAtPath:newDir withIntermediateDirectories:YES
                            attributes:nil error: NULL] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Dang !"
                                                        message: @"Couldn't create folder !"
                                                       delegate: self
                                              cancelButtonTitle: @"OK"
                                              otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else{
        
        [appDelegate setTotalPosts:posts+1];
    }
    
    [appDelegate setCurrentPostOnEdit:posts+1];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setCurrentPostOnEdit:(indexPath.row + 1)];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITa bleViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
