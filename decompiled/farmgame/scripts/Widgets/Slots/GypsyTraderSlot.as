package Widgets.Slots
{
   import Classes.Animal;
   import Classes.GypsyTrader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class GypsyTraderSlot extends ZwSlotFrame
   {
      
      private static const X:String = "x";
      
      private const GARNET_MC:String = "garnet_mc";
      
      private const SAPPHIRE_MC:String = "sapphire_mc";
      
      private const GOLD_MC:String = "gold_mc";
      
      private const CHECKMARK_MC:String = "checkmark_mc";
      
      private const GARNET_COUNT_TF:String = "garnet_count_tf";
      
      private const SAPPHIRE_COUNT_TF:String = "sapphire_count_tf";
      
      private const GOLD_COUNT_TF:String = "gold_count_tf";
      
      private var m_shouldShowCheckMark:Boolean = false;
      
      private var m_featureName:String;
      
      private var m_data:Object;
      
      private var m_buyButton:FarmAnimatedCashButton = null;
      
      private var m_redeemButton:FarmAnimatedTextButton = null;
      
      protected var m_iconPreview:ResourcePreviewFrame;
      
      private var m_checkMark:ZwWidget;
      
      private const PINK_TEXT:String = "pink";
      
      private const BLUE_TEXT:String = "blue";
      
      private const GREEN_TEXT:String = "green";
      
      public function GypsyTraderSlot(element:DisplayObject, featureName:String)
      {
         super(element);
         this.m_featureName = featureName;
         addWidget(this.m_buyButton = new FarmAnimatedCashButton(m_element.buy_bt,"Buy","",this.onBuyItem),true);
         addWidget(this.m_redeemButton = new FarmAnimatedTextButton(m_element.trade_bt,"Trade",this.onRedeemItem),true);
         if(m_element.hasOwnProperty("icon_mc"))
         {
            addWidget(this.m_iconPreview = new ResourcePreviewFrame(m_element.icon_mc));
         }
         if(m_element.hasOwnProperty(this.CHECKMARK_MC))
         {
            addWidget(this.m_checkMark = new ZwWidget(m_element[this.CHECKMARK_MC]),this.m_shouldShowCheckMark);
         }
      }
      
      override public function populate(data:Object) : void
      {
         var overrideExportName:String = null;
         var exportedName:String = null;
         super.populate(data);
         this.m_data = data;
         if(m_element.hasOwnProperty(this.GARNET_MC) && Boolean(m_element[this.GARNET_MC].hasOwnProperty(this.GARNET_COUNT_TF)))
         {
            m_element[this.GARNET_MC].visible = true;
            m_element[this.GARNET_MC][this.GARNET_COUNT_TF].visible = true;
            m_element[this.GARNET_MC][this.GARNET_COUNT_TF].text = X + data[this.GREEN_TEXT];
         }
         if(m_element.hasOwnProperty(this.SAPPHIRE_MC) && Boolean(m_element[this.SAPPHIRE_MC].hasOwnProperty(this.SAPPHIRE_COUNT_TF)))
         {
            m_element[this.SAPPHIRE_MC].visible = true;
            m_element[this.SAPPHIRE_MC][this.SAPPHIRE_COUNT_TF].visible = true;
            m_element[this.SAPPHIRE_MC][this.SAPPHIRE_COUNT_TF].text = X + data[this.BLUE_TEXT];
         }
         if(m_element.hasOwnProperty(this.GOLD_MC) && Boolean(m_element[this.GOLD_MC].hasOwnProperty(this.GOLD_COUNT_TF)))
         {
            m_element[this.GOLD_MC].visible = true;
            m_element[this.GOLD_MC][this.GOLD_COUNT_TF].visible = true;
            m_element[this.GOLD_MC][this.GOLD_COUNT_TF].text = X + data[this.PINK_TEXT];
         }
         this.m_shouldShowCheckMark = data["checkMarkVisible"];
         this.m_redeemButton.visible = true;
         this.m_buyButton.visible = true;
         var redeemable:Boolean = Boolean(data["toggleRedeemVisible"]);
         if(redeemable)
         {
            this.m_redeemButton.enabled = true;
            this.m_redeemButton.applyGrayOut = false;
         }
         else
         {
            this.m_redeemButton.enabled = false;
            this.m_redeemButton.applyGrayOut = true;
         }
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
         if(this.m_iconPreview)
         {
            if(item)
            {
               overrideExportName = item.overrideExportName;
               if(overrideExportName == "")
               {
                  overrideExportName = item.name;
               }
               exportedName = overrideExportName + "_" + Animal.STATE_FRONT_IDLE;
               this.m_iconPreview.visible = true;
               this.m_iconPreview.load(item.imageRelativeUrl(Animal.STATE_FRONT_IDLE),exportedName,this.repositionSlotPreviewFrame,true,false);
               this.m_iconPreview.detachTooltip();
               this.m_iconPreview.attachTooltip(new FarmTextTooltip(item.friendlyTitle));
               if(this.m_buyButton)
               {
                  this.m_buyButton.setAmountText(item.cash.toString());
               }
            }
         }
         if(this.m_checkMark)
         {
            this.m_checkMark.visible = this.m_shouldShowCheckMark;
         }
      }
      
      private function repositionSlotPreviewFrame() : void
      {
         var mc:MovieClip = this.m_iconPreview.exportedMovieClip;
         if(mc)
         {
            mc.y = -mc.height;
         }
      }
      
      private function onBuyItem(event:Event) : void
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_data.name);
         UI.displayMessage(ZLocUtils.t("Dialogs",this.m_featureName + "BuyConfirmPopup",{
            "cashQuantity":item.cash,
            "item":item.friendlyTitle
         }),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmBuyItemPopupClose,"",true);
      }
      
      private function onConfirmBuyItemPopupClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.YES)
         {
            this.manager.buyCollectionItem(this.m_data.name);
         }
      }
      
      private function onRedeemItem(event:Event) : void
      {
         this.manager.redeemItem(this.m_data.name);
      }
      
      public function refreshSlot() : void
      {
         this.m_checkMark.visible = this.manager.hasCollectedItem(this.m_data.name);
         if(Boolean(this.m_data) && Boolean(this.m_redeemButton) && !this.manager.areSnowFlakeReqsMetFor(this.m_data))
         {
            this.m_redeemButton.enabled = false;
            this.m_redeemButton.applyGrayOut = true;
         }
         else
         {
            this.m_redeemButton.enabled = true;
            this.m_redeemButton.applyGrayOut = false;
         }
      }
      
      private function get manager() : GypsyTrader
      {
         return GypsyTrader.getInstance();
      }
   }
}

