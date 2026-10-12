package Widgets.Windows.Subscriptions
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Subscriptions.SubscriptionsPriceTable;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class SubscriptionsTutorialWindow extends FarmWindow
   {
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_Subscriptions_whatis.swf";
      
      private var m_priceTable:SubscriptionsPriceTable;
      
      public function SubscriptionsTutorialWindow()
      {
         super(ASSET_PATH);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         addWidget(new ZwTextField(m_window.default_tf,ZLocUtils.t("Dialogs","Subscriptions_Tutorial_Body")));
         addWidget(new FarmAnimatedTextButton(m_window.signUp_bt,ZLocUtils.t("Dialogs","Okay"),onClose));
         addWidget(this.m_priceTable = new SubscriptionsPriceTable(m_window.tables_mc,this.howDoesThisWorkClick),false);
         addWidget(new ZwTextField(this.m_priceTable.element.generic_tf,ZLocUtils.t("Dialogs","Subscriptions_Table_Header")));
         if(m_window.hasOwnProperty("details_bt"))
         {
            addWidget(new FarmAnimatedTextButton(m_window.details_bt,ZLocUtils.t("Dialogs","Subscriptions_Tutorial_SeeDetails"),this.howDoesThisWorkClick,true,true));
         }
      }
      
      private function howDoesThisWorkClick(event:Event) : void
      {
         this.m_priceTable.visible = !this.m_priceTable.visible;
      }
   }
}

