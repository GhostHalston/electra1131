#import "ViewController.h"
#include "codesign.h"
#include "electra.h"
#include "utils.h"
#include "multi_path_sploit.h"
#include "vfs_sploit.h"
#include "electra_objc.h"
#include "kmem.h"
#include "offsets.h"
#include <sys/sysctl.h>
#include "file_utils.h"
#include "electra_objc.h"

@interface ViewController ()
@end

static ViewController *currentViewController;

@implementation ViewController

#define localize(key) NSLocalizedString(key, @"")
#define postProgress(prg) [[NSNotificationCenter defaultCenter] postNotificationName: @"JB" object:nil userInfo:@{@"JBProgress": prg}]

#define ELECTRARemover_URL "https://www.dl.dropboxusercontent.com/s/odbvpyvpsutd2w3/ElecTh0rRemoverG10_304.ipa"
//#define ELECTRARemover_URL "https://www.dl.dropboxusercontent.com/s/gladlh6h2tyi5cw/ElecTh0rRemoverG10.ipa"
//#define ELECTRARemover_URL "https://www.dl.dropboxusercontent.com/s/fmyo3rufw07snis/ElecTh0rRemoverS1.ipa"

#define ELECTRA_Remover_TWITTER_HANDLE "pwned4ever"
#define K_ENABLE_TWEAKS "enableTweaks"

+ (instancetype)currentViewController {
    return currentViewController;
}

// thx DoubleH3lix

double uptime(){
    struct timeval boottime;
    size_t len = sizeof(boottime);
    int mib[2] = { CTL_KERN, KERN_BOOTTIME };
    if( sysctl(mib, 2, &boottime, &len, NULL, 0) < 0 )
    {
        return -1.0;
    }
    time_t bsec = boottime.tv_sec, csec = time(NULL);
    
    return difftime(csec, bsec);
}

-(void)updateProgressFromNotification:(id)sender{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *prog=[sender userInfo][@"JBProgress"];
        NSLog(@"Progress: %@",prog);
        [_jailbreak setEnabled:NO];
        [_jailbreak setAlpha:0.5];
        [_enableTweaks setEnabled:NO];
        [_setNonce setEnabled:NO];
        [_jailbreak setTitle:prog forState:UIControlStateNormal];
    });
}

- (void)shareElectra {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:localize(@"I'm using Unc0ver/Electra/Th0r Jailbreak Remover Toolkit VFS version 3.0.7, Updated Oct 19th 09:15PM-EDT By:@%@ 🍻 for iOS 11.2 - 11.4(beta 1-3), to remove my jailbreak on my %@ on iOS %@. You can download it now @ %@ "), @ELECTRA_Remover_TWITTER_HANDLE, [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], @ELECTRARemover_URL]] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop, UIActivityTypeOpenInIBooks, UIActivityTypeMarkupAsPDF];
    if ([activityViewController respondsToSelector:@selector(popoverPresentationController)] ) {
        activityViewController.popoverPresentationController.sourceView = _jailbreak;
    }
    
    [self presentViewController:activityViewController animated:YES completion:nil];
    unlink("/var/mobile/Media/.bootstrapped_electraremover");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgressFromNotification:) name:@"JB" object:nil];
    
#if ELECTRADEBUG
#else  /* !ELECTRADEBUG */
    [self checkVersion];
