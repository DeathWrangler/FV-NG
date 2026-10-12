package Widgets.Windows.Crafting
{
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.crafting.RecipeState;
   import Classes.util.ZLocUtils;
   import Events.GenericPopupEvent;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.DefaultRecipeMasteryEarningsFrame;
   import Widgets.Frames.Crafting.RecipeMasteryEarningsFrame;
   import Widgets.Frames.Crafting.RecipeMasteryShareFrame;
   import Widgets.Frames.Crafting.RecipeMultiMasterySlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import flash.utils.Dictionary;
   
   public class RecipeMasteryWindow extends FarmWindow
   {
      
      protected var m_multipleMastery:Array = [];
      
      protected var m_coins:int = 0;
      
      protected var m_xp:int = 0;
      
      protected var m_featuredMastery:Object;
      
      protected var m_centerFrame:ZwFrame;
      
      protected var m_signIcon:FarmIcon;
      
      protected var m_shareFrame:ZwFrame;
      
      public function RecipeMasteryWindow(mastery:Array)
      {
         mastery.sort(this.getMasteryComparison);
         if(mastery.length > 0)
         {
            this.m_featuredMastery = mastery.pop();
         }
         this.m_multipleMastery = mastery;
         mastery.reverse();
         super("assets/dialogs/FV_Craft_Mastery.swf");
      }
      
      protected function getMasteryComparison(itemA:Object, itemB:Object) : int
      {
         var result:int = 0;
         if(itemA.hasOwnProperty("level") && itemB.hasOwnProperty("level") && itemA.level != itemB.level)
         {
            if(itemB.level > itemA.level)
            {
               result = -1;
            }
            else
            {
               result = 1;
            }
         }
         return result;
      }
      
      override protected function postLoadComplete() : void
      {
         var productMastered:FarmItem = null;
         var recipe:RecipeItem = null;
         var masteryIdx:int = 0;
         var firstRecipe:RecipeState = null;
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Crafting","Mastery_Title")));
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Crafting","Mastery_Header")));
         var signsChanged:Dictionary = new Dictionary();
         if(this.m_featuredMastery)
         {
            productMastered = Global.farmGameSettingsManager.getFarmItemByCode(this.m_featuredMastery.code);
            if(productMastered)
            {
               if(1 < this.m_featuredMastery.level)
               {
                  addWidget(new ZwTextField(m_window.generic2_tf,ZLocUtils.t("Crafting","Mastery_WhatWasIt_MultiStar",{
                     "quantity":this.m_featuredMastery.level,
                     "item":ZLocUtils.tk_pk(productMastered.friendlyName)
                  })));
               }
               else
               {
                  addWidget(new ZwTextField(m_window.generic2_tf,ZLocUtils.t("Crafting","Mastery_WhatWasIt_1Star",{"item":ZLocUtils.tk_pk(productMastered.friendlyName)})));
               }
               recipe = Global.craftConfigSettings.getRecipeByProductItemCode(this.m_featuredMastery.code);
               addWidget(new FarmIcon(m_window.icon_mc,recipe.getMasterySignIcon(this.m_featuredMastery.level)));
            }
            signsChanged[this.m_featuredMastery.code] = 1;
         }
         var coinBonus:int = 0;
         var xpBonus:int = 0;
         var numSignsChanged:int = 1;
         if(this.m_multipleMastery.length > 0)
         {
            for(masteryIdx = 0; masteryIdx < this.m_multipleMastery.length; masteryIdx++)
            {
               recipe = Global.craftConfigSettings.getRecipeById(this.m_multipleMastery[masteryIdx].code);
               if(recipe)
               {
                  if(!signsChanged[this.m_multipleMastery[masteryIdx].code] || signsChanged[this.m_multipleMastery[masteryIdx].code] <= 0)
                  {
                     signsChanged[this.m_multipleMastery[masteryIdx].code] = 1;
                     numSignsChanged++;
                  }
                  coinBonus += recipe.getRecipeMasteryCoins(this.m_multipleMastery[masteryIdx].level);
                  xpBonus += recipe.getRecipeMasteryXp(this.m_multipleMastery[masteryIdx].level);
               }
            }
            addWidget(new RecipeMultiMasterySlotFrame(m_window.multipleMastery_mc,this.m_multipleMastery));
         }
         if(this.m_featuredMastery)
         {
            recipe = Global.craftConfigSettings.getRecipeById(this.m_featuredMastery.code);
            coinBonus += recipe.getRecipeMasteryCoins(this.m_featuredMastery.level);
            xpBonus += recipe.getRecipeMasteryXp(this.m_featuredMastery.level);
            addWidget(new RecipeMasteryEarningsFrame(m_window.earned_mc,this.m_featuredMastery.code,numSignsChanged,coinBonus,xpBonus,this.m_featuredMastery.level));
         }
         else
         {
            firstRecipe = Global.player.craftingState.craftingSkillState.getAllRecipeStates().pop() as RecipeState;
            addWidget(new DefaultRecipeMasteryEarningsFrame(m_window.earned_mc,firstRecipe.recipeId));
         }
         this.m_centerFrame = new ZwFrame(m_window.share_mc);
         addWidget(this.m_centerFrame);
         this.fillCenterFrame(recipe);
      }
      
      protected function fillCenterFrame(recipe:RecipeItem) : void
      {
         if(Boolean(recipe) && Boolean(this.m_featuredMastery))
         {
            this.m_shareFrame = new RecipeMasteryShareFrame(m_window.share_mc.postFeed_mc,recipe,this.m_featuredMastery.level,this.m_featuredMastery.reward,this);
            addWidget(this.m_shareFrame);
            this.m_shareFrame.registerEventListener(GenericPopupEvent.SELECTED,close);
            this.m_centerFrame.registerEventListener(GenericPopupEvent.SELECTED,close);
         }
      }
   }
}

