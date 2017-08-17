//
//  ViewController.m
//  TYBarrageManagerDemo
//
//  Created by tany on 16/11/29.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "ViewController.h"
#import "BarrageView.h"
#import "BarrageLabelCell.h"
#import "BarrageData.h"

@interface ViewController ()<BarrageViewDataSource, BarrageViewDelegate>

@property (nonatomic, weak) BarrageView *barrageView;

@property (nonatomic, strong) NSMutableArray *datas;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSArray *texts;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _texts = @[@"  hello1  ",@"  hellohello2  ",@"  hellohellohellohello3  ",@"  hellohellohellohellohellohello4  ",@"  hellohellohellohellohellohellohellohello5  "];
    
    [self addBarrageView];
    
    [self loadData];
}

- (void)addBarrageView
{
    BarrageView *barrageView = [[BarrageView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), 250)];
    barrageView.timeInterval = 0.5;
    barrageView.backgroundColor = [UIColor colorWithRed:50/255. green:180/255. blue:255/255. alpha:1];
    barrageView.dataSource = self;
    barrageView.delegate = self;
    [self.view addSubview:barrageView];
    _barrageView = barrageView;
}

- (void)startTime
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(sendBarrage) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)loadData
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < arc4random_uniform(16); ++i) {
        BarrageData *data = [[BarrageData alloc]init];
        data.priority = arc4random_uniform(2);
        data.text = _texts[arc4random_uniform(_texts.count)];
        [array addObject:data];
    }
    _datas = [array copy];
}
- (IBAction)startBarrage:(id)sender {
    if (_timer == nil) {
        [_barrageView prepareBarrage];
    }
    [_barrageView sendBarrageDatas:_datas];
    [self startTime];
}
- (IBAction)sendBarrage:(id)sender {
    [self loadData];
    [_barrageView sendBarrageDatas:_datas];
}
- (IBAction)pauseBarrage:(id)sender {
    [_barrageView pause];
}

- (IBAction)resumeBarrage:(id)sender {
     [_barrageView resume];
}

- (IBAction)stopBarrage:(id)sender {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    [_barrageView stop];
}

- (void)sendBarrage
{
    [self loadData];
    [_barrageView sendBarrageDatas:_datas];
}

#pragma mark - BarrageViewDataSource

- (BarragePriority)barrageView:(BarrageView *)barrageView priorityWithBarrageData:(BarrageData*)barrageData
{
    return barrageData.priority;
}

- (BarrageViewCell *)barrageView:(BarrageView *)barrageView cellForBarrageData:(BarrageData *)barrageData
{
    BarrageLabelCell *cell = [[BarrageLabelCell alloc]init];
    cell.textLabel.text = barrageData.text;
    if (barrageData.priority > 0) {
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.textColor = [UIColor redColor];
    }
    cell.renderSize = [self boundingSizeWithText:barrageData.text font:cell.textLabel.font constrainedToSize:CGSizeMake(1000, 30)];
    cell.renderSpeed = cell.renderSize.width < 60 ? 100 :100+(cell.renderSize.width/100-1)*30;
    return cell;
}

- (CGSize)boundingSizeWithText:(NSString *)text font:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGSize textSize = CGSizeZero;
    //iOS 7
    CGRect frame = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName:font } context:nil];
    textSize = CGSizeMake(frame.size.width, frame.size.height + 1);
    return textSize;
}

- (void)barrageView:(BarrageView *)barrageView didClickedBarrageCell:(BarrageViewCell *)BarrageCell {
    NSLog(@"BarrageViewCell %@",BarrageCell);
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    if (!parent) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
}


@end
