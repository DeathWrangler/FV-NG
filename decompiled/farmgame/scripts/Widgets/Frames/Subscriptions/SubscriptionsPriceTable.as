package Widgets.Frames.Subscriptions
{
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Subscriptions.SubscriptionsMainWindow;
   import flash.display.DisplayObject;
   
   public class SubscriptionsPriceTable extends ZwFrame
   {
      
      public function SubscriptionsPriceTable(element:DisplayObject, callback:Function = null)
      {
         var packageFrame:ZwFrame = null;
         super(element);
         var subscriptionsData:Array = SubscriptionsMainWindow.getSubscriptionData();
         var doneButton:FarmAnimatedTextButton = new FarmAnimatedTextButton(m_element.done_bt,ZLocUtils.t("Dialogs","Okay"),callback);
         addWidget(doneButton);
         var i:int = 0;
         while(i < subscriptionsData.length && m_element["Slot_" + i + "_mc"] != null)
         {
            packageFrame = new ZwFrame(m_element["Slot_" + i + "_mc"]);
            packageFrame.addWidget(new ZwBaseWidget(m_element["Slot_" + i + "_mc"].deal_available_mc));
            packageFrame.addWidget(new ZwTextField(m_element["Slot_" + i + "_mc"].deal_available_mc.fc_tf,String(subscriptionsData[i].amount)));
            packageFrame.addWidget(new ZwTextField(m_element["Slot_" + i + "_mc"].deal_available_mc.cost_tf,Utilities.formatNumber(subscriptionsData[i].tradingCost)));
            packageFrame.addWidget(new ZwTextField(m_element["Slot_" + i + "_mc"].deal_available_mc.description_tf,ZLocUtils.t("Dialogs","Subscriptions_MOTD_Active_For")));
            addWidget(packageFrame);
            i++;
         }
      }
   }
}

