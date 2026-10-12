package Transactions
{
   import Classes.FeatureDataObjects.BuildingExpansionData;
   import Classes.Quest.FarmQuestManager;
   import Classes.StorageBuilding;
   import Classes.ZItem.FarmItem;
   import Classes.storage.PartItem;
   import Engine.Events.TransactionEvent;
   
   public class TCompleteNow extends TWorldState
   {
      
      public static const ACTION_COMPLETE_NOW:String = "CompleteNow";
      
      private var m_partName:String;
      
      private var m_callBack:Function;
      
      private var m_useGifts:int;
      
      private var m_forceCash:Boolean;
      
      private var m_rewardItemCodes:Array;
      
      public function TCompleteNow(building:StorageBuilding, partName:String = null, callback:Function = null, useGifts:int = 1, forceCash:Boolean = false)
      {
         var buildingExpansionData:BuildingExpansionData = null;
         var parts:Vector.<PartItem> = null;
         var part:PartItem = null;
         var partFarmItem:FarmItem = null;
         var numParts:int = 0;
         this.m_partName = partName;
         this.m_callBack = callback;
         this.m_useGifts = useGifts;
         this.m_forceCash = forceCash;
         if(!Global.flashHotParams["MULTISTORE_COMPLETENOW"])
         {
            this.m_useGifts = 1;
         }
         if(this.m_useGifts > 1)
         {
            buildingExpansionData = building.getBuildingExpansionDataByLevel(building.storageLevel);
            if(buildingExpansionData)
            {
               parts = buildingExpansionData.parts;
               if(parts)
               {
                  for each(part in parts)
                  {
                     partFarmItem = part.item;
                     if(partFarmItem)
                     {
                        for(numParts = 0; numParts < this.m_useGifts; numParts++)
                        {
                           Global.player.removeGift(null,partFarmItem.name);
                        }
                     }
                  }
               }
            }
         }
         super(building);
      }
      
      override public function perform() : void
      {
         var params:Object = {
            "partName":this.m_partName,
            "isGift":this.m_useGifts > 1
         };
         if(this.m_forceCash)
         {
            params["currency"] = "cash";
         }
         signedWorldAction(ACTION_COMPLETE_NOW,params);
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         var building:StorageBuilding = m_object as StorageBuilding;
         building.onStoreComplete(result);
         building.reloadImage();
         if(this.m_callBack !== null)
         {
            this.m_callBack.call(null,result);
         }
         if(result)
         {
            if(result.hasOwnProperty("rewardItemCodes"))
            {
               this.m_rewardItemCodes = result.rewardItemCodes as Array;
               FarmQuestManager.getInstance().processTransactionOnServerComplete(new TransactionEvent(TransactionEvent.COMPLETED,this));
            }
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = new Object();
         var storageBuilding:StorageBuilding = m_object as StorageBuilding;
         result.method = TWorldState.METHOD_PERFORM_ACTION;
         result.action = ACTION_COMPLETE_NOW;
         result.item = storageBuilding.getItem();
         result.storageLevelUp = result.currentExpansionLevel = storageBuilding.storageLevel;
         result.rewardItemCodes = this.m_rewardItemCodes;
         return result;
      }
   }
}

