package Widgets.Frames.Crafting
{
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   
   public class ChooseCottageRecipeFrame extends ZwFrame
   {
      
      private const RECIPE_ICON_SIZE:int = 85;
      
      public function ChooseCottageRecipeFrame(element:MovieClip, craftType:String, slotIndex:int)
      {
         super(element);
         addWidget(new ZwFrame(element));
         var suffix:String = craftType + slotIndex.toString();
         addWidget(new ZwTextField(element.recipeName_tf,ZLocUtils.t("Crafting","ChooseCraftSampleRecipe_" + suffix)));
         addWidget(new ZwTextField(element.generic_tf,ZLocUtils.t("Crafting","ChooseCraftSampleRecipeBushelsNeeded")));
         addWidget(new ZwTextField(element.generic2_tf,ZLocUtils.t("Crafting","ChooseCraftSampleRecipeDesc_" + suffix)));
         var iconUrl:String = Global.farmGameSettingsManager.getString("craftingSampleRecipeImage_" + suffix);
         var icon:FarmIcon = new FarmIcon(element.icon_mc,iconUrl);
         icon.setIconSize(this.RECIPE_ICON_SIZE,this.RECIPE_ICON_SIZE);
         addWidget(icon);
      }
   }
}

