package Widgets.Windows
{
   import Classes.Constants.WorldsConstants;
   import Classes.Constants.ZLocConstants;
   import Classes.MatchMaking.MatchMakingManager;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.AFInnovationManager;
   import Managers.FarmStatsManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.DataEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class AFInnovationWindow extends FarmWindowWithTutorial
   {
      
      private static const NUM_TUTORIAL_SCENES:int = 4;
      
      protected var m_featureName:String;
      
      private var m_redeem_mc:MovieClip;
      
      private var m_icon_mc:MovieClip;
      
      private var m_bonusMc:ZwWidget;
      
      private var m_FindMatchButton:FarmAnimatedTextButton;
      
      private var m_InviteFriendButton:FarmAnimatedTextButton;
      
      private var m_PlaySoloButton:FarmAnimatedTextButton;
      
      private var m_CollectButton:FarmAnimatedTextButton;
      
      private var m_askBtn:FarmAnimatedTextButton;
      
      private const WHATISTHIS_MC:String = "whatisthis_mc";
      
      private const ASK_BT:String = "ask_bt";
      
      private const BUY_BT:String = "buy_bt";
      
      private const PLAY1_BT:String = "play1_bt";
      
      private const PLAY2_BT:String = "play2_bt";
      
      private const PLAY3_BT:String = "play3_bt";
      
      private const COLLECT_BT:String = "collect_bt";
      
      private const REDEEEM_BT:String = "redeem_bt";
      
      private const REDEEM_MC:String = "redeem_mc";
      
      private const UNLOCK_BT:String = "unlock_bt";
      
      private const TUTORIAL_BT:String = "tutorial_bt";
      
      private const TUTORIAL_MC:String = "tutorial_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const BODY_TF:String = "body_tf";
      
      private const UNLOCK_TF:String = "unlock_tf";
      
      private const PLAY_TF:String = "play_tf";
      
      private const COUNT_TF:String = "count_tf";
      
      private const COUNT1_TF:String = "inventory_tf";
      
      private const QUANTITY_TF:String = "quantity_tf";
      
      private const NAME_TF:String = "name_tf";
      
      private const COLLECT_TF:String = "collect_tf";
      
      private const TEXT_WHATISTHIS:String = "HowDoesThisWork";
      
      private const ICON_MC:String = "icon_mc";
      
      private var m_matchTimer:Timer;
      
      private var m_startGameTimer:Timer;
      
      private var m_timerRetries:int = 0;
      
      private var m_currentTimeCount:int;
      
      private var m_timer:Timer;
      
      private const DEFAULT_CONNECTION_WAITING_PERIOD:Number = 180;
      
      private const DEFAULT_STARTGAME_WAITING_PERIOD:Number = 4000;
      
      private var m_tutorial_bt:FarmAnimatedTextButton;
      
      private var m_tutorial_mc:MovieClip;
      
      private var m_runesCount:ZwTextField;
      
      private var m_isDisabledByRuntime:Boolean = false;
      
      private var m_isRuntimeLoaded:Boolean = false;
      
      private const SERVICE_CLASS:String = "AFInnovationService";
      
      private const SERVICE_FUNC_IS_GAME_DISABLED:String = "isGameDisabled";
      
      private var m_unlockLandButton:FarmAnimatedTextButton;
      
      private var m_unlockLandText:ZwTextField;
      
      private var m_currencyCount_tf:ZwTextField;
      
      private var m_redeemButton:FarmAnimatedTextButton;
      
      private var m_gameId:String;
      
      private var m_player2UID:String;
      
      private var m_showTutorialWithEAPage:Boolean;
      
      private var m_movedToPPPPool:Boolean = false;
      
      public function AFInnovationWindow(featureName:String, assetPath:String = "", showTutorialWithEAPage:Boolean = false)
      {
         this.m_featureName = featureName;
         this.m_showTutorialWithEAPage = showTutorialWithEAPage;
         var numOfTutorialPages:int = NUM_TUTORIAL_SCENES;
         if(WorldSeasonsManager.getInstance().isEAUser(WorldsConstants.WORLD_ID_ANGLOFRENCH))
         {
            numOfTutorialPages = NUM_TUTORIAL_SCENES + 1;
         }
         super(this.m_featureName,assetPath,numOfTutorialPages,true,true);
         TransactionManager.addTransaction(new TGenericTransaction(this.SERVICE_CLASS,this.SERVICE_FUNC_IS_GAME_DISABLED,this.onReceiveRuntimeVar),true);
      }
      
      override protected function postLoadComplete() : void
      {
         var icon_mc:FarmIcon = null;
         FarmStatsManager.count("Hand_of_Destiny","Main_UI","impression");
         var consumableItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.manager.ConsumableCode);
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_Title")));
         }
         if(m_window.hasOwnProperty(this.BODY_TF))
         {
            addWidget(new ZwTextField(m_window[this.BODY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_body")));
         }
         if(m_window.hasOwnProperty(this.NAME_TF))
         {
            addWidget(new ZwTextField(m_window[this.NAME_TF],consumableItem.friendlyTitle));
         }
         if(m_window.hasOwnProperty(this.PLAY_TF))
         {
            addWidget(new ZwTextField(m_window[this.PLAY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_StartPlay")));
         }
         if(m_window.hasOwnProperty(this.COUNT_TF))
         {
            addWidget(this.m_runesCount = new ZwTextField(m_window[this.COUNT_TF],"x" + this.manager.getConsumableCount().toString()));
         }
         if(m_window.hasOwnProperty(this.TIMER_TF))
         {
            addWidget(new ZwTextField(m_window[this.TIMER_TF],this.manager.getFeatureEndDaysLeftText()));
         }
         if(m_window.hasOwnProperty(this.COUNT1_TF))
         {
            addWidget(this.m_currencyCount_tf = new ZwTextField(m_window[this.COUNT1_TF],"x" + this.manager.getCurrencyCount().toString()));
         }
         if(m_window.hasOwnProperty(this.QUANTITY_TF))
         {
            addWidget(new ZwTextField(m_window[this.QUANTITY_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_FootText")));
         }
         if(m_window.hasOwnProperty(this.COLLECT_TF))
         {
            addWidget(new ZwTextField(m_window[this.COLLECT_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_CollectText")));
         }
         if(m_window.hasOwnProperty(this.REDEEM_MC))
         {
            this.m_redeem_mc = m_window[this.REDEEM_MC] as MovieClip;
            this.m_redeem_mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.TUTORIAL_MC))
         {
            this.m_tutorial_mc = m_window[this.TUTORIAL_MC];
            this.m_tutorial_mc.visible = true;
         }
         if(m_window.hasOwnProperty(this.ICON_MC))
         {
            this.m_icon_mc = m_window[this.ICON_MC] as MovieClip;
            icon_mc = new FarmIcon(this.m_icon_mc,consumableItem.iconUrl);
            addWidget(icon_mc);
         }
         if(m_window.hasOwnProperty(this.WHATISTHIS_MC))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.WHATISTHIS_MC],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.TEXT_WHATISTHIS),this.howDoesThisWorkClick));
         }
         if(m_window.hasOwnProperty(this.ASK_BT))
         {
            addWidget(this.m_askBtn = new FarmAnimatedTextButton(m_window[this.ASK_BT],"Ask",this.onAskClick));
         }
         if(m_window.hasOwnProperty(this.BUY_BT))
         {
            addWidget(new FarmAnimatedTextButton(m_window[this.BUY_BT],"Buy",this.onBuyClick));
         }
         if(m_window.hasOwnProperty(this.COLLECT_BT))
         {
            addWidget(this.m_CollectButton = new FarmAnimatedTextButton(m_window[this.COLLECT_BT],"Collect",this.onCollectClick));
         }
         if(m_window.hasOwnProperty(this.REDEEEM_BT))
         {
            addWidget(this.m_redeemButton = new FarmAnimatedTextButton(m_window[this.REDEEEM_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_RedeemRewardButtonText"),this.onRedeemClick));
            this.m_redeemButton.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_RedeemToolTipText")));
         }
         if(m_window.hasOwnProperty(this.PLAY1_BT))
         {
            addWidget(this.m_FindMatchButton = new FarmAnimatedTextButton(m_window[this.PLAY1_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_FindGameButtonText"),this.onFindGameClick));
            this.m_FindMatchButton.enabled = this.m_isRuntimeLoaded;
         }
         if(m_window.hasOwnProperty(this.PLAY2_BT))
         {
            addWidget(this.m_InviteFriendButton = new FarmAnimatedTextButton(m_window[this.PLAY2_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_InviteFriendButtonText"),this.onInviteFriendClick));
            this.m_InviteFriendButton.enabled = this.m_isRuntimeLoaded;
         }
         if(m_window.hasOwnProperty(this.PLAY3_BT))
         {
            addWidget(this.m_PlaySoloButton = new FarmAnimatedTextButton(m_window[this.PLAY3_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_PlaySoloButtonText"),this.onPlaySoloClick));
         }
         if(m_window.hasOwnProperty(this.TUTORIAL_BT))
         {
            addWidget(this.m_tutorial_bt = new FarmAnimatedTextButton(m_window[this.TUTORIAL_BT],"",this.openGameTutorial));
         }
         if(m_window.hasOwnProperty(this.UNLOCK_BT) && m_window.hasOwnProperty(this.UNLOCK_TF))
         {
            addWidget(this.m_unlockLandButton = new FarmAnimatedTextButton(m_window[this.UNLOCK_BT],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_UnlockTileButtonText"),this.onUnlockClick));
            addWidget(this.m_unlockLandText = new ZwTextField(m_window[this.UNLOCK_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_UnlockTileText")));
            if(this.manager.lockedTilesArray.length <= 0)
            {
               if(Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_ANGLOFRENCH)
               {
                  this.m_unlockLandButton.enabled = false;
                  this.m_unlockLandButton.applyGrayOut = true;
                  this.m_unlockLandText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_UnlockTileText2");
               }
               else
               {
                  this.m_unlockLandButton.text = "Travel";
                  this.m_unlockLandText.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_MainWindow_UnlockTileText3");
               }
            }
         }
         this.updateCollectButton();
         this.updatePlayButtons();
         this.refreshAskButton();
         this.performBonusActionsIfEnabled();
         super.postLoadComplete();
         if(this.m_showTutorialWithEAPage)
         {
            this.showTutorialWithEAPage();
         }
      }
      
      private function performBonusActionsIfEnabled() : void
      {
         if(Boolean(Global.flashHotParams[AFInnovationManager.AFINNOVATION_BONUSENABLED_FLAG]) && !Global.player.getSeenFlag(Global.flashHotParams[AFInnovationManager.AFINNOVATION_BONUSENABLED_FLAG]))
         {
            Global.player.setSeenFlag(Global.flashHotParams[AFInnovationManager.AFINNOVATION_BONUSENABLED_FLAG],true,true);
            this.manager.resetCollectTimer();
            if(this.hasSeenTutorial && Boolean(m_window.bonus_mc))
            {
               addWidget(this.m_bonusMc = new ZwWidget(m_window.bonus_mc));
            }
            this.refreshWindow();
         }
      }
      
      public function showTutorialWithEAPage() : void
      {
         var element:MovieClip = null;
         var i:int = 0;
         var child:MovieClip = null;
         tutorialSceneNumber = 5;
         if(m_tutorial != null)
         {
            element = m_tutorial.element as MovieClip;
            element.gotoAndStop(5);
            for(i = 0; i < element.numChildren; i++)
            {
               child = element.getChildAt(i) as MovieClip;
               if(Boolean(child) && child != m_window.tutorial_mc.okay_bt)
               {
                  child.gotoAndPlay(1);
               }
            }
            m_tutorial.visible = true;
         }
      }
      
      private function onReceiveRuntimeVar(result:Object) : void
      {
         this.m_isRuntimeLoaded = true;
         if(this.manager.canUserStartPlaying() && this.isLoaded())
         {
            this.m_FindMatchButton.enabled = true;
            this.m_InviteFriendButton.enabled = true;
         }
         if(result)
         {
            this.m_isDisabledByRuntime = result.isDisabled as Boolean;
         }
      }
      
      public function openGameTutorial(event:MouseEvent) : void
      {
         FarmStatsManager.count("Hand_of_Destiny","Main_UI","how_to_play");
         tintWindow();
         enableInput = false;
         this.manager.openGameTutorial();
      }
      
      private function get manager() : AFInnovationManager
      {
         return AFInnovationManager.getInstance(this.m_featureName);
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         showTutorial();
      }
      
      private function onAskClick(event:Event) : void
      {
         FarmStatsManager.count("Hand_of_Destiny","Main_UI","ask_runes");
         if(this.m_askBtn.enabled)
         {
            this.m_askBtn.enabled = false;
            this.manager.askForRunes();
            this.refreshAskButton();
         }
      }
      
      private function onBuyClick(event:Event) : void
      {
         FarmStatsManager.count("Hand_of_Destiny","Main_UI","buy_runes");
         tintWindow();
         enableInput = false;
         this.manager.openBuyWindow(this);
      }
      
      private function onCollectClick(event:Event) : void
      {
         FarmStatsManager.count("Hand_of_Destiny","Main_UI","collect_runes");
         this.manager.collectDailyRunes();
         this.updateCollectButton();
         this.updatePlayButtons();
         if(this.m_bonusMc)
         {
            this.m_bonusMc.visible = false;
         }
      }
      
      private function onRedeemClick(event:Event) : void
      {
         FarmStatsManager.count("Hand_of_Destiny","Main_UI","redeem_rewards");
         tintWindow();
         enableInput = false;
         this.manager.openRedeemWindow();
      }
      
      private function onFindGameClick(event:Event) : void
      {
         var message:String = null;
         FarmStatsManager.count("Hand_of_Destiny","Main_UI","find_game");
         if(MatchMakingManager.getInstance().isConnected())
         {
            if(this.m_isDisabledByRuntime)
            {
               message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_disabledMessage");
               UI.displayMessage(message,GenericPopup.TYPE_OK,null,"AfInnovationDisabledMsg",true);
               FarmStatsManager.count("Hand_of_Destiny","Main_UI","find_game_disabled");
            }
            else
            {
               tintWindow();
               enableInput = false;
               this.manager.openP2PGameWindow();
               this.startConnectionTimer();
               MatchMakingManager.getInstance().getMatchFromActivePool(this.onActiveMatchSuccess,this.onActiveMatchFirstFailure);
            }
            this.manager.shouldDeductRunes = true;
         }
         else
         {
            message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"zoomErrorMessage");
            UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.closeCallback,"",true);
         }
      }
      
      public function refreshAskButton() : void
      {
         var xPostTimeRemaining:int = 0;
         var timeRemaining:Array = null;
         if(this.m_askBtn)
         {
            xPostTimeRemaining = this.manager.getThrottleTimeRemaining(AFInnovationManager.FEED_NAME);
            if(xPostTimeRemaining > 0)
            {
               timeRemaining = FarmGameUtil.parseTimeLeft(xPostTimeRemaining);
               if(timeRemaining[1] !== 0 || timeRemaining[2] !== 0)
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_askBtn,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"asksnowflake_timeleft",{
                     "hrs":timeRemaining[1],
                     "min":timeRemaining[2]
                  }));
               }
               else
               {
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_askBtn,"Ask again in " + timeRemaining[3] + " seconds");
               }
            }
            else
            {
               this.m_askBtn.enabled = true;
               this.m_askBtn.detachTooltip();
            }
         }
      }
      
      private function onActiveMatchSuccess(uid:String, gameId:String) : void
      {
         if(!AFInnovationManager.getInstance().p2pWindow.gameStarted)
         {
            FarmStatsManager.count("Hand_of_Destiny","Matchmaking_Track",uid,"Active",gameId,"",this.m_currentTimeCount);
            MatchMakingManager.getInstance().setUserInactive();
            this.stopConnectionTimer();
            MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
            MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
            if(this.m_matchTimer)
            {
               this.m_matchTimer.stop();
            }
            this.manager.player2UId = uid;
            this.manager.setPlayerStatus(uid);
            this.manager.p2pWindow.initializeGameBoard(uid,gameId,this.manager.playerStatus);
         }
      }
      
      private function onActiveMatchFirstFailure() : void
      {
         MatchMakingManager.getInstance().setUserActive();
         MatchMakingManager.getInstance().addEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
         if(this.m_matchTimer != null)
         {
            this.m_matchTimer.stop();
            this.m_matchTimer = null;
         }
         this.m_matchTimer = new Timer(10000);
         this.m_timerRetries = 0;
         this.m_matchTimer.addEventListener(TimerEvent.TIMER,this.onActiveMatchTimerExpired);
         this.m_matchTimer.start();
      }
      
      private function onActiveMatchTimerExpired(event:TimerEvent) : void
      {
         ++this.m_timerRetries;
         if(this.m_timerRetries >= 3)
         {
            this.m_matchTimer.stop();
            MatchMakingManager.getInstance().getMatchFromActivePool(this.onActiveMatchSuccess,this.onActiveMatchFailure);
         }
         else
         {
            MatchMakingManager.getInstance().getMatchFromActivePool(this.onActiveMatchSuccess,null);
         }
      }
      
      private function onchatMessageReceived(e:DataEvent) : void
      {
         if(e.data.indexOf("StartGame:" + this.m_gameId) != -1 && !AFInnovationManager.getInstance().p2pWindow.gameStarted)
         {
            if(this.m_matchTimer)
            {
               this.m_matchTimer.stop();
            }
            if(this.m_startGameTimer)
            {
               this.m_startGameTimer.stop();
            }
            MatchMakingManager.getInstance().matchFound = false;
            this.stopConnectionTimer();
            MatchMakingManager.getInstance().setUserInactive();
            MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
            MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
            this.manager.player2UId = this.m_player2UID;
            this.manager.setPlayerStatus(this.m_player2UID);
            AFInnovationManager.getInstance().p2pWindow.initializeGameBoard(this.m_player2UID,this.m_gameId,this.manager.playerStatus);
         }
      }
      
      private function ongameRequestReceived(e:DataEvent) : void
      {
         var parts:Array = null;
         var uid:String = null;
         var gameId:String = null;
         if(e.data)
         {
            parts = e.data.split(",");
            uid = parts[0];
            gameId = parts[1];
            if(!AFInnovationManager.getInstance().p2pWindow.gameStarted)
            {
               MatchMakingManager.getInstance().matchFound = true;
               MatchMakingManager.getInstance().addZoomFriend(uid);
               MatchMakingManager.getInstance().sendMessage("Accepted:" + gameId,uid);
               this.m_gameId = gameId;
               this.m_player2UID = uid;
               MatchMakingManager.getInstance().addEventListener(MatchMakingManager.EVENTTYPE_CHAT,this.onchatMessageReceived);
               if(this.m_matchTimer)
               {
                  this.m_matchTimer.stop();
               }
               this.m_startGameTimer = new Timer(this.DEFAULT_STARTGAME_WAITING_PERIOD);
               this.m_startGameTimer.addEventListener(TimerEvent.TIMER,this.onStartGameTimerExpired);
               this.m_startGameTimer.start();
            }
            else
            {
               MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
               MatchMakingManager.getInstance().sendMessage("Rejected:" + gameId,uid);
            }
         }
      }
      
      private function onStartGameTimerExpired(event:TimerEvent) : void
      {
         this.m_startGameTimer.stop();
         MatchMakingManager.getInstance().matchFound = false;
         if(!this.m_movedToPPPPool)
         {
            if(this.m_matchTimer != null)
            {
               this.m_matchTimer.stop();
               this.m_matchTimer = null;
            }
            this.m_matchTimer = new Timer(5000);
            this.m_timerRetries = 0;
            this.m_matchTimer.addEventListener(TimerEvent.TIMER,this.onActiveMatchTimerExpired);
            this.m_matchTimer.start();
         }
      }
      
      private function onActiveMatchFailure() : void
      {
         if(!AFInnovationManager.getInstance().p2pWindow.gameStarted)
         {
            this.m_movedToPPPPool = true;
            MatchMakingManager.getInstance().setUserInactive();
            MatchMakingManager.getInstance().getMatchFromOnlinePool(this.onOnlineMatchSuccess,this.onOnlineMatchFailure);
         }
      }
      
      private function onActiveMatchRetryFailure() : void
      {
         MatchMakingManager.getInstance().addEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
      }
      
      private function onOnlineMatchSuccess(uid:String, gameId:String) : void
      {
         FarmStatsManager.count("Hand_of_Destiny","Matchmaking_Track",uid,"PPP",gameId,"",this.m_currentTimeCount);
         MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
         if(!AFInnovationManager.getInstance().p2pWindow.gameStarted)
         {
            this.stopConnectionTimer();
            this.manager.player2UId = uid;
            this.manager.setPlayerStatus(uid);
            AFInnovationManager.getInstance().p2pWindow.initializeGameBoard(uid,gameId,this.manager.playerStatus);
         }
      }
      
      private function onOnlineMatchFailure() : void
      {
         FarmStatsManager.count("Hand_of_Destiny","Matchmaking_Track","match_notfound");
         MatchMakingManager.getInstance().removeEventListener(MatchMakingManager.EVENTTYPE_GAMEREQUEST,this.ongameRequestReceived);
         this.showConnectionFailMessage();
      }
      
      private function startConnectionTimer() : void
      {
         this.m_currentTimeCount = 0;
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(event:TimerEvent) : void
      {
         this.refreshConnectionTimerText();
      }
      
      private function refreshConnectionTimerText() : void
      {
         var timerText:String = null;
         if(this.m_currentTimeCount > this.DEFAULT_CONNECTION_WAITING_PERIOD)
         {
            this.onP2ConnectionTimerExpired();
         }
         else
         {
            timerText = HUD.getformattedTimeLeft(this.DEFAULT_CONNECTION_WAITING_PERIOD - this.m_currentTimeCount);
            AFInnovationManager.getInstance().p2pWindow.setOverlayText(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_FindGameText1"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_FindGameText2",{"timer":timerText}));
            this.m_currentTimeCount += 1;
         }
      }
      
      public function onP2ConnectionTimerExpired() : void
      {
         this.showConnectionFailMessage();
      }
      
      public function showConnectionFailMessage() : void
      {
         this.stopConnectionTimer();
         AFInnovationManager.getInstance().p2pWindow.setOverlayText(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_NoGameFoundText1"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_NoGameFoundText2"),ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Okay"),AFInnovationManager.getInstance().p2pWindow.closeWindowAndShowMainUI);
      }
      
      private function stopConnectionTimer() : void
      {
         if(this.m_timer)
         {
            this.m_currentTimeCount = 0;
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      private function closeCallback(e:GenericPopupEvent) : void
      {
         if(e.button == GenericPopup.ACCEPT)
         {
            FarmGameUtil.redirectHomeNoError();
         }
      }
      
      private function onInviteFriendClick(event:Event) : void
      {
         var message:String = null;
         FarmStatsManager.count("Hand_of_Destiny","Main_UI","invite_friend");
         if(this.m_isDisabledByRuntime)
         {
            message = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_disabledMessage");
            UI.displayMessage(message,GenericPopup.TYPE_OK,null,"AfInnovationDisabledMsg",true);
            FarmStatsManager.count("Hand_of_Destiny","Main_UI","invite_friend_disabled");
         }
         else
         {
            UI.displayPopup(new MFSSendGameRequest(this.m_featureName,"",null,this.manager.mfsDialogURL),false);
            this.manager.shouldDeductRunes = true;
            this.close();
         }
      }
      
      private function onPlaySoloClick(event:Event) : void
      {
         FarmStatsManager.count("Hand_of_Destiny","Main_UI","play_solo");
         tintWindow();
         enableInput = false;
         this.manager.shouldDeductRunes = true;
         this.manager.openPlaySoloWindow();
      }
      
      private function onUnlockClick(event:Event) : void
      {
         FarmStatsManager.count("Hand_of_Destiny","Main_UI","unlock_tiles");
         this.close();
         if(Global.worldManager.currentWorldType != WorldsConstants.WORLD_ID_ANGLOFRENCH)
         {
            Global.hud.travelNameDisplay.showNewTravelWindow();
         }
         else
         {
            this.manager.highlightTiles();
         }
      }
      
      public function updateCollectButton() : void
      {
         var key:String = null;
         if(this.manager.canCollectForTheDay() == false)
         {
            this.m_CollectButton.enabled = false;
            this.m_CollectButton.callback = null;
            key = this.m_featureName + AFInnovationManager.COLLECT_TIME_KEY;
            FarmGameUtil.disableButtonAndShowTooltip(this.m_CollectButton,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_CollectHoverText",{"time":HUD.getformattedTimeLeft(this.manager.getTimeLeft(key))}));
         }
         else
         {
            this.m_CollectButton.enabled = true;
            this.m_CollectButton.callback = this.onCollectClick;
            this.m_CollectButton.detachTooltip();
         }
         this.m_runesCount.text = "x" + this.manager.getConsumableCount().toString();
      }
      
      public function updatePlayButtons() : void
      {
         if(this.manager.canUserStartPlaying() == false)
         {
            this.m_FindMatchButton.enabled = false;
            this.m_PlaySoloButton.enabled = false;
            this.m_InviteFriendButton.enabled = false;
         }
         else
         {
            this.m_FindMatchButton.enabled = true;
            this.m_PlaySoloButton.enabled = true;
            this.m_InviteFriendButton.enabled = true;
         }
      }
      
      public function updateCurrency() : void
      {
         this.m_currencyCount_tf.text = "x" + this.manager.getCurrencyCount().toString();
      }
      
      override public function refreshWindow() : void
      {
         this.updatePlayButtons();
         this.updateCollectButton();
         this.updateCurrency();
         this.refreshAskButton();
      }
      
      override public function untintWindow() : void
      {
         this.refreshWindow();
         super.untintWindow();
      }
      
      override public function close() : void
      {
         FarmStatsManager.count("Hand_of_Destiny","Main_UI","close_window");
         this.manager.mainWindow = null;
         super.close();
      }
   }
}

