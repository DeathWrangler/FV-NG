package Widgets.Windows
{
   import Classes.MultiRewardTreasurePayerLandBundleConstructionBuilding;
   import Display.UI;
   import Engine.Managers.InputManager;
   import Managers.ItemFinderManager;
   import Managers.OrderBoard.CarribeanInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class CaribbeanLandBundleWindow extends FarmWindow
   {
      
      private static const OPEN_UI_DELAY:int = 3200;
      
      private var m_timer:Timer;
      
      private var m_item:Object;
      
      private var m_featureName:String = null;
      
      private var WINDOW_PATH:String = "assets/dialogs/caribbean/landbundle/FV_motd_xcb_LandBundle.swf";
      
      private var m_windowCloseButton:FarmButton = null;
      
      public function CaribbeanLandBundleWindow(featureName:String)
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
            addWidget(new ZwTextField(m_window["mainWindow"]["body_tf"],"Get 4 tiles at a discount. Hurry! Offer lasts till May 17th!"));
            addWidget(new ZwTextField(m_window["mainWindow"]["title_tf"],"Starfish Island"));
            addWidget(new ZwTextField(m_window["mainWindow"]["body2_tf"],"Get ahead on Fab’s Gourmet Delights with the Beach Cafe, gives double franchise Fame!"));
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
         ItemFinderManager.getInstance().highlightMultipleWorldItems(["xcb_rubbletreasure_payer20","xcb_rubbletreasure_payer21","xcb_rubbletreasure_payer22","xcb_rubbletreasure_payer23"]);
         this.m_item = Global.world.getObjectsByName("xcb_rubbletreasure_payer20")[0];
         this.m_timer = new Timer(OPEN_UI_DELAY,1);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.showUI);
         this.m_timer.start();
         InputManager.disableInput();
         UI.stopPopups(true);
      }
      
      private function get manager() : CarribeanInnovationManager
      {
         return CarribeanInnovationManager.getInstance(this.m_featureName);
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

