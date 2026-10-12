package Widgets.Slots.Crafting
{
   import Classes.crafting.RecipeItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class MultiMasterySlot extends ZwSlotFrame
   {
      
      public function MultiMasterySlot(element:DisplayObject)
      {
         super(element);
         addWidget(new ZwTextField(m_element.generic_tf));
         addWidget(new FarmIcon(m_element.icon_mc));
      }
      
      override public function populate(recipeData:Object) : void
      {
         var recipe:RecipeItem = Global.craftConfigSettings.getRecipeById(recipeData.code);
         m_element.generic_tf.text = ZLocUtils.tk_pk_asTitle(recipe.friendlyName);
         m_element.generic_tf.visible = true;
         var url:String = recipe.getMasterySignIcon(recipeData.level);
         var farmIcon:FarmIcon = getWidget(m_element.icon_mc) as FarmIcon;
         if(Boolean(farmIcon) && url != "")
         {
            farmIcon.loadIcon(url);
            farmIcon.setIconHeight(75);
            farmIcon.setIconWidth(75);
            farmIcon.visible = true;
         }
      }
   }
}

