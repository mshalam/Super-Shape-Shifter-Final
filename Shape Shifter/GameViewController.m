//
//  GameViewController.m
//  Shape Shifter
//
//  Created by Loriah Pope on 12/5/14.
//  Copyright (c) 2014 llp260. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "Level.h"
#import "GameData.h"
#import <Social/Social.h>

@import AVFoundation;


@interface GameViewController ()

@property (assign, nonatomic) NSUInteger timeLeft;
@property (assign, nonatomic) NSUInteger score;
@property (assign, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSString *currentTime;

@property (assign, nonatomic) BOOL nextGame;

@property (weak, nonatomic) IBOutlet UILabel *targetLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetTitle;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTitle;
@property (weak, nonatomic) IBOutlet UILabel *scoreTitle;
@property (weak, nonatomic) IBOutlet UILabel *levelTitle;

@property (weak, nonatomic) IBOutlet UIView *timeOutLabel;


@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@property (strong, nonatomic) AVAudioPlayer *backgroundMusic;

@property (strong, nonatomic) AVAudioPlayer *tapSounds;

@property (strong, nonatomic) Level *level;
@property (strong, nonatomic) GameScene *scene;
@property (strong, nonatomic) GameData *data;

@property (weak, nonatomic) IBOutlet UIButton *closeSettings;
@property (weak, nonatomic) IBOutlet UIView *closeInfo;

@property (weak, nonatomic) IBOutlet UILabel *userScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;

@property (weak, nonatomic) IBOutlet UIButton *retryButton;

@property (weak, nonatomic) IBOutlet UIView *infoPanel;

@property (weak, nonatomic) IBOutlet UIView *settingsPanel;

@property (weak, nonatomic) IBOutlet UIImageView *gameOverPanel;

@property (weak, nonatomic) IBOutlet UISwitch *musicToggle;


@property (weak, nonatomic) IBOutlet UIImageView *levelSelectBackground;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *howToButton;
@property (weak, nonatomic) IBOutlet UILabel *SuperLabel;
@property (weak, nonatomic) IBOutlet UILabel *ShapeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ShifterLabel;

@property (weak, nonatomic)  NSSet *myShapes;

@end

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)beginGame {
    //resets data
    [[GameData sharedGameData] reset];
    
    self.targetTitle.hidden = NO;
    self.timeTitle.hidden = NO;
    self.scoreTitle.hidden = NO;
    self.targetLabel.hidden = NO;
    self.timeLabel.hidden = NO;
    
    self.timeLeft = self.level.maximumTime;
    //begin to countdown time
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(decrementTime) userInfo:nil repeats:YES];
    
    [self updateLabels];
    
    [self shuffle];
}

//music functionality when music switch is toggled on/off
- (IBAction)stopMusic:(id)sender {
    if(!self.musicToggle.on)
    {
        [self.backgroundMusic stop];
        self.musicToggle.on = false;
    }
    else{
        [self.backgroundMusic play];
        self.musicToggle.on = true;
    }
    
}

//tap sound functionality when music switch is toggled on/off
- (IBAction)stopTapSounds:(id)sender {
    if(self.tapToggle.on)
    {
        NSLog(@"Tap On");
        self.scene.tapOn = false;
    }
    else{
        NSLog(@"Tap Off");
        self.scene.tapOn = true;
    }
}

// Method called when button is pressed to post score to Facebook
- (IBAction)postToFb:(id)sender {
    [self shareScoreFb];
}
// Method called when button is pressed to post score to Twitter
- (IBAction)postToTw:(id)sender {
    [self shareScoreTw];
}

//beginning screen when game is first loaded
-(void)introScreen {
    //hide the info and setting button so they can't be clicked on
    self.infoButton.hidden = YES;
    self.settingsButton.hidden = YES;
    
    //begin slide in animation for title screen
    self.SuperLabel.center = CGPointMake(-125, 175);
    self.ShapeLabel.center = CGPointMake(-175, 225);
    self.ShifterLabel.center = CGPointMake(-225, 275);
    
    self.SuperLabel.hidden = NO;
    self.ShapeLabel.hidden = NO;
    self.ShifterLabel.hidden = NO;
    
    [UILabel animateWithDuration:1.0 animations:^{
        self.SuperLabel.center = CGPointMake(100, 175);
    }];
    
    [UILabel animateWithDuration:1.5 animations:^{
        self.ShapeLabel.center = CGPointMake(150, 225);
    }];
    
    [UILabel animateWithDuration:2.0 animations:^{
        self.ShifterLabel.center = CGPointMake(200, 275);
    }];
    //end slide in animation for title screen
    
    //hide everything while intro screen is showing
    self.playButton.hidden = NO;
    self.howToButton.hidden = NO;
    
    self.targetTitle.hidden = YES;
    self.timeTitle.hidden = YES;
    self.scoreTitle.hidden = YES;
    self.levelTitle.hidden = YES;
    self.targetLabel.hidden = YES;
    self.timeLabel.hidden = YES;
    self.timeOutLabel.hidden = YES;
    
    self.facebookButton.hidden = YES;
    self.twitterButton.hidden = YES;
    
    self.endTimeLabel.hidden = YES;
    self.userScoreLabel.hidden = YES;
    self.highScoreLabel.hidden = YES;
    
    self.levelSelectBackground.image = [UIImage imageNamed:@"Background"];
    
    //bring components of intro screen forward
    [self.view bringSubviewToFront:self.SuperLabel];
    [self.view bringSubviewToFront:self.ShapeLabel];
    [self.view bringSubviewToFront:self.ShifterLabel];
    [self.view bringSubviewToFront:self.playButton];
    [self.view bringSubviewToFront:self.howToButton];
}

