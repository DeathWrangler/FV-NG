package Classes.NeighborActions
{
   import Classes.ChickenCoopBuilding;
   import Classes.FarmGameObject;
   import Classes.NeighborVisitAvatar;
   import Classes.Plot;
   import Classes.SimpleHarvestableResource;
   import Classes.util.ZLocUtils;
   import Engine.Classes.WorldObject;
   import Engine.Managers.TransactionManager;
   import Managers.RetentionMasterManager;
   import Transactions.NeighborActions.TClearNeighborAction;
   
   public class BaseNeighborAction
   {
      
      private var m_type:String;
      
      protected var m_object:WorldObject;
      
      private var m_worldType:String;
      
      public function BaseNeighborAction(object:WorldObject)
      {
         super();
         this.m_type = this.getType();
         this.m_object = object;
      }
      
      public static function factory(type:String, objectId:int, worldType:String) : BaseNeighborAction
      {
         var worldObject:WorldObject = null;
         var plowPlot:Plot = null;
         var fertPlot:Plot = null;
         var unwitherPlot:Plot = null;
         var resource:SimpleHarvestableResource = null;
         var chickenCoop:ChickenCoopBuilding = null;
         var result:BaseNeighborAction = null;
         worldObject = Global.world.getObjectById(objectId);
         if(worldObject)
         {
            switch(type)
            {
               case NeighborActionConstants.ACTION_TYPE_PLOW:
                  plowPlot = worldObject as Plot;
                  if(plowPlot)
                  {
                     result = new PlowNeighborAction(plowPlot);
                  }
                  break;
               case NeighborActionConstants.ACTION_TYPE_FERT:
                  fertPlot = worldObject as Plot;
                  if(fertPlot)
                  {
                     result = new FertNeighborAction(fertPlot);
                  }
                  break;
               case NeighborActionConstants.ACTION_TYPE_UNWITHER:
                  unwitherPlot = worldObject as Plot;
                  if(unwitherPlot)
                  {
                     result = new UnwitherNeighborAction(unwitherPlot);
                  }
                  break;
               case NeighborActionConstants.ACTION_TYPE_HARVEST:
                  resource = worldObject as SimpleHarvestableResource;
                  if(resource)
                  {
                     result = new HarvestNeighborAction(resource);
                  }
                  break;
               case NeighborActionConstants.ACTION_TYPE_FEED_CHICKENS:
                  chickenCoop = worldObject as ChickenCoopBuilding;
                  if(chickenCoop)
                  {
                     result = new FeedChickensNeighborAction(chickenCoop);
                  }
                  break;
               case NeighborActionConstants.ACTION_TYPE_TRICK_NEIGHBOR:
                  if(worldObject)
                  {
                     result = new TrickNeighborAction(worldObject);
                  }
            }
         }
         if(result is BaseNeighborAction)
         {
            result.worldType = worldType;
         }
         return result;
      }
      
      protected function getType() : String
      {
         return NeighborActionConstants.ACTION_TYPE_UNKNOWN;
      }
      
      public function get worldType() : String
      {
         return this.m_worldType;
      }
      
      public function set worldType(worldType:String) : void
      {
         this.m_worldType = worldType;
      }
      
      public function getLimitType() : String
      {
         return NeighborActionConstants.LIMIT_TYPE_FARM_ACTION;
      }
      
      public function getActionKey() : String
      {
         return null;
      }
      
      public function get objectId() : int
      {
         return this.m_object.getId();
      }
      
      protected function getExecuteXpYield() : int
      {
         return 0;
      }
      
      protected function getExecuteCoinYield() : int
      {
         return 0;
      }
      
      public function getRedeemXpYield() : Number
      {
         return 0;
      }
      
      public function getRedeemCoinYield() : Number
      {
         return 0;
      }
      
      public function getWorkedObject() : WorldObject
      {
         return this.m_object;
      }
      
      public function execute() : void
      {
         var xp:int = Global.player.calculateAndAddXp(this.getExecuteXpYield());
         var coins:int = this.getExecuteCoinYield();
         Global.player.gold += coins;
         if(Boolean(RetentionMasterManager) && this.m_object is FarmGameObject)
         {
            (this.m_object as FarmGameObject).displayStatus(ZLocUtils.t("FarmGame","Status_WorkNeighbor",{
               "coinNum":coins,
               "xpNum":xp
            }));
         }
         else
         {
            Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_WorkNeighbor",{
               "coinNum":coins,
               "xpNum":xp
            }));
         }
      }
      
      public function redeem(neighborId:String, neighborAvatar:NeighborVisitAvatar) : void
      {
         this.clear(neighborId);
      }
      
      public function clear(neighborId:String) : void
      {
         TransactionManager.addTransaction(new TClearNeighborAction(neighborId,this.getType(),this.objectId));
      }
   }
}

