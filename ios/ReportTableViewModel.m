//
//  ReportTableViewModel.m
//
//
//  Created by ms on 2019/11/22.
//

#import "ReportTableViewModel.h"
#import "ReportTableModel.h"
#import "ReportTableView.h"
#import <React/RCTConvert.h>
#import "ReportTableHeaderView.h"

@interface ReportTableViewModel();

@property (nonatomic, strong) ReportTableView * reportTableView;
@property (nonatomic, strong) NSMutableArray<NSArray<ItemModel *> *> *dataSource;
@property (nonatomic, strong) ReportTableModel *reportTabelModel;
@property (nonatomic, strong) ReportTableHeaderScrollView *headerScrollView;
@property (nonatomic, assign) NSInteger propertyCount;
@property (nonatomic, weak)   RCTBridge *bridge;

@end

@implementation ReportTableViewModel

- (NSMutableArray<NSArray<ItemModel *> *> *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (ReportTableView *)reportTableView {
    if (!_reportTableView) {
        _reportTableView = [[ReportTableView alloc] init];
        [self addSubview:_reportTableView];
    }
    return _reportTableView;
}

- (ReportTableHeaderScrollView *)headerScrollView{
    if (!_headerScrollView) {
        ReportTableHeaderView *headerView = [[ReportTableHeaderView alloc] initWithBridge:self.bridge];
        _headerScrollView = [[ReportTableHeaderScrollView alloc] init];
        _headerScrollView.bounces = true;
        [_headerScrollView addSubview: headerView];
    }
    return _headerScrollView;
}


- (id)initWithBridge:(RCTBridge *)bridge {
    self = [super init];
    if (self) {
        self.bridge = bridge;
        self.reportTabelModel = [[ReportTableModel alloc] init];
        self.propertyCount = 0;
    }
    return self;
}

- (NSMutableArray<ForzenRange *> *)generateMergeRange:(NSArray<NSArray<ItemModel *> *>*)dataSource {
    NSMutableArray<ForzenRange *> *frozenArray = [NSMutableArray array];
    for (int i = 0; i < dataSource.count; i++) { // i columnIndex
        NSArray *rowArr = dataSource[i];
        for (int j = 0; j < rowArr.count; j ++) { // j = rowIndex
             NSInteger sameRowLength = [self jungleSameLength:[self rowWithIndex:j columnIndex:i]];
             NSInteger samecolumnLength = [self jungleSameLength:[self columnWithIndex:j columnIndex:i]];
             if (sameRowLength > 1 || samecolumnLength > 1) {
                ForzenRange *forzenRange = [[ForzenRange alloc] init];
                forzenRange.startX = i;
                forzenRange.startY = j;
                forzenRange.endX = i + samecolumnLength - 1;
                forzenRange.endY = j + sameRowLength - 1;
                [frozenArray addObject:forzenRange];
             }
        }
    }
    return frozenArray;
}

- (NSInteger)jungleSameLength:(NSArray<ItemModel *> *)arr {
    if (arr.count <= 1) {
        return arr.count;
    }
    ItemModel *model = arr[0];
    if (model.used && model.used == YES) {
        return 1;
    }
    NSInteger sameLenth = [self sameLength:arr andKeyIndex:model.keyIndex];
    return sameLenth;
}

- (NSInteger)sameLength:(NSArray<ItemModel *> *)arr andKeyIndex:(NSInteger)keyIndex{
    NSInteger sameLenth = 0;
    for (int i = 0; i< arr.count; i++) {
        ItemModel *model = arr[i];
        if (model.keyIndex == keyIndex) {
            sameLenth += 1;
            if (sameLenth > 1) {
                model.used = true;
            }
        } else {
            break;
        }
    }
    return sameLenth;
}

- (NSMutableArray *)rowWithIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex {
    NSMutableArray<ItemModel *> *result = [NSMutableArray array];
    NSArray *arr = self.dataSource[columnIndex];
    for (NSInteger i = rowIndex; i <arr.count; i++) {
        ItemModel *model = arr[i];
        [result addObject:model];
    }
    return result;
}

- (NSMutableArray *)columnWithIndex:(NSInteger)rowIndex columnIndex:(NSInteger)columnIndex {
    NSMutableArray<ItemModel *> *result = [NSMutableArray array];
    for (NSInteger i = columnIndex; i <self.dataSource.count; i++) {
        NSArray *arr = self.dataSource[i];
        ItemModel *model = arr[rowIndex];
        [result addObject:model];
    }
    return result;
}

- (CGFloat)getTextWidth:(NSString *)text withTextSize:(CGFloat)fontSize {
    CGFloat textW = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size.width;
    return textW;
}

- (void)setData:(NSArray *)data {
    NSMutableArray *dataSource = [NSMutableArray arrayWithArray:data];
    self.reportTabelModel.dataSource = dataSource;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setMinWidth:(float)minWidth {
    self.reportTabelModel.minWidth = minWidth;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setMaxWidth:(float)maxWidth {
    self.reportTabelModel.maxWidth = maxWidth;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setMinHeight:(float)minHeight {
    self.reportTabelModel.minHeight = minHeight;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setFrozenColumns:(NSInteger)frozenColumns {
    self.reportTabelModel.frozenColumns = frozenColumns;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setFrozenRows:(NSInteger)frozenRows {
    self.reportTabelModel.frozenRows = frozenRows;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setOnClickEvent:(RCTDirectEventBlock)onClickEvent {
    self.reportTabelModel.onClickEvent = onClickEvent;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setSize:(CGSize)size {
    self.reportTableView.frame = CGRectMake(0, 0, size.width, size.height);
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setHeaderViewSize:(CGSize)headerViewSize {
    if (headerViewSize.width != 0) {
        self.headerScrollView.contentSize = headerViewSize;
    }
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)setOnScrollEnd:(RCTDirectEventBlock)onScrollEnd {
    self.reportTabelModel.onScrollEnd = onScrollEnd;
    self.propertyCount += 1;
    [self reloadCheck];
}

- (void)reloadCheck {
    if (self.propertyCount >= 10) {
        [self integratedDataSource];
    }
}

- (void)integratedDataSource {
    NSMutableArray *dataSource = [NSMutableArray arrayWithArray: self.reportTabelModel.dataSource];
    NSMutableArray *cloumsHight = [NSMutableArray array];
    NSMutableArray *rowsWidth = [NSMutableArray array];
    CGFloat minWidth = self.reportTabelModel.minWidth; //margin
    CGFloat maxWidth = self.reportTabelModel.maxWidth; //margin
    CGFloat minHeight = self.reportTabelModel.minHeight;
   
    for (int i = 0; i < dataSource.count; i++) {
       NSArray *rowArr = dataSource[i];
       NSMutableArray *modelArr = [NSMutableArray array];
       CGFloat rowWith = minWidth;
       CGFloat columnHeigt = minHeight;
       for (int j = 0; j < rowArr.count; j ++) {
           if (i == 0) {
               [rowsWidth addObject:[NSNumber numberWithFloat:minWidth]];
           }
           NSDictionary *dir = rowArr[j];
           ItemModel *model = [[ItemModel alloc] init];
           model.keyIndex = [RCTConvert NSInteger:[dir objectForKey:@"keyIndex"]];
           model.title = [RCTConvert NSString:[dir objectForKey:@"title"]];
           model.backgroundColor = [RCTConvert UIColor:[dir objectForKey:@"backgroundColor"]];
           model.fontSize = [RCTConvert CGFloat:[dir objectForKey:@"fontSize"]];
           model.textColor = [RCTConvert UIColor:[dir objectForKey:@"textColor"]];
           
           CGFloat textW = [self getTextWidth: model.title withTextSize: model.fontSize];
           if (textW > rowWith - 2 * 6) { //margin
               if (textW < maxWidth - 2 * 6) {
                   rowWith = textW;
               } else {
                   rowWith = maxWidth;
                   columnHeigt = (ceilf(textW / (maxWidth - 2 * 6)) - 1) * (model.fontSize + 2) + minHeight;
               }
            } else {
               rowWith = minWidth;
            }
            if ([rowsWidth[j] floatValue] < rowWith) {
               rowsWidth[j] = [NSNumber numberWithFloat:rowWith];
            }
    
            [modelArr addObject:model];
        }
        [cloumsHight addObject:[NSNumber numberWithFloat:columnHeigt]];
        [self.dataSource addObject:modelArr];
    }
    NSMutableArray<ForzenRange *> *frozenArray = [self generateMergeRange:self.dataSource];
    self.reportTabelModel.frozenArray = frozenArray;
    self.reportTabelModel.dataSource = self.dataSource;
    self.reportTabelModel.rowsWidth = rowsWidth;
    self.reportTabelModel.cloumsHight = cloumsHight;
    
    
    CGFloat tableHeigt = 0;
    for (int i = 0; i < cloumsHight.count; i++) {
        tableHeigt += [cloumsHight[i] floatValue];
    }
    if (_headerScrollView != nil) {
        CGSize headerSize = self.headerScrollView.contentSize;
        tableHeigt += headerSize.height;
        
        CGRect tableRect = self.reportTableView.frame;
        tableRect.size.height = MIN(tableRect.size.height, tableHeigt + 5);
        self.reportTableView.frame = tableRect;
    
        self.headerScrollView.frame = CGRectMake(0, 0, self.reportTableView.frame.size.width, headerSize.height);
        headerSize.height = 0;
        self.headerScrollView.contentSize = headerSize;
        self.reportTableView.headerScrollView = self.headerScrollView;
    }
    
    self.reportTableView.reportTableModel = self.reportTabelModel;
}

@end
