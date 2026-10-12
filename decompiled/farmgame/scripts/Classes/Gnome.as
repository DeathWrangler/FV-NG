package Classes
{
   import Classes.ZItem.FarmItem;
   import Display.UI;
   import Managers.FeatureBuildingSurfacingManager;
   import Widgets.Windows.BuildingSurfaceWindow;
   
   public class Gnome extends RotateableDecoration
   {
      
      public function Gnome(itemName:String = null)
      {
         super(itemName);
         m_surfacingKeyword = FeatureBuildingSurfacingManager.GNOME_SURFACING_KEYWORD;
      }
      
      override public function onFinishPlace(transactionResult:Object = null) : void
      {
         var building:FarmItem = null;
         super.onFinishPlace(transactionResult);
         if(Boolean(surfacingKeyword) && Boolean(m_item))
         {
            building = FeatureBuildingSurfacingManager.getInstance().conditionallyGetBuildingToSurface(this,surfacingKeyword);
            if(building)
            {
               UI.displayPopup(new BuildingSurfaceWindow(building,this,true));
            }
         }
      }
   }
}

