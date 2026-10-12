package Widgets.Windows.MOTD
{
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class ChristmasCharityBundleMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private var m_itemName:String;
      
      private var m_counterMC:MovieClip;
      
      private var m_cost:int = 0;
      
      public function ChristmasCharityBundleMOTD(displayParams:Object = null)
      {
         super(displayParams);
         this.m_itemName = displayParams["item"];
         this.m_cost = displayParams["cost"];
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var timeLeft:String = null;
         super.onLoadComplete(event);
         if(this.m_counterMC == null)
         {
            this.m_counterMC = m_window.mainWindow;
            if(ObjectUtil.pathExists(this.m_counterMC,["accept_bt","cost_tf"]))
            {
               addWidget(new ZwTextField(this.m_counterMC.accept_bt.cost_tf,this.m_cost.toString()));
            }
            if(ObjectUtil.pathExists(this.m_counterMC,["accept_bt","generic_tf"]))
            {
               addWidget(new ZwTextField(this.m_counterMC.accept_bt.generic_tf,"Buy"));
            }
            if(m_window.mainWindow.hasOwnProperty("link_mc"))
            {
               addWidget(new FarmAnimatedTextButton(m_window.mainWindow.link_mc,ZLocUtils.t("Dialogs","MOTD_Christmas_Charity_Link_Text"),this.onLinkClicked));
            }
            timeLeft = this.getDaysRemaining().toString();
            if(Boolean(m_window.mainWindow.hasOwnProperty("discount_mc")) && Boolean(m_window.mainWindow.discount_mc.hasOwnProperty("timer_tf")))
            {
               m_window.mainWindow.discount_mc.timer_tf.text = ZLocUtils.t("Dialogs","MOTD_Christmas_Charity_Timer_Text",{"days":timeLeft});
            }
         }
      }
      
      private function onLinkClicked(event:Event) : void
      {
         navigateToURL(new URLRequest(ZLocUtils.t("Dialogs","MOTD_Christmas_Charity_Link_URL")),"_blank");
      }
      
      public function getDaysRemaining() : int
      {
         var endDate:Number = NaN;
         var changeFarmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
         var result:int = 7;
         if(changeFarmItem.limitedEndTime)
         {
            endDate = changeFarmItem.limitedEndTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
            result = (endDate - GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND) / FarmGameUtil.NUM_SECS_IN_DAY;
            result += 1;
         }
         return result;
      }
   }
}

