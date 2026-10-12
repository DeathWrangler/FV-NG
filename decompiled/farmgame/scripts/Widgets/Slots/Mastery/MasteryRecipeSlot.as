package Widgets.Slots.Mastery
{
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Mastery.MasteryWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class MasteryRecipeSlot extends MasterySlot
   {
      
      private static const HIGHEST_MASTERY:int = 5;
      
      private var m_recipeNumber:ZwTextField;
      
      public function MasteryRecipeSlot(element:DisplayObject, masteryWindow:MasteryWindow)
      {
         super(element,masteryWindow);
         addWidget(new ZwTextField(m_element.recipeLevel_tf,ZLocUtils.t("Dialogs","Mastery_RecipeLevel")));
         this.m_recipeNumber = addWidget(new ZwTextField(m_element.recipeNumber_tf)) as ZwTextField;
      }
      
      override public function populate(data:Object) : void
      {
         var recipe:RecipeItem = null;
         var recipeLevel:int = 0;
         var masteryLevel:int = 0;
         var progress:int = 0;
         recipe = data as RecipeItem;
         var nextLevel:int = 1;
         if(recipe)
         {
            m_element.recipeLevel_tf.visible = true;
            m_itemName.text = recipe.friendlyTitle;
            m_itemName.visible = true;
            m_icon.loadIcon(recipe.image);
            m_icon.visible = true;
            if(CraftingManager.getInstance().isRecipeLocked(recipe.id) == 0)
            {
               recipeLevel = Global.player.craftingState.craftingSkillState.getRecipeStateById(recipe.id).level;
               masteryLevel = recipe.getMasteryLevelForRecipeLevel(recipeLevel);
               if(masteryLevel == HIGHEST_MASTERY)
               {
                  m_progressBar.progress = 100;
                  m_toolTip.setText(ZLocUtils.t("Dialogs","Mastery_recipeAllStars"));
               }
               else
               {
                  nextLevel = recipe.getRecipeMasteryRequirement(masteryLevel + 1);
                  progress = recipeLevel / nextLevel * 100;
                  if(progress > 100)
                  {
                     progress = 100;
                     m_toolTip.setText(ZLocUtils.t("Dialogs","Mastery_recipeAllStars"));
                  }
                  else
                  {
                     m_toolTip.setText(ZLocUtils.t("Dialogs","Mastery_recipeStars",{
                        "level":nextLevel,
                        "num":masteryLevel + 1
                     }));
                  }
                  m_progressBar.progress = progress;
               }
               this.m_recipeNumber.text = recipeLevel.toString();
               (m_element.stars_mc as MovieClip).gotoAndStop(masteryLevel + 1);
            }
            else
            {
               this.m_recipeNumber.text = "0";
               (m_element.stars_mc as MovieClip).gotoAndStop(0);
               nextLevel = recipe.getRecipeMasteryRequirement(1);
               m_progressBar.progress = 0;
               m_toolTip.setText(ZLocUtils.t("Dialogs","Mastery_recipeStars",{
                  "level":nextLevel,
                  "num":1
               }));
            }
            this.m_recipeNumber.visible = true;
            m_progressBar.visible = true;
            m_starsFrame.visible = true;
            setupMasterySignPurchaseFrame(data);
         }
      }
      
      override protected function getMasterySignCode(data:Object) : String
      {
         var result:String = "";
         var recipeItem:RecipeItem = data as RecipeItem;
         if(Boolean(recipeItem) && Boolean(recipeItem.masterySignCode))
         {
            result = recipeItem.masterySignCode;
         }
         return result;
      }
      
      override protected function getItemId(data:Object) : String
      {
         var result:String = "";
         var recipeItem:RecipeItem = data as RecipeItem;
         if(recipeItem)
         {
            result = recipeItem.id;
         }
         return result;
      }
      
      override protected function getType(data:Object) : String
      {
         return MasteryWindow.TYPE_RECIPE;
      }
      
      override public function release() : void
      {
         super.release();
         this.m_recipeNumber = null;
      }
   }
}

