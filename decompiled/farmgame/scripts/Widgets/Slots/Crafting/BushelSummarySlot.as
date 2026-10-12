package Widgets.Slots.Crafting
{
   import Classes.crafting.BushelsFoundSummary;
   import Classes.util.ZLocUtils;
   import Engine.Utilities;
   import Managers.Crafting.CraftingManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.InteractiveObject;
   
   public class BushelSummarySlot extends ZwSlotFrame
   {
      
      protected var m_data:BushelsFoundSummary = null;
      
      private var m_plusBushels:ZwFrame;
      
      private var m_plusMastery:ZwFrame;
      
      protected var m_bushelIcon:FarmIcon;
      
      protected var m_marketStallIcon:FarmIcon;
      
      protected var m_foundBushelsText:ZwTextField;
      
      protected var m_foundMasteryBushelsText:ZwTextField;
      
      protected var m_stallText:ZwTextField;
      
      protected var m_stallMasteryText:ZwTextField;
      
      private var m_bushelSummaryData:BushelsFoundSummary;
      
      private var m_shareButton:FarmAnimatedButton;
      
      public function BushelSummarySlot(element:DisplayObject, shareButton:FarmAnimatedButton)
      {
         this.m_shareButton = shareButton;
         super(element);
         this.m_bushelIcon = new FarmIcon(m_element.bushelIcon_mc);
         addWidget(this.m_bushelIcon);
         this.m_marketStallIcon = new FarmIcon(m_element.stallIcon_mc);
         addWidget(this.m_marketStallIcon);
         this.m_foundBushelsText = new ZwTextField(m_element.bushel_tf);
         addWidget(this.m_foundBushelsText);
         this.m_foundMasteryBushelsText = new ZwTextField(m_element.bushelPlus_tf);
         addWidget(this.m_foundMasteryBushelsText);
         this.m_stallText = new ZwTextField(m_element.stand_tf);
         addWidget(this.m_stallText);
         this.m_stallMasteryText = new ZwTextField(m_element.standPlus_tf);
         addWidget(this.m_stallMasteryText);
         this.m_plusBushels = new ZwFrame(m_element.plusIcon1_mc);
         this.m_plusMastery = new ZwFrame(m_element.plusIcon2_mc);
         this.m_plusBushels.visible = false;
         this.m_plusMastery.visible = false;
      }
      
      public function get bushelSummaryData() : BushelsFoundSummary
      {
         return this.m_bushelSummaryData;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         var bushelSummary:BushelsFoundSummary = data as BushelsFoundSummary;
         this.m_bushelSummaryData = bushelSummary;
         this.m_foundBushelsText.text = ZLocUtils.t("Crafting","BushelInformationWindow_FoundTitle",{
            "quantity":bushelSummary.quantity,
            "bushelItem":ZLocUtils.tk_pk(bushelSummary.bushelItem.friendlyName,"",bushelSummary.quantity)
         });
         this.m_bushelIcon.loadIcon(bushelSummary.bushelItem.icon);
         this.m_marketStallIcon.loadIcon(CraftingManager.getInstance().getBushelMarketIconForBushel(bushelSummary.bushelItem.code));
         if(bushelSummary.rewardUrl == "")
         {
            this.m_shareButton.element.alpha = 0.7;
            Utilities.toggleInputOnlySelf(this.m_shareButton.element as InteractiveObject,false);
         }
         else
         {
            this.m_shareButton.element.alpha = 1;
            Utilities.toggleInputOnlySelf(this.m_shareButton.element as InteractiveObject,true);
         }
         this.m_stallText.text = ZLocUtils.t("Crafting","BushelInformationWindow_MarketTitle",{"quantity":this.getTimeStallIsOpenFor(bushelSummary)});
      }
      
      protected function getTimeStallIsOpenFor(bushelSummary:BushelsFoundSummary) : int
      {
         var baseTime:int = 24;
         var additionalHours:int = Global.getStarsForMastery(bushelSummary.bushelItem.crop) * 8;
         return int(baseTime + additionalHours);
      }
      
      override public function release() : void
      {
         super.release();
         this.m_plusBushels = null;
         this.m_plusMastery = null;
         this.m_bushelIcon = null;
         this.m_marketStallIcon = null;
         this.m_foundBushelsText = null;
         this.m_foundMasteryBushelsText = null;
         this.m_stallText = null;
         this.m_stallMasteryText = null;
         this.m_shareButton = null;
         this.m_data = null;
         this.m_bushelSummaryData = null;
      }
      
      override public function clearView() : void
      {
      }
   }
}

