package Widgets.Windows
{
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   
   public class MessageIndicatorWindow extends FarmWindow
   {
      
      private const DIALOG_ASSET:String = "assets/hud/IndicatorArrows/FV_HUD_Signpost.swf";
      
      protected var m_text:String;
      
      protected var m_visibility:Boolean;
      
      public function MessageIndicatorWindow(text:String, initVisibility:Boolean = false)
      {
         super(this.DIALOG_ASSET);
         this.m_text = text;
         this.m_visibility = initVisibility;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var mainFrame:ZwFrame = new ZwFrame(m_window.signpost_mc);
         var textFrame:ZwFrame = new ZwFrame(m_window.signpost_mc);
         textFrame.addWidget(new ZwTextField(m_window.signpost_mc.generic_tf,this.m_text));
         textFrame.alpha = 100;
         mainFrame.addWidget(textFrame,true);
         addWidget(mainFrame,this.m_visibility);
      }
      
      public function showRolloverEffect(isShow:Boolean) : void
      {
         var mainFrame:ZwFrame = null;
         if(m_window)
         {
            mainFrame = getWidget(m_window.signpost_mc) as ZwFrame;
            if(mainFrame)
            {
               m_window.visible = isShow ? true : false;
               mainFrame.visible = isShow ? true : false;
            }
         }
      }
   }
}

