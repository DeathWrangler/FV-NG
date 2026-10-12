package Widgets.Frames.Crafting
{
   import Classes.util.ZLocUtils;
   import flash.display.MovieClip;
   
   public class DefaultRecipeMasteryEarningsFrame extends RecipeMasteryEarningsFrame
   {
      
      public function DefaultRecipeMasteryEarningsFrame(element:MovieClip, defaultRecipe:String)
      {
         super(element,defaultRecipe,0,0,0,0);
         m_element.generic_tf.text = ZLocUtils.t("Crafting","Mastery_EarnDefaultTitle");
         m_element.generic4_tf.text = ZLocUtils.t("Crafting","Mastery_EarnDefaultCoins");
         m_element.generic5_tf.text = ZLocUtils.t("Crafting","Mastery_EarnDefaultXp");
      }
   }
}

