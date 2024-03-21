//
//  ViewController.h
//  CalcularStarDirection
//
//  Created by zhimafox on 2024/3/21.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController : UIViewController

// 陀螺仪管理器
@property (nonatomic, strong) CMMotionManager *motionManager;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImgView;

@property (weak, nonatomic) IBOutlet UIView *stageView;
@property (weak, nonatomic) IBOutlet UIImageView *starImgView;
@property (weak, nonatomic) IBOutlet UILabel *degTxt;
@property (weak, nonatomic) IBOutlet UILabel *rotationDegTxt;


// 目标星体的方位角与高度角
@property (nonatomic, assign) double m42Azimuth;
@property (nonatomic, assign) double m42Elevation;

// 您的经纬度信息
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

@end

