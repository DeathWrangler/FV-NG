package Widgets.Windows
{
   import Widgets.Buttons.FarmAnimatedTextButton;
   import flash.events.Event;
   
   public class ContingencyBuildableRewardGrantWindow extends FarmWindow
   {
      
      public function ContingencyBuildableRewardGrantWindow(assetPath:String = "", access:String = "HUD")
      {
         super(assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("accept_bt"))
            {
               addWidget(new FarmAnimatedTextButton(m_window["accept_bt"],"Okay!",this.onClose));
            }
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         super.close();
      }
   }
}

