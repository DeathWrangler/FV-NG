package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.FarmGameObject;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Managers.FarmVillageManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Crafting.VillageResourceBuildingWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class FarmVillageToolTipRequirementSlot extends ZwSlotFrame
   {
      
      private var m_slotIndex:int;
      
      private var m_itemName:String;
      
      private var m_quantity:int;
      
      private var m_icon:FarmIcon;
      
      private var m_item:FarmItem;
      
      private var m_count:ZwTextField;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_checkMark:ZwWidget;
      
      private var m_storageCount:int;
      
      private var m_areRequirementsFulfilled:Boolean;
      
      public function FarmVillageToolTipRequirementSlot(element:MovieClip, quantity:int, itemName:String)
      {
         super(element);
         this.m_itemName = itemName;
         this.m_quantity = quantity;
         this.m_count = new ZwTextField(m_element["count_tf"],"");
         addWidget(this.m_count);
         if(m_element["icon_mc"])
         {
            this.m_icon = new FarmIcon(m_element["icon_mc"],null);
            this.m_icon.registerEventListener(MouseEvent.CLICK,this.onClickIcon);
            addWidget(this.m_icon);
         }
         if(m_element["buy_mc"])
         {
            this.m_buyButton = new FarmAnimatedCashButton(m_element["buy_mc"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageBuyAll"),"",this.onBuyButtonClicked,false,false,true);
            addWidget(this.m_buyButton,false);
         }
         if(m_element["check_mc"])
         {
            this.m_checkMark = new ZwWidget(m_element["check_mc"]);
            addWidget(this.m_checkMark,false);
         }
      }
      
      public function update() : void
      {
         var countString:String = null;
         var cost:TextField = null;
         if(this.m_itemName)
         {
            this.m_storageCount = FarmVillageManager.instance.getInventoryCountForItem(this.m_itemName);
            countString = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"FarmVillageCount",{
               "count":this.m_storageCount.toString(),
               "required":this.m_quantity.toString()
            });
            if(m_element["count_tf"])
            {
               if(this.m_count)
               {
                  this.m_count.text = countString;
               }
               else
               {
                  this.m_count = new ZwTextField(m_element["count_tf"],countString);
                  addWidget(this.m_count);
               }
            }
            this.m_item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
            if(m_element["icon_mc"])
            {
               if(this.m_icon)
               {
                  if(this.m_icon.iconUrl != this.m_item.iconUrl)
                  {
                     this.m_icon.loadIcon(this.m_item.iconUrl);
                  }
                  this.m_icon.attachTooltip(new FarmTextTooltip(FarmVillageManager.instance.getFindItemInBuildingString(this.m_itemName)));
               }
            }
            if(this.m_storageCount >= this.m_quantity)
            {
               this.m_areRequirementsFulfilled = true;
            }
            else
            {
               this.m_areRequirementsFulfilled = false;
            }
         }
         if(this.m_areRequirementsFulfilled && Boolean(this.m_checkMark))
         {
            this.m_checkMark.visible = true;
            this.m_buyButton.visible = false;
         }
         else if(!this.m_areRequirementsFulfilled && Boolean(this.m_buyButton))
         {
            cost = this.m_buyButton.element["amount_tf"];
            if(cost)
            {
               cost.text = (this.getRequirementCashCost() * this.m_quantity - this.m_storageCount).toString();
            }
            this.m_checkMark.visible = false;
            this.m_buyButton.visible = true;
         }
      }
      
      public function setRequirements(itemName:String, quantity:int, slotIndex:int) : void
      {
         if(Boolean(this.m_itemName != itemName) && Boolean(this.m_icon) && Boolean(this.m_icon.tooltip))
         {
            this.m_icon.tooltip.release();
            this.m_icon.detachTooltip();
         }
         this.m_itemName = itemName;
         this.m_quantity = quantity;
         this.m_slotIndex = slotIndex;
         this.update();
      }
      
      public function areRequirementsFulfilled() : Boolean
      {
         return this.m_areRequirementsFulfilled;
      }
      
      public function getStorageCount() : int
      {
         return this.m_storageCount;
      }
      
      public function getRequirementQuantity() : int
      {
         return this.m_quantity;
      }
      
      public function getRequirementItemCode() : String
      {
         var result:String = "";
         if(this.m_item)
         {
            result = this.m_item.code;
         }
         return result;
      }
      
      public function getRequirementCashCost() : int
      {
         var result:int = 0;
         if(this.m_item)
         {
            result = this.m_item.cash;
         }
         return result;
      }
      
      public function getRequirementItemName() : String
      {
         return this.m_itemName;
      }
      
      private function onClickIcon(event:MouseEvent) : void
      {
         var buildingObject:Object = null;
         var worldItems:Array = null;
         var farmGameObject:FarmGameObject = null;
         if(this.m_itemName)
         {
            buildingObject = FarmVillageManager.instance.getItemsBuilding(this.m_itemName);
            if(buildingObject)
            {
               if(buildingObject.buildingName)
               {
                  worldItems = Global.world.getObjectsByName(buildingObject.buildingName);
                  if(Boolean(worldItems) && worldItems.length < 1)
                  {
                     UI.displayMiniMarketDialog([buildingObject.buildingName]);
                  }
                  else if(buildingObject.hasOwnProperty("inCraftshop") && Boolean(buildingObject.inCraftshop))
                  {
                     if(FarmVillageManager.instance.isEligibleForFarmVillageRecipe(this.m_itemName))
                     {
                        UI.displayPopup(new VillageResourceBuildingWindow(null,this.m_itemName));
                        StatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,"order_board","tooltip_click",this.m_itemName);
                     }
                  }
                  else
                  {
                     farmGameObject = worldItems[0] as FarmGameObject;
                     if(farmGameObject != null)
                     {
                        farmGameObject.setHighlighted(true);
                        farmGameObject.centerOn();
                     }
                  }
               }
            }
         }
      }
      
      override public function release() : void
      {
         this.m_itemName = null;
         this.m_icon = null;
         this.m_item = null;
         this.m_count = null;
         this.m_buyButton = null;
         this.m_checkMark = null;
         super.release();
      }
      
      private function onBuyButtonClicked(event:Event) : void
      {
         FarmVillageManager.instance.buyItem(this.m_itemName,this.m_quantity,this.m_slotIndex);
      }
   }
}

