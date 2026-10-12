package Widgets.Slots.Crafting
{
   import Classes.crafting.RecipeItem;
   import Classes.crafting.RecipeState;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.CraftingUI;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Crafting.CraftingMainWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class CraftingMainRecipeSlot extends ZwSlotFrame
   {
      
      private static var ANIMATION_TIME:int = 30;
      
      private static var m_ingredientNameArray:Array = ["recipeSlotFull1_mc","recipeSlotFull2_mc","recipeSlotFull3_mc"];
      
      private static var m_noIngredientNameArray:Array = ["recipeSlotEmpty1_mc","recipeSlotEmpty2_mc","recipeSlotEmpty3_mc"];
      
      private var m_recipeLevel:int;
      
      private var m_makeBtAnimMc:MovieClip;
      
      private var m_progressToNextLevel:Number;
      
      private var m_animationTime:Number;
      
      private var m_recipeItem:RecipeItem = null;
      
      private var m_recipeState:RecipeState = null;
      
      private var m_upgradeToolTip:FarmTextTooltip = null;
      
      private var m_getBushelsToolTip:FarmTextTooltip = null;
      
      private var m_cueFullFrame:ZwFrame = null;
      
      private var m_craftingMainWindow:CraftingMainWindow = null;
      
      private var m_makeCurrentFrame:Number = 0;
      
      private var m_makeTotalFrames:int;
      
      private var m_levelCurrentFrame:Number = 0;
      
      private var m_levelTotalFrames:int;
      
      public function CraftingMainRecipeSlot(element:DisplayObject, craftingMainWindow:CraftingMainWindow)
      {
         this.m_craftingMainWindow = craftingMainWindow;
         super(element);
         if(m_element.celBackgroundDefault_mc)
         {
            addWidget(new ZwWidget(m_element.celBackgroundDefault_mc));
         }
         if(m_element.celBackgroundLE_mc)
         {
            addWidget(new ZwWidget(m_element.celBackgroundLE_mc));
         }
         addWidget(new FarmIcon(m_element.icon_mc));
         (getWidget(m_element.icon_mc) as FarmIcon).setIconSize(70,70);
         addWidget(new ZwTextField(m_element.recipeName_tf));
         addWidget(new ZwTextField(m_element.level_tf));
         addWidget(new ZwWidget(m_element.star_mc));
         addWidget(new ZwWidget(m_element.lockedRecipe_mc));
         addWidget(new ZwWidget(m_element.makeAnimation_mc));
         this.m_makeTotalFrames = m_element.makeAnimation_mc.totalFrames;
         addWidget(new ZwWidget(m_element.levelAnimation_mc));
         this.m_levelTotalFrames = m_element.levelAnimation_mc.totalFrames;
         addWidget(new ZwTextField(m_element.lockedRecipe_mc.locked_tf,ZLocUtils.t("Crafting","CraftingMain_Locked")));
         this.m_cueFullFrame = new ZwFrame(m_element.cueFull_mc);
         this.m_cueFullFrame.addWidget(new ZwTextField(m_element.cueFull_mc.generic_tf,ZLocUtils.t("Crafting","CraftingMain_OvensFull",{"cottageSlotName":ZLocUtils.tk("Items",this.m_craftingMainWindow.cottage.craftType + "Slot_friendlyName")})));
         this.m_cueFullFrame.addWidget(new FarmAnimatedTextButton(m_element.cueFull_mc.getBushels_bt,ZLocUtils.t("Crafting","CraftingMain_GetBushels"),this.onGetBushels),false);
         addWidget(this.m_cueFullFrame);
         addWidget(new ZwWidget(m_element.meterRecipeUpgrade));
         addWidget(new ZwWidget(m_element.meterRecipeUpgrade.bar_mc));
         addWidget(new FarmAnimatedTextButton(m_element.getBushels_bt,ZLocUtils.t("Crafting","CraftingMain_GetBushels"),this.onGetBushels),false);
         addWidget(new FarmAnimatedTextButton(m_element.make_bt,ZLocUtils.t("Crafting","CraftingMain_MakeIt"),this.onMakeIt),false);
         if(m_element.hasOwnProperty("make_btAnim"))
         {
            this.m_makeBtAnimMc = m_element.make_btAnim as MovieClip;
         }
         for(var i:int = 0; i < CraftingMainRecipeSlot.m_ingredientNameArray.length; i++)
         {
            addWidget(new CraftingMainRecipeDetailSlot(m_element[m_ingredientNameArray[i]],this.m_craftingMainWindow,this.m_recipeItem),false);
            addWidget(new ZwWidget(m_element[m_noIngredientNameArray[i]]),true);
         }
         this.m_upgradeToolTip = new FarmTextTooltip("");
         (getWidget(m_element.meterRecipeUpgrade) as ZwWidget).attachTooltip(this.m_upgradeToolTip);
         (getWidget(m_element.level_tf) as ZwTextField).attachTooltip(this.m_upgradeToolTip);
         (getWidget(m_element.recipeName_tf) as ZwTextField).attachTooltip(this.m_upgradeToolTip);
         (getWidget(m_element.icon_mc) as FarmIcon).attachTooltip(this.m_upgradeToolTip);
         this.m_getBushelsToolTip = new FarmTextTooltip("");
         (getWidget(m_element.getBushels_bt) as FarmAnimatedTextButton).attachTooltip(this.m_getBushelsToolTip);
         (this.m_cueFullFrame.getWidget(m_element.cueFull_mc.getBushels_bt) as FarmAnimatedTextButton).attachTooltip(this.m_getBushelsToolTip);
         m_element.cueFull_mc.getBushels_bt.counterCircle_mc.visible = false;
         m_element.cueFull_mc.getBushels_bt.counter_tf.visible = false;
         m_element.getBushels_bt.counterCircle_mc.visible = false;
         m_element.getBushels_bt.counter_tf.visible = false;
         addWidget(new ZwTextField(m_element.recipeLevel_tf));
         addWidget(new FarmIcon(m_element.iconRegion_mc));
         (getWidget(m_element.iconRegion_mc) as FarmIcon).setIconSize(45,45);
      }
      
      override public function populate(recipeItemIn:Object) : void
      {
         var notLocked:Boolean = false;
         this.m_recipeItem = recipeItemIn as RecipeItem;
         if(this.m_recipeItem)
         {
            if(Boolean(m_element.celBackgroundDefault_mc) && Boolean(m_element.celBackgroundLE_mc))
            {
               if(this.m_recipeItem.isLimited)
               {
                  (getWidget(m_element.celBackgroundLE_mc) as ZwWidget).visible = true;
                  (getWidget(m_element.celBackgroundDefault_mc) as ZwWidget).visible = false;
               }
               else
               {
                  (getWidget(m_element.celBackgroundLE_mc) as ZwWidget).visible = false;
                  (getWidget(m_element.celBackgroundDefault_mc) as ZwWidget).visible = true;
               }
            }
            this.m_recipeState = Global.player.craftingState.craftingSkillState.getRecipeStateById(this.m_recipeItem.id);
            this.m_progressToNextLevel = this.m_recipeState.getFractionalProgessToNextLevel();
            this.m_recipeLevel = this.m_recipeState.level;
            if(this.m_recipeItem.regionSufix)
            {
               (getWidget(m_element.iconRegion_mc) as FarmIcon).loadIcon(this.m_recipeItem.regionImage);
               (getWidget(m_element.iconRegion_mc) as FarmIcon).visible = true;
            }
            (getWidget(m_element.recipeLevel_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingMain_Star",{"levelNum":this.m_recipeItem.skillLevelRequired});
            (getWidget(m_element.icon_mc) as FarmIcon).loadIcon(this.m_recipeItem.image70);
            (getWidget(m_element.recipeName_tf) as ZwTextField).text = ZLocUtils.tk_pk_asTitle(this.m_recipeItem.friendlyName);
            this.m_animationTime = 0;
            this.setIngredients();
            this.setGetBushels();
            notLocked = CraftingManager.getInstance().isRecipeLocked(this.m_recipeItem.id) == 0;
            if(notLocked)
            {
               this.setMeter(ANIMATION_TIME);
            }
            else
            {
               this.m_upgradeToolTip.setText("");
            }
            (getWidget(m_element.meterRecipeUpgrade) as ZwWidget).visible = notLocked;
            (getWidget(m_element.meterRecipeUpgrade.bar_mc) as ZwWidget).visible = notLocked;
            (getWidget(m_element.level_tf) as ZwTextField).visible = notLocked;
            (getWidget(m_element.recipeName_tf) as ZwTextField).visible = true;
            (getWidget(m_element.icon_mc) as FarmIcon).visible = true;
            (getWidget(m_element.recipeLevel_tf) as ZwTextField).visible = true;
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_recipeItem = null;
         this.m_recipeState = null;
         this.m_upgradeToolTip = null;
         this.m_cueFullFrame = null;
         this.m_craftingMainWindow = null;
      }
      
      public function setEnabled(enable:Boolean) : void
      {
         (getWidget(m_element.make_bt) as FarmAnimatedTextButton).enabled = enable;
         (getWidget(m_element.getBushels_bt) as FarmAnimatedTextButton).enabled = enable;
      }
      
      public function enterFrame(deltaTime:Number) : void
      {
         var notLocked:Boolean = false;
         if(this.m_recipeState)
         {
            if(this.m_progressToNextLevel != this.m_recipeState.getFractionalProgessToNextLevel() || this.m_recipeLevel != this.m_recipeState.level)
            {
               notLocked = CraftingManager.getInstance().isRecipeLocked(this.m_recipeItem.id) == 0;
               if(notLocked)
               {
                  this.setMeter(deltaTime);
               }
            }
            if(m_element.makeAnimation_mc.visible)
            {
               this.m_makeCurrentFrame += deltaTime;
               if(this.m_makeCurrentFrame >= this.m_makeTotalFrames)
               {
                  this.m_makeCurrentFrame = 0;
                  m_element.makeAnimation_mc.visible = false;
               }
               m_element.makeAnimation_mc.gotoAndStop(int(this.m_makeCurrentFrame));
            }
            if(m_element.levelAnimation_mc.visible)
            {
               this.m_levelCurrentFrame += deltaTime;
               if(this.m_levelCurrentFrame >= this.m_levelTotalFrames)
               {
                  this.m_levelCurrentFrame = 0;
                  m_element.levelAnimation_mc.visible = false;
               }
               m_element.levelAnimation_mc.gotoAndStop(int(this.m_levelCurrentFrame));
            }
         }
      }
      
      private function setMeter(deltaTime:Number) : void
      {
         var remainingLevels:int = 0;
         var timeLeft:String = null;
         var limitedMasteryTime:String = null;
         var limitedTooltipText:String = null;
         var interp:Number = 0;
         this.m_animationTime += deltaTime;
         interp = Math.min(1,this.m_animationTime / ANIMATION_TIME);
         if(this.m_recipeLevel != this.m_recipeState.level)
         {
            m_element.meterRecipeUpgrade.bar_mc.scaleY = this.m_progressToNextLevel + (1 - this.m_progressToNextLevel) * interp;
            if(interp == 1)
            {
               this.m_animationTime = 0;
               this.m_progressToNextLevel = 1;
               m_element.level_tf.alpha = 1 - interp;
               this.m_recipeLevel = this.m_recipeState.level;
               m_element.levelAnimation_mc.visible = true;
               this.m_levelCurrentFrame = 2;
               this.m_craftingMainWindow.updateUpgradeFrame();
            }
         }
         else
         {
            if(this.m_progressToNextLevel == 1)
            {
               m_element.meterRecipeUpgrade.bar_mc.scaleY = 1 - interp * (1 - this.m_recipeState.getFractionalProgessToNextLevel());
               m_element.level_tf.alpha = interp;
            }
            else
            {
               m_element.meterRecipeUpgrade.bar_mc.scaleY = this.m_progressToNextLevel + (this.m_recipeState.getFractionalProgessToNextLevel() - this.m_progressToNextLevel) * interp;
               m_element.level_tf.alpha = 1;
            }
            if(interp == 1)
            {
               this.m_animationTime = 0;
               this.m_progressToNextLevel = this.m_recipeState.getFractionalProgessToNextLevel();
            }
         }
         (getWidget(m_element.level_tf) as ZwTextField).text = ZLocUtils.t("Crafting","CraftingMain_Level2",{"levelNum":this.m_recipeLevel});
         if(this.m_recipeItem.isLimited)
         {
            remainingLevels = this.m_recipeItem.getRecipeMasteryRequirement(CraftingConstants.MAX_NUM_MASTERY_LEVELS) - this.m_recipeState.level;
            if(remainingLevels > 0)
            {
               timeLeft = FarmGameUtil.getTimeLeftText(FarmGameUtil.synchronizedDateToNumber(this.m_recipeItem.limitedEndDate) / 1000);
               limitedMasteryTime = remainingLevels.toString();
               limitedTooltipText = timeLeft;
               limitedTooltipText += "\n";
               limitedTooltipText += ZLocUtils.t("Crafting","LimitedRecipes_MasteryTime",{"quantity":limitedMasteryTime});
               this.m_upgradeToolTip.setText(limitedTooltipText);
            }
         }
         else
         {
            this.m_upgradeToolTip.setText(ZLocUtils.t("Crafting","CraftingMain_UpgradeRecipe",{"quantity":this.m_recipeState.getEstimatedItemsForLevel()}));
         }
      }
      
      private function setGetBushels() : void
      {
         var ingredient:Object = null;
         var friendsWithBushel:Array = null;
         var friend:Dictionary = null;
         var ingredients:Array = this.m_recipeItem.ingredients;
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
            this.m_getBushelsToolTip.setText(ZLocUtils.t("Crafting","CraftingMain_GetBushelsToolTip",{"quantity":numFriends}));
         }
      }
      
      private function setIngredients() : void
      {
         var ingredientRecipeDetailSlot:CraftingMainRecipeDetailSlot = null;
         var noIngredientZwWidget:ZwWidget = null;
         var ingredients:Array = this.m_recipeItem.ingredients;
         var craftType:String = this.m_recipeItem.craft;
         var numComplete:int = 0;
         for(var i:int = 0; i < CraftingMainRecipeSlot.m_ingredientNameArray.length; i++)
         {
            ingredientRecipeDetailSlot = getWidget(m_element[m_ingredientNameArray[i]]) as CraftingMainRecipeDetailSlot;
            ingredientRecipeDetailSlot.updateRecipeItem(this.m_recipeItem);
            noIngredientZwWidget = getWidget(m_element[m_noIngredientNameArray[i]]) as ZwWidget;
            if(i < ingredients.length)
            {
               if(ingredientRecipeDetailSlot.update(this.m_recipeItem.ingredients[i],craftType))
               {
                  numComplete++;
               }
               ingredientRecipeDetailSlot.visible = true;
               noIngredientZwWidget.visible = false;
            }
            else
            {
               ingredientRecipeDetailSlot.visible = false;
               noIngredientZwWidget.visible = true;
            }
         }
         var lockedState:int = CraftingManager.getInstance().isRecipeLocked(this.m_recipeItem.id);
         this.m_makeBtAnimMc.visible = false;
         this.m_makeBtAnimMc.stop();
         if(lockedState != 0)
         {
            (getWidget(m_element.lockedRecipe_mc) as ZwWidget).visible = true;
            (getWidget(m_element.lockedRecipe_mc.locked_tf) as ZwTextField).visible = true;
            m_element.lockedRecipe_mc.generic_tf.text = CraftingManager.getInstance().getRecipeLockedReason(this.m_recipeItem.id,lockedState);
            (getWidget(m_element.star_mc) as ZwWidget).visible = false;
            (getWidget(m_element.cueFull_mc) as ZwWidget).visible = false;
            (getWidget(m_element.make_bt) as FarmAnimatedTextButton).visible = false;
            (getWidget(m_element.getBushels_bt) as FarmAnimatedTextButton).visible = false;
         }
         else
         {
            (getWidget(m_element.star_mc) as ZwWidget).visible = true;
            (getWidget(m_element.lockedRecipe_mc) as ZwWidget).visible = false;
            if(this.m_craftingMainWindow.cottage.availableSlots > 0)
            {
               (getWidget(m_element.cueFull_mc) as ZwWidget).visible = false;
               (getWidget(m_element.make_bt) as FarmAnimatedTextButton).visible = numComplete == ingredients.length;
               if(numComplete == ingredients.length)
               {
                  this.m_makeBtAnimMc.visible = true;
                  this.m_makeBtAnimMc.play();
               }
               (getWidget(m_element.getBushels_bt) as FarmAnimatedTextButton).visible = numComplete != ingredients.length;
            }
            else
            {
               this.m_cueFullFrame.visible = true;
               (this.m_cueFullFrame.getWidget(m_element.cueFull_mc.generic_tf) as ZwTextField).visible = true;
               (this.m_cueFullFrame.getWidget(m_element.cueFull_mc.getBushels_bt) as FarmAnimatedTextButton).visible = true;
               (getWidget(m_element.make_bt) as FarmAnimatedTextButton).visible = false;
               (getWidget(m_element.getBushels_bt) as FarmAnimatedTextButton).visible = false;
            }
         }
      }
      
      public function update() : void
      {
         this.setIngredients();
         this.setGetBushels();
      }
      
      private function onMakeIt(event:MouseEvent) : void
      {
         if(this.m_recipeItem)
         {
            this.m_craftingMainWindow.enableInput = false;
            this.m_recipeItem.ovenSlot = this.m_craftingMainWindow.findEmptySlot();
            CraftingManager.getInstance().beginRecipe(this.m_recipeItem,this.onRecipeBeginDone);
            m_element.makeAnimation_mc.visible = true;
            this.m_makeCurrentFrame = 2;
            if(this.m_craftingMainWindow.isInTutorial())
            {
               if(this.m_craftingMainWindow.assertTutorialIndexIs(CraftingMainWindow.TUTORIAL_MAKE_IT))
               {
                  this.m_craftingMainWindow.displayTutorialMessage(CraftingMainWindow.TUTORIAL_FINISH_IT);
               }
            }
         }
      }
      
      private function onGetBushels(event:MouseEvent) : void
      {
         if(this.m_recipeItem)
         {
            this.m_craftingMainWindow.closeTutorialWindow();
            if(this.m_craftingMainWindow.assertTutorialIndexIs(CraftingMainWindow.TUTORIAL_GET_BUSHELS))
            {
               this.m_craftingMainWindow.tintWindow();
               this.m_craftingMainWindow.enableInput = false;
               CraftingUI.displayShoppingListWindow(this.m_recipeItem,this.onCloseGetBushels);
            }
         }
      }
      
      private function onCloseGetBushels() : void
      {
         if(this.m_craftingMainWindow != null)
         {
            this.m_craftingMainWindow.untintWindow();
            this.m_craftingMainWindow.enableInput = true;
            this.m_craftingMainWindow.updateRecipeSlotFrame();
         }
      }
      
      private function onRecipeBeginDone(tResult:Object) : void
      {
         this.m_craftingMainWindow.enableInput = true;
         CraftingManager.getInstance().handleRecipeBegunResult(tResult);
         this.m_craftingMainWindow.updateRecipeSlotFrame();
         this.m_craftingMainWindow.updateProductionSlotFrame();
      }
   }
}