#endif /* !ELECTRADEBUG */
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    BOOL enable3DTouch = YES;
    
    switch (offsets_init()) {
        case ERR_NOERR: {
            break;
        }
        case ERR_VERSION: {
            [_jailbreak setEnabled:NO];
            [_jailbreak setAlpha:0.5];
            [_enableTweaks setEnabled:NO];
            [_jailbreak setTitle:localize(@"Version Error") forState:UIControlStateNormal];
            
            enable3DTouch = NO;
            break;
        }
            
        default: {
            [_jailbreak setEnabled:NO];
            [_jailbreak setAlpha:0.5];
            [_enableTweaks setEnabled:NO];
            //[_jailbreak setBackgroundColor:(UIColor * green)] ;
            
             // localize(@"Remove Jailbreak") forState:UIControlStateNormal];

            [_jailbreak setTitle:localize(@"Error: offsets") forState:UIControlStateNormal];
            
            enable3DTouch = NO;
            break;
        }
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@K_ENABLE_TWEAKS] == nil) {
        [userDefaults setBool:YES forKey:@K_ENABLE_TWEAKS];
        [userDefaults synchronize];
    }
    BOOL enableTweaks = [userDefaults boolForKey:@K_ENABLE_TWEAKS];
    [_enableTweaks setOn:enableTweaks];
    [_jailbreak setTitle:localize(@"Remove👆🏽Jailbreak") forState:UIControlStateNormal];
    

    uint32_t flags;
    csops(getpid(), CS_OPS_STATUS, &flags, 0);
    
    if ((flags & CS_PLATFORM_BINARY)) {
        [_enableTweaks setEnabled:NO];
        [_jailbreak setTitle:localize(@"Share Electra Remover") forState:UIControlStateNormal];
        
        enable3DTouch = NO;
    }
    if (enable3DTouch) {
        [notificationCenter addObserver:self selector:@selector(doit:) name:@"Remove Jailbreak" object:nil];
    }
    
    NSString *string = [NSString stringWithFormat:@"%@\niOS 11.2 - 11.4(b3)", localize(@"Compatible with")];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15 weight:UIFontWeightRegular] range:[string rangeOfString:localize(@"Compatible with")]];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.3f] range:[string rangeOfString:localize(@"Compatible with")]];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight:UIFontWeightBold] range:[string rangeOfString:@"iOS 11.2 "]];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] range:[string rangeOfString:@"iOS 11.2 "]];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium] range:[string rangeOfString:@"—"]];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] range:[string rangeOfString:@"—"]];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight:UIFontWeightBold] range:[string rangeOfString:@" 11.2 - 11.4(b3)"]];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] range:[string rangeOfString:@" 11.2 - 11.4(b3)"]];
    
    [_compatibilityLabel setAttributedText:attributedString];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)credits:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:localize(@"Credits") message:localize(@"Disclaimer and credits\vI assume no responsibility for any damage to your device or for any issues that may happen after using this tool. Beware and USE AT YOUR OWN RISK!. I will do my best at removing as many files as possible from your jailbreak. Mind you if you've changed something to your root filesystem, like a system folder/file name etc. You may run into some serious issues after using this tool. You should only try and use this tool in a last resort case, if you cannot use Cydia at all to clean/remove your tweaks/packages manually. You can use it once you've cleaned your device safely to remove any leftover folders and files you might have left.\v Credits & Thanks to Ian Beer, Coolstar, Jakeashacks, theninjaprawn, stek29, Siguza, xerub, PsychoTea and Pwn20wnd.\nuc0ver/Electra/Th0r Remover Icon design done by @louaizema\vJailbreak Removal Tool by:\n ♫♫♫ @pwned4ever ♫♫♫") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:localize(@"OK") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)doit:(id)sender {
    uint32_t flags;
    csops(getpid(), CS_OPS_STATUS, &flags, 0);
    if ((flags & CS_PLATFORM_BINARY)) {
        [self shareElectra];
        return;
    }
    
    
    [sender setEnabled:NO];
    [_enableTweaks setEnabled:NO];
    
    currentViewController = self;
    
    postProgress(localize(@"🤞VFS Exploit"));
    
    NSString *string = [NSString stringWithFormat:@"%@🤞VFS Exploit", localize(@"🤞VFSExploit")];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f] range:[string rangeOfString:@"🤞VFS Exploit"]];
    //00F900
    BOOL shouldEnableTweaks = [_enableTweaks isOn];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        
        int ut = 0;
        //int utme3 = uptime;
        int utme = ut + 40;
        while ((ut = 100 - uptime()) > 0 || (utme = 140 - uptime()) > 0) {
            
            int utme = ut + 40;
            NSString *msg = [NSString stringWithFormat:localize(@"Come back %d secs"), utme];
            postProgress(msg);
            sleep(1);
            while ((utme = 140 - uptime()) > 0) {
                NSString *msg1 = [NSString stringWithFormat:localize(@"Waiting:%d secs"), utme +40];
                postProgress(msg1);
                sleep(1);
                exit(0);
            }
            
        }
        //int newut = utme +40;
        while ((utme = 180 - uptime()) > 0) {
            NSString *msg1 = [NSString stringWithFormat:localize(@"Waiting:%d secs"), utme];
            postProgress(msg1);
            sleep(1);
            
        }
        postProgress(localize(@"🤞VFS Exploit"));
        
