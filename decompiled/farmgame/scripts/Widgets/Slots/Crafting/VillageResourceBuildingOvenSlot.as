package Widgets.Slots.Crafting
{
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingRecipeQueueManager;
   import Managers.FarmStatsManager;
   import Managers.FarmVillageManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.VillageResourceBuildingOvenFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.WidgetTooltip;
   import Widgets.Windows.Crafting.VillageResourceBuildingWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class VillageResourceBuildingOvenSlot extends ZwSlotFrame
   {
      
      private var m_craftSkill:String = "";
      
      private var m_ovenSlot:int = -1;
      
      private var m_recipeItem:RecipeItem = null;
      
      private var m_recipeId:String = "";
      
      private var m_finishNowPrice:Number = -1;
      
      private var m_finishTimeText:String = "";
      
      private var m_recipeState:String = "";
      
      private var m_unlockData:Object = null;
      
      private var m_parentWindow:VillageResourceBuildingWindow = null;
      
      private var m_openSlot:FarmIcon = null;
      
      private var m_finishNowTooltipFrame:ZwFrame = null;
      
      private var m_finishNowTooltip:WidgetTooltip = null;
      
      private var m_finishNowHeader:ZwTextField = null;
      
      private var m_finishNowSubHeader:ZwTextField = null;
      
      private var m_finishNowBuyButton:FarmAnimatedCashButton = null;
      
      private var m_hitWidget:ZwWidget = null;
      
      private var m_recipeIcon:FarmIcon = null;
      
      private var m_lockIcon:MovieClip = null;
      
      private var m_unlockFCButton:FarmAnimatedCashButton = null;
      
      private var m_unlockVCButton:FarmAnimatedCashButton = null;
      
      private var m_progressBar:ZwWidget = null;
      
      private var m_progressFrame:ZwFrame = null;
      
      private var m_readyFrame:MovieClip = null;
      
      public function VillageResourceBuildingOvenSlot(element:DisplayObject, parentWindow:VillageResourceBuildingWindow, craftSkill:String)
      {
         this.m_parentWindow = parentWindow;
         this.m_craftSkill = craftSkill;
         super(element);
         if(m_element.hasOwnProperty("empty_mc"))
         {
            this.m_openSlot = addWidget(new FarmIcon(m_element.empty_mc)) as FarmIcon;
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_recipeIcon = addWidget(new FarmIcon(m_element.icon_mc,"")) as FarmIcon;
         }
         if(m_element.hasOwnProperty("lockIcon_mc"))
         {
            this.m_lockIcon = m_element.lockIcon_mc as MovieClip;
         }
         if(m_element.hasOwnProperty("unlockFC_bt"))
         {
            this.m_unlockFCButton = addWidget(new FarmAnimatedCashButton(m_element.unlockFC_bt,ZLocUtils.t("Crafting","VillageResourceBuildingOvenSlot_UnlockButton"),"0",this.onUnlockSlotButtonClick,false,false,true)) as FarmAnimatedCashButton;
         }
         if(m_element.hasOwnProperty("unlockVC_bt"))
         {
            this.m_unlockVCButton = addWidget(new FarmAnimatedCashButton(m_element.unlockVC_bt,ZLocUtils.t("Crafting","VillageResourceBuildingOvenSlot_UnlockButton"),"0",this.onUnlockSlotButtonClick)) as FarmAnimatedCashButton;
         }
         if(m_element.hasOwnProperty("progressBar_mc") && Boolean(m_element.progressBar_mc.hasOwnProperty("bar_mc")))
         {
            this.m_progressFrame = addWidget(new ZwFrame(m_element.progressBar_mc)) as ZwFrame;
            this.m_progressBar = this.m_progressFrame.addWidget(new ZwWidget(m_element.progressBar_mc.bar_mc)) as ZwWidget;
         }
         if(m_element.hasOwnProperty("hit_bt"))
         {
            this.m_hitWidget = addWidget(new ZwWidget(m_element.hit_bt)) as ZwWidget;
         }
         if(m_element.hasOwnProperty("tooltip_mc"))
         {
            this.m_finishNowTooltipFrame = new ZwFrame(m_element.tooltip_mc as DisplayObject) as ZwFrame;
            if(m_element.tooltip_mc.hasOwnProperty("header_tf"))
            {
               this.m_finishNowHeader = this.m_finishNowTooltipFrame.addWidget(new ZwTextField(m_element.tooltip_mc.header_tf,"")) as ZwTextField;
            }
            if(m_element.tooltip_mc.hasOwnProperty("subheader_tf"))
            {
               this.m_finishNowSubHeader = this.m_finishNowTooltipFrame.addWidget(new ZwTextField(m_element.tooltip_mc.subheader_tf,"")) as ZwTextField;
            }
            if(m_element.tooltip_mc.hasOwnProperty("buyAll_bt"))
            {
               this.m_finishNowBuyButton = this.m_finishNowTooltipFrame.addWidget(new FarmAnimatedCashButton(m_element.tooltip_mc.buyAll_bt,ZLocUtils.t("Crafting","CraftingMain_Finish"),"",this.onBuyButtonClick,false,false,true)) as FarmAnimatedCashButton;
            }
            this.m_finishNowTooltip = new WidgetTooltip(this.m_finishNowTooltipFrame,this.tooltipRefresh);
            this.m_finishNowTooltip.fixed = true;
            this.m_finishNowTooltip.interactive = true;
         }
         if(m_element.hasOwnProperty("ready_mc"))
         {
            this.m_readyFrame = m_element.ready_mc as MovieClip;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var simpleButton:SimpleButton = null;
         var unlockPrice:String = null;
         super.populate(data);
         detachTooltip();
         if(this.m_recipeIcon)
         {
            this.m_recipeIcon.visible = false;
         }
         this.m_unlockData = this.m_parentWindow.getUnlockPriceAndCurrency();
         this.m_recipeId = "";
         this.m_recipeItem = null;
         if(data.hasOwnProperty("recipeId"))
         {
            this.m_recipeId = data.recipeId;
         }
         if(data.hasOwnProperty("recipeItem"))
         {
            this.m_recipeItem = data.recipeItem;
         }
         if(data.hasOwnProperty("ovenSlot"))
         {
            this.m_ovenSlot = data.ovenSlot;
         }
         if(data.hasOwnProperty("finishTime"))
         {
            this.m_finishTimeText = data.finishTime;
         }
         if(this.m_readyFrame)
         {
            this.m_readyFrame.visible = false;
         }
         if(this.m_lockIcon)
         {
            this.m_lockIcon.visible = false;
         }
         if(this.m_finishNowTooltip)
         {
            detachTooltip();
         }
         if(data.hasOwnProperty("recipeState"))
         {
            this.m_recipeState = data.recipeState;
            switch(this.m_recipeState)
            {
               case VillageResourceBuildingOvenFrame.ICON_STATE_RECIPE_COMPLETE:
                  if(this.m_readyFrame)
                  {
                     this.m_readyFrame.visible = true;
                  }
                  if(this.m_hitWidget)
                  {
                     simpleButton = this.m_hitWidget.element as SimpleButton;
                     simpleButton.addEventListener(MouseEvent.CLICK,this.onHitButtonClick);
                     simpleButton.useHandCursor = true;
                     this.m_hitWidget.visible = true;
                  }
                  if(Boolean(this.m_progressFrame) && Boolean(this.m_progressBar))
                  {
                     this.m_progressFrame.visible = true;
                     (this.m_progressBar.element as MovieClip).scaleX = 1;
                  }
                  this.showRecipeIcon();
                  break;
               case VillageResourceBuildingOvenFrame.ICON_STATE_IN_PROGRESS:
                  if(this.m_finishNowTooltip)
                  {
                     this.updateFinishNowInfo();
                     attachTooltip(this.m_finishNowTooltip);
                  }
                  if(Boolean(this.m_progressFrame) && Boolean(this.m_progressBar) && data.hasOwnProperty("percent"))
                  {
                     this.m_progressFrame.visible = true;
                     (this.m_progressBar.element as MovieClip).scaleX = data.percent;
                  }
                  this.showRecipeIcon();
                  break;
               case VillageResourceBuildingOvenFrame.ICON_STATE_OPEN:
                  if(this.m_openSlot)
                  {
                     this.m_openSlot.visible = true;
                  }
                  break;
               case VillageResourceBuildingOvenFrame.ICON_STATE_UNLOCKED:
                  if(Boolean(this.m_unlockData) && Boolean(this.m_unlockData.value))
                  {
                     unlockPrice = this.m_unlockData.value;
                     if(Boolean(this.m_unlockVCButton) && this.m_unlockData.currencyType == VillageResourceBuildingWindow.BUYABLE_WITH_CURRENCY)
                     {
                        this.m_unlockVCButton.visible = true;
                        this.m_unlockVCButton.setAmountText(unlockPrice);
                     }
                     else if(Boolean(this.m_unlockFCButton) && this.m_unlockData.currencyType == VillageResourceBuildingWindow.BUYABLE_WITH_CASH)
                     {
                        this.m_unlockFCButton.visible = true;
                        this.m_unlockFCButton.setAmountText(unlockPrice);
                     }
                  }
                  if(this.m_lockIcon)
                  {
                     this.m_lockIcon.visible = true;
                  }
                  break;
               case VillageResourceBuildingOvenFrame.ICON_STATE_LOCKED:
               case "":
               default:
                  if(this.m_lockIcon)
                  {
                     this.m_lockIcon.visible = true;
                  }
            }
         }
      }
      
      private function showRecipeIcon() : void
      {
         if(Boolean(this.m_recipeItem) && Boolean(this.m_recipeItem.image) && Boolean(this.m_recipeIcon))
         {
            this.m_recipeIcon.loadIcon(this.m_recipeItem.image);
            this.m_recipeIcon.setSmoothing(true);
            this.m_recipeIcon.visible = true;
         }
      }
      
      private function updateFinishNowPrice() : void
      {
         var realTimeRemaining:int = 0;
         var hoursToFinish:Number = NaN;
         if(this.m_recipeItem)
         {
            realTimeRemaining = this.m_recipeItem.realTimeRemaining;
            hoursToFinish = Math.round(Number(realTimeRemaining / FarmGameUtil.NUM_SECS_IN_HOUR));
            this.m_finishNowPrice = hoursToFinish > 0 ? hoursToFinish : 1;
         }
      }
      
      private function updateFinishNowInfo() : void
      {
         if(Boolean(this.m_finishNowTooltipFrame && this.m_finishNowSubHeader && this.m_finishNowBuyButton) && Boolean(this.m_finishNowPrice) && Boolean(this.m_finishTimeText))
         {
            this.m_finishNowSubHeader.text = ZLocUtils.t("Crafting","CraftingMain_ReadyTime",{"time":this.m_finishTimeText});
            this.m_finishNowSubHeader.visible = true;
            this.updateFinishNowPrice();
            this.m_finishNowBuyButton.setAmountText(this.m_finishNowPrice.toString());
            this.m_finishNowBuyButton.visible = true;
         }
      }
      
      override public function release() : void
      {
         this.m_recipeItem = null;
         this.m_unlockData = null;
         this.m_parentWindow = null;
         this.m_openSlot = null;
         this.m_finishNowTooltipFrame = null;
         this.m_finishNowTooltip = null;
         this.m_finishNowHeader = null;
         this.m_finishNowSubHeader = null;
         this.m_finishNowBuyButton = null;
         if(this.m_hitWidget)
         {
            (this.m_hitWidget.element as SimpleButton).removeEventListener(MouseEvent.CLICK,this.onHitButtonClick);
         }
         this.m_hitWidget = null;
         this.m_recipeIcon = null;
         this.m_lockIcon = null;
         this.m_unlockFCButton = null;
         this.m_unlockVCButton = null;
         this.m_progressBar = null;
         this.m_progressFrame = null;
         super.release();
      }
      
      private function onBuyButtonClick(event:Event) : void
      {
         if(Boolean(this.m_recipeId) && this.m_finishNowPrice > 0)
         {
            this.m_parentWindow.finishedRecipeRushed(this.m_recipeId,this.m_ovenSlot,this.m_finishNowPrice);
         }
      }
      
      private function onHitButtonClick(event:MouseEvent) : void
      {
         if(Global.player.craftingState.inventoryState.villageStorageCurrentCapacity + 1 <= Global.player.craftingState.inventoryState.villageStorageMaxCapacity)
         {
            if(Boolean(this.m_parentWindow && this.m_recipeItem) && Boolean(this.m_recipeItem.isComplete) && this.m_recipeState == VillageResourceBuildingOvenFrame.ICON_STATE_RECIPE_COMPLETE)
            {
               this.m_parentWindow.pause();
               this.m_parentWindow.finishRecipe(this.m_recipeId,this.m_ovenSlot);
            }
         }
         else
         {
            if(this.m_parentWindow)
            {
               this.m_parentWindow.close();
            }
            FarmVillageManager.instance.onExpandStorage();
         }
      }
      
      private function onUnlockSlotButtonClick(event:Event) : void
      {
         if(Boolean(this.m_parentWindow) && Boolean(this.m_unlockData))
         {
            this.m_parentWindow.unlockBuilding();
            FarmStatsManager.count(FarmVillageManager.FARM_VILLAGE_STAT,VillageResourceBuildingWindow.CRAFT_SHOP_STAT,"station_unlcok",(this.m_parentWindow.m_villageResourceBuilding.storageLevel + 1).toString(),this.m_unlockData.value,this.m_unlockData.currencyType);
         }
      }
      
      private function tooltipRefresh() : void
      {
         var recipesInProgress:Array = CraftingRecipeQueueManager.getInstanceByCraftType(this.m_craftSkill).recipeQueue;
         var recipesInProgressLength:int = int(recipesInProgress.length);
         var recipeItem:RecipeItem = null;
         var timeRemaining:int = 0;
         for(var i:int = 0; i < recipesInProgressLength; i++)
         {
            if(recipesInProgress[i])
            {
               recipeItem = recipesInProgress[i] as RecipeItem;
               if(recipeItem.ovenSlot == this.m_ovenSlot && recipeItem.id == this.m_recipeId)
               {
                  this.m_recipeItem = recipeItem;
                  if(recipeItem.serverStartTS > 0 && recipeItem.realTimeRemaining <= 0)
                  {
                     detachTooltip();
                     if(this.m_parentWindow)
                     {
                        this.m_parentWindow.update();
                     }
                  }
                  else
                  {
                     timeRemaining = recipeItem.realTimeRemaining;
                     this.m_finishTimeText = FarmGameUtil.toFriendlyTime(recipeItem.realTimeRemaining);
                     if(Boolean(this.m_progressFrame) && Boolean(this.m_progressBar))
                     {
                        this.m_progressFrame.visible = true;
                        (this.m_progressBar.element as MovieClip).scaleX = Number((recipeItem.secondsToCook - timeRemaining) / recipeItem.secondsToCook);
                     }
                  }
                  break;
               }
            }
         }
         this.updateFinishNowInfo();
      }
   }
}

