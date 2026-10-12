package Widgets.Windows.Crafting
{
   import Classes.crafting.RecipeItem;
   import Widgets.Frames.Crafting.RecipeMasteryOnBoardFrame;
   
   public class RecipeMasteryOnBoard extends RecipeMasteryWindow
   {
      
      public function RecipeMasteryOnBoard(mastery:Array)
      {
         super(mastery);
      }
      
      override protected function fillCenterFrame(recipe:RecipeItem) : void
      {
         m_shareFrame = new RecipeMasteryOnBoardFrame(m_window.share_mc.info_mc,this,recipe != null);
         addWidget(m_shareFrame);
      }
   }
}

