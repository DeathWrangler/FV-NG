package Widgets.Windows.Crafting
{
   import Classes.Player;
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.Crafting.MarketViewManager;
   import Managers.HangingGardensManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.CraftshopRecipeIngredientFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Slots.Crafting.CraftingRecipeBaseSlot;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   
   public class RecipeItemWindow extends ZwFrame
   {
      
      private var m_getIngredients:FarmAnimatedTextButton;
      
      private var m_recipeName:ZwTextField;
      
      private var m_callBackObject:Object;
      
      private var m_recipeSlots:Array = new Array();
      
      private var m_makeIt:FarmAnimatedTextButton;
      
      private var m_makeItToolTip:FarmTextTooltip;
      
      private var m_makeItEnabled:int;
      
      private var m_recipeId:String;
      
      private var m_getBushels:FarmAnimatedTextButton;
      
      private var m_getBushelsToolTip:FarmTextTooltip = null;
      
      private var m_recipeIcon:FarmIcon;
      
      private var m_recipeItem:RecipeItem = null;
      
      public function RecipeItemWindow(element:DisplayObject, callBackObject:Object)
      {
         super(element);
         this.m_callBackObject = callBackObject;
         this.m_recipeSlots = new Array();
         this.m_recipeSlots.push(addWidget(new CraftshopRecipeIngredientFrame(m_element.recipeSlotFull1_mc,this.m_callBackObject)) as CraftshopRecipeIngredientFrame);
         this.m_recipeSlots.push(addWidget(new CraftshopRecipeIngredientFrame(m_element.recipeSlotFull2_mc,this.m_callBackObject)) as CraftshopRecipeIngredientFrame);
         this.m_recipeSlots.push(addWidget(new CraftshopRecipeIngredientFrame(m_element.recipeSlotFull3_mc,this.m_callBackObject)) as CraftshopRecipeIngredientFrame);
         if(m_element.hasOwnProperty("buyIngredients_bt"))
         {
            this.m_getIngredients = addWidget(new FarmAnimatedTextButton(this.element.buyIngredients_bt,ZLocUtils.t("Dialogs","CraftshopRecipeSlot_buyIngredients_btn"),this.pressBuyIngredients)) as FarmAnimatedTextButton;
         }
         if(m_element.hasOwnProperty("close_bt"))
         {
            addWidget(new FarmButton(m_element.close_bt,this.onClose) as FarmButton);
         }
         if(m_element.hasOwnProperty("title_mc"))
         {
            addWidget(this.m_recipeName = new ZwTextField(m_element.title_mc));
         }
         if(m_element.hasOwnProperty("make_bt"))
         {
            this.m_makeIt = addWidget(new FarmAnimatedTextButton(m_element.make_bt,ZLocUtils.t("Dialogs","CraftshopRecipeSlot_make_btn"),this.pressMake)) as FarmAnimatedTextButton;
            this.m_makeItToolTip = new FarmTextTooltip("");
            this.m_makeIt.attachTooltip(this.m_makeItToolTip);
         }
         if(m_element.hasOwnProperty("getBushels_bt"))
         {
            this.m_getBushels = addWidget(new FarmAnimatedTextButton(this.element.getBushels_bt,ZLocUtils.t("Dialogs","CraftshopRecipeSlot_getIngredients_btn"),this.pressGetBushels)) as FarmAnimatedTextButton;
            this.m_getBushelsToolTip = new FarmTextTooltip("");
            this.m_getBushels.attachTooltip(this.m_getBushelsToolTip);
            this.element.getBushels_bt.counter_tf.visible = false;
            this.element.getBushels_bt.counterCircle_mc.visible = false;
         }
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_recipeIcon = addWidget(new FarmIcon(this.element.icon_mc,Player.NO_PROFILE_PIC_URL)) as FarmIcon;
         }
      }
      
      private function onClose(e:Event) : void
      {
         this.visible = false;
         this.m_parent.hideOverlay();
      }
      
      private function pressMake(event:MouseEvent) : void
      {
         if(this.m_makeItEnabled == CraftingConstants.CAN_MAKE_RECIPE)
         {
            this.m_callBackObject.makeRecipe(this.m_recipeId);
         }
      }
      
      private function pressGetBushels(event:MouseEvent) : void
      {
         this.m_callBackObject.getBushels(this.m_recipeId);
      }
      
      private function pressBuyIngredients(event:MouseEvent) : void
      {
         this.m_callBackObject.buyIngredients(this.m_recipeId);
      }
      
      public function populateWithRecipe(recipeItem:RecipeItem) : void
      {
         var numIngredients:int = 0;
         var ingredientSlotIndex:int = 0;
         var recipeState:String = null;
         var inProgressRecipeIdHash:Object = null;
         var masteryStars:int = 0;
         var emptyIngredientSlotIndex:int = 0;
         var ingredientWidget:ZwWidget = null;
         if(Boolean(recipeItem) && Boolean(this.m_recipeSlots))
         {
            this.m_recipeId = recipeItem.id;
            this.m_recipeItem = recipeItem;
            this.m_makeIt.applyGrayOut = true;
            this.m_makeIt.enabled = false;
            if(recipeItem.image)
            {
               this.m_recipeIcon.loadIcon(recipeItem.image);
               this.m_recipeIcon.setIconSize(100,100);
               this.m_recipeIcon.visible = true;
            }
            this.m_recipeName.text = recipeItem.friendlyTitle;
            this.m_recipeName.visible = true;
            numIngredients = int(recipeItem.ingredients.length);
            for(ingredientSlotIndex = 0; ingredientSlotIndex < numIngredients; ingredientSlotIndex++)
            {
               (this.m_recipeSlots[ingredientSlotIndex] as CraftshopRecipeIngredientFrame).update(recipeItem,ingredientSlotIndex);
            }
            if(numIngredients < CraftingRecipeBaseSlot.MAX_RECIPE_INGREDIENT_SLOTS)
            {
               for(emptyIngredientSlotIndex = numIngredients; emptyIngredientSlotIndex < CraftingRecipeBaseSlot.MAX_RECIPE_INGREDIENT_SLOTS; emptyIngredientSlotIndex++)
               {
                  (this.m_recipeSlots[emptyIngredientSlotIndex] as CraftshopRecipeIngredientFrame).visible = false;
                  ingredientWidget = this.m_recipeSlots[CraftingRecipeBaseSlot.MAX_RECIPE_INGREDIENT_SLOTS + emptyIngredientSlotIndex] as ZwWidget;
                  if(ingredientWidget)
                  {
                     ingredientWidget.visible = true;
                  }
               }
            }
            recipeState = "";
            inProgressRecipeIdHash = CraftingManager.getInProgressRecipeHash("craftshop");
            masteryStars = CraftingManager.getInstance().getRecipeMasteryEarnedForCraftType("craftshop");
            if(recipeItem.comingSoon)
            {
               recipeState = CraftingConstants.RECIPE_STATE_LOCK;
            }
            else if(!recipeItem.canUnlock)
            {
               recipeState = CraftingConstants.RECIPE_STATE_PREREQ_LOCKED;
            }
            else
            {
               if(recipeItem.canMake)
               {
                  recipeState = CraftingConstants.RECIPE_STATE_HAS_INGREDIENTS;
               }
               if(recipeItem.requiredRecipeMastery > masteryStars)
               {
                  recipeState = CraftingConstants.RECIPE_STATE_RECIPE_MASTERY_LOCKED;
               }
               if(inProgressRecipeIdHash.hasOwnProperty(this.m_recipeId))
               {
                  recipeState = CraftingConstants.RECIPE_STATE_IN_PROGRESS;
                  if(recipeItem.serverStartTS > 0 && recipeItem.realTimeRemaining <= 0)
                  {
                     recipeState = CraftingConstants.RECIPE_STATE_COMPLETE;
                  }
               }
            }
            switch(recipeState)
            {
               case CraftingConstants.RECIPE_STATE_IN_PROGRESS:
                  if(HangingGardensManager.isInHangingGardensExperiment() && Boolean(Global.flashHotParams["HANGING_GARDENS_CRAFTSHOP"]))
                  {
                     if(recipeItem.canMake)
                     {
                        this.m_makeIt.visible = true;
                        this.m_makeIt.enabled = true;
                        this.updateMakeButton(this.m_callBackObject.canMakeRecipeInThisWorld(recipeItem),recipeItem);
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
                  break;
               case CraftingConstants.RECIPE_STATE_HAS_INGREDIENTS:
                  this.m_makeIt.visible = true;
                  this.m_makeIt.enabled = true;
                  this.updateMakeButton(this.m_callBackObject.canMakeRecipeInThisWorld(recipeItem),recipeItem);
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
      }
      
      private function updateMakeButton(canMakeRecipeStatus:int, recipeItem:RecipeItem) : void
      {
         this.m_makeItEnabled = canMakeRecipeStatus;
         this.m_makeIt.applyGrayOut = canMakeRecipeStatus != CraftingConstants.CAN_MAKE_RECIPE;
         if(canMakeRecipeStatus == CraftingConstants.CAN_MAKE_RECIPE)
         {
            this.m_makeItToolTip.setText("");
         }
         else if(canMakeRecipeStatus == CraftingConstants.OVEN_SLOTS_FULL)
         {
            if(HangingGardensManager.isInHangingGardensExperiment() && Boolean(Global.flashHotParams["HANGING_GARDENS_CRAFTSHOP"]))
            {
               this.m_makeItToolTip.setText(ZLocUtils.t("Dialogs","CraftshopRecipeSlot_slotFull"));
            }
            else
            {
               this.m_makeItToolTip.setText(ZLocUtils.t("Dialogs","CraftshopRecipeSlot_RecipeBeingMade"));
            }
         }
         else if(canMakeRecipeStatus == CraftingConstants.MAX_BUSHEL_CAPACITY)
         {
            this.m_makeItToolTip.setText(ZLocUtils.t("Dialogs","CraftshopRecipeSlot_BushelLimitBackup"));
         }
      }
      
      private function updateGetBushelsTooltip() : void
      {
         var ingredients:Array = null;
         var ingredient:Object = null;
         var friendsWithBushel:Array = null;
         var friend:Dictionary = null;
         var numFriends:int = 0;
         if(this.m_recipeItem)
         {
            ingredients = this.m_recipeItem.ingredients;
            numFriends = 0;
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
}

