package GameMode
{
   import Classes.Farmstamatic.IFarmstamaticFeatureComponent;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Widgets.Windows.FarmstamaticTakePhoto;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class GMFarmstamatic extends GMDefault
   {
      
      public function GMFarmstamatic(isGift:Boolean = false, shouldReOpenGift:Boolean = true, featureComponent:IFarmstamaticFeatureComponent = null)
      {
         var dialog:Sprite = null;
         super(isGift,shouldReOpenGift);
         try
         {
            if(featureComponent)
            {
               dialog = featureComponent.createFarmstamaticDialog(this);
            }
            if(!dialog)
            {
               dialog = new FarmstamaticTakePhoto(this,featureComponent);
            }
            UI.displayPopup(dialog);
         }
         catch(err:Error)
         {
            ErrorManager.addError("Error instantiating Farmstamatic " + err.message);
            Global.world.addGameMode(new GMDefault());
         }
      }
      
      override protected function canBeClicked(event:MouseEvent) : Boolean
      {
         return false;
      }
   }
}