- (void)shuffle {
    NSSet *newShapes = [self.level shuffle];
    self.myShapes = newShapes;
    [self.scene addSpritesForShapes:newShapes];
}

-(void)clear {
    self.myShapes = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SKView *skView = (SKView *)self.view;
    skView.multipleTouchEnabled = NO;
    
    //load game scene
    self.scene = [GameScene sceneWithSize:skView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    
    
    self.userScoreLabel.hidden = YES;
    self.highScoreLabel.hidden = YES;
    self.retryButton.hidden = YES;
    self.timeOutLabel.hidden = YES;
    
    self.gameOverPanel.hidden = YES;
    
    self.infoPanel.hidden = YES;
    
    self.settingsPanel.hidden = YES;
    
    //show game scene
    [skView presentScene:self.scene];
    
    //begin background music
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"backgroundMusic" withExtension:@"mp3"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.backgroundMusic.numberOfLoops = -1;
    [self.backgroundMusic play];
    
    if(self.nextGame != YES){
        [self introScreen];
    }

}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)showSuccessAlert {
    
}

// Funciton for sharing score on Facebook
-(void)shareScoreFb {
    SLComposeViewController* fbVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    SLComposeViewControllerCompletionHandler block = ^(SLComposeViewControllerResult result) {
        [fbVC dismissViewControllerAnimated:YES completion:nil];
        
        if (result == SLComposeViewControllerResultCancelled) {
            NSLog(@"post cancelled");
        }
        else if(result == SLComposeViewControllerResultDone) {
            [self performSelector:@selector(showSuccessAlert) withObject:nil afterDelay:1];
        }
    };
    
    [fbVC setCompletionHandler:block];
    
    NSString* text;
    long highScore = [GameData sharedGameData].highScore;
    
    if(self.score >= highScore) {
        
        text = [NSString stringWithFormat:@"-- Super Shape Shifter --\nI just beat my highscore! \nSCORE: %lu! Beat that!",
                (unsigned long)self.score];
    }else {
        text = [NSString stringWithFormat:@"-- Super Shape Shifter --\n \nSCORE: %lu! Beat that!",
                self.score];
    }
    [fbVC setInitialText:text];
    [self presentViewController:fbVC animated:YES completion:nil];
    NSLog(@"highscore: %lu",[GameData sharedGameData].highScore);
    NSLog(@"score: %lu",[GameData sharedGameData].score);
}

// Funciton for sharing score on Twitter
- (void) shareScoreTw {
    SLComposeViewController* twVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    SLComposeViewControllerCompletionHandler blocktw = ^(SLComposeViewControllerResult result) {
        [twVC dismissViewControllerAnimated:YES completion:nil];
        
        if (result == SLComposeViewControllerResultCancelled) {
            NSLog(@"post cancelled");
        }
        else if(result == SLComposeViewControllerResultDone) {
            [self performSelector:@selector(showSuccessAlert) withObject:nil afterDelay:1];
        }
    };
    [twVC setCompletionHandler:blocktw];
    
    NSString* textTw;
    long highScoreTw = [GameData sharedGameData].highScore;
    
    if(self.score >= highScoreTw) {
        
        textTw = [NSString stringWithFormat:@"-- Super Shape Shifter --\nI just beat my highscore! \nSCORE: %lu! Beat that!",
                  (unsigned long)self.score];
    }else {
        textTw = [NSString stringWithFormat:@"-- Super Shape Shifter --\n \nSCORE: %lu! Beat that!",
                  self.score];
    }
    [twVC setInitialText:textTw];
    [self presentViewController:twVC animated:YES completion:nil];
    
}

