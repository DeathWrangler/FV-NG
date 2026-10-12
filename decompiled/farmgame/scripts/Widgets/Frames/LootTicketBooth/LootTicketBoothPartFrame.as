package Widgets.Frames.LootTicketBooth
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.LootTicketBoothManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Windows.LootTicketBooth.LootTicketBoothWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public final class LootTicketBoothPartFrame extends ZwFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_item:FarmItem;
      
      private var m_numOwned:int;
      
      private var m_numNeeded:int;
      
      private var m_isPreviousStageUnlocked:Boolean;
      
      private var m_icon:FarmIcon;
      
      private var m_countTextField:FarmTextField;
      
      private var m_nameTextField:FarmTextField;
      
      private var m_instructionsTextField:FarmTextField;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_unlockButton:FarmAnimatedTextButton;
      
      public function LootTicketBoothPartFrame(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.item_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_countTextField = addWidget(new FarmTextField(m_element.count_tf,"")) as FarmTextField;
         this.m_nameTextField = addWidget(new FarmTextField(m_element.itemName_tf,"")) as FarmTextField;
         this.m_instructionsTextField = addWidget(new FarmTextField(m_element.instructions_tf,"")) as FarmTextField;
         this.m_buyButton = addWidget(new FarmAnimatedTextButton(m_element.buy_bt,"00",this.onBuyButtonClick)) as FarmAnimatedTextButton;
         this.m_unlockButton = addWidget(new FarmAnimatedTextButton(m_element.unlock_bt,"Unlock",this.onUnlockButtonClick),false) as FarmAnimatedTextButton;
      }
      
      override public function release() : void
      {
         this.m_item = null;
         this.m_icon = null;
         this.m_countTextField = null;
         this.m_nameTextField = null;
         this.m_instructionsTextField = null;
         this.m_buyButton = null;
         this.m_unlockButton = null;
         super.release();
      }
      
      public function populate(item:FarmItem, numNeeded:int, isPreviousStageUnlocked:Boolean) : void
      {
         this.m_item = item;
         this.m_numNeeded = numNeeded;
         this.m_isPreviousStageUnlocked = isPreviousStageUnlocked;
         this.refresh();
      }
      
      public function get hasEnoughParts() : Boolean
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
         this.m_numOwned = Global.player.getGiftCountForItem(this.m_item.name);
         this.m_countTextField.text = ZLocUtils.t("Dialogs","LootTicketBooth_PartCount",{
            "quantity":this.m_numOwned,
            "maximum":this.m_numNeeded
         });
         var parentWindow:LootTicketBoothWindow = getAncestorByClassType(LootTicketBoothWindow) as LootTicketBoothWindow;
         if(!this.m_isPreviousStageUnlocked)
         {
            this.m_instructionsTextField.text = ZLocUtils.t("Dialogs",parentWindow.featureName + "_SequentialUnlockMessage");
            this.m_instructionsTextField.visible = true;
            this.m_buyButton.visible = false;
            this.m_unlockButton.visible = false;
         }
         else if(this.hasEnoughParts)
         {
            this.m_instructionsTextField.text = ZLocUtils.t("Dialogs",parentWindow.featureName + "_EnoughMessage",{"item":this.m_item.friendlyTitle});
            this.m_instructionsTextField.visible = true;
            this.m_buyButton.visible = false;
            this.m_unlockButton.visible = true;
         }
         else
         {
            this.m_instructionsTextField.text = ZLocUtils.t("Dialogs",parentWindow.featureName + "_UnlockMessage",{"item":this.m_item.friendlyTitle});
            this.m_instructionsTextField.visible = true;
            if(this.m_item.buyable && this.m_item.buyableWithCash())
            {
               this.m_buyButton.text = String(this.m_item.cash);
               this.m_buyButton.visible = true;
            }
            else
            {
               this.m_buyButton.visible = false;
            }
            this.m_unlockButton.visible = false;
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var parentWindow:LootTicketBoothWindow = null;
         if(this.m_buyButton.enabled)
         {
            Global.player.buyFarmItem(this.m_item,Currency.CASH,1,true,false,true,null,true);
            ++this.m_numOwned;
            this.refresh();
            if(this.hasEnoughParts)
            {
               parentWindow = getAncestorByClassType(LootTicketBoothWindow) as LootTicketBoothWindow;
               if(parentWindow)
               {
                  parentWindow.refresh();
               }
            }
         }
      }
      
      private function onUnlockButtonClick(event:MouseEvent) : void
      {
         var parentWindow:LootTicketBoothWindow = null;
         if(this.m_unlockButton.enabled)
         {
            parentWindow = getAncestorByClassType(LootTicketBoothWindow) as LootTicketBoothWindow;
            if(parentWindow)
            {
               LootTicketBoothManager.setStageUnlocked(parentWindow.featureName,parentWindow.currentStageName);
               parentWindow.refresh();
               parentWindow.refreshStageTabs();
            }
         }
      }
   }
}

