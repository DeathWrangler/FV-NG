package Widgets.Windows
{
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.events.MouseEvent;
   
   public class IconToasterWindow extends AutoCloseToasterWindow
   {
      
      protected static const ASSET_PATH:String = "assets/dialogs/FV_GenericBanner_icon.swf";
      
      protected var m_iconPath:String = "";
      
      protected var m_message:String = "";
      
      public function IconToasterWindow(iconPath:String, message:String)
      {
         super(ASSET_PATH);
         this.m_iconPath = iconPath;
         this.m_message = message;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         var mainFrame:ZwFrame = new ZwFrame(m_window.bannerad_mc);
         addWidget(mainFrame);
         mainFrame.addWidget(new ZwTextField(m_window.bannerad_mc.generic_tf,this.m_message,true));
         var farmIcon:FarmIcon = new FarmIcon(m_window.bannerad_mc.icon_mc,this.m_iconPath);
         addWidget(farmIcon);
         var zwButton:ZwButton = new ZwButton(m_window.bannerad_mc.close_bt);
         zwButton.registerEventListener(MouseEvent.CLICK,onClose);
         addWidget(zwButton);
      }
      
      override protected function getToasterHeight() : Number
      {
         var result:Number = 0;
         if(m_window)
         {
            result = this.getWidget(m_window.bannerad_mc).height;
         }
         return result;
      }
      
      override protected function getToasterOffsetY() : Number
      {
         return this.getWidget(m_window.bannerad_mc).height;
      }
   }
}

