package MyLife.Assets.Avatar.Interfaces
{
   import flash.display.Sprite;
   import flash.events.IEventDispatcher;
   
   public interface IAvatarClothingLoader extends IEventDispatcher
   {
      
      function loadClothing(param1:Array, param2:Function = null, param3:Number = 15000, param4:Function = null) : void;
      
      function getIconUrl(param1:String) : String;
      
      function getAsset(param1:String, param2:String = null) : Sprite;
      
      function cancel() : void;
      
      function getCategoryDefaults(param1:String) : Object;
      
      function getAllDefaults(param1:int) : Object;
      
      function getAssetPath(param1:String) : String;
      
      function getScriptPath() : String;
      
      function getItemImagePath(param1:String) : String;
      
      function cleanUp() : void;
      
      function loadClothingCollectionData(param1:Function) : void;
      
      function parseCustomizationData(param1:Object) : Object;
      
      function setRenderQuality(param1:String) : String;
   }
}

