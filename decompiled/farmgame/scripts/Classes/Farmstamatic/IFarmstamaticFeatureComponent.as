package Classes.Farmstamatic
{
   import GameMode.GameMode;
   import flash.display.Sprite;
   
   public interface IFarmstamaticFeatureComponent
   {
      
      function getSubmitPhotoParams() : Object;
      
      function onSubmitPhotoResult(param1:Object) : void;
      
      function getSubmitPhotoTransactionData() : Object;
      
      function getFeatureName() : String;
      
      function createFarmstamaticDialog(param1:GameMode) : Sprite;
   }
}

