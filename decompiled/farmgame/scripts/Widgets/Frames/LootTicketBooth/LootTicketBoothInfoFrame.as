package Widgets.Frames.LootTicketBooth
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.consumables.CLootTicket;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.LootTicketBooth.LootTicketBoothWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public final class LootTicketBoothInfoFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_item:FarmItem;
      
      private var m_numOwned:int;
      
      private var m_numNeeded:int;
      
      private var m_maxLimit:int;
      
      private var m_icon:FarmIcon;
      
      private var m_checkWidget:ZwWidget;
      
      private var m_countTextField:FarmTextField;
      
      private var m_countNeededTextField:FarmTextField;
      
      private var m_nameTextField:FarmTextField;
      
      private var m_infoTextField:FarmTextField;
      
      private var m_askButton:FarmAnimatedTextButton;
      
      private var m_askTextField:FarmTextField;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_waitingFeedCallback:Boolean = false;
      
      public function LootTicketBoothInfoFrame(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.mc_icon)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_checkWidget = addWidget(new ZwWidget(m_element.check_mc),false) as ZwWidget;
         this.m_countTextField = addWidget(new FarmTextField(m_element.count_tf,"")) as FarmTextField;
         this.m_countNeededTextField = addWidget(new FarmTextField(m_element.countNeeded_tf,"")) as FarmTextField;
         this.m_nameTextField = addWidget(new FarmTextField(m_element.ticketName_tf,"")) as FarmTextField;
         this.m_infoTextField = addWidget(new FarmTextField(m_element.generic_mc,"")) as FarmTextField;
         this.m_askButton = addWidget(new FarmAnimatedTextButton(m_element.ask_bt,"Ask",this.onAskButtonClick)) as FarmAnimatedTextButton;
         this.m_askTextField = addWidget(new FarmTextField(m_element.ask_tf,"")) as FarmTextField;
         this.m_buyButton = addWidget(new FarmAnimatedTextButton(m_element.buy_bt,"00",this.onBuyButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_countTextField = null;
         this.m_nameTextField = null;
         this.m_infoTextField = null;
         this.m_askButton = null;
         this.m_askTextField = null;
         this.m_buyButton = null;
         super.release();
      }
      
      public function populate(item:FarmItem, numNeeded:int) : void
      {
         this.m_item = item;
         this.m_numNeeded = numNeeded;
         this.refresh();
      }
      
      public function get hasEnoughTickets() : Boolean
      {
         var result:Boolean = false;
         if(this.m_numOwned >= this.m_numNeeded)
         {
            result = true;
         }
         return result;
      }
      
      public function refresh() : void
      {
         this.m_icon.loadIcon(this.m_item.iconUrl);
         this.m_nameTextField.text = this.m_item.friendlyTitle;
         var parentWindow:LootTicketBoothWindow = getAncestorByClassType(LootTicketBoothWindow) as LootTicketBoothWindow;
         var infoKey:String = parentWindow.featureName + "_TicketMessage";
         if(ZLocUtils.hasString("Dialogs",infoKey))
         {
            this.m_infoTextField.text = ZLocUtils.t("Dialogs",infoKey,{
               "quantity":this.m_numNeeded,
               "item":this.m_item.friendlyTitle
            });
         }
         this.m_numOwned = Global.player.getGiftCountForItem(this.m_item.name);
         this.m_countTextField.text = String(this.m_numOwned);
         this.m_countNeededTextField.text = String(this.m_numNeeded);
         this.m_buyButton.text = String(this.m_item.cash);
         if(this.hasEnoughTickets)
         {
            this.m_checkWidget.visible = true;
            this.m_buyButton.visible = false;
         }
         else
         {
            this.m_buyButton.visible = true;
            this.m_checkWidget.visible = false;
         }
         this.refreshAskButton();
      }
      
      private function refreshAskButton() : void
      {
         var canTakeItem:Boolean = false;
         var canRequestPart:Boolean = false;
         var parentWindow:LootTicketBoothWindow = getAncestorByClassType(LootTicketBoothWindow) as LootTicketBoothWindow;
         if(parentWindow)
         {
            canTakeItem = CLootTicket.canTakeItem(this.m_item.name);
            canRequestPart = parentWindow.building.canRequestPartFeed(this.m_item.code);
            this.m_askButton.enabled = !this.m_waitingFeedCallback && canTakeItem && canRequestPart;
            if(this.m_askButton.enabled)
            {
               this.m_askTextField.visible = false;
            }
            else
            {
               if(!canTakeItem)
               {
                  this.m_askTextField.text = "Tank is Full";
               }
               else
               {
                  this.m_askTextField.text = "Ask again in " + FarmGameUtil.toFriendlyTime(parentWindow.building.getTimeUntilPostAnotherFeed(this.m_item.code),true);
               }
               this.m_askTextField.visible = true;
            }
         }
      }
      
      private function onAskButtonClick(event:MouseEvent) : void
      {
         var parentWindow:LootTicketBoothWindow = null;
         if(this.m_askButton.enabled)
         {
            this.m_waitingFeedCallback = true;
            this.m_askButton.enabled = false;
            parentWindow = getAncestorByClassType(LootTicketBoothWindow) as LootTicketBoothWindow;
            parentWindow.building.requestExpansionPart(this.m_item,this.askFeedCallback,FeatureBuilding.PART_ASK_METHOD_FEED,parentWindow.featureName + "_AskPart");
            FarmStatsManager.count("click","askForTicket",parentWindow.featureName,parentWindow.currentStageName);
         }
      }
      
      private function askFeedCallback(result:Object = null) : void
      {
         if(result != null)
         {
            this.m_waitingFeedCallback = false;
         }
         this.refreshAskButton();
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var parentWindow:LootTicketBoothWindow = null;
         if(this.m_buyButton.enabled)
         {
            Global.player.buyFarmItem(this.m_item,Currency.CASH,1,true,false,true,null,true);
            ++this.m_numOwned;
            this.refresh();
            parentWindow = getAncestorByClassType(LootTicketBoothWindow) as LootTicketBoothWindow;
            if(this.hasEnoughTickets)
            {
               parentWindow.refreshActionButton();
            }
            FarmStatsManager.count("click","buyTicket",parentWindow.featureName,parentWindow.currentStageName);
         }
      }
   }
}

