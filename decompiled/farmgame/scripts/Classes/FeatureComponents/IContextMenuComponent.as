package Classes.FeatureComponents
{
   import flash.events.MouseEvent;
   
   public interface IContextMenuComponent
   {
      
      function appendMenuItems(param1:Array) : Array;
      
      function onMenuClick(param1:MouseEvent) : void;
      
      function getSpecificEntry(param1:String, param2:String = null) : Object;
   }
}

