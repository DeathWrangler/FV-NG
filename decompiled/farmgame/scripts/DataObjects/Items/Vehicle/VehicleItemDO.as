package DataObjects.Items.Vehicle
{
   import DataObjects.Items.BaseItemDO;
   
   public class VehicleItemDO extends BaseItemDO
   {
      
      public var actionSizeX:int;
      
      public var actionSizeY:int;
      
      public var energyCost:int;
      
      public var simpleZAttributeTags:ItemSimpleZAttributeTagsDO;
      
      public var embeddedImage:Array;
      
      public function VehicleItemDO()
      {
         super();
      }
   }
}

