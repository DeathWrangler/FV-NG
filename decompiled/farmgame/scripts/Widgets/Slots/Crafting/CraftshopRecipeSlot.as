package Widgets.Slots.Crafting
{
   import Classes.Quest.PrerequisiteUtility;
   import Classes.crafting.CraftingSkillState;
   import Classes.crafting.RecipeState;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.MarketViewManager;
   import Managers.HangingGardensManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.CraftshopRecipeCrewFrame;
   import Widgets.Frames.Crafting.CraftshopRecipeFinishFrame;
   import Widgets.Frames.Crafting.CraftshopRecipeIngredientFrame;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class CraftshopRecipeSlot extends CraftingRecipeBaseSlot
   {
      
      private static const MAX_MASTERY_LEVEL:int = 3;
      
      private static const MASTERY_PROGRESS_BAR_MAX_WIDTH:int = 70;
      
      protected var m_recipeCookTime:ZwTextField;
      
      private var m_mastery:ZwFrame;
      
      private var m_stars:ZwFrame;
      
      private var m_progressBar:ZwWidget;
      
      private var m_progressTrack:ZwWidget;
      
      protected var m_recipeSlots:Array = new Array();
      
      protected var m_crewSlots:Array = new Array();
      
      protected var m_crewBackground:ZwFrame;
      
      protected var m_crewBackgroundBonus:ZwFrame;
      
      protected var m_crewBackgroundBonusText:ZwTextField;
      
      protected var m_recipeCount:ZwTextField;
      
      protected var m_finishNow:CraftshopRecipeFinishFrame;
      
      protected var m_getBushels:FarmAnimatedTextButton;
      
      private var m_getBushelsToolTip:FarmTextTooltip = null;
      
      protected var m_getIngredients:FarmAnimatedTextButton;
      
      protected var m_expirationWarning:ZwFrame = null;
      
      protected var m_expireTextFrame:ZwFrame = null;
      
      protected var m_expirationWarningHeader:ZwTextField = null;
      
      public function CraftshopRecipeSlot(element:DisplayObject, callBackObject:Object, featureName:String = "")
      {
         super(element,callBackObject);
         if(this.element.counter_tf)
         {
            this.m_recipeCount = addWidget(new ZwTextField(this.element.counter_tf,"counter_tf")) as ZwTextField;
         }
         this.m_mastery = addWidget(new ZwFrame(this.element.mastery_mc)) as ZwFrame;
         this.m_mastery.attachTooltip(new FarmTextTooltip(""));
         this.m_stars = addWidget(new ZwFrame(this.element.mastery_mc.stars_mc)) as ZwFrame;
         (this.m_stars.element as MovieClip).stop();
         this.m_progressBar = addWidget(new ZwWidget(this.element.mastery_mc.progressBar_mc)) as ZwWidget;
         this.m_progressTrack = addWidget(new ZwWidget(this.element.mastery_mc.progressTrack_mc)) as ZwWidget;
         this.m_recipeSlots = new Array();
         this.m_recipeSlots.push(addWidget(new CraftshopRecipeIngredientFrame(this.element.recipeSlotFull1_mc,m_callBackObject,featureName)) as CraftshopRecipeIngredientFrame);
         this.m_recipeSlots.push(addWidget(new CraftshopRecipeIngredientFrame(this.element.recipeSlotFull2_mc,m_callBackObject,featureName)) as CraftshopRecipeIngredientFrame);
         this.m_recipeSlots.push(addWidget(new CraftshopRecipeIngredientFrame(this.element.recipeSlotFull3_mc,m_callBackObject,featureName)) as CraftshopRecipeIngredientFrame);
         this.m_recipeSlots.push(addWidget(new ZwWidget(this.element.recipeSlotEmpty1_mc)) as ZwWidget);
         this.m_recipeSlots.push(addWidget(new ZwWidget(this.element.recipeSlotEmpty2_mc)) as ZwWidget);
         this.m_recipeSlots.push(addWidget(new ZwWidget(this.element.recipeSlotEmpty3_mc)) as ZwWidget);
         this.m_recipeCookTime = addWidget(new ZwTextField(this.element.recipeTime_tf,"recipeTime_tf")) as ZwTextField;
         if(this.element.friendBox_mc)
         {
            this.m_crewBackground = addWidget(new ZwFrame(this.element.friendBox_mc)) as ZwFrame;
            this.m_crewBackgroundBonus = addWidget(new ZwFrame(this.element.friendBox_mc.bonusItem_mc)) as ZwFrame;
            this.m_crewBackgroundBonusText = addWidget(new ZwTextField(this.element.friendBox_mc.bonusItem_mc.bonusItem_tf,"Bonus Item Unlocked")) as ZwTextField;
            this.m_crewSlots = new Array();
            this.m_crewSlots.push(addWidget(new CraftshopRecipeCrewFrame(this.element.slot_0_mc)) as CraftshopRecipeCrewFrame);
            this.m_crewSlots.push(addWidget(new CraftshopRecipeCrewFrame(this.element.slot_1_mc)) as CraftshopRecipeCrewFrame);
            this.m_crewSlots.push(addWidget(new CraftshopRecipeCrewFrame(this.element.slot_2_mc)) as CraftshopRecipeCrewFrame);
            this.m_crewSlots.push(addWidget(new CraftshopRecipeCrewFrame(this.element.slot_3_mc)) as CraftshopRecipeCrewFrame);
         }
         this.m_finishNow = addWidget(new CraftshopRecipeFinishFrame(this.element.frameProduction_mc,m_callBackObject)) as CraftshopRecipeFinishFrame;
         if(this.element.getBushels_bt)
         {
            this.m_getBushels = addWidget(new FarmAnimatedTextButton(this.element.getBushels_bt,ZLocUtils.t("Dialogs","CraftshopRecipeSlot_getIngredients_btn"),this.pressGetBushels)) as FarmAnimatedTextButton;
            this.m_getBushelsToolTip = new FarmTextTooltip("");
            this.m_getBushels.attachTooltip(this.m_getBushelsToolTip);
            this.element.getBushels_bt.counter_tf.visible = false;
            this.element.getBushels_bt.counterCircle_mc.visible = false;
         }
         this.m_getIngredients = addWidget(new FarmAnimatedTextButton(this.element.buyIngredients_bt,ZLocUtils.t("Dialogs","CraftshopRecipeSlot_buyIngredients_btn"),this.pressBuyIngredients)) as FarmAnimatedTextButton;
         this.m_expirationWarning = addWidget(new ZwFrame(this.element.expiration_bt),false) as ZwFrame;
         (this.m_expirationWarning.element as DisplayObject).addEventListener(MouseEvent.MOUSE_OVER,this.onExpireMouseOver);
         (this.m_expirationWarning.element as DisplayObject).addEventListener(MouseEvent.MOUSE_OUT,this.onExpireMouseOut);
         this.m_expireTextFrame = addWidget(new ZwFrame(this.element.textFields_mc),false) as ZwFrame;
         this.m_expireTextFrame.addWidget(new ZwTextField(this.element.textFields_mc.discription_tf,ZLocUtils.t("Dialogs","CraftshopRecipeExpiring")));
         this.m_expirationWarningHeader = this.m_expireTextFrame.addWidget(new ZwTextField(this.element.textFields_mc.title_tf,"")) as ZwTextField;
      }
      
      override public function release() : void
      {
         (this.m_expirationWarning.element as DisplayObject).removeEventListener(MouseEvent.MOUSE_OVER,this.onExpireMouseOver);
         (this.m_expirationWarning.element as DisplayObject).removeEventListener(MouseEvent.MOUSE_OUT,this.onExpireMouseOut);
         this.m_expirationWarning = null;
         this.m_expireTextFrame = null;
         this.m_expirationWarningHeader = null;
         this.m_recipeCookTime = null;
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
         super.release();
      }
      
      private function onExpireMouseOver(event:MouseEvent) : void
      {
         this.m_expireTextFrame.visible = true;
      }
      
      private function onExpireMouseOut(event:MouseEvent) : void
      {
         this.m_expireTextFrame.visible = false;
      }
      
      public function pressGetBushels(event:MouseEvent) : void
      {
         m_callBackObject.getBushels(m_recipeId);
      }
      
      public function pressBuyIngredients(event:MouseEvent) : void
      {
         m_callBackObject.buyIngredients(m_recipeId);
      }
      
      private function updateRecipeInfo() : void
      {
         var secondsToCook:int = 0;
         var cookHours:int = 0;
         var cookMinutes:int = 0;
         var cookSeconds:int = 0;
         var cookTimeString:String = null;
         if(m_recipeItem)
         {
            if(m_recipeItem.image)
            {
               m_recipeIcon.loadIcon(m_recipeItem.image70);
               m_recipeIcon.setIconSize(70,70);
               m_recipeIcon.visible = true;
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
      }
      
      private function updateSubSlots(data:Object) : void
      {
         var numIngredients:int = 0;
         var ingredientSlotIndex:int = 0;
         var recipeCrew:Array = null;
         var emptyIngredientSlotIndex:int = 0;
         var crewSlotIndex:int = 0;
         var uid:String = null;
         var bonusItem:Boolean = false;
         if(Boolean(m_recipeItem) && Boolean(this.m_recipeSlots) && Boolean(this.m_crewSlots))
         {
            numIngredients = int(m_recipeItem.ingredients.length);
            for(ingredientSlotIndex = 0; ingredientSlotIndex < numIngredients; ingredientSlotIndex++)
            {
               (this.m_recipeSlots[ingredientSlotIndex] as CraftshopRecipeIngredientFrame).update(m_recipeItem,ingredientSlotIndex);
            }
            if(numIngredients < MAX_RECIPE_INGREDIENT_SLOTS)
            {
               for(emptyIngredientSlotIndex = numIngredients; emptyIngredientSlotIndex < MAX_RECIPE_INGREDIENT_SLOTS; emptyIngredientSlotIndex++)
               {
                  (this.m_recipeSlots[emptyIngredientSlotIndex] as CraftshopRecipeIngredientFrame).visible = false;
                  (this.m_recipeSlots[MAX_RECIPE_INGREDIENT_SLOTS + emptyIngredientSlotIndex] as ZwWidget).visible = true;
               }
            }
            recipeCrew = Global.player.craftingState.getCrewOnRecipe(m_recipeId);
            if(data.hasOwnProperty("recipeState") && Boolean(data.recipeState))
            {
               if(data.recipeState == "inProgress" || data.recipeState == "recipeComplete")
               {
                  bonusItem = recipeCrew.length >= CraftingConstants.CREW_NEEDED_FOR_BONUS_ITEM;
                  if(this.m_crewBackgroundBonusText)
                  {
                     this.m_crewBackgroundBonusText.text = ZLocUtils.t(CraftingConstants.CRAFTING_PROPERTIES_FILE,"BonusItem_Locked");
                     if(bonusItem)
                     {
                        this.m_crewBackgroundBonusText.text = ZLocUtils.t(CraftingConstants.CRAFTING_PROPERTIES_FILE,"BonusItem_Unlocked");
                     }
                     this.m_crewBackgroundBonusText.visible = true;
                     this.m_crewBackgroundBonus.visible = true;
                     this.m_crewBackground.visible = true;
                     (this.m_crewBackground.element as MovieClip).gotoAndPlay(1);
                     for(crewSlotIndex = 0; crewSlotIndex < this.m_crewSlots.length; crewSlotIndex++)
                     {
                        uid = "-1";
                        if(crewSlotIndex < recipeCrew.length)
                        {
                           uid = recipeCrew[crewSlotIndex].m_uid;
                        }
                        (this.m_crewSlots[crewSlotIndex] as CraftshopRecipeCrewFrame).update(uid);
                     }
                  }
               }
            }
         }
         this.updateRecipeCount(bonusItem);
      }
      
      override public function populate(data:Object) : void
      {
         var skillState:CraftingSkillState = null;
         var recipeState:RecipeState = null;
         var preReqsNotMet:Array = null;
         var worlCurrency:Object = null;
         var worldCurrencyValue:String = null;
         var worldCurrencyReward:String = null;
         var prereqs:Array = null;
         var endTime:Number = NaN;
         super.populate(data);
         m_background.visible = true;
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
            this.m_mastery.visible = true;
            this.m_stars.visible = true;
            this.m_progressBar.visible = true;
            this.m_progressTrack.visible = true;
            skillState = Global.player.craftingState.craftingSkillState;
            recipeState = skillState.getRecipeStateById(m_recipeId);
            this.updateMastery(recipeState);
            this.updateSubSlots(data);
            if(data.hasOwnProperty("recipeState"))
            {
               switch(data.recipeState)
               {
                  case CraftingConstants.RECIPE_STATE_COMPLETE:
                     this.m_finishNow.update(data);
                     this.m_finishNow.visible = true;
                     break;
                  case CraftingConstants.RECIPE_STATE_IN_PROGRESS:
                     if(HangingGardensManager.isInHangingGardensExperiment() && Boolean(Global.flashHotParams["HANGING_GARDENS_CRAFTSHOP"]))
                     {
                        if(m_recipeItem.canMake)
                        {
                           m_makeIt.visible = true;
                           updateMakeButton(m_callBackObject.canMakeRecipeInThisWorld(m_recipeItem),m_recipeItem);
                        }
                        else
                        {
                           if(this.m_getBushels)
                           {
                              this.m_getBushels.visible = true;
                           }
                           this.m_getIngredients.visible = true;
                        }
                     }
                     else
                     {
                        this.m_finishNow.update(data);
                        this.m_finishNow.visible = true;
                     }
                     break;
                  case CraftingConstants.RECIPE_STATE_HAS_INGREDIENTS:
                     m_makeIt.visible = true;
                     updateMakeButton(m_callBackObject.canMakeRecipeInThisWorld(m_recipeItem),m_recipeItem);
                     break;
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
                  default:
                     if(this.m_getBushels)
                     {
                        this.m_getBushels.visible = true;
                     }
                     this.m_getIngredients.visible = true;
               }
            }
            if(this.m_getBushelsToolTip)
            {
               this.updateGetBushelsTooltip();
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
                  this.m_expirationWarning.visible = true;
                  this.m_expirationWarningHeader.text = FarmGameUtil.getTimeLeftText(endTime / FarmGameUtil.NUM_MSECS_IN_SECOND);
               }
               else
               {
                  this.m_expirationWarning.visible = false;
               }
            }
         }
      }
      
      private function updateRecipeCount(bonusItem:Boolean) : void
      {
         var nReward:int = 1;
         if(bonusItem)
         {
            nReward++;
         }
         if(this.m_recipeCount)
         {
            this.m_recipeCount.text = ZLocUtils.t("Dialogs","CraftshopRecipeSlot_RewardCount",{"quantity":nReward.toString()});
            this.m_recipeCount.visible = true;
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
         (this.m_stars.element as MovieClip).gotoAndStop(level + 1);
         this.m_progressBar.width = Math.round(fraction * MASTERY_PROGRESS_BAR_MAX_WIDTH);
         if(level >= MAX_MASTERY_LEVEL)
         {
            (this.m_mastery.tooltip as FarmTextTooltip).setText(ZLocUtils.t("Dialogs","RecipeMastered"));
            this.m_progressBar.width = MASTERY_PROGRESS_BAR_MAX_WIDTH;
         }
         else
         {
            (this.m_mastery.tooltip as FarmTextTooltip).setText(ZLocUtils.t("Dialogs","RecipeMasteryProgress",{
               "quantity":progress,
               "maximum":goal
            }));
         }
      }
      
      private function updateGetBushelsTooltip() : void
      {
         var ingredient:Object = null;
         var friendsWithBushel:Array = null;
         var friend:Dictionary = null;
         var ingredients:Array = m_recipeItem.ingredients;
         var numFriends:int = 0;
         for each(ingredient in ingredients)
         {
            friendsWithBushel = MarketViewManager.getInstance().getFriendsWithBushel(ingredient.itemCode);
            for each(friend in friendsWithBushel)
            {
               if(friend["timeToBags"] == 0)
               {
                  numFriends++;
               }
            }
         }
         if(numFriends == 0)
         {
            this.m_getBushelsToolTip.setText("");
         }
         else
         {
            this.m_getBushelsToolTip.setText(ZLocUtils.t(CraftingConstants.CRAFTING_PROPERTIES_FILE,"CraftingMain_GetBushelsToolTip",{"quantity":numFriends}));
         }
      }
   }
}

