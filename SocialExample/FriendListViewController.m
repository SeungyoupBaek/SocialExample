//
//  FriendListViewController.m
//  SocialExample
//
//  Created by SDT-1 on 2014. 1. 21..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "FriendListViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define FACEBOOK_APPID @"243905615771288"

@interface FriendListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) NSArray *data;
@property (weak, nonatomic) ACAccount *facebookAccount;

@end

@implementation FriendListViewController

-(void)requestFriendList{
    NSString *urlStr = @"https://graph.facebook.com/me/friends";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *params = nil;
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:params];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error){
        if (nil != error) {
            NSLog(@"Error : %@", error);
            return;
        }
        
        
        __autoreleasing NSError *parseError;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&parseError];
        
        self.data = result[@"data"];
        // 메인 쓰레드에서 화면 업데이트
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.table reloadData];
        }];
    }];
}

-(void)showFriendList{
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ACFacebookAppIdKey : FACEBOOK_APPID,
                              ACFacebookPermissionsKey : @[@"friends_about_me"],
                              ACFacebookAudienceKey : ACFacebookAudienceEveryone};
    
    [store requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error){
        if (error) {
            NSLog(@"Error : %@", error);
        }
        if (granted) {
            NSLog(@"권한 승인 성공");
            NSArray *accountList = [store accountsWithAccountType:accountType];
            self.facebookAccount = [accountList lastObject];
            
            // 피드 정보를 요청한다.
            [self requestFriendList];
        }
        else{
            NSLog(@"권한 승인 실패");
        }
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.data count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FRIEND_CELL"];
    
    NSDictionary *one = self.data[indexPath.row];
    
    // feed는 사용자가 올린 글에 해당하는 message 와 like 등과 같은 이벤트 story로 나뉜다.
    NSString *contents = one[@"name"];
//    if (one[@"message"]) {
//        // 메세지인 경우에는 like의 개수
//        NSDictionary *likes = one[@"likes"];
//        NSArray *data = likes[@"data"];
//        //NSLog(@"message likes : %@ - %@", likes, count);
//        contents = [NSString stringWithFormat:@"%@ ...(%d)", one[@"message"], (int)[data count]];
//    }else{
//        contents = one[@"story"];
//        cell.indentationLevel = 2;
//    }
    
    cell.textLabel.text = contents;
    return cell;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self showFriendList];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
