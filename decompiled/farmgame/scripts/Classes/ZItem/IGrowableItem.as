package Classes.ZItem
{
   public interface IGrowableItem
   {
      
      function get staticData() : Object;
      
      function get growthConsumable() : String;
      
      function getStage(param1:String) : Object;
      
      function get farmItem() : FarmItem;
   }
}

