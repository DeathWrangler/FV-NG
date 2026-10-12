package Widgets.Frames.Market
{
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   
   public class MarketSlotItemStatFrame extends ZwFrame
   {
      
      private var m_infoTextField:ZwTextField;
      
      private var m_icon:FarmIcon;
      
      public function MarketSlotItemStatFrame(element:MovieClip)
      {
         super(element);
         this.m_infoTextField = addWidget(new ZwTextField(m_element.statInfo_tf)) as ZwTextField;
         this.m_icon = addWidget(new FarmIcon(m_element.statIcon_mc)) as FarmIcon;
      }
      
      public function set infoText(value:String) : void
      {
         this.m_infoTextField.text = value;
      }
      
      override public function release() : void
      {
         this.m_infoTextField = null;
         this.m_icon = null;
         super.release();
      }
      
      public function loadIcon(iconUrl:String) : void
      {
         this.m_icon.loadIcon(iconUrl);
      }
   }
}

