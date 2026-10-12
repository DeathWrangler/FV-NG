package Classes.NeighborActions
{
   import Classes.Constants.WorldsConstants;
   import Classes.NeighborVisitAvatar;
   import Classes.util.ZLocUtils;
   import Engine.Classes.WorldObject;
   
   public class NeighborVisit
   {
      
      private var m_neighborId:String;
      
      private var m_timestamp:int;
      
      private var m_actions:Array;
      
      private var m_level:int;
      
      private var m_masteries:int;
      
      private var m_achievements:int;
      
      private var m_avatarData:Object;
      
      private var m_neighborPic:String;
      
      private var m_name:String;
      
      private var m_isStranger:Boolean;
      
      public function NeighborVisit(neigborId:String, timestamp:int, allActionData:Object, neighborPic:String = "", level:int = 0, achievements:int = 0, masteries:int = 0, avatarData:Object = null, name:String = "", isStranger:Boolean = false)
      {
         var actionData:Object = null;
         var actionType:String = null;
         var objectId:int = 0;
         var worldType:String = null;
         var action:BaseNeighborAction = null;
         super();
         this.m_neighborId = neigborId;
         this.m_timestamp = timestamp;
         this.m_actions = new Array();
         this.m_level = level;
         this.m_achievements = achievements;
         this.m_neighborPic = neighborPic;
         this.m_masteries = masteries;
         this.m_avatarData = avatarData;
         this.m_name = name;
         this.m_isStranger = isStranger;
         for each(actionData in allActionData)
         {
            actionType = actionData.actionType ? actionData.actionType : null;
            objectId = actionData.objectId ? int(actionData.objectId) : int(null);
            worldType = actionData.worldType ? actionData.worldType : WorldsConstants.WORLD_ID_HOME;
            if(Boolean(actionType) && Boolean(objectId) && Boolean(worldType))
            {
               action = BaseNeighborAction.factory(actionType,objectId,worldType);
               if(action)
               {
                  this.m_actions.push(action);
               }
            }
         }
      }
      
      public function isValid(worldType:String) : Boolean
      {
         var worldObjectsInWorld:Array = null;
         var result:Boolean = false;
         if(Boolean(this.m_neighborId) && Boolean(this.m_timestamp))
         {
            worldObjectsInWorld = this.getWorkedObjectsByWorldType(worldType);
            if(worldObjectsInWorld.length > 0)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function get level() : int
      {
         return this.m_level;
      }
      
      public function get achievements() : int
      {
         return this.m_achievements;
      }
      
      public function get masteries() : int
      {
         return this.m_masteries;
      }
      
      public function get avatarData() : Object
      {
         return this.m_avatarData;
      }
      
      public function get neighborPic() : String
      {
         return this.m_neighborPic;
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function get isStranger() : Boolean
      {
         return this.m_isStranger;
      }
      
      public function get neighborId() : String
      {
         return this.m_neighborId;
      }
      
      public function get neighborActions() : Array
      {
         return this.m_actions;
      }
      
      public function getWorkedObjects() : Array
      {
         var action:BaseNeighborAction = null;
         var worldObject:WorldObject = null;
         var result:Array = new Array();
         for each(action in this.m_actions)
         {
            worldObject = Global.world.getObjectById(action.objectId) as WorldObject;
            if(worldObject)
            {
               result.push(worldObject);
            }
         }
         return result;
      }
      
      public function getWorkedObjectsByWorldType(worldType:String) : Array
      {
         var action:BaseNeighborAction = null;
         var worldObject:WorldObject = null;
         var result:Array = new Array();
         for each(action in this.m_actions)
         {
            if(worldType == action.worldType)
            {
               worldObject = Global.world.getObjectById(action.objectId) as WorldObject;
               if(worldObject)
               {
                  result.push(worldObject);
               }
            }
         }
         return result;
      }
      
      public function redeemActions(neighborAvatar:NeighborVisitAvatar) : void
      {
         var action:BaseNeighborAction = null;
         var xpYield:Number = 0;
         var coinYield:Number = 0;
         for each(action in this.m_actions)
         {
            action.redeem(this.neighborId,neighborAvatar);
            xpYield += Global.player.calculateXp(action.getRedeemXpYield());
            coinYield += action.getRedeemCoinYield();
         }
         if(xpYield > 0)
         {
            if(coinYield > 0)
            {
               Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestCoinsXP",{
                  "coinNum":coinYield,
                  "xpNum":xpYield
               }));
            }
            else
            {
               Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestXP",{"xpNum":xpYield}));
            }
         }
         else if(coinYield > 0)
         {
            Global.selectedAvatar.displayStatus(ZLocUtils.t("FarmGame","Status_HarvestPlot",{"coinNum":coinYield}));
         }
      }
      
      public function clearActions() : void
      {
         var action:BaseNeighborAction = null;
         for each(action in this.m_actions)
         {
            action.clear(this.neighborId);
         }
      }
   }
}

