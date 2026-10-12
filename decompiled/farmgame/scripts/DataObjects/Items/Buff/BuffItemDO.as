package DataObjects.Items.Buff
{
   import DataObjects.Items.BaseItemDO;
   
   public class BuffItemDO extends BaseItemDO
   {
      
      public var buffSize:Number;
      
      public var buffType:String;
      
      public var masteryTypes:ItemMasteryTypesDO;
      
      public var multiplierKey:String;
      
      public var prereqs:ItemPrereqsDO;
      
      public var walkspeed:int;
      
      public function BuffItemDO()
      {
         super();
      }
   }
}

