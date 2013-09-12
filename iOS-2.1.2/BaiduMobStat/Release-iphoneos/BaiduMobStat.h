//
//  BaiduMobStat.h
//  BaiduMobStat
//
//  Created by jaygao on 11-11-1.
//  Copyright (c) 2011年 Baidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;

typedef enum _BaiduMobStatLogStrategy {
    BaiduMobStatLogStrategyAppLaunch = 0, //每次程序启动
    BaiduMobStatLogStrategyDay = 1, //每天的程序第一次进入前台
    BaiduMobStatLogStrategyCustom = 2, //根据开发者设定的时间间隔接口发送
} BaiduMobStatLogStrategy;


/**
 *  百度移动应用统计接口,更多信息请查看[百度移动统计](http://mtj.baidu.com)
 *  
 */

@interface BaiduMobStat : NSObject{
    BOOL exceptionLogEnabled_;
}

/**
 *  获取统计对象的实例
 */
+ (BaiduMobStat*) defaultStat;

/**
 *  设置应用的appkey (在[百度移动统计](http://mtj.baidu.com)获取)，在其他api调用以前必须先调用该api.
 */
-(void) startWithAppId:(NSString*) appId;

/**
 *  记录一次事件的点击，eventId请在网站上创建。未创建的evenId记录将无效。 [百度移动统计](http://mtj.baidu.com)
 */
-(void) logEvent:(NSString*) eventId eventLabel:(NSString*)eventLabel;

/**
 *  标识某个页面访问的开始，请参见Example程序，在合适的位置调用。
 */
-(void) pageviewStartWithName:(NSString*) name;
/**
 *  标识某个页面访问的结束，与pageviewStartWithName配对使用，请参见Example程序，在合适的位置调用。
 */
-(void) pageviewEndWithName:(NSString*) name;

/**
 *  v1.1 新增
 *  设置或者获取渠道Id。
 *  可以不设置, 此时系统会处理为AppStore渠道
 */
@property (nonatomic,retain) NSString* channelId;

/**
 *  是否启用异常日志收集
 */
@property (nonatomic) BOOL enableExceptionLog;

/**
 *  v2.0 新增
 *  是否只在wifi连接下才发送日志
 *  默认值为 NO, 不管什么网络都发送日志
 */
@property (nonatomic) BOOL logSendWifiOnly;

/**
 *  v2.0 新增
 *  设置日志发送策略, 默认采用BaiduMobStatLogStrategyAppLaunch：启动发送
 */
@property (nonatomic) BaiduMobStatLogStrategy logStrategy;

/**
 *  v2.0 新增
 *  设置日志发送时间间隔，当logStrategy设置为BaiduMobStatLogStrategyCustom时生效
 *  单位为小时，有效值为 1 <= logSendInterval <= 24
 *  默认值 为1
 */
@property (nonatomic) int logSendInterval;


@end
