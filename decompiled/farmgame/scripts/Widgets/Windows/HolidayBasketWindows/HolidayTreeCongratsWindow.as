package Widgets.Windows.HolidayBasketWindows
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.events.MouseEvent;
   
   public class HolidayTreeCongratsWindow extends FarmWindow
   {
      
      private var m_item:FarmItem = null;
      
      private var m_okayClickCallback:Function = null;
      
      private var m_sendItemLimit:int = 0;
      
      public function HolidayTreeCongratsWindow(item:FarmItem, okayClickCallback:Function, sendItemLimit:int)
      {
         super("assets/dialogs/FV_HolidayTree_Congrats.swf");
         this.m_item = item;
         this.m_okayClickCallback = okayClickCallback;
         this.m_sendItemLimit = sendItemLimit;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Dialogs","holidaytree2010_CongratulationsTitle")));
         addWidget(new ZwTextField(m_window.desc_tf,ZLocUtils.t("Dialogs","holidaytree2010_CongratulationsMessage",{
            "item":ZLocUtils.tk_pk(this.m_item.friendlyName),
            "quantity":this.m_sendItemLimit
         })));
         addWidget(new FarmAnimatedTextButton(m_window.okay_bt,ZLocUtils.t("Dialogs","holidaytree2010_CongratulationsOkay"),this.onOkayClick));
         addWidget(new FarmIcon(m_window.icon_mc,this.m_item.icon));
      }
      
      private function onOkayClick(event:MouseEvent) : void
      {
         close();
         if(this.m_okayClickCallback != null)
         {
            this.m_okayClickCallback();
         }
      }
   }
}

