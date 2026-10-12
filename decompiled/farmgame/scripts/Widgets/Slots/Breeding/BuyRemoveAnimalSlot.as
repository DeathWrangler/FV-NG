package Widgets.Slots.Breeding
{
   import Classes.FeatureBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import GameMode.GMConstructBuilding;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.MovieClipTooltip;
   import Widgets.Tooltips.PersistantMovieClipTooltip;
   import Widgets.Windows.Breeding.AnimalBreedingContentsWindow;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class BuyRemoveAnimalSlot extends ZwSlotFrame
   {
      
      public static const EXPERIMENT_FRICTIONLESS:String = "fv_animal_pen_frictionless_buy";
      
      private static const FRICTIONLESS_NO_POPUP:int = 2;
      
      private static const FRICTIONLESS_POPUP:int = 1;
      
      private static const MARKET_BUY:int = 3;
      
      private static const BUY_CLICK_COUNTER:String = "buy_from_ui";
      
      private var m_itemTitle:ZwTextField = null;
      
      private var m_itemAmount:ZwTextField = null;
      
      private var m_popupIcon:FarmIcon = null;
      
      private var m_buyButton:FarmAnimatedTextButton = null;
      
      private var m_removeButton:FarmAnimatedTextButton = null;
      
      private var m_farmItem:FarmItem = null;
      
      private var m_animalSprite:Sprite = null;
      
      private var m_data:Object = null;
      
      protected var m_parentWindow:AnimalBreedingContentsWindow;
      
      private const TOOLTIP_NUM_FRAMES:int = 30;
      
      private const TOOLTIP_STOP_FRAME:int = 8;
      
      private var m_farmCashPrice:ZwBaseWidget = null;
      
      private var m_harvestItem:FarmItem = null;
      
      private var m_tooltip_mc:PersistantMovieClipTooltip = null;
      
      public function BuyRemoveAnimalSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow as AnimalBreedingContentsWindow;
         this.m_tooltip_mc = new PersistantMovieClipTooltip(m_element as MovieClip,this.TOOLTIP_NUM_FRAMES,MovieClipTooltip.DEFAULT_HIDE_FRAME_NUM,"tooltip_mc");
         if(m_element.hasOwnProperty("itemTitle_tf"))
         {
            this.m_itemTitle = new ZwTextField(m_element.itemTitle_tf,"");
            addWidget(this.m_itemTitle);
         }
         if(m_element.buy_bt)
         {
            this.m_buyButton = new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Dialogs","BuyPart"),this.onBuyClick);
            addWidget(this.m_buyButton);
         }
         if(m_element.hasOwnProperty("itemAmount_tf"))
         {
            this.m_itemAmount = new ZwTextField(m_element.itemAmount_tf,"");
            addWidget(this.m_itemAmount);
         }
         if(m_element.hasOwnProperty("tooltip_mc") && Boolean(m_element.tooltip_mc.hasOwnProperty("tooltipIcon_mc")))
         {
            this.m_popupIcon = new FarmIcon(m_element.tooltip_mc.tooltipIcon_mc);
            addWidget(this.m_popupIcon);
         }
         if(m_element.hasOwnProperty("tooltip_mc") && Boolean(m_element.tooltip_mc.hasOwnProperty("remove_bt")))
         {
            this.m_removeButton = new FarmAnimatedTextButton(m_element.tooltip_mc.remove_bt,ZLocUtils.t("Dialogs","Remove"),this.animalMouseClickHandler);
            addWidget(this.m_removeButton);
         }
         if(m_element.hasOwnProperty("fcPrice_mc"))
         {
            this.m_farmCashPrice = addWidget(new ZwBaseWidget(m_element.fcPrice_mc));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var holder:MovieClip = null;
         var cashAmnt:String = null;
         var itemIcon:FarmIcon = null;
         var height:Number = NaN;
         var width:Number = NaN;
         var objectPreviewFrame:ObjectPreviewFrame = null;
         super.populate(data);
         this.m_data = data;
         this.m_farmItem = Global.farmGameSettingsManager.getFarmItemByCode(data.code);
         if(this.m_buyButton)
         {
            this.m_buyButton.visible = true;
         }
         if(this.m_removeButton)
         {
            this.m_removeButton.visible = true;
            this.m_removeButton.enabled = data.quantity > 0;
         }
         if(data.name)
         {
            this.m_itemTitle.text = data.name;
            this.m_itemTitle.visible = true;
         }
         if(this.m_itemAmount)
         {
            this.m_itemAmount.text = data.quantity ? "x" + data.quantity : "x0";
            this.m_itemAmount.visible = true;
         }
         if(Boolean(this.m_farmCashPrice) && Boolean(this.m_farmCashPrice.element != null) && this.m_farmCashPrice.element.hasOwnProperty("FCPrice_tf"))
         {
            this.m_farmCashPrice.visible = true;
            cashAmnt = this.m_farmItem.cash ? this.m_farmItem.cash.toString() : "0";
            this.m_farmCashPrice.element.FCPrice_tf.text = cashAmnt;
         }
         if(m_element.hasOwnProperty("tooltip_mc"))
         {
            (m_element.tooltip_mc as MovieClip).gotoAndStop(this.TOOLTIP_STOP_FRAME);
            if(Boolean(this.m_farmItem) && Boolean(this.m_farmItem.harvestItem))
            {
               this.m_harvestItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_farmItem.harvestItem);
            }
            if(this.m_harvestItem)
            {
               if((m_element.tooltip_mc as MovieClip).hasOwnProperty("tooltipIcon_mc"))
               {
                  holder = m_element.tooltip_mc.tooltipIcon_mc as MovieClip;
                  itemIcon = getWidget(holder) as FarmIcon;
                  itemIcon.loadIcon(this.m_harvestItem.icon);
                  itemIcon.visible = true;
                  height = itemIcon.getIconHeight();
                  width = itemIcon.getIconWidth();
                  if(holder.width > 1 && holder.height > 1)
                  {
                     itemIcon.setIconWidth(holder.width);
                     itemIcon.setIconHeight(holder.height);
                  }
                  else if(m_element.tooltip_mc.width > 1)
                  {
                     itemIcon.setIconWidth(m_element.tooltip_mc.width / 2);
                     itemIcon.setIconHeight(m_element.tooltip_mc.width / 2);
                  }
               }
            }
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            holder = m_element.icon_mc;
            objectPreviewFrame = getWidget(holder) as ObjectPreviewFrame;
            if(objectPreviewFrame)
            {
               objectPreviewFrame.detachTooltip();
               removeWidget(objectPreviewFrame);
            }
            objectPreviewFrame = new ObjectPreviewFrame(holder,this.m_farmItem,null,[4],null,"frt_idle");
            objectPreviewFrame.attachTooltip(this.m_tooltip_mc);
            addWidget(objectPreviewFrame,true);
            this.m_animalSprite = objectPreviewFrame.sprite;
            if(Boolean(this.m_animalSprite) && data.quantity > 0)
            {
               this.m_animalSprite.buttonMode = true;
               this.m_animalSprite.mouseChildren = true;
               this.m_animalSprite.useHandCursor = true;
            }
         }
         this.m_popupIcon.visible = true;
      }
      
      override public function release() : void
      {
         this.m_itemTitle = null;
         this.m_itemAmount = null;
         this.m_popupIcon = null;
         this.m_buyButton = null;
         this.m_removeButton = null;
         this.m_farmItem = null;
         this.m_animalSprite = null;
         this.m_data = null;
         this.m_parentWindow = null;
         this.m_farmCashPrice = null;
         this.m_harvestItem = null;
         this.m_tooltip_mc = null;
         super.release();
      }
      
      private function animalMouseClickHandler(event:MouseEvent) : void
      {
         FarmStatsManager.count("dialog",this.m_parentWindow.building.getItemName(),"remove",this.m_farmItem.name);
         this.m_parentWindow.skipCloseStat = true;
         if(this.m_animalSprite)
         {
            this.m_animalSprite.removeEventListener(MouseEvent.CLICK,this.animalMouseClickHandler);
            this.m_animalSprite = null;
         }
         var extraData:Object = new Object();
         extraData.isGift = false;
         extraData.repopGift = false;
         this.m_farmItem.onUse(this.m_parentWindow.building.getId(),extraData);
         this.m_parentWindow.close();
      }
      
      private function hasCapacity() : Boolean
      {
         return this.m_parentWindow.building.count < this.m_parentWindow.building.capacity;
      }
      
      protected function updateUI() : void
      {
         this.m_parentWindow.refreshWindow();
         if(this.m_itemAmount)
         {
            this.m_itemAmount.text = this.m_data.quantity ? "x" + this.m_data.quantity : "x0";
            this.m_itemAmount.visible = true;
            this.m_removeButton.enabled = this.m_data.quantity > 0;
         }
      }
      
      private function handleBuy() : void
      {
         var result:Boolean = false;
         var variant:int = Global.experimentManager.getExperimentVariant(EXPERIMENT_FRICTIONLESS);
         switch(variant)
         {
            case FRICTIONLESS_NO_POPUP:
               this.buyFrictionless();
               break;
            case MARKET_BUY:
               this.handleMarket();
               break;
            case FRICTIONLESS_POPUP:
            default:
               this.handlePromptBuy();
         }
      }
      
      private function handlePromptBuy() : void
      {
         var messageText:String = null;
         if(Global.player.canBuyCash(this.m_farmItem.cash,true,this.m_farmItem.type))
         {
            messageText = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
               "item":ZLocUtils.tk_pk(this.m_farmItem.friendlyName),
               "cashQuantity":this.m_farmItem.cash
            });
            UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.buyCallback),false);
         }
      }
      
      private function buyCallback(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT && this.m_farmItem != null)
         {
            FarmStatsManager.count(this.m_parentWindow.building.bldgName,BUY_CLICK_COUNTER,this.m_farmItem.name,this.m_farmItem.cash.toString(),"prompt");
            this.buy();
         }
      }
      
      private function buy() : void
      {
         Global.world.addGameMode(new GMConstructBuilding(this.m_farmItem.name,this.m_parentWindow.building,false,true,false,1,false,false),false);
         ++this.m_data.quantity;
         this.updateUI();
      }
      
      private function buyFrictionless() : void
      {
         if(Global.player.canBuyCash(this.m_farmItem.cash,true,this.m_farmItem.type))
         {
            FarmStatsManager.count(this.m_parentWindow.building.bldgName,BUY_CLICK_COUNTER,this.m_farmItem.name,this.m_farmItem.cash.toString(),"frictionless");
            this.buy();
         }
      }
      
      private function handleMarket() : void
      {
         var building:FeatureBuilding = null;
         building = (this.m_parentWindow as AnimalBreedingContentsWindow).building;
         var createWindow:Function = function(purchased:Boolean = false):void
         {
            if(!purchased)
            {
               building.displayStorageDialog();
            }
            else
            {
               FarmStatsManager.count(building.bldgName,BUY_CLICK_COUNTER,m_farmItem.name,m_farmItem.cash.toString(),"market");
            }
         };
         UI.displayMiniMarketDialog([this.m_farmItem.name],"animal","animal",createWindow,true);
         this.m_parentWindow.close();
      }
      
      private function onBuyClick(event:MouseEvent) : void
      {
         if(this.m_parentWindow.building.capacity > this.m_parentWindow.building.count)
         {
            this.handleBuy();
         }
         else
         {
            this.handleMarket();
         }
      }
   }
}

