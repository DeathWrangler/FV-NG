package Classes.NeighborActions
{
   import flash.utils.Dictionary;
   
   public class NeighborActionDataStore
   {
      
      private var m_neighborActions:Dictionary = null;
      
      public function NeighborActionDataStore(allVisitorActionsData:Object)
      {
         var visitorActionsData:Object = null;
         var visitorId:String = null;
         var timestamp:int = 0;
         var actionData:Object = null;
         var neighborPic:String = null;
         var level:int = 0;
         var achievements:int = 0;
         var masteries:int = 0;
         var avatar:Object = null;
         var name:String = null;
         var isStranger:Boolean = false;
         super();
         this.m_neighborActions = new Dictionary();
         for each(visitorActionsData in allVisitorActionsData)
         {
            visitorId = visitorActionsData.visitorId ? visitorActionsData.visitorId : "0";
            timestamp = visitorActionsData.timestamp ? int(visitorActionsData.timestamp) : 0;
            actionData = visitorActionsData.actions ? visitorActionsData.actions : null;
            neighborPic = visitorActionsData.neighborPic ? visitorActionsData.neighborPic : null;
            level = visitorActionsData.level ? int(visitorActionsData.level) : 0;
            achievements = visitorActionsData.achievements ? int(visitorActionsData.achievements) : 0;
            masteries = visitorActionsData.masteries ? int(visitorActionsData.masteries) : 0;
            avatar = visitorActionsData.avatar ? visitorActionsData.avatar : null;
            name = visitorActionsData.name ? visitorActionsData.name : "";
            isStranger = visitorActionsData.isStranger ? Boolean(visitorActionsData.isStranger) : false;
            if(Boolean(visitorId) && Boolean(timestamp) && Boolean(actionData))
            {
               this.m_neighborActions[visitorId] = new NeighborVisit(visitorId,timestamp,actionData,neighborPic,level,achievements,masteries,avatar,name,isStranger);
            }
         }
      }
      
      public function get neighborVisits() : Dictionary
      {
         return this.m_neighborActions;
      }
   }
}

