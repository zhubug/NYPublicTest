//
//  TXCustomModel.h
//  ATAuthSDK
//
//  Created by yangli on 2019/4/4.
//  Copyright © 2019 alicom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TXCustomModel : NSObject

/**
 * 说明，可设置的Y轴距离
 * 全屏模式：默认是以375x667pt为基准，其他屏幕尺寸可以根据(ratio = 屏幕高度/667)比率来适配，比如 Y*ratio
 **/

// 导航栏
@property (nonatomic, strong) UIColor *navColor; // 导航栏主题色
@property (nonatomic, copy) NSAttributedString *navTitle; // 导航栏标题，内容、字体、大小、颜色
@property (nonatomic, strong) UIImage *navBackImage; // 导航栏返回图片
/** 是否隐藏授权页导航栏返回按钮，默认不隐藏 */
@property (nonatomic, assign) BOOL hideNavBackItem;
@property (nonatomic, strong) UIBarButtonItem *navMoreControl; // 导航栏右侧自定义控件，UIBarButtonItem

// logo图片
@property (nonatomic, strong) UIImage *logoImage; // logo图片
@property (nonatomic, assign) CGFloat logoWidth; // logo宽
@property (nonatomic, assign) CGFloat logoHeight; // logo高
@property (nonatomic, assign) BOOL logoIsHidden; // logo是否隐藏
@property (nonatomic, assign) CGFloat logoTopOffetY; // logo相对导航栏底部的Y轴距离

// slogan
@property (nonatomic, copy) NSAttributedString *sloganText; // slogan文案，内容、字体、大小、颜色
@property (nonatomic, assign) BOOL sloganIsHidden; // slogan是否隐藏
@property (nonatomic, assign) CGFloat sloganTopOffetY; // slogan相对导航栏底部的Y轴距离

// 号码
@property (nonatomic, strong) UIColor *numberColor;
@property (nonatomic, strong) UIFont *numberFont;
@property (nonatomic, assign) CGFloat numberTopOffetY; // number相对导航栏底部的Y轴距离
@property (nonatomic, assign) CGFloat numberOffetX; // number相对屏幕中线的X轴偏移距离，大于0则右移，小于0则左移

// 登录
@property (nonatomic, strong) NSAttributedString *loginBtnText;
@property (nonatomic,strong) NSArray *loginBtnBgImgs; //loginBtn背景图片组，高度默认50.0pt，@[激活状态的图片,失效状态的图片,高亮状态的图片]
@property (nonatomic, assign) CGFloat loginBtnTopOffetY; // loginBtn相对导航栏底部的Y轴距离
@property (nonatomic, assign) CGFloat loginBtnHeight; // loginBtn高度，必须大于40.0pt
@property (nonatomic, assign) CGFloat loginBtnLRPadding; // 按钮左右屏幕边距，按钮的宽度必须大于屏幕的一半
/**
 *  是否自动隐藏点击登录按钮之后授权页的转圈的 loading, 默认为 Yes，在获取登录Token成功后自动隐藏
 *  如果设置为 NO，需要自己手动调用 [[TXCommonHandler sharedInstance] hideLoginLoading] 隐藏
 */
@property (nonatomic, assign) BOOL autoHideLoginLoading;

// 协议
@property (nonatomic, copy) NSArray *checkBoxImages; // checkBox图片组，[uncheckedImg,checkedImg]
@property (nonatomic, assign) BOOL checkBoxIsChecked; // checkBox是否勾选，默认YES
@property (nonatomic, assign) BOOL checkBoxIsHidden; // checkBox是否隐藏，默认NO
@property (nonatomic, assign) CGFloat checkBoxWH; // checkBox大小，高宽一样，必须大于12.0pt

@property (nonatomic, copy) NSArray *privacyOne; // 协议1，[协议名称,协议Url]
@property (nonatomic, copy) NSArray *privacyTwo; // 协议2，[协议名称,协议Url]
@property (nonatomic, copy) NSArray *privacyColors; // 协议内容颜色，[非点击文案颜色,点击文案颜色]
@property (nonatomic, assign) CGFloat privacyBottomOffetY; // 协议相对屏幕底部的Y轴距离！！！与其他有区别
@property (nonatomic, assign) NSTextAlignment privacyAlignment; // 协议文案支持居中、居左设置，默认居左
@property (nonatomic, copy) NSString *privacyPreText; // 协议整体文案，前缀部分文案
@property (nonatomic, copy) NSString *privacySufText; // 协议整体文案，后缀部分文案
@property (nonatomic, strong) UIFont *privacyFont; // 协议文案字体大小
@property (nonatomic, assign) CGFloat privacyLRPadding; // 协议整体（包括checkBox）的左右屏幕边距，当协议整体宽度小于（屏幕宽度-2*左右边距）且居中模式，则左右边距设置无效

// 切换到其他方式
@property (nonatomic, copy) NSAttributedString *changeBtnTitle; // changeBtn标题，内容、字体、大小、颜色
@property (nonatomic, assign) BOOL changeBtnIsHidden; // changeBtn是否隐藏
@property (nonatomic, assign) CGFloat changeBtnTopOffetY; // changeBtn相对导航栏底部的Y轴距离

// 其他控件自定义block
@property (nonatomic,copy) void(^customViewBlock)(UIView *superCustomView);

@end

NS_ASSUME_NONNULL_END