- (void)decrementTime{
    
    self.score = [GameData sharedGameData].score;
    
    self.timeLeft--;
    
    [self updateLabels];
    
    if(self.timeLeft == 0){
        
        [[GameData sharedGameData] save];
        
        self.userScoreLabel.text = [NSString stringWithFormat:@"Your Score: %lu", (unsigned long)self.score];
        
        self.highScoreLabel.text = [NSString stringWithFormat:@"High Score: %li", [GameData sharedGameData].highScore];
        
        [self showGameOver];
        
        self.infoPanel.hidden = YES;
        self.settingsPanel.hidden =YES;
        
        self.userScoreLabel.hidden = NO;
        self.highScoreLabel.hidden = NO;
        self.endTimeLabel.hidden = NO;
        self.retryButton.hidden = NO;
        self.timeOutLabel.hidden = NO;
        
        [self.view bringSubviewToFront:self.gameOverPanel];
        [self.view bringSubviewToFront:self.endTimeLabel];
        [self.view bringSubviewToFront:self.userScoreLabel];
        [self.view bringSubviewToFront:self.highScoreLabel];
        [self.view bringSubviewToFront:self.retryButton];
        [self.view bringSubviewToFront:self.timeOutLabel];

        self.timeLabel.text = @"Time!";
       [_timer invalidate];
    }
    
}

- (void)updateLabels {
    self.targetLabel.text = [NSString stringWithFormat:@"%lu", [GameData sharedGameData].highScore];
    self.timeLabel.text = [NSString stringWithFormat:@"%lu", (long)self.timeLeft];
}

- (void)showGameOver {
    //game over screen updates if you beat your high score
    [GameData sharedGameData].highScore = MAX([GameData sharedGameData].score, [GameData sharedGameData].highScore);
    
    [self.view bringSubviewToFront:self.gameOverPanel];
    
    self.gameOverPanel.hidden = NO;
    self.scene.userInteractionEnabled = NO;
    
    self.facebookButton.hidden = NO;
    self.twitterButton.hidden = NO;
}

- (void)hideGameOver {
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
    self.tapGestureRecognizer = nil;
    
    self.gameOverPanel.hidden = YES;
    self.scene.userInteractionEnabled = YES;
}

-(void)showInfoMessage{
    self.infoPanel.hidden = NO;
    self.scene.userInteractionEnabled = NO;
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideInfoMessage)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

-(void)showSettingsMessage{
    self.settingsPanel.hidden = NO;
    self.scene.userInteractionEnabled = NO;
    [self.view bringSubviewToFront:self.settingsPanel];
}

- (IBAction)closeInfo:(id)sender {
    [self hideInfoMessage];
}

- (IBAction)closeSettings:(id)sender {
    [self hideSettingsMessage];
}

- (void)hideInfoMessage {
    self.infoPanel.hidden = YES;
    self.scene.userInteractionEnabled = YES;
}

- (void)hideSettingsMessage {
    [self.view removeGestureRecognizer:self.tapGestureRecognizer];
    self.tapGestureRecognizer = nil;
    
    self.settingsPanel.hidden = YES;
    self.scene.userInteractionEnabled = YES;
}

-(IBAction)infoClick:(id)sender{
    _currentTime = self.timeLabel.text;
    [self.view bringSubviewToFront:self.infoPanel];
    
    NSLog(@"You have clicked the info button");
    
    [self showInfoMessage];
}

-(IBAction)settingsClick:(id)sender{
    
    NSLog(@"You have clicked the settings button");
    
    [self showSettingsMessage];
}

-(IBAction)playGame:(id)sender{
    //hide all intro screen components
    self.SuperLabel.hidden = YES;
    self.ShapeLabel.hidden = YES;
    self.ShifterLabel.hidden = YES;
    self.infoButton.hidden = NO;
    self.infoPanel.hidden = YES;
    self.settingsButton.hidden = NO;
    self.settingsPanel.hidden = YES;
    self.levelSelectBackground.hidden = YES;
    self.playButton.hidden = YES;
    self.howToButton.hidden = YES;
    self.userScoreLabel.hidden = YES;
    self.highScoreLabel.hidden = YES;
    self.endTimeLabel.hidden = YES;
    self.retryButton.hidden = YES;
    self.facebookButton.hidden = YES;
    self.twitterButton.hidden = YES;
    self.timeOutLabel.hidden = YES;
    
    //load first level configuration
    self.level = [[Level alloc] initWithFile:@"Level_1"];
    self.scene.level = self.level;
    
    //revert score text back to 0
    self.scene.score.text = @"0";
    
    //remove old shapes
    [self.scene.shapesLayer removeAllChildren];
    
    //add new shapes
    [self.scene addTiles];
    
    self.scene.userInteractionEnabled = YES;
    
    //allows bombs to begin spawning again
    self.scene.timeLeft = self.level.maximumTime+1;
    
    [self beginGame];
    
}

//how to screen
- (IBAction)howTo:(id)sender {
    [self.view bringSubviewToFront:self.infoPanel];
    [self showInfoMessage];
}

@end










