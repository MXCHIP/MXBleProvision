//
//  ViewController.m
//  MXOCDemo
//
//  Created by huafeng on 2024/4/3.
//

#import "ViewController.h"
#import "MXBleProvision/MXBleProvision-Swift.h"
@import CryptoSwift;

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource, MXBleProvisionDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *list;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    btn.frame = CGRectMake((self.view.frame.size.width-100)/2.0, 20, 100, 40);
    [btn setTitle:@"重新扫描" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(scanMeshDevices) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btn];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = headerView;
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scanMeshDevices];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

// 3.发现mesh设备
- (void)scanMeshDevices {
    NSLog(@"scanMeshDevices");
    [MXBleProvisionManager.sharedInstance startScanWithTimeout:0 callback:^(NSArray<NSDictionary<NSString *,id> *> * _Nonnull devices, BOOL isStop) {
        self.list = devices;
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDelegate UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];;
    }
    if (self.list.count > indexPath.row) {
        NSDictionary *info = [self.list objectAtIndex:indexPath.row];
        cell.textLabel.text = [info objectForKey:@"name"];
        cell.detailTextLabel.text = [info objectForKey:@"mac"];
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.list.count > indexPath.row) {
        //开始配网
        NSDictionary *info = [self.list objectAtIndex:indexPath.row];
        [MXBleProvisionManager.sharedInstance stopScan];
        NSString *pk = info[@"productKey"];
        NSString *dn = info[@"deviceName"];
        [MXBleProvisionManager startProvisionWithType:0 productKey:pk deviceName:dn mac:nil secret:nil httpURL:nil mqttURL:nil delegate:self];
    }
}

#pragma  mark -----------------------

- (void)inputWifiInfoWithHandler:(void (^ _Nonnull)(NSString * _Nonnull, NSString * _Nonnull))handler
{
    handler(@"", @"");
}
- (void)mxBleProvisionProcessWithDeviceIdentifier:(NSString * _Nonnull)deviceIdentifier step:(NSInteger)step
{
    
}
- (void)mxBleProvisionFinishWithDeviceIdentifier:(NSString * _Nonnull)deviceIdentifier error:(NSError * _Nullable)error device_name:(NSString * _Nullable)device_name
{
    [MXBleProvisionManager cleanProvisionCache];
    if (error != nil) {
        NSLog(@"失败原因：%@", error);
    }
}
- (void)requestRandomWithParams:(NSDictionary<NSString *, id> * _Nullable)params type:(NSInteger)type handler:(void (^ _Nonnull)(NSString * _Nullable))handler
{
    //返回16长度的字符串，自行生成或者通过云端API生成
    handler(@"ABCDEFGHIJKLMNAA");
}
- (void)requestBleKeyWithParams:(NSDictionary<NSString *, id> * _Nullable)params type:(NSInteger)type handler:(void (^ _Nonnull)(NSString * _Nullable))handler
{
    //返回blekey，调用API云端生成
    handler(@"AAAAAAAAAAAAAAAA");
}
- (void)requestConnectStatusWithParams:(NSDictionary<NSString *, id> * _Nullable)params type:(NSInteger)type handler:(void (^ _Nonnull)(BOOL))handler
{
    //轮询设备连接状态，调用API返回结果
    handler(YES);
}

@end
