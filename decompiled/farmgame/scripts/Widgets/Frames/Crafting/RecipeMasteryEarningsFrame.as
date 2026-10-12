package Widgets.Frames.Crafting
{
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class RecipeMasteryEarningsFrame extends ZwFrame
   {
      
      public function RecipeMasteryEarningsFrame(element:MovieClip, recipeId:String, numSigns:int, coins:int, xp:int, level:int)
      {
         super(element);
         if(Global.player.masterySignEnabled())
         {
            this.populateSignsInfo(numSigns);
         }
         else
         {
            addWidget(new ZwTextField(m_element.generic2_tf,ZLocUtils.t("Crafting","Mastery_EarnedNew")));
         }
         addWidget(new ZwTextField(m_element.generic_tf,ZLocUtils.t("Crafting","Mastery_EarnedTitle")));
         xp = Global.player.calculateAndAddXp(xp);
         var coinMultiplier:int = Global.player.getWorldCurrencyMultiplier(Currency.COINS);
         if(Global.player.masterySignEnabled())
         {
            addWidget(new ZwTextField(m_element.generic3_tf,ZLocUtils.t("Crafting","Mastery_EarnedWhere")));
         }
         else
         {
            addWidget(new ZwTextField(m_element.generic3_tf,ZLocUtils.t("Crafting","Mastery_EarnedWhere_new")));
         }
         addWidget(new ZwTextField(m_element.generic4_tf,ZLocUtils.t("Crafting","Mastery_EarnedCoins",{"quantity":coins * coinMultiplier})));
         addWidget(new ZwTextField(m_element.generic5_tf,ZLocUtils.t("Crafting","Mastery_EarnedXp",{"quantity":xp})));
         Global.player.updateWorldCurrency(Currency.GOLD,coins,true);
         var recipe:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeId);
         var nextGoal:int = recipe.getRecipeMasteryRequirement(level + 1) - Global.player.craftingState.craftingSkillState.getRecipeStateById(recipeId).level;
         if(level < 5)
         {
            if(Global.player.masterySignEnabled())
            {
               addWidget(new ZwTextField(m_element.generic6_tf,ZLocUtils.t("Crafting","Mastery_EarnedNext",{
                  "quantity":nextGoal,
                  "levelNum":level + 1
               })));
            }
            else
            {
               addWidget(new ZwTextField(m_element.generic6_tf,ZLocUtils.t("Crafting","Mastery_EarnedNext_New",{
                  "quantity":nextGoal,
                  "levelNum":level + 1
               })));
            }
         }
         else
         {
            addWidget(new ZwTextField(m_element.generic6_tf,ZLocUtils.t("Crafting","Mastery_EarnedAll")));
         }
      }
      
      protected function populateSignsInfo(numSigns:int) : void
      {
         switch(numSigns)
         {
            case 0:
            case 1:
               addWidget(new ZwTextField(m_element.generic2_tf,ZLocUtils.t("Crafting","Mastery_EarnedOneSign")));
               break;
            default:
               addWidget(new ZwTextField(m_element.generic2_tf,ZLocUtils.t("Crafting","Mastery_EarnedMoreSign",{"quantity":numSigns})));
         }
      }
   }
}

