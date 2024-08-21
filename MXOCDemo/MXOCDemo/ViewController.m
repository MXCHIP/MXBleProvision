//
//  ViewController.m
//  MXOCDemo
//
//  Created by huafeng on 2024/4/3.
//

#import "ViewController.h"
#import "MXBleProvision/MXBleProvision-Swift.h"
@import CryptoSwift;

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource, MXBleProvisionDelegate, MXBleDeviceLogDelegate>

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
    [MXBleProvisionManager.sharedInstance startScanWithTimeout:0 deviceType:0 callback:^(NSArray<NSDictionary<NSString *,id> *> * _Nonnull devices, BOOL isStop) {
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
        CBPeripheral *peripheral = info[@"peripheral"];
        
        [MXFogProvisionManager.shard provisionDeviceWithPeripheral:peripheral productKey:pk deviceName:dn timeout:30 delegate:self logDelegate:self];
    }
}

#pragma  mark -----------------------

- (void)inputWifiInfoWithHandler:(void (^)(NSString * _Nonnull, NSString * _Nonnull, NSDictionary<NSString *,id> * _Nullable))handler
{
    NSMutableDictionary *custom = [[NSMutableDictionary alloc] init];
    custom[@"htturl"] = @"app.api.fogcloud.io";
    custom[@"mqtturl"] = @"app.mqtt.fogcloud.io";
    handler(@"mxchip-guest", @"12345678", custom);
}

//配网结束
- (void)mxBleProvisionFinishWithProductKey:(NSString *)productKey
                          deviceIdentifier:(NSString *)deviceIdentifier
                                     error:(NSError *)error
                               device_name:(NSString *)device_name
{
    [MXFogProvisionManager.shard cleanProvisionCache];
    if (error != nil) {
        NSLog(@"失败原因：%@", error);
    } else {
        //配网成功
    }
}
//请求blekey
- (void)requestBleKeyWithParams:(NSDictionary<NSString *, id> * _Nullable)params type:(NSInteger)type handler:(void (^ _Nonnull)(NSString * _Nullable))handler
{
    //返回blekey，调用API云端生成
    handler(@"AAAAAAAAAAAAAAAA");
}
- (void)requestConnectStatusWithParams:(NSDictionary<NSString *, id> * _Nullable)params type:(NSInteger)type handler:(void (^ _Nonnull)(BOOL))handler
{
    //轮询设备连接状态，调用API返回结果
    handler(NO);
}


- (void)openDeviceLogFailWithPeripheral:(CBPeripheral *)peripheral {
    
}

- (void)openDeviceLogSuccessWithPeripheral:(CBPeripheral *)peripheral {
    
}

- (void)receiveDeviceLogWithPeripheral:(CBPeripheral *)peripheral log:(NSString *)log {
    NSLog(@"收到设备日志：%@", log);
}


@end
