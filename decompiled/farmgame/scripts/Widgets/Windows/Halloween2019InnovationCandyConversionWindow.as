package Widgets.Windows
{
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.OrderBoard.Halloween2019InnovationManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Halloween2019InnovationDiscoveredRecipeFrame;
   import Widgets.Frames.Halloween2019InnovationExperimentRecipeFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class Halloween2019InnovationCandyConversionWindow extends FarmWindow
   {
      
      private static const TITLE_TF:String = "title_tf";
      
      private static const ALL_DISC_RECIPE_MC:String = "all_disc_recipe_mc";
      
      private static const ALL_TRY_RECIPE_MC:String = "all_try_recipe_mc";
      
      private static const COUNTDOWN_TIMER_MC:String = "countdown_timer_mc";
      
      private static const COUNTDOWN_TIMER_TF:String = "countdown_timer_tf";
      
      private static const COUNTDOWN_TEXT_TF:String = "countdown_text_tf";
      
      private static const BUY_BT:String = "buy_bt";
      
      private static const TRY_SKIP_COST:int = 6;
      
      private static const DEFAULT_TRY_TIME:int = 14400;
      
      private var m_featureName:String;
      
      private var m_allDiscRecipeMc:Halloween2019InnovationDiscoveredRecipeFrame;
      
      private var m_allTryRecipeMc:Halloween2019InnovationExperimentRecipeFrame;
      
      private var m_countdownTimerMc:MovieClip;
      
      private var m_countdownTimerTf:ZwTextField;
      
      private var m_countdownTextTf:ZwTextField;
      
      private var m_skipBt:FarmAnimatedCashButton;
      
      public function Halloween2019InnovationCandyConversionWindow(featureName:String, assetPath:String = "")
      {
         this.m_featureName = featureName;
         super(assetPath);
      }
      
      private static function get manager() : Halloween2019InnovationManager
      {
         return Halloween2019InnovationManager.getInstance();
      }
      
      public static function tryFrameTiming() : int
      {
         return manager.getTryTimeLeftUtil();
      }
      
      public static function tryFrameVisibility() : Boolean
      {
         return tryFrameTiming() <= DEFAULT_TRY_TIME;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty(TITLE_TF))
         {
            addWidget(new ZwTextField(m_window[TITLE_TF],"Recipe Book\n"));
            m_window[TITLE_TF].visible = true;
         }
         if(m_window.hasOwnProperty("subtext_tf"))
         {
            addWidget(new ZwTextField(m_window["subtext_tf"],"Discover recipes for special candies for this week\'s trick-or-treaters."));
            m_window["subtext_tf"].visible = true;
         }
         if(m_window.hasOwnProperty(ALL_TRY_RECIPE_MC))
         {
            this.m_allTryRecipeMc = new Halloween2019InnovationExperimentRecipeFrame(m_window["all_try_recipe_mc"],this,this.m_featureName);
         }
      }
      
      private function onClickSkipButton(event:Event) : void
      {
         var confirmationText:String = ZLocUtils.t("Dialogs","CandyTry_CashBuyConfirmation",{"price":TRY_SKIP_COST});
         if(UI.displayMessage(confirmationText,GenericPopup.TYPE_ACCEPTCANCEL,this.onAcceptSkipConfirmation,"farmAnimatedCashConfirmation",true,true))
         {
            this.m_skipBt.enabled = false;
            this.tintWindow();
            this.enableInput = false;
         }
      }
      
      private function onAcceptSkipConfirmation(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            manager.onTryBuyBT(TRY_SKIP_COST);
         }
         else
         {
            this.m_skipBt.enabled = true;
            this.untintWindow();
            this.enableInput = true;
         }
      }
      
      override public function close() : void
      {
         if(manager.mainWindow)
         {
            manager.mainWindow.untintWindow();
            manager.mainWindow.enableInput = true;
            manager.mainWindow.refreshStations();
            manager.mainWindow.visible = true;
         }
         super.close();
      }
      
      override public function refreshWindow() : void
      {
         this.m_allTryRecipeMc.refresh();
         super.refreshWindow();
      }
      
      public function refreshTimer() : void
      {
         this.m_countdownTimerMc.visible = false;
         this.m_countdownTimerTf.visible = false;
      }
   }
}

