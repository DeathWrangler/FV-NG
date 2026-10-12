package Widgets.Slots
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.ErrorManager;
   import Managers.TemplateUIUtility;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.MovieClipTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class ItemCollectionSlot extends ZwSlotFrame
   {
      
      private static const TOOLTIP_SHOW_FRAME_NUM:int = 30;
      
      private static const TOOLTIP_ICON_SIZE:int = 50;
      
      private static const TOOLTIP_SHARE_BUY_REMOVE:int = 1;
      
      private static const TOOLTIP_BUY_REMOVE:int = 2;
      
      private static const TOOLTIP_SHARE_BUY:int = 3;
      
      private static const TOOLTIP_SHARE_REMOVE:int = 4;
      
      private static const TOOLTIP_REMOVE:int = 5;
      
      private static const TOOLTIP_SHARE:int = 6;
      
      private static const TOOLTIP_BUY:int = 7;
      
      private static const TOOLTIP_NOTAVAIALABLE:int = 8;
      
      private var m_slotBGIcon:DisplayObject;
      
      private var m_itemTitle:ZwTextField = null;
      
      private var m_marketButton:ZwButton = null;
      
      private var m_buyButton:FarmAnimatedTextButton = null;
      
      protected var m_itemAmount:ZwTextField = null;
      
      private var m_sign:MovieClip;
      
      private var m_itemPreviewFrame:ObjectPreviewFrame;
      
      private var m_farmItem:FarmItem;
      
      private var m_secondaryPreviewFrame:ObjectPreviewFrame;
      
      private var m_previewItem:FarmItem;
      
      private var m_removeButton:FarmAnimatedButton;
      
      private var m_marketCallback:Function = null;
      
      private var m_removeCallback:Function = null;
      
      public function ItemCollectionSlot(element:DisplayObject)
      {
         super(element);
         if(m_element.itemTitle_tf_new)
         {
            this.m_itemTitle = new ZwTextField(m_element.itemTitle_tf_new,"");
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionSubTextColor(m_element.itemTitle_tf_new);
            }
         }
         else if(m_element.hasOwnProperty("itemTitle_tf"))
         {
            this.m_itemTitle = new ZwTextField(m_element.itemTitle_tf,"");
         }
         if(this.m_itemTitle)
         {
            addWidget(this.m_itemTitle);
         }
         if(m_element.hasOwnProperty("sign_mc"))
         {
            this.m_sign = m_element.sign_mc as MovieClip;
         }
         if(m_element.hasOwnProperty("itemAmount_tf"))
         {
            this.m_itemAmount = new ZwTextField(m_element.itemAmount_tf,"");
            addWidget(this.m_itemAmount);
         }
         if(!Global.worldManager.isVisiting())
         {
            attachTooltip(new MovieClipTooltip(m_element as MovieClip,TOOLTIP_SHOW_FRAME_NUM));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var farmIcon:FarmIcon = null;
         var buttonBGPath:String = null;
         super.populate(data);
         this.m_farmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.code);
         this.m_marketCallback = data.callbacks["market"];
         this.m_removeCallback = data.callbacks["remove"];
         var tooltipState:int = this.checkTooltipState(data);
         this.setupTooltip(tooltipState);
         if(data.hasOwnProperty("previewItemName"))
         {
            this.m_previewItem = Global.farmGameSettingsManager.getFarmItemByName(data.previewItemName);
            if(this.m_itemPreviewFrame != null)
            {
               removeWidget(this.m_itemPreviewFrame);
               this.m_itemPreviewFrame = null;
            }
            if(m_element.hasOwnProperty("item_mc"))
            {
               this.m_itemPreviewFrame = new ObjectPreviewFrame(m_element.item_mc,this.m_previewItem,null,[this.m_previewItem.sizeX == 1 ? 2 : 1.75]);
               addWidget(this.m_itemPreviewFrame,true);
               if(data.quantity == 0)
               {
                  (this.m_itemPreviewFrame.element as MovieClip).alpha = 0.6;
               }
               else
               {
                  (this.m_itemPreviewFrame.element as MovieClip).alpha = 1;
               }
            }
         }
         else if(m_element.hasOwnProperty("item_mc"))
         {
            removeWidget(m_element.item_mc);
            farmIcon = new FarmIcon(m_element.item_mc,data.icon);
            addWidget(farmIcon,true);
         }
         if(this.m_itemTitle != null)
         {
            this.m_itemTitle.text = data.name;
            this.m_itemTitle.visible = true;
         }
         if(this.m_itemAmount != null)
         {
            this.m_itemAmount.text = "x" + data.quantity.toString();
            this.m_itemAmount.visible = true;
         }
         if(this.m_sign != null)
         {
            this.m_sign.visible = true;
         }
         if(this.m_secondaryPreviewFrame != null)
         {
            removeWidget(this.m_secondaryPreviewFrame);
            this.m_secondaryPreviewFrame = null;
         }
         if(m_element.hasOwnProperty("masterysign_mc"))
         {
            this.m_secondaryPreviewFrame = new ObjectPreviewFrame(m_element.masterysign_mc,this.m_farmItem,null,[this.m_farmItem.sizeX == 1 ? 2 : 1.75],null,"static");
            addWidget(this.m_secondaryPreviewFrame,true);
         }
         if(m_element.hasOwnProperty("market_bt"))
         {
            removeWidget(m_element.market_bt);
            this.m_marketButton = addWidget(new FarmAnimatedTextButton(m_element.market_bt,ZLocUtils.t("Dialogs","Market"),this.m_marketCallback)) as ZwButton;
            this.m_marketButton.visible = this.m_farmItem.canPurchase;
         }
         if(m_element.hasOwnProperty("mc_Button"))
         {
            buttonBGPath = Global.worldSettingsManager.getSlotBGImagePath("Button100");
            if(buttonBGPath)
            {
               ImageLoader.getInstance(Global.getAssetURL(buttonBGPath)).getContent(this.onSlotUrlLoaded);
               if(this.m_slotBGIcon)
               {
                  m_element["mc_Button"].addChild(this.m_slotBGIcon);
                  m_element["mc_Button"].visible = true;
               }
            }
         }
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      private function isSharable() : Boolean
      {
         return false;
      }
      
      private function checkTooltipState(data:Object) : int
      {
         var canPurchase:Boolean = false;
         var state:int = 0;
         if(this.m_farmItem)
         {
            canPurchase = this.m_farmItem.canPurchase;
            if(data.quantity > 0)
            {
               if(canPurchase && this.isSharable())
               {
                  state = TOOLTIP_SHARE_BUY_REMOVE;
               }
               else if(this.isSharable())
               {
                  state = TOOLTIP_SHARE_REMOVE;
               }
               else if(canPurchase)
               {
                  state = TOOLTIP_BUY_REMOVE;
               }
               else
               {
                  state = TOOLTIP_REMOVE;
               }
            }
            else if(canPurchase && this.isSharable())
            {
               state = TOOLTIP_SHARE_BUY;
            }
            else if(this.isSharable())
            {
               state = TOOLTIP_SHARE;
            }
            else if(canPurchase)
            {
               state = TOOLTIP_BUY;
            }
            else
            {
               state = TOOLTIP_NOTAVAIALABLE;
            }
         }
         return state;
      }
      
      private function setupTooltip(state:int) : void
      {
         switch(state)
         {
            case TOOLTIP_SHARE_BUY_REMOVE:
               this.toggleTooltipStates(true,true,false,true,TOOLTIP_SHARE_BUY_REMOVE);
               break;
            case TOOLTIP_BUY_REMOVE:
               this.toggleTooltipStates(true,true,false,true,TOOLTIP_BUY_REMOVE);
               break;
            case TOOLTIP_SHARE_BUY:
               this.toggleTooltipStates(true,false,false,true,TOOLTIP_SHARE_BUY);
               break;
            case TOOLTIP_SHARE_REMOVE:
               this.toggleTooltipStates(false,true,false,true,TOOLTIP_SHARE_REMOVE);
               break;
            case TOOLTIP_REMOVE:
               this.toggleTooltipStates(false,true,false,true,TOOLTIP_REMOVE);
               break;
            case TOOLTIP_SHARE:
               this.toggleTooltipStates(false,false,false,true,TOOLTIP_SHARE);
               break;
            case TOOLTIP_BUY:
               this.toggleTooltipStates(true,false,false,true,TOOLTIP_SHARE_BUY);
               break;
            case TOOLTIP_NOTAVAIALABLE:
               this.toggleTooltipStates(false,false,true,false,TOOLTIP_NOTAVAIALABLE);
         }
      }
      
      private function toggleTooltipStates(showBuy:Boolean, showRemove:Boolean, showText:Boolean, showPopup:Boolean, frameNum:int) : void
      {
         if(m_element.hasOwnProperty("tooltip_mc"))
         {
            (m_element.tooltip_mc as MovieClip).gotoAndStop(frameNum);
         }
         else if(showBuy || showRemove || showText)
         {
            ErrorManager.addError("toggleTooltipStates(...) local var m_element.tooltip_mc is null");
         }
         if(showBuy)
         {
            if(m_element.tooltip_mc.buy_bt)
            {
               removeWidget(m_element.tooltip_mc.buy_bt);
               this.m_buyButton = addWidget(new FarmAnimatedTextButton(m_element.tooltip_mc.buy_bt,ZLocUtils.t("Dialogs","Market"),this.m_marketCallback)) as FarmAnimatedTextButton;
               this.m_buyButton.visible = true;
            }
         }
         else if(this.m_buyButton != null)
         {
            this.m_buyButton = null;
         }
         if(showRemove)
         {
            if(m_element.tooltip_mc.remove_bt)
            {
               removeWidget(m_element.tooltip_mc.remove_bt);
               this.m_removeButton = addWidget(new FarmAnimatedTextButton(m_element.tooltip_mc.remove_bt,ZLocUtils.t("Dialogs","Generic_CompletedRemove"),this.m_removeCallback)) as FarmAnimatedTextButton;
               this.m_removeButton.visible = true;
            }
         }
         else if(this.m_removeButton != null)
         {
            this.m_removeButton = null;
         }
         m_element.tooltip_mc.visible = showBuy || showRemove || showText;
      }
   }
}

