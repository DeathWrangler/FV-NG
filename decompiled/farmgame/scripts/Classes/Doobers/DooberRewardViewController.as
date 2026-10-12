package Classes.Doobers
{
   import Classes.Constants.DooberConstants;
   import Classes.util.ZLocUtils;
   import Display.FarmDynamicDialog;
   import Engine.Helpers.Vector2;
   import Engine.Helpers.Vector3;
   import Engine.IsoMath;
   import Engine.Managers.SoundManager;
   import com.troyer.widget.controller.ButtonController;
   import com.troyer.widget.event.WidgetControllerEvent;
   import com.troyer.widget.view.TextFieldView;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class DooberRewardViewController extends EventDispatcher
   {
      
      private static const PLOTS_PER_DOOBER_A_COEFFICIENT:Number = 1.73;
      
      private static const PLOTS_PER_DOOBER_B_COEFFICIENT:Number = 0.005;
      
      private static const PLOTS_PER_DOOBER_C_COEFFICIENT:Number = 0.00005;
      
      private static const PLOTS_PER_DOOBER_D_COEFFICIENT:Number = 6e-8;
      
      private static var m_queuedRewardViews:Vector.<DooberRewardViewController> = new Vector.<DooberRewardViewController>();
      
      private static var m_consolidationId:int = 0;
      
      private static var m_plotsPerDoober:int = 1;
      
      private var m_rewardViews:Vector.<DooberRewardView>;
      
      private var m_position:Vector3;
      
      private var m_loadingCount:int = 0;
      
      private var m_tweeningCount:int = 0;
      
      private var m_ftueKey:String = null;
      
      private var m_ftueDialog:FarmDynamicDialog = null;
      
      private var m_flushQueue:Boolean = false;
      
      public function DooberRewardViewController(rewardViews:Vector.<DooberRewardView>, position:Vector3)
      {
         super();
         this.m_rewardViews = rewardViews;
         if(position)
         {
            this.m_position = position;
         }
         ++m_consolidationId;
      }
      
      public static function setPlotsPerDooberAmount(numPlots:int) : void
      {
         m_plotsPerDoober = numPlots;
      }
      
      public static function willHarvestNumPlots(numPlots:int) : void
      {
         var numPlotsPerDooberAmount:int = Math.round(PLOTS_PER_DOOBER_A_COEFFICIENT + PLOTS_PER_DOOBER_B_COEFFICIENT * numPlots + PLOTS_PER_DOOBER_C_COEFFICIENT * Math.pow(numPlots,2) + PLOTS_PER_DOOBER_D_COEFFICIENT * Math.pow(numPlots,3));
         setPlotsPerDooberAmount(numPlotsPerDooberAmount);
      }
      
      public static function flushQueuedDoobers() : void
      {
         var flushView:DooberRewardViewController = null;
         if(m_queuedRewardViews.length > 0)
         {
            flushView = m_queuedRewardViews.shift();
            flushView.m_flushQueue = true;
            flushView.loadRewardViews();
         }
      }
      
      public function setFtueKey(ftueKey:String) : void
      {
         if("" != ftueKey && null != ftueKey)
         {
            this.m_ftueKey = ftueKey;
         }
      }
      
      public function loadRewardViews() : void
      {
         var controller:DooberRewardViewController = null;
         var rewardViewIndex:int = 0;
         var suppressedView:DooberRewardView = null;
         var handled:Boolean = false;
         var viewToShow:DooberRewardView = null;
         if(m_consolidationId % m_plotsPerDoober != 0 && this.m_flushQueue == false)
         {
            m_queuedRewardViews.push(this);
         }
         else
         {
            for each(controller in m_queuedRewardViews)
            {
               for each(suppressedView in controller.m_rewardViews)
               {
                  handled = false;
                  for each(viewToShow in this.m_rewardViews)
                  {
                     if(suppressedView.type == viewToShow.type)
                     {
                        viewToShow.amount += suppressedView.amount;
                        handled = true;
                        break;
                     }
                  }
                  if(handled == false)
                  {
                     this.m_rewardViews.push(suppressedView);
                  }
               }
            }
            m_queuedRewardViews = new Vector.<DooberRewardViewController>();
            this.m_loadingCount = this.m_rewardViews.length;
            for(rewardViewIndex = 0; rewardViewIndex < this.m_rewardViews.length; rewardViewIndex++)
            {
               this.m_rewardViews[rewardViewIndex].addEventListener(Event.COMPLETE,this.onRewardViewLoaded);
               this.m_rewardViews[rewardViewIndex].startLoad();
            }
         }
      }
      
      private function onRewardViewLoaded(event:Event) : void
      {
         --this.m_loadingCount;
         if(this.m_loadingCount <= 0)
         {
            this.displayDoobers();
         }
      }
      
      public function displayDoobers() : void
      {
         var xDistance:Number = NaN;
         var screen:Vector2 = IsoMath.tilePosToPixelPos(this.m_position.x,this.m_position.y,this.m_position.z);
         this.m_tweeningCount = this.m_rewardViews.length;
         var randomNumber:Number = Math.floor(Math.random() * DooberConstants.ANIM_RANDOM_SCALE_FACTOR) + DooberConstants.ANIM_RANDOM_MIN;
         for(var rewardViewIndex:int = 0; rewardViewIndex < this.m_rewardViews.length; rewardViewIndex++)
         {
            this.m_rewardViews[rewardViewIndex].x = screen.x;
            this.m_rewardViews[rewardViewIndex].y = screen.y;
            this.m_rewardViews[rewardViewIndex].scaleX = this.m_rewardViews[rewardViewIndex].scaleY = 0;
            if(rewardViewIndex % 2 == 0)
            {
               this.m_rewardViews[rewardViewIndex].rotation -= randomNumber;
               xDistance = screen.x + randomNumber;
            }
            else
            {
               xDistance = screen.x - randomNumber;
               this.m_rewardViews[rewardViewIndex].rotation += randomNumber;
               randomNumber *= DooberConstants.ANIM_RANDOM_REDUCE_FACTOR;
            }
            this.m_rewardViews[rewardViewIndex].tweenRewardView(xDistance,this.cleanupTweener);
            GlobalEngine.viewport.uiBase.addChild(this.m_rewardViews[rewardViewIndex]);
            SoundManager.addOrPlaySound(DooberConstants.ANIM_SOUND_ID,Global.getAssetURL(DooberConstants.ANIM_SOUND_PATH));
         }
      }
      
      public function cleanupTweener() : void
      {
         --this.m_tweeningCount;
         if(this.m_tweeningCount == 0)
         {
            if(this.m_ftueKey)
            {
               this.showFTUE();
            }
         }
      }
      
      private function showFTUE() : void
      {
         var title:String = ZLocUtils.t("Dialogs",this.m_ftueKey + "_title");
         var message:String = ZLocUtils.t("Dialogs",this.m_ftueKey + "_message");
         this.m_ftueDialog = FarmDynamicDialog.createDialog(this.m_ftueKey,FarmDynamicDialog);
         if(this.m_ftueDialog)
         {
            this.m_ftueDialog.setShortcutAttribute("titleText",TextFieldView.ATTRIBUTE_TEXT,title);
            this.m_ftueDialog.setShortcutAttribute("bodyText",TextFieldView.ATTRIBUTE_TEXT,message);
            this.m_ftueDialog.setShortcutAttribute("shareButton",ButtonController.ATTRIBUTE_TEXT,ZLocUtils.t("Dialogs","ShareButton"));
            this.m_ftueDialog.setShortcutListener("shareButton",WidgetControllerEvent.BUTTON_PRESSED,this.onFTUEShare);
            this.m_ftueDialog.show(true);
         }
      }
      
      private function onFTUEShare(event:Event) : void
      {
         var iconUrl:String = Global.getAssetURL(DooberConstants.DOOBER_FTUE_FEED_ICON_BASE_URL + this.m_ftueKey + ".png");
         var bundleData:Object = {"images":[{
            "href":"{SN_APP_URL}",
            "src":iconUrl
         }]};
         Global.farmSocialNetwork.publishFeedStory(this.m_ftueKey,bundleData,[],false);
         if(null != this.m_ftueDialog)
         {
            this.m_ftueDialog.destroy();
         }
      }
   }
}

