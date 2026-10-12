package Classes
{
   public interface IOrchardBuilding
   {
      
      function getTreeGrowState() : String;
      
      function isExpandable() : Boolean;
      
      function get orderedItemCodes() : Array;
      
      function displayStorageDialog(param1:String = "") : void;
   }
}

