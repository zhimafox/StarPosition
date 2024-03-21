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
            
            // 根据手机的姿态角度和 m42 的方位角、高度角，计算 m42 相对于屏幕中心的位置
            double relativeAngle = self.m42Azimuth - yaw * 180.0 / M_PI; // 以手机屏幕朝上为0度，逆时针为正方向
            // 计算箭头相对于手机屏幕中心点的角度
            double arrowAngle = [self calculateArrowAngleWithYaw:yaw pitch:pitch roll:roll];
            
            // 打印 starImgView 到屏幕中心的距离
               CGFloat distanceToCenter = sqrt(pow(self.starImgView.center.x - CGRectGetMidX(self.view.bounds), 2) + pow(self.starImgView.center.y - CGRectGetMidY(self.view.bounds), 2));
//               NSLog(@"starImgView 到屏幕中心的距离：%f", distanceToCenter);
            
            [self updatePointIconPositionWithYaw:yaw pitch:pitch roll:roll];
            CGFloat angle = [self angleRelativeToCenterForView:self.starImgView];
            // 在这里更新箭头图标的位置和方向
            [self updateArrowIconWithAngle:angle];
            
            self.degTxt.text = [NSString stringWithFormat:@"%d° 距离:%d", (int)angle, (int)distanceToCenter];
//            NSLog(@"starImgView 相对于屏幕中心的角度值：%f", angle);
        } else {
            NSLog(@"Error getting device motion data: %@", error.localizedDescription);
        }
    }];
    
}

// 计算箭头相对于手机屏幕中心点的角度
- (double)calculateArrowAngleWithYaw:(double)yaw pitch:(double)pitch roll:(double)roll {
    // 根据手机的姿态角度和目标星体的方位角、高度角，计算箭头应该指向的角度
    
    // 假设您已经获取了目标星体的方位角与高度角，假设它们分别为 self.m42Azimuth 和 self.m42Elevation
    // 计算手机屏幕朝上的方向与目标星体方向的夹角
    double arrowAngle = self.m42Azimuth - yaw * 180.0 / M_PI; // 以手机屏幕朝上为0度，逆时针为正方向
    
    // 考虑目标星体的高度角调整箭头角度
    arrowAngle += self.m42Elevation; // 可能需要根据您的需求进行适当调整
    
    return arrowAngle;
}

- (void)updateArrowIconWithAngle:(double)angle {
    // 获取当前设备的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    // 根据不同的方向调整箭头图标的位置和方向
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            // 正立方向，箭头图标位置和方向不变
            [self updateArrowIconWithAngle:angle position:CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0)];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            // 倒立方向，箭头图标方向反向
            [self updateArrowIconWithAngle:-angle position:CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0)];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            // 左横向，箭头图标位置和方向顺时针旋转90度
            [self updateArrowIconWithAngle:angle - 90.0 position:CGPointMake(self.view.bounds.size.height / 2.0, self.view.bounds.size.width / 2.0)];
            break;
        case UIInterfaceOrientationLandscapeRight:
            // 右横向，箭头图标位置和方向逆时针旋转90度
            [self updateArrowIconWithAngle:angle + 90.0 position:CGPointMake(self.view.bounds.size.height / 2.0, self.view.bounds.size.width / 2.0)];
            break;
        default:
            break;
    }
}

- (void)updateArrowIconWithAngle:(double)angle position:(CGPoint)position {
//    NSLog(@"angle: %f", angle);
    if (self.arrowImgView) {
        if (fabs(angle) < 2.0) {
            // 如果角度接近0，隐藏箭头图标
            self.arrowImgView.hidden = YES;
        } else {
            // 显示箭头图标
            self.arrowImgView.hidden = NO;
            
            // 更新箭头图标的旋转角度
            self.arrowImgView.transform = CGAffineTransformMakeRotation(angle * M_PI / 180.0);
            
            // 根据需要更新箭头图标的位置
//            self.arrowImgView.center = position;
        }
    }
}

- (CGPoint)calculatePointIconPositionWithYaw:(double)yaw pitch:(double)pitch roll:(double)roll {
    // 假设您已经获取了 m42 的方位角与高度角，假设它们分别为 m42Azimuth 和 m42Elevation
    
    // 根据手机的姿态角度和 m42 的方位角、高度角，计算 m42 相对于屏幕中心的位置
    double relativeAngle = self.m42Azimuth - yaw * 180.0 / M_PI; // 以手机屏幕朝上为0度，逆时针为正方向
    double distance = 100; /* 根据 m42 的高度角和其他因素计算距离 */;
    
    // 根据相对角度和距离计算 m42 在屏幕上的坐标
    double xOffset = distance * cos(relativeAngle * M_PI / 180.0);
    double yOffset = distance * sin(relativeAngle * M_PI / 180.0);
    
    // 根据屏幕方向调整坐标系
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGPointMake(self.view.bounds.size.width / 2.0 + xOffset, self.view.bounds.size.height / 2.0 - yOffset);
        case UIInterfaceOrientationLandscapeLeft:
            return CGPointMake(self.view.bounds.size.width / 2.0 + yOffset, self.view.bounds.size.height / 2.0 + xOffset);
        case UIInterfaceOrientationLandscapeRight:
            return CGPointMake(self.view.bounds.size.width / 2.0 - yOffset, self.view.bounds.size.height / 2.0 - xOffset);
        default:
            return CGPointMake(self.view.bounds.size.width / 2.0 + xOffset, self.view.bounds.size.height / 2.0 - yOffset);
    }
}

- (void)updateArrowDirectionToPointIcon:(UIImageView *)arrowImageView targetIcon:(UIImageView *)targetImageView {
    // 计算箭头指向目标图标的方向向量
    CGFloat deltaX = targetImageView.center.x - arrowImageView.center.x;
    CGFloat deltaY = targetImageView.center.y - arrowImageView.center.y;
    
    // 计算箭头指向目标图标的角度
    CGFloat angle = [self angleRelativeToCenterForView:targetImageView];
    
    // 将角度转换为弧度，并旋转箭头图标
    arrowImageView.transform = CGAffineTransformMakeRotation(angle * M_PI / 180.0);
}

- (void)updatePointIconPositionWithYaw:(double)yaw pitch:(double)pitch roll:(double)roll {
    // 计算 point icon 相对于屏幕中心的位置
    CGPoint pointIconCenter = [self calculatePointIconPositionWithYaw:yaw pitch:pitch roll:roll];
    self.starImgView.center = pointIconCenter;
    
    // 更新箭头方向
    [self updateArrowDirectionToPointIcon:self.arrowImgView targetIcon:self.starImgView];
    
    // 更新 starImgView 的尺寸
//    CGSize starSize = CGSizeMake(30.0, 20.0); // 设置 starImgView 的尺寸，这里设置为 (50, 50)，你可以根据需要调整
//    self.starImgView.frame = CGRectMake(pointIconCenter.x - starSize.width / 2.0, pointIconCenter.y - starSize.height / 2.0, starSize.width, starSize.height);
}

- (CGFloat)angleRelativeToCenterForView:(UIView *)view {
    CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    CGPoint targetPoint = view.center;
    
    CGFloat deltaX = targetPoint.x - center.x;
    CGFloat deltaY = targetPoint.y - center.y;
    
    // 计算角度，将角度从弧度转换为度数，并确保角度在 0 到 360 之间
    CGFloat angle = atan2(deltaY, deltaX) * (180 / M_PI);
    angle = (angle < 0) ? (360 + angle) : angle;
    
    
    return angle;
}
@end
