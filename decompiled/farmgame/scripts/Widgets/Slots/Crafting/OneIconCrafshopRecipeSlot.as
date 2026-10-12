package Widgets.Slots.Crafting
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.CraftingSkillState;
   import Classes.crafting.RecipeItem;
   import Classes.crafting.RecipeState;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.ImpulseBuy;
   import Events.ImpulseBuyEvent;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.CraftshopRecipeFinishFrame;
   import Widgets.Frames.Market.MarketSlotItemTimerFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Tooltips.Market.MarketTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class OneIconCrafshopRecipeSlot extends CraftingRecipeBaseSlot
   {
      
      private static const MAX_MASTERY_LEVEL:int = 3;
      
      private static const MASTERY_PROGRESS_BAR_MAX_WIDTH:int = 70;
      
      private static const RECIPE_NO_END_TIME:Number = -1;
      
      protected var m_recipeCookTime:ZwTextField;
      
      private var m_mastery:ZwFrame;
      
      private var m_stars:ZwFrame;
      
      private var m_progressBar:ZwWidget;
      
      private var m_progressTrack:ZwWidget;
      
      protected var m_recipeSlots:Array = new Array();
      
      protected var m_crewSlots:Array = new Array();
      
      protected var m_crewBackground:ZwFrame;
      
      protected var m_recipeCount:ZwTextField;
      
      private var m_impulseBuyDialog:ImpulseBuy = null;
      
      protected var m_finishNow:CraftshopRecipeFinishFrame;
      
      protected var m_getBushels:FarmAnimatedTextButton;
      
      protected var m_getIngredients:FarmAnimatedTextButton;
      
      protected var m_expirationWarning:ZwFrame = null;
      
      protected var m_expireTextFrame:ZwFrame = null;
      
      protected var m_expirationWarningHeader:ZwTextField = null;
      
      private var m_recipeUiButton:FarmAnimatedTextButton = null;
      
      private var m_bushelCount:ZwTextField;
      
      private var m_timerFrame:MarketSlotItemTimerFrame;
      
      private var m_specialCard:ZwWidget;
      
      public function OneIconCrafshopRecipeSlot(element:DisplayObject, callBackObject:Object)
      {
         super(element,callBackObject);
         if(m_element.hasOwnProperty("counter_tf"))
         {
            this.m_recipeCount = addWidget(new ZwTextField(m_element.counter_tf,"counter_tf")) as ZwTextField;
         }
         if(m_element.hasOwnProperty("mastery_mc"))
         {
            this.m_mastery = addWidget(new ZwFrame(m_element.mastery_mc)) as ZwFrame;
            this.m_mastery.attachTooltip(new FarmTextTooltip(""));
            if(m_element.mastery_mc.stars_mc)
            {
               this.m_stars = addWidget(new ZwFrame(m_element.mastery_mc.stars_mc)) as ZwFrame;
               (this.m_stars.element as MovieClip).stop();
            }
            if(m_element.mastery_mc.progressBar_mc)
            {
               this.m_progressBar = addWidget(new ZwWidget(m_element.mastery_mc.progressBar_mc)) as ZwWidget;
            }
            if(m_element.mastery_mc.progressTrack_mc)
            {
               this.m_progressTrack = addWidget(new ZwWidget(m_element.mastery_mc.progressTrack_mc)) as ZwWidget;
            }
         }
         if(m_element.hasOwnProperty("recipeTime_tf"))
         {
            this.m_recipeCookTime = addWidget(new ZwTextField(m_element.recipeTime_tf,"")) as ZwTextField;
         }
         if(m_element.hasOwnProperty("recipeui_bt"))
         {
            this.m_recipeUiButton = addWidget(new FarmAnimatedTextButton(m_element.recipeui_bt,ZLocUtils.t("Crafting","CraftingMain_MakeIt"),this.pressOpenRecipeUI)) as FarmAnimatedTextButton;
            this.m_recipeUiButton.attachTooltip(new MarketTooltip());
         }
         if(m_element.hasOwnProperty("bushelCounter_tf"))
         {
            this.m_bushelCount = addWidget(new ZwTextField(m_element.bushelCounter_tf,"")) as ZwTextField;
         }
         if(m_element.hasOwnProperty("specialCard_mc"))
         {
            this.m_specialCard = addWidget(new ZwWidget(m_element.specialCard_mc)) as ZwWidget;
         }
         if(m_element.hasOwnProperty("expiration_bt"))
         {
            this.m_expirationWarning = addWidget(new ZwFrame(m_element.expiration_bt),false) as ZwFrame;
            (this.m_expirationWarning.element as DisplayObject).addEventListener(MouseEvent.MOUSE_OVER,this.onExpireMouseOver);
            (this.m_expirationWarning.element as DisplayObject).addEventListener(MouseEvent.MOUSE_OUT,this.onExpireMouseOut);
            if(Boolean(m_element.textFields_mc) && Boolean(m_element.textFields_mc.discription_tf) && Boolean(m_element.textFields_mc.title_tf))
            {
               this.m_expireTextFrame = addWidget(new ZwFrame(m_element.textFields_mc),false) as ZwFrame;
               this.m_expireTextFrame.addWidget(new ZwTextField(m_element.textFields_mc.discription_tf,ZLocUtils.t("Dialogs","CraftshopRecipeExpiring")));
               this.m_expirationWarningHeader = this.m_expireTextFrame.addWidget(new ZwTextField(m_element.textFields_mc.title_tf,"")) as ZwTextField;
            }
         }
         if(m_element.expiration_mc)
         {
            this.m_timerFrame = addWidget(new MarketSlotItemTimerFrame(m_element.expiration_mc,this.onExpireMouseOver,this.onExpireMouseOut)) as MarketSlotItemTimerFrame;
         }
         if(m_recipeIcon)
         {
            m_recipeIcon.attachTooltip(new MarketTooltip());
         }
      }
      
      private function onImpulseBuyCancel(event:ImpulseBuyEvent) : void
      {
         if(this.m_impulseBuyDialog)
         {
            this.m_impulseBuyDialog.removeEventListener(ImpulseBuyEvent.CANCEL,this.onImpulseBuyCancel);
            this.m_impulseBuyDialog = null;
         }
      }
      
      override public function release() : void
      {
         this.m_expirationWarning = null;
         this.m_expireTextFrame = null;
         this.m_expirationWarningHeader = null;
         this.m_recipeCookTime = null;
         this.m_bushelCount = null;
         this.m_crewBackground = null;
         this.m_recipeSlots = null;
         this.m_crewSlots = null;
         this.m_finishNow = null;
         this.m_getBushels = null;
         this.m_getIngredients = null;
         this.m_mastery = null;
         this.m_stars = null;
         this.m_progressBar = null;
         this.m_progressTrack = null;
         this.m_recipeUiButton = null;
         super.release();
      }
      
      private function onExpireMouseOver(event:MouseEvent) : void
      {
         this.m_timerFrame.toggleTextVisibility(true);
      }
      
      private function onExpireMouseOut(event:MouseEvent) : void
      {
         this.m_timerFrame.toggleTextVisibility(false);
      }
      
      private function pressOpenRecipeUI(event:MouseEvent) : void
      {
         m_callBackObject.openRecipeUI(m_recipeId);
      }
      
      private function updateRecipeInfo() : void
      {
         var farmItem:FarmItem = null;
         var tooltipText:String = null;
         var secondsToCook:int = 0;
         var cookHours:int = 0;
         var cookMinutes:int = 0;
         var cookSeconds:int = 0;
         var cookTimeString:String = null;
         if(m_recipeItem)
         {
            if(m_recipeItem.image)
            {
               m_recipeIcon.loadIcon(m_recipeItem.image);
               m_recipeIcon.setIconSize(90,90);
               m_recipeIcon.setSmoothing(true);
               m_recipeIcon.visible = true;
               m_recipeIcon.detachTooltip();
               m_recipeIcon.attachTooltip(new MarketTooltip());
               farmItem = Global.farmGameSettingsManager.getFarmItemByCode(m_recipeItem.id);
               if(farmItem)
               {
                  tooltipText = farmItem.getUsageDescription();
               }
               else
               {
                  tooltipText = ZLocUtils.t("Dialogs",m_recipeItem.name + "Message",{
                     "recipe":m_recipeItem.friendlyTitle,
                     "quantity":m_recipeItem.onFinishQuantity.toString()
                  });
               }
               if(tooltipText)
               {
                  (m_recipeIcon.tooltip as MarketTooltip).setText(tooltipText);
               }
            }
            if(m_recipeItem.name)
            {
               m_recipeName.text = m_recipeItem.friendlyTitle;
               m_recipeName.visible = true;
            }
            if(m_recipeItem.secondsToCook)
            {
               secondsToCook = m_recipeItem.secondsToCook;
               cookHours = int(secondsToCook / 3600);
               cookMinutes = int(secondsToCook / 60 % 60);
               cookSeconds = int(secondsToCook % 60);
               cookTimeString = "";
               if(secondsToCook >= 3600)
               {
                  cookTimeString = ZLocUtils.t(CraftingConstants.CRAFTING_PROPERTIES_FILE,"CraftingMain_RecipeTimeHours",{"hourNum":cookHours});
               }
               else if(secondsToCook >= 60)
               {
                  cookTimeString = ZLocUtils.t(CraftingConstants.CRAFTING_PROPERTIES_FILE,"CraftingMain_RecipeTimeMins",{"minuteNum":cookMinutes});
               }
               else
               {
                  cookTimeString = ZLocUtils.t(CraftingConstants.CRAFTING_PROPERTIES_FILE,"CraftingMain_RecipeTimeSecs",{"secondNum":cookSeconds});
               }
               this.m_recipeCookTime.text = cookTimeString;
               this.m_recipeCookTime.visible = true;
            }
         }
         this.updateMakeButtonWithBushelRequirementsForRecipe(m_recipeItem);
      }
      
      private function updateMakeButtonWithBushelRequirementsForRecipe(recipeItem:RecipeItem) : void
      {
         var ingredients:Array = null;
         var ingredientsLength:int = 0;
         var ingredientIndex:int = 0;
         var itemCode:String = null;
         var ingredientItem:FarmItem = null;
         var nRequired:int = 0;
         var nHave:int = 0;
         var recipeRequirements:String = null;
         var bushelName:String = null;
         var tooltipText:String = "";
         if(recipeItem)
         {
            ingredients = recipeItem.ingredients;
            if(ingredients)
            {
               ingredientsLength = int(ingredients.length);
               for(ingredientIndex = 0; ingredientIndex < ingredientsLength; ingredientIndex++)
               {
                  if(ingredients.hasOwnProperty(ingredientIndex.toString()))
                  {
                     itemCode = ingredients[ingredientIndex].itemCode;
                     if(itemCode)
                     {
                        ingredientItem = Global.farmGameSettingsManager.getFarmItemByCode(itemCode);
                        if(ingredientItem)
                        {
                           nRequired = int(ingredients[ingredientIndex].quantityRequired);
                           nHave = CraftingManager.getInstance().getInventoryCountHelper(itemCode,nRequired,recipeItem.craft);
                           recipeRequirements = nHave.toString() + "/" + nRequired;
                           bushelName = ingredientItem.friendlyTitle;
                           tooltipText = tooltipText + bushelName + " : " + recipeRequirements + "\n";
                        }
                     }
                  }
               }
            }
         }
         this.m_recipeUiButton.detachTooltip();
         this.m_recipeUiButton.attachTooltip(new MarketTooltip());
         (this.m_recipeUiButton.tooltip as MarketTooltip).setText(tooltipText);
      }
      
      override public function populate(data:Object) : void
      {
         var skillState:CraftingSkillState = null;
         var recipeState:RecipeState = null;
         var totalUserHas:int = 0;
         var totalUserNeeds:int = 0;
         var numIngredients:int = 0;
         var ingredientSlotIndex:int = 0;
         var limitedTimeLeft:Number = NaN;
         var parsedTime:Array = null;
         var text:String = null;
         var url:String = null;
         var itemCode:String = null;
         var userNeeds:int = 0;
         var userHas:int = 0;
         var preReqsNotMet:Array = null;
         var worlCurrency:Object = null;
         var worldCurrencyValue:String = null;
         var worldCurrencyReward:String = null;
         var prereqs:Array = null;
         var endTime:Number = NaN;
         super.populate(data);
         m_recipeId = "";
         m_recipeItem = null;
         if(data.hasOwnProperty("recipeId"))
         {
            m_recipeId = data.recipeId;
            m_recipeItem = Global.craftConfigSettings.getRecipeById(data.recipeId);
         }
         if(m_recipeItem)
         {
            this.updateRecipeInfo();
            if(this.m_specialCard)
            {
               this.m_specialCard.visible = m_recipeItem.isRecipeOfTheWeek();
            }
            this.m_recipeUiButton.visible = true;
            if(this.m_mastery)
            {
               this.m_mastery.visible = true;
            }
            if(this.m_stars)
            {
               this.m_stars.visible = true;
            }
            if(this.m_progressBar)
            {
               this.m_progressBar.visible = true;
            }
            if(this.m_progressTrack)
            {
               this.m_progressTrack.visible = true;
            }
            skillState = Global.player.craftingState.craftingSkillState;
            recipeState = skillState.getRecipeStateById(m_recipeId);
            this.updateMastery(recipeState);
            if(m_recipeItem.isLimited)
            {
               limitedTimeLeft = m_recipeItem.limitedTimeLeft / FarmGameUtil.NUM_MSECS_IN_SECOND;
               parsedTime = FarmGameUtil.parseTimeLeft(limitedTimeLeft);
               text = FarmGameUtil.getFormattedTimeLeftText(parsedTime);
               url = "assets/consumables/consume_expire_30.png";
               if(Boolean(text) && Boolean(text != "") && Boolean(url))
               {
                  this.m_timerFrame.text = text;
                  this.m_timerFrame.loadIcon(url);
                  this.m_timerFrame.toggleTextVisibility(false);
                  this.m_timerFrame.visible = true;
               }
            }
            totalUserHas = 0;
            totalUserNeeds = 0;
            numIngredients = int(m_recipeItem.ingredients.length);
            for(ingredientSlotIndex = 0; ingredientSlotIndex < numIngredients; ingredientSlotIndex++)
            {
               itemCode = m_recipeItem.ingredients[ingredientSlotIndex].itemCode;
               userNeeds = int(m_recipeItem.ingredients[ingredientSlotIndex].quantityRequired);
               userHas = CraftingManager.getInstance().getInventoryCountHelper(itemCode,userNeeds,m_recipeItem.craft);
               if(userHas > userNeeds)
               {
                  userHas = userNeeds;
               }
               totalUserHas += userHas;
               totalUserNeeds += userNeeds;
            }
            this.m_bushelCount.text = totalUserHas.toString() + "/" + totalUserNeeds.toString() + " ingredients";
            this.m_bushelCount.visible = true;
            if(data.hasOwnProperty("recipeState"))
            {
               switch(data.recipeState)
               {
                  case CraftingConstants.RECIPE_STATE_RECIPE_MASTERY_LOCKED:
                     m_locked.visible = true;
                     m_lockedText.text = ZLocUtils.t(CraftingConstants.CRAFTING_PROPERTIES_FILE,CraftingConstants.CRAFTING_GENERAL_LOCKED);
                     m_lockedText.visible = true;
                     m_lockedDescription.text = ZLocUtils.t(CraftingConstants.CRAFTING_PROPERTIES_FILE,"CraftingCottage_recipeMasteryLocked",{"quantity":m_recipeItem.requiredRecipeMastery});
                     m_lockedDescription.visible = true;
                     break;
                  case CraftingConstants.RECIPE_STATE_PREREQ_LOCKED:
                     m_locked.visible = true;
                     m_lockedText.text = ZLocUtils.t(CraftingConstants.CRAFTING_PROPERTIES_FILE,CraftingConstants.CRAFTING_GENERAL_LOCKED);
                     m_lockedText.visible = true;
                     preReqsNotMet = PrerequisiteUtility.getPrerequisiteNotMet(m_recipeItem.unlockPrerequisites);
                     m_lockedDescription.text = PrerequisiteUtility.getPrerequisiteFailureDescription(preReqsNotMet[0].value);
                     m_lockedDescription.visible = true;
                     break;
                  case CraftingConstants.RECIPE_STATE_LOCK:
                     m_locked.visible = true;
                     m_lockedText.text = ZLocUtils.t(CraftingConstants.CRAFTING_PROPERTIES_FILE,CraftingConstants.CRAFTING_GENERAL_LOCKED);
                     m_lockedText.visible = true;
                     m_lockedDescription.text = ZLocUtils.t(CraftingConstants.CRAFTING_PROPERTIES_FILE,"CraftingCottage_recipeLockedComingSoon");
                     m_lockedDescription.visible = true;
                     break;
                  case "":
               }
            }
            if(m_recipeReward)
            {
               worlCurrency = m_recipeItem.worldCurrencyRewards;
               worldCurrencyValue = worlCurrency.value.toString();
               worldCurrencyReward = ZLocUtils.tk_pk_asTitlePlural("Items:" + worlCurrency.unit + "_friendlyName");
               m_recipeReward.text = ZLocUtils.t(CraftingConstants.CRAFTING_PROPERTIES_FILE,"CraftingCottage_recipeRewardsCount",{
                  "value":worldCurrencyValue,
                  "reward":worldCurrencyReward
               });
               m_recipeReward.visible = true;
            }
            if(shouldShowExpirationWarning())
            {
               prereqs = m_recipeItem.prerequisites;
               endTime = getExpirationTime(prereqs);
               if(endTime != RECIPE_NO_END_TIME)
               {
                  if(this.m_expirationWarning)
                  {
                     this.m_expirationWarning.visible = true;
                     if(this.m_expirationWarningHeader)
                     {
                        this.m_expirationWarningHeader.text = FarmGameUtil.getTimeLeftText(endTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
                     }
                  }
               }
               else if(this.m_expirationWarning)
               {
                  this.m_expirationWarning.visible = false;
               }
            }
         }
      }
      
      private function updateMastery(recipeState:RecipeState) : void
      {
         var level:Number = 0;
         var progress:Number = 0;
         var goal:Number = 100;
         var fraction:Number = 0;
         if(recipeState)
         {
            level = recipeState.getCompletedLevel();
            progress = recipeState.xp;
            goal = recipeState.getExperienceIncNeededForLevel(recipeState.level);
            if(goal > 0)
            {
               fraction = progress / goal;
               fraction = Math.max(Math.min(fraction,1),0);
            }
         }
         if(this.m_stars)
         {
            (this.m_stars.element as MovieClip).gotoAndStop(level + 1);
         }
         if(this.m_progressBar)
         {
            this.m_progressBar.width = Math.round(fraction * MASTERY_PROGRESS_BAR_MAX_WIDTH);
         }
         if(level >= MAX_MASTERY_LEVEL)
         {
            if(this.m_mastery)
            {
               (this.m_mastery.tooltip as FarmTextTooltip).setText(ZLocUtils.t("Dialogs","RecipeMastered"));
            }
            if(this.m_progressBar)
            {
               this.m_progressBar.width = MASTERY_PROGRESS_BAR_MAX_WIDTH;
            }
         }
         else if(this.m_mastery)
         {
            (this.m_mastery.tooltip as FarmTextTooltip).setText(ZLocUtils.t("Dialogs","RecipeMasteryProgress",{
               "quantity":progress,
               "maximum":goal
            }));
         }
      }
   }
}

