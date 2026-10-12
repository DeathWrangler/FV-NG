package Widgets.Windows.DecoPoints
{
   import Classes.Constants.WorldsConstants;
   import Classes.Friend;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.MarketEvent;
   import Managers.DecoPointsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class DecoPointsMainWindow extends FarmWindow
   {
      
      private static const PHOTO_CONTEST_TOP_PHOTOS_ENABLED:String = "PHOTO_CONTEST_TOP_PHOTOS_ENABLED";
      
      private static const PHOTO_CONTEST_GALLERY_ENABLED:String = "PHOTO_CONTEST_GALLERY_ENABLED";
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_DecoPoints.swf";
      
      private static const DP_MAIN_WINDOW_FEATURE_FLAG:String = "DPMainWindowOpen";
      
      private static const DEFAULT_TUTORIAL_MC_NAME:String = "tutorial_mc";
      
      private static const FACEPILE_ICON_SIZE:int = 30;
      
      private static const DP_ICON_SIZE:int = 50;
      
      private static const TUTORIAL_SCORE_FRAME:int = 1;
      
      private static const TUTORIAL_VOTE_FRAME:int = 10;
      
      private static const TUTORIAL_TOPPHOTOS_FRAME:int = 20;
      
      private static const ASSET_SET_DEFAULT:int = 1;
      
      private static const ASSET_SET_HALLOW:int = 1;
      
      private static const ASSET_SET_HTOWN:int = 2;
      
      private static const BAR_WIDTH:int = 276;
      
      private static const MIN_BAR_PERCENT:Number = 0.05;
      
      private var m_showWhatIsThisOnLoad:Boolean;
      
      private var m_whatsIsThis:FarmAnimatedButton;
      
      private var m_voteTab_bt:FarmAnimatedTextButton;
      
      private var m_scoreTab_bt:FarmAnimatedTextButton;
      
      private var m_topPhotosTab_bt:FarmAnimatedTextButton;
      
      private var m_scoreTab:DecoPointsScoreTab;
      
      private var m_voteTab:DecoPointsVoteTab;
      
      private var m_topPhotosTab:DecoPointsTopPhotosTab;
      
      private var m_mgr:DecoPointsManager;
      
      protected var m_tutorial:MovieClip = null;
      
      private var m_mode:String;
      
      private var m_askForVotes:Boolean = false;
      
      protected var m_accept:FarmAnimatedButton = null;
      
      private var m_facepile:ZwFrame = null;
      
      private var m_UILoaded:Boolean = false;
      
      private var m_assetSet:int;
      
      public function DecoPointsMainWindow(mode:String = "", askForVotes:Boolean = false)
      {
         super(ASSET_PATH);
         switch(mode)
         {
            case DecoPointsManager.MODE_VOTE:
            case DecoPointsManager.MODE_TOPPHOTOS:
            case DecoPointsManager.MODE_SCORE:
               this.m_mode = mode;
               break;
            default:
               this.m_mode = DecoPointsManager.MODE_SCORE;
         }
         this.m_askForVotes = askForVotes;
         this.determineAssetSet();
      }
      
      private function determineAssetSet() : void
      {
         var worldType:String = Global.worldManager.currentWorldType;
         switch(worldType)
         {
            case WorldsConstants.WORLD_ID_HALLOW:
               this.m_assetSet = ASSET_SET_HALLOW;
               break;
            case WorldsConstants.WORLD_ID_HTOWN:
               this.m_assetSet = ASSET_SET_HTOWN;
               break;
            default:
               this.m_assetSet = ASSET_SET_DEFAULT;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,"",DecoPointsManager.DECOPOINTS_DIALOG,DecoPointsManager.DECOPOINTS_DIALOG_CANCEL,this.m_mode);
         super.onClose(event);
      }
      
      public function onDataLoaded() : void
      {
         this.initOnLoad(this.m_mode);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var background:ZwBaseWidget = null;
         var score:ZwBaseWidget = null;
         var deco:ZwBaseWidget = null;
         var frame:ZwBaseWidget = null;
         super.onLoadComplete(event);
         this.m_mgr = DecoPointsManager.instance;
         var tutorialMCName:String = "tutorial_" + Global.worldManager.currentWorldType + "_mc";
         if(!m_window.hasOwnProperty(tutorialMCName))
         {
            tutorialMCName = DEFAULT_TUTORIAL_MC_NAME;
         }
         if(m_window[tutorialMCName])
         {
            this.m_tutorial = m_window[tutorialMCName] as MovieClip;
            if(Boolean(m_window[tutorialMCName]) && Boolean(m_window[tutorialMCName].accept_bt))
            {
               this.m_accept = new FarmAnimatedButton(this.m_tutorial.accept_bt,this.onAcceptTutorial) as FarmAnimatedButton;
            }
            this.m_tutorial.visible = false;
         }
         if(m_window.whatisthis_mc)
         {
            this.m_whatsIsThis = new FarmAnimatedButton(m_window.whatisthis_mc,this.onWhatIsThisClick) as FarmAnimatedButton;
            this.m_whatsIsThis.visible = true;
         }
         var meterName:String = "meter_" + this.m_assetSet + "_mc";
         if(Boolean(m_window.progressBar_mc) && Boolean(m_window[meterName]))
         {
            addWidget(new ZwBaseWidget(m_window.progressBar_mc),true) as ZwBaseWidget;
            m_window[meterName].width = this.calculateWorldScoreMeterBarWidth();
            m_window[meterName].visible = true;
         }
         if(m_window.meterTitle_tf)
         {
            addWidget(new FarmTextField(m_window.meterTitle_tf,ZLocUtils.t("Dialogs",Global.worldManager.currentWorldType + "DPBarTitle")));
         }
         if(m_window.dpLevel_tf)
         {
            addWidget(new FarmTextField(m_window.dpLevel_tf,String(Global.player.currentWorldLevel)),true) as FarmTextField;
         }
         if(m_window.background_mc)
         {
            background = addWidget(new ZwBaseWidget(m_window.background_mc),true) as ZwBaseWidget;
            (background.element as MovieClip).gotoAndStop(this.m_assetSet);
         }
         if(m_window.worldScoreIcon_mc)
         {
            score = addWidget(new ZwBaseWidget(m_window.worldScoreIcon_mc),true) as ZwBaseWidget;
            (score.element as MovieClip).gotoAndStop(this.m_assetSet);
         }
         if(m_window.deco_mc)
         {
            deco = addWidget(new ZwBaseWidget(m_window.deco_mc),true) as ZwBaseWidget;
            (deco.element as MovieClip).gotoAndStop(this.m_assetSet);
         }
         if(m_window.frame_mc)
         {
            frame = addWidget(new ZwBaseWidget(m_window.frame_mc),true) as ZwBaseWidget;
            (frame.element as MovieClip).gotoAndStop(this.m_assetSet);
         }
         if(m_window.voteTab_bt)
         {
            this.m_voteTab_bt = addWidget(new FarmAnimatedTextButton(m_window.voteTab_bt,"Vote",this.onPressVoteTab)) as FarmAnimatedTextButton;
         }
         if(m_window.scoreTab_bt)
         {
            this.m_scoreTab_bt = addWidget(new FarmAnimatedTextButton(m_window.scoreTab_bt,"Your Score",this.onPressScoreTab)) as FarmAnimatedTextButton;
         }
         if(m_window.topPhotoTab_bt)
         {
            this.m_topPhotosTab_bt = addWidget(new FarmAnimatedTextButton(m_window.topPhotoTab_bt,"Top Photos",this.onPressTopPhotosTab)) as FarmAnimatedTextButton;
         }
         if(m_window.score_mc)
         {
            this.m_scoreTab = addWidget(new DecoPointsScoreTab(m_window.score_mc,this.m_mgr,this),false) as DecoPointsScoreTab;
         }
         if(m_window.vote_mc)
         {
            this.m_voteTab = addWidget(new DecoPointsVoteTab(m_window.vote_mc,this.m_mgr),true) as DecoPointsVoteTab;
         }
         if(m_window.topPhoto_mc)
         {
            this.m_topPhotosTab = addWidget(new DecoPointsTopPhotosTab(m_window.topPhoto_mc,this.m_mgr),false) as DecoPointsTopPhotosTab;
            this.m_topPhotosTab.addEventListener(MarketEvent.MARKET_BUY,this.closeWindowOnMiniMarketPurchase);
         }
         if(m_window.facepile_mc)
         {
            this.initFacepile();
         }
         this.m_showWhatIsThisOnLoad = this.getShowWhatIsThis();
         if(this.m_showWhatIsThisOnLoad)
         {
            this.onWhatIsThisClick(null);
         }
         this.makeATabVisible(DecoPointsManager.MODE_SCORE);
         this.m_UILoaded = true;
         this.initOnLoad(this.m_mode);
      }
      
      private function onPressVoteTab(event:MouseEvent) : void
      {
         this.enableVoteTab();
      }
      
      override protected function release() : void
      {
         this.m_topPhotosTab.removeEventListener(MarketEvent.MARKET_BUY,this.closeWindowOnMiniMarketPurchase);
         super.release();
      }
      
      private function initFacepile() : void
      {
         var friend:Friend = null;
         var background:ZwBaseWidget = null;
         var profilePic:FarmIcon = null;
         var facepileText:String = null;
         this.m_facepile = addWidget(new ZwFrame(m_window.facepile_mc)) as ZwFrame;
         var friends:Array = [];
         var tempFriends:Array = Global.friendManager.getPhotoContestFriends();
         while(tempFriends.length > 0)
         {
            friends.push(tempFriends.splice(Math.round(Math.random() * (tempFriends.length - 1)),1)[0]);
         }
         if(friends.length == 0 && this.m_facepile.element.hasOwnProperty("empty_mc"))
         {
            background = addWidget(new ZwBaseWidget(this.m_facepile.element.empty_mc),true) as ZwBaseWidget;
            (background.element as MovieClip).gotoAndStop(this.m_assetSet);
            this.m_facepile.addWidget(background);
         }
         var i:int = 0;
         while(i < friends.length && this.m_facepile.element.hasOwnProperty("fbIcon" + i.toString() + "_mc"))
         {
            profilePic = new FarmIcon(this.m_facepile.element["fbIcon" + i.toString() + "_mc"]);
            friend = friends[i];
            profilePic.loadIcon(friend.picture);
            profilePic.setIconSize(FACEPILE_ICON_SIZE,FACEPILE_ICON_SIZE);
            this.m_facepile.addWidget(profilePic);
            i++;
         }
         if(this.m_facepile.element.name_tf)
         {
            facepileText = "";
            switch(friends.length)
            {
               case 0:
                  facepileText = ZLocUtils.t("Dialogs","photocontest_facepile_empty");
                  break;
               case 1:
                  facepileText = ZLocUtils.t("Dialogs","photocontest_facepile_single",{"name":friends[0].firstName});
                  break;
               default:
                  facepileText = ZLocUtils.t("Dialogs","photocontest_facepile_others",{
                     "name":friends[0].firstName,
                     "num":friends.length - 1
                  });
            }
            this.m_facepile.addWidget(new ZwTextField(this.m_facepile.element.name_tf,facepileText));
         }
      }
      
      private function calculateWorldScoreMeterBarWidth() : int
      {
         var currLevel:int = Global.player.currentWorldLevel;
         var worldScore:int = Global.player.currentWorldScore;
         var lastRequiredScore:int = Global.worldScoreSettingsManager.getRequiredScoreForLevel(Global.worldManager.currentWorldScoreId,currLevel);
         var nextRequiredScore:int = Global.worldScoreSettingsManager.getRequiredScoreForLevel(Global.worldManager.currentWorldScoreId,currLevel + 1);
         var progressToNextLevel:int = worldScore - lastRequiredScore;
         var scoreForLevel:int = nextRequiredScore - lastRequiredScore;
         var percent:Number = progressToNextLevel / scoreForLevel;
         if(percent < MIN_BAR_PERCENT)
         {
            percent = MIN_BAR_PERCENT;
         }
         return int(BAR_WIDTH * percent);
      }
      
      private function initOnLoad(mode:String = "") : void
      {
         if(this.m_mgr.isInitialized() && this.m_UILoaded)
         {
            this.makeATabVisible(mode);
            this.m_voteTab.refreshGalleryImages();
            this.m_scoreTab.renderCurrentContestPhotoUI(this.m_askForVotes);
            this.m_topPhotosTab.populate(this.m_mgr.getTopPhotos());
         }
      }
      
      public function onGalleryLoaded() : void
      {
         this.m_voteTab.refreshGalleryImages();
      }
      
      public function makeATabVisible(mode:String = "") : void
      {
         this.m_scoreTab.visible = false;
         this.m_topPhotosTab.visible = false;
         this.m_voteTab.visible = false;
         this.m_facepile.visible = false;
         this.m_voteTab_bt.enabled = true;
         this.m_scoreTab_bt.enabled = true;
         this.m_topPhotosTab_bt.enabled = true;
         switch(mode)
         {
            case DecoPointsManager.MODE_VOTE:
               this.m_voteTab.visible = true;
               this.m_facepile.visible = true;
               this.m_voteTab_bt.enabled = false;
               this.m_mode = mode;
               break;
            case DecoPointsManager.MODE_TOPPHOTOS:
               this.m_topPhotosTab.visible = true;
               this.m_topPhotosTab_bt.enabled = false;
               this.m_mode = mode;
               break;
            default:
               this.m_scoreTab.visible = true;
               this.m_facepile.visible = true;
               this.m_scoreTab_bt.enabled = false;
               this.m_mode = DecoPointsManager.MODE_SCORE;
         }
         FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,"",DecoPointsManager.DECOPOINTS_DIALOG,DecoPointsManager.DECOPOINTS_DIALOG_VIEW,this.m_mode);
      }
      
      private function onWhatIsThisClick(event:MouseEvent) : void
      {
         if(this.m_tutorial)
         {
            this.m_tutorial.visible = true;
            switch(this.m_mode)
            {
               case DecoPointsManager.MODE_VOTE:
                  this.m_tutorial.gotoAndPlay(TUTORIAL_VOTE_FRAME);
                  break;
               case DecoPointsManager.MODE_TOPPHOTOS:
                  this.m_tutorial.gotoAndPlay(TUTORIAL_TOPPHOTOS_FRAME);
                  break;
               default:
                  this.m_tutorial.gotoAndPlay(TUTORIAL_SCORE_FRAME);
            }
            this.disableUI();
            FarmStatsManager.count(DecoPointsManager.DECOPOINTS_COUNTER,"",DecoPointsManager.DECOPOINTS_DIALOG,DecoPointsManager.DECOPOINTS_DIALOG_WHATSTHIS,this.m_mode);
         }
      }
      
      public function onAcceptTutorial(event:MouseEvent) : void
      {
         this.m_tutorial.visible = false;
         this.enableUI();
      }
      
      private function enableUI() : void
      {
         this.m_scoreTab_bt.enabled = true;
         this.m_topPhotosTab_bt.enabled = true;
         this.m_voteTab_bt.enabled = true;
         this.m_scoreTab.enabled = true;
         this.m_topPhotosTab.enabled = true;
         this.m_voteTab.enabled = true;
      }
      
      private function disableUI() : void
      {
         this.m_scoreTab_bt.enabled = false;
         this.m_topPhotosTab_bt.enabled = false;
         this.m_voteTab_bt.enabled = false;
         this.m_scoreTab.enabled = false;
         this.m_topPhotosTab.enabled = false;
         this.m_voteTab.enabled = false;
      }
      
      private function toggleFreeze(flag:Boolean = true) : void
      {
         this.m_scoreTab_bt.enabled = flag;
         this.m_voteTab_bt.enabled = flag;
         this.m_topPhotosTab_bt.enabled = flag;
         m_closeButton.enabled = flag;
      }
      
      private function onPressScoreTab(event:MouseEvent) : void
      {
         this.makeATabVisible(DecoPointsManager.MODE_SCORE);
      }
      
      private function onPressTopPhotosTab(event:MouseEvent) : void
      {
         if(Global.flashHotParams[PHOTO_CONTEST_TOP_PHOTOS_ENABLED])
         {
            this.makeATabVisible(DecoPointsManager.MODE_TOPPHOTOS);
         }
         else
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","WeeklyPhotoContest_top_photos_disabled"));
         }
      }
      
      private function getShowWhatIsThis() : Boolean
      {
         var showWhatIsThis:Boolean = false;
         if(!Global.player.getSeenFlag(DP_MAIN_WINDOW_FEATURE_FLAG))
         {
            Global.player.setSeenFlag(DP_MAIN_WINDOW_FEATURE_FLAG);
            showWhatIsThis = true;
         }
         return showWhatIsThis;
      }
      
      public function enableVoteTab() : void
      {
         if(this.m_voteTab)
         {
            if(Global.flashHotParams[PHOTO_CONTEST_GALLERY_ENABLED])
            {
               this.m_voteTab.enableVoteTab();
               this.makeATabVisible(DecoPointsManager.MODE_VOTE);
            }
            else
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","WeeklyPhotoContest_gallery_disabled"));
            }
         }
      }
      
      private function closeWindowOnMiniMarketPurchase(event:Event) : void
      {
         close();
      }
   }
}

