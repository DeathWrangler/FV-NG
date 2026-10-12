package Classes.NeighborActions
{
   import Classes.HarvestableResource;
   import Classes.ItemInstance;
   import Classes.NeighborVisitAvatar;
   import Classes.SimpleHarvestableResource;
   import Classes.ZItem.FarmItem;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Managers.FarmGameSettingsManager;
   import Transactions.NeighborActions.THarvestNeighbor;
   
   public class HarvestNeighborAction extends BaseNeighborAction
   {
      
      public function HarvestNeighborAction(resource:SimpleHarvestableResource)
      {
         super(resource);
      }
      
      override protected function getType() : String
      {
         return NeighborActionConstants.ACTION_TYPE_HARVEST;
      }
      
      override public function redeem(neighborId:String, neighborAvatar:NeighborVisitAvatar) : void
      {
         var resource:SimpleHarvestableResource = null;
         var objectFound:Boolean = false;
         var workedObject:WorldObject = Global.world.getObjectById(this.getWorkedObject().getId());
         if(workedObject)
         {
            resource = workedObject as SimpleHarvestableResource;
            if(resource)
            {
               if(resource.isHarvestable())
               {
                  resource.harvest(HarvestableResource.ENERGY_SOURCE_AVATAR,0,true,true,neighborId);
                  resource.doHarvestDropOff(neighborAvatar,false);
                  objectFound = true;
               }
            }
         }
         if(!objectFound)
         {
            super.redeem(neighborId,neighborAvatar);
         }
      }
      
      override public function getRedeemXpYield() : Number
      {
         var item:FarmItem = null;
         var result:Number = 0;
         if(m_object is ItemInstance)
         {
            item = (m_object as ItemInstance).getItem();
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               result = item.getNumberFromDataSource("xpYield");
            }
            else
            {
               result = Number(item.xml.xpYield);
            }
         }
         return result;
      }
      
      override public function getRedeemCoinYield() : Number
      {
         var item:FarmItem = null;
         var result:Number = 0;
         if(m_object is ItemInstance)
         {
            item = (m_object as ItemInstance).getItem();
            if(FarmGameSettingsManager.isInDataSourceExperiment())
            {
               result = item.getNumberFromDataSource("coinYield");
            }
            else
            {
               result = Number(item.xml.coinYield);
            }
         }
         return result;
      }
      
      override public function execute() : void
      {
         var resource:SimpleHarvestableResource = this.m_object as SimpleHarvestableResource;
         if(resource)
         {
            TransactionManager.addTransaction(new THarvestNeighbor(resource));
         }
      }
      
      override protected function getExecuteXpYield() : int
      {
         return Global.farmGameSettingsManager.getInt("neighborPlowBonusXp",1);
      }
      
      override protected function getExecuteCoinYield() : int
      {
         return Global.farmGameSettingsManager.getInt("neighborPlowBonusGold",10);
      }
   }
}

