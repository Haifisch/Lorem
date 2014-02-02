//
//  ALLRDropletMoreViewController.m
//  Lorem
//
//  Created by Aehmlo Lxaitn on 1/28/14.
//  Copyright (c) 2014 Aehmlo Lxaitn. All rights reserved.
//

#import "ALLRDropletMoreViewController.h"

@interface ALLRDropletMoreViewController ()

@end

@implementation ALLRDropletMoreViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (void)dropletManagerDidUpdate{
    if ([[ALLRDropletManager sharedManager] dropletWithID:self.droplet.id]){
        self.droplet = [[ALLRDropletManager sharedManager] dropletWithID:self.droplet.id];
        [self.tableViewController.tableView reloadData];
    } else [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.droplet.locked) return;
    switch(indexPath.row){
        case 1:{
            UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Resetting your root password will reboot your droplet, and a new root password will be emailed to you. This cannot be undone."
                                                            delegate:nil
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:@"Reset Root Password"
                                                   otherButtonTitles:nil];
            
            as.actionSheetStyle = UIActionSheetStyleAutomatic;
            as.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex){
                if(buttonIndex==0){
                        [[ALLRDropletManager sharedManager] resetRootPasswordForDroplet:self.droplet completion:^(BOOL success){
                            if(success) NSLog(@"Successfully shut down droplet.");
                            else NSLog(@"Error occured while shutting down droplet.");
                            [self.droplet reloadStateWithCompletion:^(BOOL success){
                                [[[UIAlertView alloc] initWithTitle:success?@"Password Reset Successful":@"Password Reset Failed" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                            }];
                        }];
                }
            };
            [as showInView:self.view];
            break;
        }case 0:{
            pv = [[UIPickerView alloc] initWithFrame:(CGRect){{0, self.view.bounds.size.height-200},{self.view.bounds.size.width, 200}}];
            pv.delegate = self;
            pv.dataSource = self;
            pv.showsSelectionIndicator = YES;
            [self.view addSubview:pv];
            toolbar = [[UIToolbar alloc] initWithFrame:(CGRect){{0, self.view.bounds.size.height-244},{self.view.bounds.size.width, 44}}];
            UIBarButtonItem *middleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped)];
            cancelButton.tintColor = [UIColor DOBlueColor];
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped)];
            doneButton.tintColor = [UIColor DOBlueColor];
            [toolbar setItems:@[cancelButton, middleSpace, doneButton]];
            [self.view addSubview:toolbar];
            self.tableViewController.tableView.userInteractionEnabled = NO;
            break;
        }
        default:
            break;
    }
}

- (void)cancelButtonTapped{
    [pv removeFromSuperview];
    [toolbar removeFromSuperview];
    self.tableViewController.tableView.userInteractionEnabled = YES;
    pv = nil;
}

- (void)doneButtonTapped{
    [pv removeFromSuperview];
    [toolbar removeFromSuperview];
    self.tableViewController.tableView.userInteractionEnabled = YES;
    pv = nil;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [[[ALLRMiscellaneousAPIInfoManager sharedManager].sizes[row][@"name"] stringByReplacingOccurrencesOfString:@"MB" withString:@" MB"] stringByReplacingOccurrencesOfString:@"GB" withString:@" GB"]; //This isn't at all unstable. Nope. No way. Impossible.
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [[ALLRMiscellaneousAPIInfoManager sharedManager].sizes count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return self.view.bounds.size.width;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ALLRDropletDetailTableViewCell"];
    if(!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ALLRDropletDetailTableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsZero;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Resize";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            cell.textLabel.text = @"Reset Root Password";
            cell.textLabel.textColor = [UIColor DORedColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        default:
            break;
    }
    return cell;
}

- (instancetype)initWithParent:(ALLRDropletDetailViewController *)parent{
    if ((self = [super init])){
        self.parent = parent;
        self.droplet = parent.droplet;
        self.title = @"More Options";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropletManagerDidUpdate) name:@"com.aehmlo.lorem/dropletManagerDidUpdate" object:nil];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.tableViewController.tableView.frame = self.view.bounds;
    self.tableViewController.tableView.dataSource = self;
    self.tableViewController.tableView.delegate = self;
    self.tableViewController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableViewController.tableView];
    [self.tableViewController.tableView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end