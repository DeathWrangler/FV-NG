package Widgets.Slots.FeatureCrafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureCrafting.FeatureCraftingRecipe;
   import Classes.FeatureCrafting.FeatureCraftingStation;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingIngredientSlotContainerFrame;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingRecipeMasteryFrame;
   import Widgets.Frames.FeatureCrafting.FeatureCraftingRecipeSlotContainerFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingRecipesWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class FeatureCraftingRecipeSlot extends ZwSlotFrame
   {
      
      private static const DOUBLE_CLICK_DELAY:int = 500;
      
      private static const ICON_SIZE:int = 100;
      
      protected var m_parentWindow:FeatureCraftingRecipesWindow;
      
      protected var m_data:FeatureCraftingRecipe;
      
      private var m_lastClickTime:int;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_timeTextField:ZwTextField;
      
      private var m_messageTextField:ZwTextField;
      
      private var m_masteryFrame:FeatureCraftingRecipeMasteryFrame;
      
      private var m_ingredientSlots:FeatureCraftingIngredientSlotContainerFrame;
      
      private var m_makeButton:FarmAnimatedTextButton;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_harvestTimer:Timer;
      
      public function FeatureCraftingRecipeSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.clearScale();
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.name_tf," ")) as ZwTextField;
         this.m_timeTextField = addWidget(new ZwTextField(m_element.recipeTime_tf," ")) as ZwTextField;
         this.m_messageTextField = addWidget(new ZwTextField(m_element.unlock_tf," ")) as ZwTextField;
         this.m_masteryFrame = addWidget(new FeatureCraftingRecipeMasteryFrame(m_element.mastery_mc)) as FeatureCraftingRecipeMasteryFrame;
         this.m_ingredientSlots = addWidget(new FeatureCraftingIngredientSlotContainerFrame(m_element.ingredients_mc)) as FeatureCraftingIngredientSlotContainerFrame;
         this.m_makeButton = addWidget(new FarmAnimatedTextButton(m_element.make_bt,"",this.onMakeButtonClick)) as FarmAnimatedTextButton;
         this.m_buyButton = addWidget(new FarmAnimatedCashButton(m_element.buyAll_bt,"","00",this.onBuyButtonClick)) as FarmAnimatedCashButton;
      }
      
      override public function release() : void
      {
         this.m_parentWindow = null;
         this.m_icon = null;
         this.m_nameTextField = null;
         this.m_timeTextField = null;
         this.m_messageTextField = null;
         this.m_masteryFrame = null;
         this.m_ingredientSlots = null;
         this.m_makeButton = null;
         this.m_buyButton = null;
         this.stopHarvestTimer();
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.stopHarvestTimer();
         this.m_data = data as FeatureCraftingRecipe;
         if(this.m_data)
         {
            this.refresh();
         }
      }
      
      public function get data() : FeatureCraftingRecipe
      {
         return this.m_data;
      }
      
      public function get parentWindow() : FeatureCraftingRecipesWindow
      {
         if(!this.m_parentWindow)
         {
            this.m_parentWindow = getAncestorByClassType(FeatureCraftingRecipesWindow) as FeatureCraftingRecipesWindow;
         }
         return this.m_parentWindow;
      }
      
      public function refresh() : void
      {
         var station:FeatureCraftingStation = null;
         var secondsToFinish:int = 0;
         var hours:int = 0;
         var minutes:int = 0;
         var seconds:int = 0;
         var finishTimeString:String = null;
         var masteryLevel:int = 0;
         var masteryPoints:int = 0;
         var pointsForCurrentLevel:int = 0;
         var pointsForNextLevel:int = 0;
         var masteryProgress:int = 0;
         var masteryGoal:int = 0;
         if(this.m_data)
         {
            if(this.parentWindow)
            {
               station = this.parentWindow.station;
            }
            else
            {
               station = this.data.station;
            }
            this.m_icon.loadIcon(this.m_data.iconUrl);
            this.m_icon.visible = true;
            this.m_nameTextField.text = this.m_data.friendlyTitle;
            this.m_nameTextField.visible = true;
            secondsToFinish = this.m_data.finishTime;
            hours = int(secondsToFinish / 3600);
            minutes = int(secondsToFinish / 60 % 60);
            seconds = int(secondsToFinish % 60);
            finishTimeString = "";
            if(secondsToFinish >= 3600)
            {
               finishTimeString = ZLocUtils.t("Crafting","CraftingMain_RecipeTimeHours",{"hourNum":hours});
            }
            else if(secondsToFinish >= 60)
            {
               finishTimeString = ZLocUtils.t("Crafting","CraftingMain_RecipeTimeMins",{"minuteNum":minutes});
            }
            else
            {
               finishTimeString = ZLocUtils.t("Crafting","CraftingMain_RecipeTimeSecs",{"secondNum":seconds});
            }
            this.m_timeTextField.text = finishTimeString;
            this.m_timeTextField.visible = true;
            masteryLevel = this.m_data.masteryStarCount;
            masteryPoints = this.m_data.masteryHarvests;
            pointsForCurrentLevel = this.m_data.getMasteryHarvestsForGivenLevel(masteryLevel);
            pointsForNextLevel = this.m_data.getMasteryHarvestsForGivenLevel(masteryLevel + 1);
            masteryProgress = masteryPoints - pointsForCurrentLevel;
            masteryGoal = pointsForNextLevel - pointsForCurrentLevel;
            this.m_masteryFrame.populate(masteryLevel,masteryProgress,masteryGoal);
            this.m_masteryFrame.visible = true;
            this.m_ingredientSlots.items = this.m_data.requiredGoods();
            this.m_ingredientSlots.visible = true;
            if(this.m_data.unlocked)
            {
               if(station.active && station.currentRecipeName() == this.m_data.name)
               {
                  this.refreshHarvestState();
               }
               else if(this.m_data.hasAllRequiredGoods)
               {
                  this.m_makeButton.text = "Make";
                  if(station.active)
                  {
                     this.m_makeButton.enabled = false;
                     this.m_makeButton.visible = true;
                  }
                  else
                  {
                     this.m_makeButton.enabled = this.m_makeButton.visible = true;
                  }
                  this.m_messageTextField.visible = false;
                  this.m_buyButton.enabled = this.m_buyButton.visible = false;
               }
               else
               {
                  this.m_makeButton.text = "Make";
                  this.m_makeButton.enabled = false;
                  this.m_makeButton.visible = true;
                  this.m_messageTextField.visible = false;
                  this.m_buyButton.text = "Buy All";
                  this.m_buyButton.setAmountText(String(this.m_data.recipeBuyAllGoodsCost()));
                  this.m_buyButton.enabled = this.m_buyButton.visible = true;
               }
            }
            else if(this.m_data.unlockCost > 0)
            {
               this.m_makeButton.enabled = this.m_makeButton.visible = false;
               this.m_messageTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"RecipeWindow_UnlockMessage",{"level":this.m_data.unlockLevel});
               this.m_messageTextField.visible = true;
               this.m_buyButton.text = "Unlock";
               this.m_buyButton.setAmountText(String(this.m_data.unlockCost));
               this.m_buyButton.enabled = this.m_buyButton.visible = true;
            }
            else
            {
               this.m_makeButton.text = "Locked";
               this.m_makeButton.enabled = false;
               this.m_messageTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"RecipeWindow_UnlockMessage",{"level":this.m_data.unlockLevel});
               this.m_messageTextField.visible = true;
               this.m_buyButton.enabled = this.m_buyButton.visible = false;
            }
         }
      }
      
      public function refreshHarvestState() : void
      {
         var station:FeatureCraftingStation = null;
         var timeLeft:int = 0;
         var timeLeftText:String = null;
         if(Boolean(m_element) && Boolean(this.m_data))
         {
            if(this.parentWindow)
            {
               station = this.parentWindow.station;
            }
            else
            {
               station = this.data.station;
            }
            if(Boolean(station) && station.active)
            {
               if(station.isReady())
               {
                  this.m_makeButton.text = "Harvest";
                  this.m_makeButton.enabled = this.m_makeButton.visible = true;
                  this.m_messageTextField.visible = false;
                  this.m_buyButton.enabled = this.m_buyButton.visible = false;
                  this.stopHarvestTimer();
               }
               else
               {
                  this.m_buyButton.enabled = this.m_buyButton.visible = true;
                  this.m_buyButton.text = "Finish";
                  this.m_buyButton.setAmountText(station.getCompleteNowCost().toString());
                  this.m_makeButton.enabled = this.m_makeButton.visible = false;
                  timeLeft = station.getEndTime() - GlobalEngine.serverTime / 1000;
                  timeLeftText = FarmGameUtil.toFriendlyTime(timeLeft);
                  this.m_messageTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"RecipeWindow_TimeRemainingMessage",{"time":timeLeftText});
                  this.m_messageTextField.visible = true;
                  this.startHarvestTimer();
               }
            }
            else
            {
               this.stopHarvestTimer();
            }
         }
         else
         {
            this.stopHarvestTimer();
         }
      }
      
      private function startHarvestTimer() : void
      {
         if(!this.m_harvestTimer)
         {
            this.m_harvestTimer = new Timer(1000);
            this.m_harvestTimer.addEventListener(TimerEvent.TIMER,this.onHarvestTimer);
            this.m_harvestTimer.start();
         }
      }
      
      private function stopHarvestTimer() : void
      {
         if(this.m_harvestTimer)
         {
            this.m_harvestTimer.stop();
            this.m_harvestTimer.removeEventListener(TimerEvent.TIMER,this.onHarvestTimer);
            this.m_harvestTimer = null;
         }
      }
      
      private function onHarvestTimer(event:TimerEvent) : void
      {
         this.refreshHarvestState();
      }
      
      private function onMakeButtonClick(event:MouseEvent) : void
      {
         var station:FeatureCraftingStation = null;
         var stationSlot:FeatureCraftingStationSlot = null;
         if(Boolean(this.m_makeButton.enabled) && Boolean(this.m_data) && GlobalEngine.currentTime >= this.m_lastClickTime + DOUBLE_CLICK_DELAY)
         {
            if(this.parentWindow)
            {
               station = this.parentWindow.station;
            }
            else
            {
               station = this.data.station;
            }
            if(station.isReady() && station.currentRecipeName() == this.m_data.name)
            {
               station.harvest();
               (m_parent as FeatureCraftingRecipeSlotContainerFrame).refreshDisplay();
               if(this.data.system.currentNPCWindow)
               {
                  this.data.system.currentNPCWindow.refresh();
               }
            }
            else if(this.parentWindow)
            {
               this.parentWindow.startRecipe(this.m_data.name);
            }
            else if(Boolean(this.data.station) && Boolean(this.data.system.currentNPCWindow) && this.data.system.currentNPCWindow.hasSingleRecipeWindow)
            {
               this.data.station.startRecipe(this.m_data.name);
               this.data.system.currentNPCWindow.singleRecipeWindow.toggleSingleRecipeFrame(false);
               stationSlot = this.m_data.system.currentContentsWindow.recipeStationSlots.getSlotIdByStation(station);
               if(stationSlot)
               {
                  stationSlot.refresh();
               }
            }
            this.m_lastClickTime = GlobalEngine.currentTime;
         }
      }
      
      private function onBuyButtonClick(event:MouseEvent) : void
      {
         var station:FeatureCraftingStation = null;
         var text:String = null;
         var message:String = null;
         if(Boolean(this.m_buyButton.enabled) && Boolean(this.m_data) && GlobalEngine.currentTime >= this.m_lastClickTime + DOUBLE_CLICK_DELAY)
         {
            if(this.m_data.unlocked)
            {
               if(this.parentWindow)
               {
                  station = this.parentWindow.station;
               }
               else
               {
                  station = this.data.station;
               }
               if(station.active && station.currentRecipeName() == this.m_data.name && !station.isReady())
               {
                  station.completeNow();
               }
               else if(this.m_data.recipeBuyAllGoodsCost() >= 10)
               {
                  text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"RecipeWindow_BuyAll_Confirmation",{"cost":this.m_data.recipeBuyAllGoodsCost()});
                  UI.displayMessage(text,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyAllMessageClose,"FeatureCraftingUnlockStorage",true);
               }
               else
               {
                  this.m_data.buyAllGoods();
                  (m_parent as FeatureCraftingRecipeSlotContainerFrame).refreshDisplay();
               }
               (m_parent as FeatureCraftingRecipeSlotContainerFrame).refreshDisplay();
            }
            else
            {
               message = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,"RecipeWindow_UnlockButton_Confirmation",{
                  "cost":this.m_data.unlockCost,
                  "recipeName":this.m_data.friendlyTitle
               });
               UI.displayMessage(message,GenericPopup.TYPE_ACCEPTCANCEL,this.onUnlockMessageClose,"FeatureCraftingUnlockRecipe",true);
            }
            this.m_lastClickTime = GlobalEngine.currentTime;
         }
      }
      
      private function onBuyAllMessageClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            this.m_data.buyAllGoods();
            (m_parent as FeatureCraftingRecipeSlotContainerFrame).refreshDisplay();
         }
      }
      
      private function onUnlockMessageClose(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            this.m_data.buyUnlock();
            (m_parent as FeatureCraftingRecipeSlotContainerFrame).refreshDisplay();
         }
      }
   }
}

