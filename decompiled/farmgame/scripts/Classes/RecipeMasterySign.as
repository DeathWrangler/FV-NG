package Classes
{
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   
   public class RecipeMasterySign extends Decoration
   {
      
      private var m_level:int = 1;
      
      private const MAX_IMAGE_STATE:int = 4;
      
      public function RecipeMasterySign(itemName:String = null)
      {
         var recipe:RecipeItem = null;
         var player:Player = null;
         var recipeLevel:int = 0;
         super(itemName);
         if(Global.player.initFinished && Global.worldManager.isWorldSwapStable)
         {
            recipe = Global.craftConfigSettings.getRecipeByMasterySign(Global.farmGameSettingsManager.getFarmItemByName(itemName).code);
            if(Boolean(recipe) && !Global.worldManager.isVisiting())
            {
               player = Global.player;
               recipeLevel = Global.player.craftingState.craftingSkillState.getRecipeStateById(recipe.id).level;
               this.level = recipe.getMasteryLevelForRecipeLevel(recipeLevel);
            }
         }
      }
      
      public function getCurrentSuffix() : int
      {
         return Math.max(Math.min(this.m_level - 1,this.MAX_IMAGE_STATE),0);
      }
      
      override public function getCurrentImageName() : String
      {
         return "built_" + this.getCurrentSuffix();
      }
      
      override protected function updateToolTipText() : void
      {
         var toolTip:String = null;
         if(isHighlighted())
         {
            if(!Global.worldManager.isVisiting())
            {
               toolTip = m_item.friendlyTitle + "\n" + this.getOwnerToolTipText();
            }
            else
            {
               toolTip = m_item.friendlyTitle;
            }
         }
         setToolTip(toolTip);
         updateToolTipPosition();
      }
      
      protected function getOwnerToolTipText() : String
      {
         var tooltip:String = "";
         var curRecipe:RecipeItem = Global.craftConfigSettings.getRecipeByMasterySign(this.getItem().code);
         var goodLevel:int = Global.player.craftingState.craftingSkillState.getRecipeStateById(curRecipe.id).level;
         if(this.m_level == 0)
         {
            this.level = curRecipe.getMasteryLevelForRecipeLevel(goodLevel);
         }
         if(this.m_level > this.MAX_IMAGE_STATE || goodLevel >= Global.craftConfigSettings.getMaxRecipeLevel(curRecipe.id))
         {
            tooltip = ZLocUtils.t("Crafting","recipemastery_mastered",{
               "levelNum":goodLevel,
               "recipe":ZLocUtils.tk_pk(curRecipe.friendlyName + "_recipe")
            });
         }
         else
         {
            tooltip = ZLocUtils.t("Crafting","recipemastery_notes",{
               "levelNumA":goodLevel,
               "recipe":ZLocUtils.tk_pk(curRecipe.friendlyName + "_recipe"),
               "levelNumB":curRecipe.getRecipeMasteryRequirement(this.m_level + 1)
            });
         }
         return tooltip;
      }
      
      public function set level(lvl:int) : void
      {
         this.m_level = lvl;
         this.setState(state);
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.level = data.level;
      }
      
      override public function getItemFriendlyName() : String
      {
         var friendlyName:String = m_item.friendlyName;
         if(!ZLocUtils.hasString(friendlyName))
         {
            friendlyName = "Items:" + m_item.className + "_friendlyName";
         }
         return friendlyName;
      }
   }
}