#if WANT_VFS
       // int exploitstatus = multi_path_go();

        int exploitstatus = vfs_sploit();
#else /* !WANT_VFS */
        //int exploitstatus = multi_path_go();

        int exploitstatus = vfs_sploit();
#endif /* !WANT_VFS */
        
        switch (exploitstatus) {
            case ERR_NOERR: {
                postProgress(localize(@"VFS Working...♫♫"));
                break;
            }
            case ERR_EXPLOIT: {
                
                postProgress(localize(@"Error: exploit"));
                return;
            }
            case ERR_UNSUPPORTED: {
                postProgress(localize(@"Error: unsupported"));
                return;
            }
            default:
                postProgress(localize(@"Error Exploiting"));
                return;
        }
        
        int jailbreakstatus = start_electra(tfp0, shouldEnableTweaks);
        
        switch (jailbreakstatus) {
            case ERR_NOERR: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    postProgress(localize(@"Done"));
                    UIAlertController *openSSHRunning = [UIAlertController alertControllerWithTitle:localize(@"Jailbreak Removed!") message:localize(@" All files/tweaks that come with a Jailbreak have been removed! You can safely rejailbreak and start all over again if you want\vp.s. I didn't remove any of your personal data or pictures/apps/messages/contacts etc, however if your trying to remove the JB so you can bypass a jailbreak detection app, sometimes this tool will not help with that specifc app detecting a Jailbroken device. First try the app after you've rebooted. If the app still fails to launch. Your best option is to bypass this by Erasing All Content and Settings when your device boots back up, if you want. Make a backup of all your photos and messages etc. You can close the app after you click EXIT and see your springboard should now be cleaned of all your Jailbreak apps, if there is any apps left. You will need to rejailbreak and install the same apps again and remove them in cydia after you've installed them.\vI set your Device to reboot in 2 minutes as soon as this prompt comes up......\n If you leave this prompt open for 2 minutes your device will reboot....\nThank you for using my tool.. If you would like to, close it now before it reboots. Then open it again and click share!. After you've shared it, Please REBOOT Manually.\n♫♫♫ @pwned4ever ♫♫♫ ") preferredStyle:UIAlertControllerStyleAlert];
                    [openSSHRunning addAction:[UIAlertAction actionWithTitle:localize(@"Exit") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        [openSSHRunning dismissViewControllerAnimated:YES completion:nil];
                        exit(0);
                    }]];
                    [self presentViewController:openSSHRunning animated:YES completion:nil];
                });
                sleep(120);
                do_restart();
                break;
            }
            case ERR_TFP0: {
                postProgress(localize(@"Error: tfp0"));
                break;
            }
            case ERR_ALREADY_JAILBROKEN: {
                postProgress(localize(@"Reboot and retry"));
                break;
            }
            case ERR_AMFID_PATCH: {
                postProgress(localize(@"Error: amfid patch"));
                break;
            }
            case ERR_ROOTFS_REMOUNT: {
                postProgress(localize(@"Error: rootfs remount"));
                break;
            }
            case ERR_SNAPSHOT: {
                postProgress(localize(@"Error: snapshot failed"));
                break;
            }
            case ERR_CONFLICT: {
                postProgress(localize(@"Error: conflict"));
                break;
            }
            default: {
                postProgress(localize(@"Error Jailbreaking"));
                break;
            }
        }
        
        NSLog(@" ♫ KPP never bothered me anyway... ♫ ");
    });
}

