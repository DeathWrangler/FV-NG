package Widgets.Windows
{
   import Classes.MultiRewardTreasurePayerLandBundleConstructionBuilding;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Managers.IsraelInnovationManager;
   import Managers.ItemFinderManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class IsraelLandBundleWindow extends FarmWindow
   {
      
      private static const OPEN_UI_DELAY:int = 3200;
      
      private var m_timer:Timer;
      
      private var m_item:Object;
      
      private var m_featureName:String = null;
      
      private var WINDOW_PATH:String = "assets/dialogs/israel/landbundle/FV_motd_xis_LandBundle.swf";
      
      private var m_windowCloseButton:FarmButton = null;
      
      public function IsraelLandBundleWindow(featureName:String)
      {
         this.m_featureName = featureName;
         super(this.WINDOW_PATH);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(Boolean(m_window) && Boolean(m_window.mainWindow))
         {
            addWidget(new ZwBaseWidget(m_window.mainWindow));
            addWidget(new ZwTextField(m_window["mainWindow"]["body_tf"],"Get 4 tiles at a discount. Hurry! Offer lasts till Sep 27th!"));
            addWidget(new ZwTextField(m_window["mainWindow"]["title_tf"],"Oasis Row"));
            addWidget(new ZwTextField(m_window["mainWindow"]["body2_tf"],"Get 20 Farm Off Chips free. Use them to redeem cool rewards on the Great Farm-Off"));
            addWidget(new FarmAnimatedTextButton(m_window["mainWindow"]["accept_bt"],"Show me!",this.onAccept));
            this.m_windowCloseButton = addWidget(new FarmButton(m_window.mainWindow.close_bt,this.onClose)) as FarmButton;
            UI.stopPopups(true);
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         UI.stopPopups(false);
         this.manager.showMainUI();
         close();
      }
      
      protected function onAccept(event:MouseEvent) : void
      {
         close();
         UI.stopPopups(false);
         this.manager.closeMainWindow();
         ItemFinderManager.getInstance().highlightMultipleWorldItems(["xis_rubbletreasure_payer25","xis_rubbletreasure_payer26","xis_rubbletreasure_payer27","xis_rubbletreasure_payer28"]);
         this.m_item = Global.world.getObjectsByName("xis_rubbletreasure_payer25")[0];
         this.m_timer = new Timer(OPEN_UI_DELAY,1);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.showUI);
         this.m_timer.start();
         InputManager.disableInput();
         UI.stopPopups(true);
      }
      
      private function get manager() : IsraelInnovationManager
      {
         return IsraelInnovationManager.getInstance(this.m_featureName);
      }
      
      private function showUI(event:Event = null) : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.showUI);
         }
         InputManager.enableInput();
         UI.stopPopups(false);
         if(this.m_item is MultiRewardTreasurePayerLandBundleConstructionBuilding)
         {
            (this.m_item as MultiRewardTreasurePayerLandBundleConstructionBuilding).onClick();
         }
      }
      
      override protected function release() : void
      {
         this.m_windowCloseButton = null;
         super.release();
      }
   }
}

