//
//  RegisterViewController.m
//  喔喔农机机主版
//
//  Created by 栾云腾 on 15/12/21.
//  Copyright © 2015年 栾云腾. All rights reserved.
//

#import "RegisterViewController.h"
#import <SMS_SDK/SMSSDK.h>

#import <SMS_SDK/SMSSDK.h>
#import <SMS_SDK/SMSSDKCountryAndAreaCode.h>
#import <SMS_SDK/SMSSDK+DeprecatedMethods.h>
#import <SMS_SDK/SMSSDK+ExtexdMethods.h>
#import <MOBFoundation/MOBFoundation.h>

#import <AFHTTPSessionManager.h>
#import <AFNetworking.h>

@interface RegisterViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;

@property (weak, nonatomic) IBOutlet UITextField *confirmedPassword;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeField;
@property (strong,nonatomic) NSString *verifyCode;
@property (strong,nonatomic)AFHTTPSessionManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation RegisterViewController

//-(void)setManager:(AFHTTPSessionManager *)manager{
//    if (_manager == nil) {
//        _manager = [AFHTTPSessionManager manager];
//    }else{
//        return;
//    }
//}

-(AFHTTPSessionManager *)manager{
    if (_manager == nil) {
        _manager = [AFHTTPSessionManager manager];
        return _manager;
    }else{
        return _manager;
    }
}

//验证手机号格式
-(BOOL)validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

//获取验证码
- (IBAction)getVerifyCode:(id)sender {
    
    //检测手机号格式是否正确
    BOOL flagPhoneNumber = [self validateMobile:self.phoneNumber.text];
    if (flagPhoneNumber ==NO) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:@"手机号码格式错误，请确认后重新输入" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.phoneNumber.text = nil;
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [SMSSDK getVerificationCodeByMethod: SMSGetCodeMethodSMS phoneNumber:self.phoneNumber.text
                                   zone:@"86"
                       customIdentifier:nil
                                 result:^(NSError *error)
     {
         
         if (!error)
         {
             NSLog(@"send successfully!");
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"验证码发送成功！" message:@"请留意您的短信" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 self.registerButton.userInteractionEnabled = YES;
                 self.registerButton.alpha = 1.0;
             }];
             [alert addAction:defaultAction];
             [self presentViewController:alert animated:YES completion:nil];

         }
         else
         {
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"验证码发送失败！" message:@"请尝试更换手机号或者重新发送" preferredStyle:UIAlertControllerStyleAlert];
             UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             }];
             [alert addAction:defaultAction];
             [self presentViewController:alert animated:YES completion:nil];
         }
     }];
}
//点击注册按钮
- (IBAction)registerButtonClicked:(id)sender {
    //是否输入用户名
    if (self.userName.text ==nil||[self.userName.text isEqual:@""]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:@"请输入用户名" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            nil;
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    //检测两次输入的密码是否一致
    BOOL flagPassword;
    flagPassword = [self.password.text isEqual:self.confirmedPassword.text];
    if (flagPassword == NO||[self.password.text isEqual:@""] ||[self.confirmedPassword.text isEqual:@""] ) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"错误提示"
                                                                       message:@"两次输入的密码不一致,请重新输入！"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  self.password.text = nil;
                                                                  self.confirmedPassword.text = nil;
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    //检测用户名是否已被注册过
    
    //检测手机号是否被注册过
    //AFHTTPSessionManager *myManager = [AFHTTPSessionManager manager];
    NSString *url =[@"http://api.carpela.me:8080/lender-api/user/" stringByAppendingString:self.phoneNumber.text];
    
    [self.manager GET:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        //NSLog(@"success %@",responseObject);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:@"该手机号已被注册，请更换手机号！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.phoneNumber.text = nil;
        }];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"fail %@",error);
    }];
    
    
    //检测验证码是否通过
    
    
    [SMSSDK  commitVerificationCode:self.verifyCodeField.text phoneNumber:self.phoneNumber.text zone:@"86" result:^(NSError *error) {
        
        if (!error)
        {
            NSLog(@"验证成功");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"验证成功！" message:@"您可以使用当前账号登陆" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            NSLog(@"验证失败");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误提示" message:@"验证码错误，请再次发送验证码！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.verifyCodeField.text = nil;
                self.registerButton.userInteractionEnabled = NO;
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }}];

}

//向服务器发送注册信息，包括名字，密码，手机号码
//-(void)postRegister{
//    NSDictionary *parameters = @{@"phonenumber":self.phoneNumber.text,@"name":self.userName.text,@"password":self.password.text};
//    [self.manager POST:@"http://api.carpela.me:8080/lender-api/user/" parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//        NSLog(@"success %@",responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"failure %@",error);
//    }];
//}

     
//按下return键关闭键盘,有bug，需调试
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