- (IBAction)tappedOnSetNonce:(id)sender {
    __block NSString *generatorToSet = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:localize(@"Set the system boot nonce on jailbreak") message:localize(@"Enter the generator for the nonce you want the system to generate on boot") preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:localize(@"Cancel") style:UIAlertActionStyleDefault handler:nil]];
    UIAlertAction *set = [UIAlertAction actionWithTitle:localize(@"Set") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        const char *generatorInput = [alertController.textFields.firstObject.text UTF8String];
        char compareString[22];
        uint64_t rawGeneratorValue;
        sscanf(generatorInput, "0x%16llx",&rawGeneratorValue);
        sprintf(compareString, "0x%016llx", rawGeneratorValue);
        if(strcmp(compareString, generatorInput) != 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:localize(@"Error") message:localize(@"Failed to validate generator") preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:localize(@"OK") style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        generatorToSet = [NSString stringWithUTF8String:generatorInput];
        [userDefaults setObject:generatorToSet forKey:@K_GENERATOR];
        [userDefaults synchronize];
        uint32_t flags;
        csops(getpid(), CS_OPS_STATUS, &flags, 0);
        UIAlertController *alertController = nil;
        if ((flags & CS_PLATFORM_BINARY)) {
            alertController = [UIAlertController alertControllerWithTitle:localize(@"Notice") message:localize(@"The system boot nonce will be set the next time you enable your jailbreak") preferredStyle:UIAlertControllerStyleAlert];
        } else {
            alertController = [UIAlertController alertControllerWithTitle:localize(@"Notice") message:localize(@"The system boot nonce will be set once you enable the jailbreak") preferredStyle:UIAlertControllerStyleAlert];
        }
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    [alertController addAction:set];
    [alertController setPreferredAction:set];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = [NSString stringWithFormat:@"%s", genToSet()];
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

NSString *getURLForUsername(NSString *user) {
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:[NSURL URLWithString:@"tweetbot://"]]) {
        return [@"tweetbot:///user_profile/" stringByAppendingString:user];
    } else if ([application canOpenURL:[NSURL URLWithString:@"twitterrific://"]]) {
        return [@"twitterrific:///profile?screen_name=" stringByAppendingString:user];
    } else if ([application canOpenURL:[NSURL URLWithString:@"tweetings://"]]) {
        return [@"tweetings:///user?screen_name=" stringByAppendingString:user];
    } else if ([application canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        return [@"twitter://user?screen_name=" stringByAppendingString:user];
    } else {
        return [@"https://mobile.twitter.com/" stringByAppendingString:user];
    }
    return nil;
}

- (IBAction)tappedOnHyperlink:(id)sender {
    UIApplication *application = [UIApplication sharedApplication];
    NSString *str = getURLForUsername(@ELECTRA_Remover_TWITTER_HANDLE);
    NSURL *URL = [NSURL URLWithString:str];
    [application openURL:URL options:@{} completionHandler:nil];
}

- (void)removingLiberiOS {
    postProgress(localize(@"Removing JB"));
}

- (void)installingCydia {
    postProgress(localize(@"Removing JB"));
}

- (void)cydiaDone {
    postProgress(localize(@"All done now"));
}

- (void)displaySnapshotNotice {
    dispatch_async(dispatch_get_main_queue(), ^{
        postProgress(localize(@"user prompt"));
        UIAlertController *apfsNoticeController = [UIAlertController alertControllerWithTitle:localize(@"APFS Snapshot Created") message:localize(@"An APFS Snapshot has been successfully created! You may be able to use SemiRestore to restore your phone to this snapshot in the future.") preferredStyle:UIAlertControllerStyleAlert];
        [apfsNoticeController addAction:[UIAlertAction actionWithTitle:localize(@"Continue Jailbreak") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            postProgress(localize(@"Please Wait (2/3)"));
            snapshotWarningRead();
        }]];
        [self presentViewController:apfsNoticeController animated:YES completion:nil];
    });
}

- (void)displaySnapshotWarning {
    dispatch_async(dispatch_get_main_queue(), ^{
        postProgress(localize(@"user prompt"));
        UIAlertController *apfsWarningController = [UIAlertController alertControllerWithTitle:localize(@"APFS Snapshot Not Found") message:localize(@"Warning: Your device was bootstrapped using a pre-release version of Electra and thus does not have an APFS Snapshot present. While Electra may work fine, you will not be able to use SemiRestore to restore to stock if you need to. Please clean your device and re-bootstrap with this version of Electra to create a snapshot.") preferredStyle:UIAlertControllerStyleAlert];
        [apfsWarningController addAction:[UIAlertAction actionWithTitle:@"Continue Jailbreak" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            postProgress(localize(@"Please Wait (2/3)"));
            snapshotWarningRead();
        }]];
        [self presentViewController:apfsWarningController animated:YES completion:nil];
    });
}

- (void)restarting {
    postProgress(localize(@"Restarting"));
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)enableTweaksChanged:(id)sender {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL enableTweaks = [_enableTweaks isOn];
    [userDefaults setBool:enableTweaks forKey:@K_ENABLE_TWEAKS];
    [userDefaults synchronize];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
