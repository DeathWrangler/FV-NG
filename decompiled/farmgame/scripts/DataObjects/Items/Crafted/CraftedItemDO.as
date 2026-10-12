package DataObjects.Items.Crafted
{
   import DataObjects.Items.BaseItemDO;
   
   public class CraftedItemDO extends BaseItemDO
   {
      
      public var defaultPrice:int;
      
      public var railsPriceMax:int;
      
      public var railsPriceMin:int;
      
      public function CraftedItemDO()
      {
         super();
      }
   }
}

