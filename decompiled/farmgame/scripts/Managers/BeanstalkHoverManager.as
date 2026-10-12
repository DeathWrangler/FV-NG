package Managers
{
   import Classes.Constants.Experiments;
   import Classes.EverGrowingHarvestableBuilding;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Transactions.TGenericTransaction;
   import Widgets.Windows.BeanstalkHover;
   import com.greensock.TweenLite;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class BeanstalkHoverManager
   {
      
      public static const BEANSTALK_STATS_KINGDOM:String = "magic_beanstalk";
      
      private static const HOVER_OUT_MS_DELAY_TIME:Number = 1 * FarmGameUtil.NUM_MSECS_IN_SECOND;
      
      private const VIEWPORT_Y_BUFFER:int = 50;
      
      private const BEANSTALK_HEIGHT_RATIOS:Array = new Array(0.25,0.5,0.7,0.75,0.85,1);
      
      private const LEADERBOARD_NAME:String = "ALLTIME_beanstalk_001";
      
      private const DEFAULT_REGROW_PRICE:int = 2;
      
      public var m_beanstalk:EverGrowingHarvestableBuilding = null;
      
      private var m_status:BeanstalkHover = null;
      
      private var m_friend:BeanstalkHover = null;
      
      private var m_attached:Boolean = false;
      
      private const HOVER_FADE_OUT_TIME:Number = 0.75;
      
      private var hideTimer:Timer = null;
      
      private var m_viewPortRefreshIndex:int = 0;
      
      private var m_beanstalkPos:Point = null;
      
      private var m_friendsInitialized:Boolean = false;
      
      private var m_tweenFriendOut:TweenLite = null;
      
      private var m_tweenStatusOut:TweenLite = null;
      
      private var m_pricingVariants:Array = new Array(2,2,1,3);
      
      public function BeanstalkHoverManager(beanstalk:EverGrowingHarvestableBuilding)
      {
         super();
         this.m_beanstalk = beanstalk;
         this.m_attached = false;
         this.m_status = new BeanstalkHover(BeanstalkHover.TYPE_STATUS,this);
         this.m_friend = new BeanstalkHover(BeanstalkHover.TYPE_FRIEND,this);
         this.hideTimer = new Timer(HOVER_OUT_MS_DELAY_TIME,1);
      }
      
      protected function alignWindowOrigin() : void
      {
         if(this.m_attached)
         {
            this.m_beanstalkPos = this.m_beanstalk.getDisplayObject().localToGlobal(new Point(0,0));
            this.updateHovers();
         }
      }
      
      public function showHovers() : void
      {
         this.hideTimer.reset();
         if(this.m_tweenFriendOut)
         {
            this.m_tweenFriendOut.kill();
         }
         if(this.m_tweenStatusOut)
         {
            this.m_tweenStatusOut.kill();
         }
         this.m_friend.alpha = 1;
         this.m_status.alpha = 1;
         if(!this.m_attached)
         {
            Global.stage.addChild(this.m_status);
            Global.stage.addChild(this.m_friend);
            this.m_attached = true;
            this.m_viewPortRefreshIndex = GlobalEngine.viewport.addRefreshCallback(this.alignWindowOrigin);
         }
         this.m_friend.visible = true;
         this.m_status.visible = true;
         this.updateHovers();
      }
      
      public function hideHovers() : void
      {
         this.hideTimer.addEventListener(TimerEvent.TIMER,this.doFadeOut);
         this.hideTimer.start();
      }
      
      public function doFadeOut(event:TimerEvent) : void
      {
         this.m_tweenFriendOut = TweenLite.to(this.m_friend,this.HOVER_FADE_OUT_TIME,{
            "alpha":0,
            "onComplete":this.doHide
         });
         this.m_tweenStatusOut = TweenLite.to(this.m_status,this.HOVER_FADE_OUT_TIME,{
            "alpha":0,
            "onComplete":this.doHide
         });
      }
      
      private function doHide() : void
      {
         if(this.m_attached)
         {
            Global.stage.removeChild(this.m_status);
            Global.stage.removeChild(this.m_friend);
            GlobalEngine.viewport.removeRefreshCallback(this.m_viewPortRefreshIndex);
         }
         this.m_attached = false;
         this.m_friend.visible = false;
         this.m_status.visible = false;
         this.hideTimer.removeEventListener(TimerEvent.TIMER,this.doHide);
      }
      
      private function updateHovers() : void
      {
         var friends:Array = null;
         var highscore:int = this.m_beanstalk.maxHeight;
         var nextGoal:int = this.m_beanstalk.getNextGoalHeight();
         var currentHeight:int = this.m_beanstalk.totalHeight;
         var hadWithered:Boolean = this.m_beanstalk.hadWithered;
         var ratioIdx:int = this.m_beanstalk.getCurrentGoalLevel();
         var beanstalkDisplayHeight:int = this.m_beanstalk.getDisplayRect().height * this.BEANSTALK_HEIGHT_RATIOS[ratioIdx];
         var screenHeight:int = this.m_beanstalk.getDisplayObject().localToGlobal(new Point(0,0)).y + this.m_beanstalk.getDisplayRect().height - this.m_friend.height - this.VIEWPORT_Y_BUFFER;
         if(screenHeight < 0)
         {
            screenHeight = 0;
         }
         var trueBeanstalkHeight:int = Math.min(screenHeight,beanstalkDisplayHeight);
         var yOffset:int = this.m_beanstalk.getDisplayRect().height - trueBeanstalkHeight;
         var xOffset:int = this.m_beanstalk.getDisplayRect().width;
         this.m_beanstalkPos = this.m_beanstalk.getDisplayObject().localToGlobal(new Point(0,0));
         this.m_status.update(this.m_beanstalkPos,yOffset,xOffset);
         var shouldShowWitherRetore:Boolean = hadWithered && this.m_beanstalk.totalHeight != this.m_beanstalk.witherRestoreHeight;
         this.m_status.updateStatus(currentHeight,nextGoal,highscore,shouldShowWitherRetore);
         if(!this.m_friendsInitialized)
         {
            if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_EVERGROWING_CROP_LEADERBOARD) == 2)
            {
               if(LeaderboardManager.initialized)
               {
                  LeaderboardManager.initialize();
               }
               friends = LeaderboardManager.getFriendList(this.LEADERBOARD_NAME);
               this.m_friendsInitialized = this.m_friend.updateFriend(friends);
            }
            else
            {
               this.m_friend.updateFriend(null);
            }
         }
         this.m_friend.update(this.m_beanstalkPos,yOffset - this.m_friend.height,xOffset / 2);
      }
      
      public function showRegrowConfirmation() : void
      {
         UI.displayMessage(ZLocUtils.t("Dialogs","Retention_Beanstalk_RegrowConfirmation",{
            "height":this.getRegrowHeight(),
            "amount":this.getRegrowPrice()
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.regrowCallback,"EverGrowingRegrow",true);
      }
      
      private function regrowCallback(event:GenericPopupEvent) : void
      {
         var price:int = 0;
         if(event.button == GenericPopup.ACCEPT)
         {
            price = this.getRegrowPrice();
            if(price > 0 && Global.player.canBuyCash(price))
            {
               this.regrow();
            }
         }
      }
      
      public function regrow() : void
      {
         if(Global.player.canBuyCash(this.getRegrowPrice()))
         {
            Global.player.cash -= this.getRegrowPrice();
            this.m_beanstalk.totalHeight = this.getRegrowHeight();
            this.m_beanstalk.hadWithered = false;
            TransactionManager.addTransaction(new TGenericTransaction("EverGrowingUtilityService","performRegrow",null,["ever_growing_beanstalk"]));
         }
      }
      
      public function getRegrowPrice() : int
      {
         var heightDifference:int = this.m_beanstalk.witherRestoreHeight - this.m_beanstalk.totalHeight;
         var numSteps:Number = heightDifference / this.m_beanstalk.growthStep;
         var priceVariant:int = this.getRegrowPriceMultiplier();
         return int(Math.ceil(numSteps * priceVariant));
      }
      
      public function getRegrowHeight() : int
      {
         return this.m_beanstalk.witherRestoreHeight;
      }
      
      private function getRegrowPriceMultiplier() : int
      {
         var priceMultiplier:int = this.DEFAULT_REGROW_PRICE;
         var priceExperimentVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_EVERGROWING_CROP_PRICING_VARIANT);
         if(this.m_pricingVariants[priceExperimentVariant])
         {
            priceMultiplier = int(this.m_pricingVariants[priceExperimentVariant]);
         }
         return priceMultiplier;
      }
   }
}

