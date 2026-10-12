package Widgets.Windows.SocialRaffle
{
   import Classes.FeatureBuilding;
   import Classes.SocialRaffle.SocialRaffleConstants;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Display.UI;
   import Managers.FarmStatsManager;
   import Managers.SocialRaffleManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Frames.SocialRaffle.RaffleGameFrame;
   import Widgets.Frames.SocialRaffle.RaffleMainFrame;
   import Widgets.Windows.Carnival.CarnivalBoothWindow;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class SocialRaffleWindow extends FarmWindow
   {
      
      private static const TUTORIAL_SEEN_FLAG:String = "SocialRaffleTutorial";
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_SocialRaffle.swf";
      
      private var m_raffleMainUI:RaffleMainFrame = null;
      
      private var m_raffleGameUI:RaffleGameFrame = null;
      
      private var m_featureBuilding:FeatureBuilding = null;
      
      public function SocialRaffleWindow(featurebuilding:FeatureBuilding, modal:Boolean = true, bAddClickBlocker:Boolean = false)
      {
         super(DIALOG_ASSET,modal,bAddClickBlocker);
         this.m_featureBuilding = featurebuilding;
      }
      
      private static function calculateGCD(a:int, b:int) : int
      {
         if(b == 0)
         {
            return a;
         }
         return calculateGCD(b,a % b);
      }
      
      public static function generateOddsString(fraction:Number, winString:String = "1:1", loseString:String = "0:1") : String
      {
         var chance:int = 0;
         var gcd:int = 0;
         var result:String = "";
         if(fraction <= 0)
         {
            result = loseString;
         }
         else if(fraction >= 1)
         {
            result = winString;
         }
         else
         {
            chance = fraction * SocialRaffleConstants.MAX_RAFFLE_ODDS;
            gcd = calculateGCD(chance,SocialRaffleConstants.MAX_RAFFLE_ODDS);
            result = "" + chance / gcd + ":" + SocialRaffleConstants.MAX_RAFFLE_ODDS / gcd;
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var bStartGame:Boolean = this.shouldStartGame();
         this.m_raffleMainUI = new RaffleMainFrame(m_window.mainboard_mc,this);
         this.addWidget(this.m_raffleMainUI,!bStartGame);
         var socialRaffleManager:Object = SocialRaffleManager.getInstance();
         var raffleDataView:Object = socialRaffleManager.raffleDataView;
         if(raffleDataView != null)
         {
            this.createGameFrame(raffleDataView);
         }
         else
         {
            socialRaffleManager.initCallback = this.createGameFrame;
         }
         if(m_window.moreInfo_bt)
         {
            this.addWidget(new FarmAnimatedTextButton(m_window.moreInfo_bt,ZLocUtils.t("Dialogs","MoreInfo"),this.onMoreInfo));
         }
         this.m_window.x += 32;
         this.m_window.y += 20;
         if(raffleDataView.showPastHelperFriends)
         {
            UI.displayPopup(new SocialRaffleStatusWindow(),false);
            socialRaffleManager.setSeenRaffleHelpers();
         }
         if(!Global.player.getSeenFlag(TUTORIAL_SEEN_FLAG))
         {
            Global.player.setSeenFlag(TUTORIAL_SEEN_FLAG);
            TutorialUI.displayRaffleTutorialWindow(false,null);
         }
         FarmStatsManager.count(SocialRaffleConstants.STATS_COUNTER,"open");
      }
      
      private function onMoreInfo(event:MouseEvent) : void
      {
         this.pause();
         TutorialUI.displayRaffleTutorialWindow(false,this.unpause);
      }
      
      override public function close() : void
      {
         CarnivalBoothWindow.promoteCarnivalBooth();
         super.close();
         SocialRaffleManager.getInstance().initCallback = null;
      }
      
      public function pause() : void
      {
         if(m_window)
         {
            tintWindow();
            enableInput = false;
         }
      }
      
      public function unpause() : void
      {
         if(m_window)
         {
            untintWindow();
            enableInput = true;
         }
      }
      
      public function toggleCloseButton(disabled:Boolean) : void
      {
         var closebt:FarmButton = getWidget(m_window.close_bt) as FarmButton;
         if(closebt)
         {
            closebt.applyGrayOut = disabled;
            closebt.enabled = !disabled;
         }
      }
      
      private function shouldStartGame() : Boolean
      {
         return SocialRaffleManager.getInstance().isRaffleComplete();
      }
      
      private function createGameFrame(raffleDataView:Object) : void
      {
         var bStartGame:Boolean = false;
         if(this.m_raffleGameUI == null)
         {
            bStartGame = this.shouldStartGame();
            this.m_raffleGameUI = new RaffleGameFrame(m_window.gameboard_mc,this);
            this.addWidget(this.m_raffleGameUI,bStartGame);
            if(bStartGame)
            {
               this.m_raffleMainUI.visible = false;
               this.m_raffleGameUI.startGame(this.onGameComplete);
            }
         }
         SocialRaffleManager.getInstance().initCallback = null;
      }
      
      private function onGameComplete() : void
      {
         SocialRaffleManager.getInstance().finishRewardFlow(null,true);
         this.m_raffleMainUI.visible = true;
         this.m_raffleGameUI.visible = false;
         this.close();
      }
   }
}

