package Classes
{
   import Classes.ZItem.FarmItem;
   import flash.utils.getDefinitionByName;
   
   public class TargetedConsumable extends Consumable
   {
      
      protected var m_targetObjectId:Number;
      
      public function TargetedConsumable(itemName:String, targetObjectId:Number)
      {
         super(itemName);
         this.m_targetObjectId = targetObjectId;
      }
      
      public static function createTargetedConsumable(itemName:String, targetObjectId:Number) : TargetedConsumable
      {
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(itemName);
         var tempClass:Class = getDefinitionByName("Classes.consumables." + item.className) as Class;
         return new tempClass(itemName,targetObjectId);
      }
   }
}

