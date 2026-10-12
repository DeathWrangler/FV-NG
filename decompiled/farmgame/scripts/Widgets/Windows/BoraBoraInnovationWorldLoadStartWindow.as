package Widgets.Windows
{
   import Managers.OrderBoard.BoraBoraInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.events.Event;
   
   public class BoraBoraInnovationWorldLoadStartWindow extends FarmWindow
   {
      
      private var m_okayBt:FarmAnimatedTextButton;
      
      private var m_featureName:String;
      
      public function BoraBoraInnovationWorldLoadStartWindow(featureName:String, windowAssetRelUrl:String)
      {
         this.m_featureName = featureName;
         super(windowAssetRelUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         this.visible = true;
         if(m_window.hasOwnProperty("title_tf"))
         {
         }
         if(m_window.hasOwnProperty("test_okay_bt"))
         {
            addWidget(this.m_okayBt = new FarmAnimatedTextButton(m_window["test_okay_bt"],"Okay",this.onOkayBt));
            this.m_okayBt.visible = true;
         }
      }
      
      private function onOkayBt(event:Event) : void
      {
         close();
         BoraBoraInnovationManager.getInstance(this.m_featureName).showMainWindow();
      }
   }
}

