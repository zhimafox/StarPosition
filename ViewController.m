//
//  ViewController.m
//  CalcularStarDirection
//
//  Created by zhimafox on 2024/3/21.
//

#import "ViewController.h"

#import <UIKit/UIKit.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.m42Azimuth = 217.6;
    self.m42Elevation = 11.12;
    // 初始化陀螺仪管理器
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.1; // 设置更新间隔
    
    // 开始获取陀螺仪数据
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        if (!error) {
            // 获取当前手机的方向
            double yaw = motion.attitude.yaw; // 偏航角（方位角）
            double pitch = motion.attitude.pitch; // 俯仰角
            double roll = motion.attitude.roll; // 横滚角
            [self updateViewWithYaw:yaw pitch:pitch roll:roll];
        } else {
            NSLog(@"Error getting device motion data: %@", error.localizedDescription);
        }
    }];
}

- (void)updateViewWithYaw:(double)yaw pitch:(double)pitch roll:(double)roll {
    CGPoint postionOfStar = [self calculateStarIconPositionWithYaw:yaw pitch:pitch roll:roll distance:200];
    CGFloat angle = [self calculateStarRelativeToCenter:postionOfStar];
    self.starImgView.center = postionOfStar;
    self.arrowImgView.transform = CGAffineTransformMakeRotation(angle * M_PI / 180.0);
    
    //star到圆心的距离
    CGFloat distanceToCenter = sqrt(pow(self.starImgView.center.x - CGRectGetMidX(self.stageView.bounds), 2) + pow(self.starImgView.center.y - CGRectGetMidY(self.stageView.bounds), 2));
    
    self.degTxt.text = [NSString stringWithFormat:@"角度:%d° 距离:%0.2f", (int)angle, distanceToCenter];
}

- (CGPoint)calculateStarIconPositionWithYaw:(double)yaw pitch:(double)pitch roll:(double)roll distance:(double)distance {
    // 假设您已经获取了 m42 的方位角与高度角，假设它们分别为 m42Azimuth 和 m42Elevation
    
    // 根据手机的姿态角度和 m42 的方位角、高度角，计算 m42 相对于屏幕中心的位置
    double relativeAngle = self.m42Azimuth - yaw * 180.0 / M_PI; // 以手机屏幕朝上为0度，逆时针为正方向
    
    // 根据相对角度和距离计算 m42 在屏幕上的坐标
    double xOffset = distance * cos(relativeAngle * M_PI / 180.0);
    double yOffset = distance * sin(relativeAngle * M_PI / 180.0);
    
    // 根据屏幕方向调整坐标系
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGPointMake(self.stageView.bounds.size.width / 2.0 + xOffset, self.stageView.bounds.size.height / 2.0 - yOffset);
        case UIInterfaceOrientationLandscapeLeft:
            return CGPointMake(self.stageView.bounds.size.width / 2.0 + yOffset, self.stageView.bounds.size.height / 2.0 + xOffset);
        case UIInterfaceOrientationLandscapeRight:
            return CGPointMake(self.stageView.bounds.size.width / 2.0 - yOffset, self.stageView.bounds.size.height / 2.0 - xOffset);
        default:
            return CGPointMake(self.stageView.bounds.size.width / 2.0 + xOffset, self.stageView.bounds.size.height / 2.0 - yOffset);
    }
}

- (CGFloat)calculateStarRelativeToCenter:(CGPoint)targetPoint {
    CGPoint center = CGPointMake(CGRectGetMidX(self.stageView.bounds), CGRectGetMidY(self.stageView.bounds));
    
    CGFloat deltaX = targetPoint.x - center.x;
    CGFloat deltaY = targetPoint.y - center.y;
    
    // 计算角度，将角度从弧度转换为度数，并确保角度在 0 到 360 之间
    CGFloat angle = atan2(deltaY, deltaX) * (180 / M_PI);
    angle = (angle < 0) ? (360 + angle) : angle;
    
    return angle;
}
@end
