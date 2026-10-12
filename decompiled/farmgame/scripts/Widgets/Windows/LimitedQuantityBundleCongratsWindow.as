package Widgets.Windows
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.events.Event;
   
   public class LimitedQuantityBundleCongratsWindow extends FarmWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_LQBundle_Oasis_Congrats.swf";
      
      private var m_itemName:String = "pkg_oasis_bundle";
      
      private var m_worldName:String = "farm";
      
      public function LimitedQuantityBundleCongratsWindow(assetPath:String, itemName:String, worldName:String)
      {
         super(assetPath);
         this.m_itemName = itemName;
         this.m_worldName = worldName;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(Boolean(m_window) && Boolean(m_window.accept_bt))
         {
            addWidget(new FarmAnimatedTextButton(m_window.accept_bt,"Thanks!",this.onClose));
            m_window.accept_bt.enabled = true;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.onClose(event);
         Global.worldManager.swapFarm(this.m_worldName,false);
      }
   }
}

