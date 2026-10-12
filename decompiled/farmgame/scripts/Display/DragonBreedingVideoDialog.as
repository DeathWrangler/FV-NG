package Display
{
   import Display.Dialogs.CutsceneDialog;
   import Managers.DragonBreedingManager;
   import com.troyer.widget.view.BaseWidgetView;
   
   public class DragonBreedingVideoDialog extends CutsceneDialog
   {
      
      public function DragonBreedingVideoDialog(view:BaseWidgetView)
      {
         super(view);
      }
      
      override public function destroy() : void
      {
         DragonBreedingManager.showMotd();
         super.destroy();
      }
   }
}

