package Widgets.Slots
{
   import Cache.Classes.ZCacheUtil;
   import Classes.FeatureBuilding;
   import Classes.Mastery;
   import Classes.ZItem.FarmItem;
   import Classes.ZItem.HarvestableItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketSlotMasteryFrame;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Tooltips.MovieClipTooltip;
   import Widgets.Windows.StorageContentsWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   
   public class BloomContentsSlot extends ZwSlotFrame
   {
      
      private static const TOOLTIP_SHOW_FRAME_NUM:int = 7;
      
      private static const TOOLTIP_BUY_REMOVE:int = 1;
      
      private static const TOOLTIP_BUY:int = 2;
      
      private static const TOOLTIP_REMOVE:int = 3;
      
      private static const TOOLTIP_NOTAVAILABLE:int = 4;
      
      protected var m_parentWindow:StorageContentsWindow = null;
      
      protected var m_singleObjectPreviewFrame:ObjectPreviewFrame = null;
      
      protected var m_singleSprite:Sprite = null;
      
      protected var m_data:Object = null;
      
      protected var m_fullObjectPreviewFrame:ObjectPreviewFrame = null;
      
      protected var m_fullSprite:Sprite = null;
      
      protected var m_singleAmount:ZwTextField = null;
      
      protected var m_fullAmount:ZwTextField = null;
      
      protected var m_itemTitle:ZwTextField = null;
      
      private var m_sign:MovieClip = null;
      
      private var m_masteryFrame:MarketSlotMasteryFrame = null;
      
      protected var m_bulbFarmItem:FarmItem = null;
      
      protected var m_singleFarmItem:FarmItem = null;
      
      protected var m_fullFarmItem:FarmItem = null;
      
      private var m_buyButton:FarmAnimatedTextButton = null;
      
      private var m_fullbuyButton:FarmAnimatedTextButton = null;
      
      private var m_removeButton:FarmAnimatedTextButton = null;
      
      private var m_fullremoveButton:FarmAnimatedTextButton = null;
      
      private var m_singleType:ZwTextField = null;
      
      private var m_fullType:ZwTextField = null;
      
      public function BloomContentsSlot(element:DisplayObject, parentWindow:StorageContentsWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow;
         if(m_element.bloomSingle_mc.hasOwnProperty("itemAmount_tf"))
         {
            this.m_singleAmount = new ZwTextField(m_element.bloomSingle_mc.itemAmount_tf,"");
            addWidget(this.m_singleAmount);
         }
         if(m_element.bloomFull_mc.hasOwnProperty("fullitemAmount_tf"))
         {
            this.m_fullAmount = new ZwTextField(m_element.bloomFull_mc.fullitemAmount_tf,"");
            addWidget(this.m_fullAmount);
         }
         if(m_element.hasOwnProperty("itemTitle_tf"))
         {
            this.m_itemTitle = new ZwTextField(m_element.itemTitle_tf,"");
            addWidget(this.m_itemTitle);
         }
         if(m_element.hasOwnProperty("sign_mc"))
         {
            this.m_sign = m_element.sign_mc as MovieClip;
         }
         if(m_element.hasOwnProperty("mastery_mc"))
         {
            this.m_masteryFrame = addWidget(new MarketSlotMasteryFrame(m_element.mastery_mc)) as MarketSlotMasteryFrame;
         }
         this.attachTooltip(new MovieClipTooltip(element as MovieClip,TOOLTIP_SHOW_FRAME_NUM));
      }
      
      override public function release() : void
      {
         super.release();
         this.m_itemTitle = null;
         this.m_parentWindow = null;
         this.m_sign = null;
         this.m_masteryFrame = null;
         this.m_singleFarmItem = null;
         this.m_fullFarmItem = null;
      }
      
      override public function populate(data:Object) : void
      {
         var holder:MovieClip = null;
         var offset:Point = null;
         var fullOffset:Point = null;
         var mastery:Mastery = null;
         super.populate(data);
         this.m_data = data;
         if(this.m_singleObjectPreviewFrame != null)
         {
            removeWidget(this.m_singleObjectPreviewFrame);
            this.m_singleObjectPreviewFrame = null;
         }
         if(this.m_fullObjectPreviewFrame != null)
         {
            removeWidget(this.m_fullObjectPreviewFrame);
            this.m_fullObjectPreviewFrame = null;
         }
         this.m_bulbFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.bulb);
         this.m_singleFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.singlebloom);
         this.m_fullFarmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.fullbloom);
         if(m_element != null && m_element.hasOwnProperty("bloomSingle_mc") && Boolean(m_element.bloomSingle_mc.hasOwnProperty("icon_mc")))
         {
            if(this.m_singleFarmItem.displayLoader.canUseAnimation)
            {
               this.m_singleFarmItem.displayLoader.useAnimation = true;
            }
            holder = m_element.bloomSingle_mc.icon_mc;
            offset = new Point(0,0);
            if(data.hasOwnProperty("offsetX"))
            {
               offset.x = data.offsetX;
            }
            if(data.hasOwnProperty("offsetY"))
            {
               offset.y = data.offsetY;
            }
            this.m_singleObjectPreviewFrame = new ObjectPreviewFrame(holder,this.m_singleFarmItem,null,[1.5],null,FeatureBuilding.STATE_DISPLAY,null,null,offset);
            (this.m_singleObjectPreviewFrame.element as MovieClip).filters = [];
            addWidget(this.m_singleObjectPreviewFrame,true);
            this.m_singleSprite = this.m_singleObjectPreviewFrame.sprite;
            if(Boolean(this.m_singleSprite) && data.singleQuantity > 0)
            {
               this.m_singleSprite.buttonMode = true;
               this.m_singleSprite.mouseChildren = true;
               this.m_singleSprite.useHandCursor = true;
               this.m_singleSprite.addEventListener(MouseEvent.CLICK,ZCacheUtil.applyPartial(this.mouseClickHandler,this,[this.m_singleFarmItem]));
            }
            if(this.m_singleAmount != null)
            {
               this.m_singleAmount.text = "x" + data.singleQuantity.toString();
               this.m_singleAmount.visible = true;
               if(data.singleQuantity == 0)
               {
                  this.makeTransparent(this.m_singleObjectPreviewFrame);
               }
            }
         }
         var singleTooltip:int = this.checkTooltipState(data.singlebloom,data.singleQuantity);
         this.setupTooltip(singleTooltip,"tooltipSingle_mc");
         if(m_element != null && m_element.hasOwnProperty("bloomFull_mc") && Boolean(m_element.bloomFull_mc.hasOwnProperty("fullicon_mc")))
         {
            if(this.m_fullFarmItem.displayLoader.canUseAnimation)
            {
               this.m_fullFarmItem.displayLoader.useAnimation = true;
            }
            holder = m_element.bloomFull_mc.fullicon_mc;
            fullOffset = new Point(0,0);
            if(data.hasOwnProperty("offsetX"))
            {
               fullOffset.x = data.offsetX;
            }
            if(data.hasOwnProperty("offsetY"))
            {
               fullOffset.y = data.offsetY;
            }
            this.m_fullObjectPreviewFrame = new ObjectPreviewFrame(holder,this.m_fullFarmItem,null,[2],null,FeatureBuilding.STATE_DISPLAY,null,null,offset);
            (this.m_fullObjectPreviewFrame.element as MovieClip).filters = [];
            addWidget(this.m_fullObjectPreviewFrame,true);
            this.m_fullSprite = this.m_fullObjectPreviewFrame.sprite;
            if(Boolean(this.m_fullSprite) && data.fullQuantity > 0)
            {
               this.m_fullSprite.buttonMode = true;
               this.m_fullSprite.mouseChildren = true;
               this.m_fullSprite.useHandCursor = true;
               this.m_fullSprite.addEventListener(MouseEvent.CLICK,ZCacheUtil.applyPartial(this.mouseClickHandler,this,[this.m_fullFarmItem]));
            }
            if(this.m_fullAmount != null)
            {
               this.m_fullAmount.text = "x" + data.fullQuantity.toString();
               this.m_fullAmount.visible = true;
               if(data.fullQuantity == 0)
               {
                  this.makeTransparent(this.m_fullObjectPreviewFrame);
               }
            }
         }
         var fullTooltip:int = this.checkTooltipState(data.fullbloom,data.fullQuantity);
         this.setupTooltip(fullTooltip,"tooltipFull_mc");
         if(this.m_itemTitle != null)
         {
            if(data.hasOwnProperty("displayName"))
            {
               this.m_itemTitle.text = data.displayName;
            }
            else
            {
               this.m_itemTitle.text = this.m_singleFarmItem.friendlyTitle;
            }
            this.m_itemTitle.visible = true;
         }
         if(this.m_sign != null)
         {
            this.m_sign.visible = true;
            if(data.quantity > 0)
            {
               this.m_sign.gotoAndStop(1);
            }
            else
            {
               this.m_sign.gotoAndStop(2);
            }
         }
         if(data.quantity > 0 || this.m_fullFarmItem.canPurchase)
         {
            if(this.m_masteryFrame != null)
            {
               if(this.m_fullFarmItem is HarvestableItem && (this.m_fullFarmItem as HarvestableItem).hasMastery)
               {
                  mastery = (this.m_fullFarmItem as HarvestableItem).mastery;
                  this.m_masteryFrame.update(mastery.currentLevel + 1,mastery.currentProgress,mastery.totalCropsNeeded);
                  this.m_masteryFrame.visible = true;
               }
               else
               {
                  this.m_masteryFrame.visible = false;
               }
            }
         }
         else if(this.m_masteryFrame)
         {
            this.m_masteryFrame.visible = false;
         }
      }
      
      private function mouseClickHandler(item:FarmItem, extraItemData:Object, event:MouseEvent) : void
      {
         FarmStatsManager.count("dialog",this.m_parentWindow.building.getItemName(),"remove",item.name);
         this.m_parentWindow.skipCloseStat = true;
         if(this.m_singleSprite)
         {
            this.m_singleSprite.removeEventListener(MouseEvent.CLICK,this.mouseClickHandler);
            this.m_singleSprite = null;
         }
         var extraData:Object = extraItemData;
         extraData.isGift = false;
         extraData.repopGift = false;
         item.onUse(this.m_parentWindow.building.getId(),extraData);
         this.m_parentWindow.close();
      }
      
      private function makeTransparent(previewFrame:ObjectPreviewFrame) : void
      {
         var alphaFilter:ColorMatrixFilter = null;
         if(previewFrame != null)
         {
            alphaFilter = new ColorMatrixFilter([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0.6,0]);
            (previewFrame.element as MovieClip).filters = [alphaFilter];
         }
      }
      
      private function onClickMarket(event:MouseEvent) : void
      {
         var createWindow:Function;
         var building:FeatureBuilding = null;
         FarmStatsManager.count("dialog",this.m_parentWindow.building.getItemName(),"market",this.m_singleFarmItem.name + "/" + this.m_fullFarmItem.name);
         this.m_parentWindow.skipCloseStat = true;
         building = this.m_parentWindow.building;
         createWindow = function(purchased:Boolean = false):void
         {
            if(!purchased)
            {
               building.displayStorageDialog();
            }
         };
         UI.displayMiniMarketDialog([this.m_singleFarmItem.name,this.m_fullFarmItem.name],"bloom","bloom",createWindow,true);
         this.m_parentWindow.close();
      }
      
      private function checkTooltipState(code:String, quantity:Number) : int
      {
         var canPurchase:Boolean = false;
         var state:int = 0;
         var farmItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(code);
         if(farmItem)
         {
            canPurchase = farmItem.canPurchase;
            if(quantity > 0)
            {
               if(canPurchase)
               {
                  state = TOOLTIP_BUY_REMOVE;
               }
               else
               {
                  state = TOOLTIP_REMOVE;
               }
            }
            else if(canPurchase)
            {
               state = TOOLTIP_BUY;
            }
            else
            {
               state = TOOLTIP_NOTAVAILABLE;
            }
         }
         return state;
      }
      
      private function setupTooltip(state:int, tooltip:String) : void
      {
         switch(state)
         {
            case TOOLTIP_BUY_REMOVE:
               this.toggleTooltipStates(tooltip,true,true,false,true,TOOLTIP_BUY_REMOVE);
               break;
            case TOOLTIP_REMOVE:
               this.toggleTooltipStates(tooltip,false,true,false,true,TOOLTIP_REMOVE);
               break;
            case TOOLTIP_BUY:
               this.toggleTooltipStates(tooltip,true,false,false,true,TOOLTIP_BUY);
               break;
            case TOOLTIP_NOTAVAILABLE:
               this.toggleTooltipStates(tooltip,false,false,true,false,TOOLTIP_NOTAVAILABLE);
         }
      }
      
      private function toggleTooltipStates(toolString:String, showBuy:Boolean, showRemove:Boolean, showText:Boolean, showPopup:Boolean, frameNum:int) : void
      {
         var movieTip:MovieClip = null;
         var removeHandler:Function = null;
         var tooltip:Object = m_element[toolString];
         var fullBloom:Boolean = toolString == "tooltipFull_mc";
         if(m_element.hasOwnProperty(toolString))
         {
            movieTip = m_element[toolString] as MovieClip;
            movieTip.gotoAndStop(TOOLTIP_NOTAVAILABLE);
            movieTip.gotoAndStop(frameNum);
         }
         else if(showBuy || showRemove || showText)
         {
            ErrorManager.addError("toggleTooltipStates(...) local var m_element.tooltip_mc is null");
         }
         if(showBuy)
         {
            if(!fullBloom && Boolean(tooltip.buy_bt))
            {
               removeWidget(tooltip.buy_bt);
               this.m_buyButton = addWidget(new FarmAnimatedTextButton(tooltip.buy_bt,ZLocUtils.t("Dialogs","Market"),this.onClickMarket)) as FarmAnimatedTextButton;
               this.m_buyButton.visible = true;
            }
            if(tooltip.fullbuy_bt)
            {
               removeWidget(tooltip.fullbuy_bt);
               this.m_fullbuyButton = addWidget(new FarmAnimatedTextButton(tooltip.fullbuy_bt,ZLocUtils.t("Dialogs","Market"),this.onClickMarket)) as FarmAnimatedTextButton;
               this.m_fullbuyButton.visible = true;
            }
         }
         if(showRemove)
         {
            if(!fullBloom && Boolean(tooltip.remove_bt))
            {
               removeWidget(tooltip.remove_bt);
               removeHandler = null;
               if(this.m_data["singleBlooms"] > 0)
               {
                  removeHandler = ZCacheUtil.applyPartial(this.mouseClickHandler,this,[this.m_singleFarmItem,new Object()]);
               }
               else
               {
                  removeHandler = ZCacheUtil.applyPartial(this.mouseClickHandler,this,[this.m_bulbFarmItem,{"expansionLevel":2}]);
               }
               this.m_removeButton = addWidget(new FarmAnimatedTextButton(tooltip.remove_bt,ZLocUtils.t("Dialogs","Generic_CompletedRemove"),removeHandler)) as FarmAnimatedTextButton;
               this.m_removeButton.visible = true;
            }
            if(tooltip.fullremove_bt)
            {
               removeWidget(tooltip.fullremove_bt);
               this.m_fullremoveButton = addWidget(new FarmAnimatedTextButton(tooltip.fullremove_bt,ZLocUtils.t("Dialogs","Generic_CompletedRemove"),ZCacheUtil.applyPartial(this.mouseClickHandler,this,[this.m_fullFarmItem,new Object()]))) as FarmAnimatedTextButton;
               this.m_fullremoveButton.visible = true;
            }
         }
         if(tooltip.title_tf)
         {
            removeWidget(tooltip.title_tf);
            this.m_singleType = addWidget(new ZwTextField(tooltip.title_tf,ZLocUtils.t("Dialogs","Bloom_Single"))) as ZwTextField;
            this.m_singleType.visible = true;
         }
         if(tooltip.fulltitle_tf)
         {
            removeWidget(tooltip.fulltitle_tf);
            this.m_fullType = addWidget(new ZwTextField(tooltip.fulltitle_tf,ZLocUtils.t("Dialogs","Bloom_Full"))) as ZwTextField;
            this.m_fullType.visible = true;
         }
         tooltip.visible = showBuy || showRemove || showText;
      }
   }
}

