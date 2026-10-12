package Classes.consumables
{
   import Classes.Consumable;
   import Classes.FeatureBuilding;
   import Classes.FeatureDataObjects.LootTicketBoothStageConfig;
   import Managers.LootTicketBoothManager;
   import Widgets.Windows.LootTicketBooth.LootTicketBoothWindow;
   
   public class CLootTicket extends Consumable
   {
      
      public static const CLASS_NAME:String = "CLootTicket";
      
      public function CLootTicket(itemName:String)
      {
         super(itemName);
      }
      
      public static function getBoothFeatureName(itemName:String) : String
      {
         var result:String = null;
         var featureXML:XML = Global.farmGameSettingsManager.getFeatureXML(itemName);
         if(featureXML)
         {
            result = featureXML.boothFeatureName.toString();
         }
         return result;
      }
      
      public static function canTakeItem(itemName:String) : Boolean
      {
         var stage:LootTicketBoothStageConfig = null;
         var ticketItemOwned:int = 0;
         var result:Boolean = true;
         var boothFeatureName:String = getBoothFeatureName(itemName);
         if(boothFeatureName)
         {
            stage = LootTicketBoothManager.getLastStageUnlocked(boothFeatureName);
            if(stage)
            {
               if(stage.ticketItemName == itemName)
               {
                  ticketItemOwned = Global.player.getGiftCountForItem(stage.ticketItemName);
                  if(ticketItemOwned >= stage.ticketItemLimit)
                  {
                     result = false;
                  }
               }
            }
         }
         return result;
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         var boothFeatureName:String = getBoothFeatureName(getItemName());
         var objects:Array = Global.world.getObjectsByName(boothFeatureName);
         if(Boolean(objects) && Boolean(objects.length > 0) && objects[0] is FeatureBuilding)
         {
            LootTicketBoothWindow.display(objects[0] as FeatureBuilding);
         }
      }
   }
}

