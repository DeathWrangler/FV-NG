package Widgets.Slots.LootTicketBooth
{
   import Classes.FeatureDataObjects.LootTicketBoothStageConfig;
   import Classes.ZItem.FarmItem;
   import Classes.consumables.CLootTicket;
   import Classes.util.ZLocUtils;
   import Managers.LootTicketBoothManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.Market.MarketTooltip;
   import Widgets.Windows.LootTicketBooth.LootTicketBoothWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public final class LootTicketBoothSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_itemVisible:Boolean = true;
      
      private var m_buyButtonVisible:Boolean;
      
      private var m_preview:Boolean;
      
      private var m_data:Object;
      
      private var m_icon:FarmIcon;
      
      private var m_previewFrame:ObjectPreviewFrame;
      
      private var m_checkWidget:ZwWidget;
      
      private var m_questionMarkWidget:ZwWidget;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_rarityTextField:ZwTextField;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      public function LootTicketBoothSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_checkWidget = addWidget(new ZwWidget(m_element.check_mc)) as ZwWidget;
         this.m_questionMarkWidget = addWidget(new ZwWidget(m_element.question_mc)) as ZwWidget;
         this.m_nameTextField = addWidget(new ZwTextField(m_element.name_tf," ")) as ZwTextField;
         this.m_rarityTextField = addWidget(new ZwTextField(m_element.rarity_tf," ")) as ZwTextField;
         this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buy_bt,"Buy","00",this.onBuyButtonClick)) as FarmAnimatedCashButton;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         this.refresh();
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_icon = null;
         this.m_previewFrame = null;
         this.m_checkWidget = null;
         this.m_questionMarkWidget = null;
         this.m_nameTextField = null;
         this.m_rarityTextField = null;
         this.m_buyButton = null;
         super.release();
      }
      
      public function setState(itemVisible:Boolean, buyButtonVisible:Boolean, preview:Boolean) : void
      {
         this.m_itemVisible = itemVisible;
         this.m_buyButtonVisible = buyButtonVisible;
         this.m_preview = preview;
         this.refresh();
      }
      
      private function refresh() : void
      {
         var itemName:String = null;
         var item:FarmItem = null;
         var parentWindow:LootTicketBoothWindow = null;
         var itemWon:int = 0;
         var tooltipText:String = null;
         var nextStage:LootTicketBoothStageConfig = null;
         var stageTitle:String = null;
         if(this.m_data)
         {
            itemName = this.m_data.itemName;
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(item)
            {
               if(this.m_itemVisible)
               {
                  this.m_nameTextField.text = item.friendlyTitle;
                  this.m_nameTextField.visible = true;
                  parentWindow = getAncestorByClassType(LootTicketBoothWindow) as LootTicketBoothWindow;
                  if(this.m_preview && item.hasPreview)
                  {
                     if(m_element.hasOwnProperty("preview_mc"))
                     {
                        if(item.displayLoader.canUseAnimation)
                        {
                           item.displayLoader.useAnimation = true;
                        }
                        if(this.m_previewFrame != null)
                        {
                           removeWidget(this.m_previewFrame);
                        }
                        this.m_previewFrame = addWidget(new ObjectPreviewFrame(m_element.preview_mc,item,null,[2],[100])) as ObjectPreviewFrame;
                        this.m_previewFrame.visible = true;
                     }
                     this.m_icon.visible = false;
                  }
                  else
                  {
                     this.m_icon.loadIcon(item.iconUrl);
                     this.m_icon.visible = true;
                     if(item.className == "CSeedPackage")
                     {
                        tooltipText = ZLocUtils.t("Dialogs","LootTicketBooth_LootItem_SeedMessage");
                     }
                     else if(item.className == CLootTicket.CLASS_NAME)
                     {
                        nextStage = LootTicketBoothManager.getNextStage(parentWindow.featureName,parentWindow.currentStageName);
                        if(nextStage)
                        {
                           stageTitle = LootTicketBoothManager.getStageTitle(parentWindow.featureName,nextStage.name);
                           tooltipText = ZLocUtils.t("Dialogs","LootTicketBooth_LootItem_PartMessage",{
                              "stage":stageTitle,
                              "total":nextStage.partItemNeeded
                           });
                        }
                     }
                     if(tooltipText)
                     {
                        if(!this.m_icon.tooltip)
                        {
                           this.m_icon.attachTooltip(new MarketTooltip(tooltipText));
                        }
                        else
                        {
                           (this.m_icon.tooltip as MarketTooltip).setText(tooltipText);
                        }
                     }
                     else
                     {
                        this.m_icon.detachTooltip();
                     }
                     if(this.m_previewFrame)
                     {
                        this.m_previewFrame.visible = false;
                     }
                  }
                  itemWon = LootTicketBoothManager.getStageItemWon(parentWindow.featureName,parentWindow.currentStageName,item.name);
                  this.m_checkWidget.visible = itemWon > 0;
                  if(this.m_buyButtonVisible && item.buyable && item.buyableWithCash())
                  {
                     this.m_buyButton.setAmountText(String(item.cash));
                     this.m_buyButton.visible = true;
                  }
                  else
                  {
                     this.m_buyButton.visible = false;
                  }
                  this.m_questionMarkWidget.visible = false;
               }
               else
               {
                  this.m_nameTextField.visible = false;
                  this.m_questionMarkWidget.visible = true;
                  this.m_icon.visible = false;
               }
            }
            this.m_rarityTextField.text = ZLocUtils.t("Dialogs","LootTicketBoothRarity_" + this.m_data.rare);
            this.m_rarityTextField.visible = true;
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var itemName:String = null;
         var item:FarmItem = null;
         if(this.m_buyButton.enabled)
         {
            itemName = this.m_data.itemName;
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            if(item)
            {
               Global.player.buyFarmItem(item,Currency.CASH,1,true,true,true,null,true);
            }
         }
      }
   }
}

