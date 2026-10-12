package Classes
{
   import Classes.ZItem.ConsumableItem;
   import Classes.ZItem.FarmItem;
   import flash.utils.getDefinitionByName;
   
   public class AutoConsumable extends ItemInstance
   {
      
      private var subClasses:Array = [ActionDrivenAutoConsumable,WanderingPirateAutoConsumable,MiniDartsAutoConsumable,BBChristmasAutoConsumable,FeatureOptionAutoConsumable,ActionDrivenPersistAutoConsumable];
      
      public function AutoConsumable(itemName:String)
      {
         super(itemName);
      }
      
      public static function createAutoConsumable(itemName:String) : AutoConsumable
      {
         var result:AutoConsumable = null;
         var classDefinition:Class = null;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         if(Boolean(item) && Boolean(item is ConsumableItem) && Boolean(item.className))
         {
            try
            {
               classDefinition = getDefinitionByName("Classes." + item.className) as Class;
               if(classDefinition)
               {
                  result = new classDefinition(itemName);
               }
            }
            catch(e:Error)
            {
            }
         }
         return result;
      }
      
      public function consume() : void
      {
      }
   }
}

