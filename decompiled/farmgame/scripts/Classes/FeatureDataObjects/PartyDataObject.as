package Classes.FeatureDataObjects
{
   import Classes.FriendSetGoal;
   import Classes.W2WFeatureState;
   import Classes.util.FarmGameUtil;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class PartyDataObject extends EventDispatcher
   {
      
      public static const PARTY_PLACEMENT_KEY:String = "partyPlacement";
      
      protected var m_friendSetGoal:FriendSetGoal;
      
      protected var m_w2wData:W2WFeatureState;
      
      protected var m_partyLocation:String = "";
      
      protected var m_friendSetCode:String = "";
      
      protected var m_isInitialized:Boolean = false;
      
      protected var m_partyEndDate:String = "";
      
      protected var m_shouldAutoComplete:Boolean = false;
      
      public function PartyDataObject(friendSetCode:String)
      {
         super();
         this.m_friendSetCode = friendSetCode;
         var friendSetXml:XML = Global.farmGameSettingsManager.getFriendSetXMLByCode(friendSetCode);
         this.m_friendSetGoal = Global.farmGameSettingsManager.getFriendSetGoalByCode(friendSetCode);
         this.m_friendSetGoal.friendSet = FriendSet.factory(friendSetCode);
         if(friendSetXml.hasOwnProperty(PARTY_PLACEMENT_KEY))
         {
            this.m_partyLocation = friendSetXml[PARTY_PLACEMENT_KEY][0];
         }
         if(friendSetXml.hasOwnProperty("partyEndDate"))
         {
            this.m_partyEndDate = friendSetXml["partyEndDate"];
         }
         if(friendSetXml.hasOwnProperty("autoComplete"))
         {
            this.m_shouldAutoComplete = friendSetXml["autoComplete"];
         }
      }
      
      public function initializeFriendSetData() : void
      {
         this.m_friendSetGoal.friendSet.addEventListener(Event.COMPLETE,this.onFriendSetInitialized);
         this.m_friendSetGoal.friendSet.initializeData();
      }
      
      private function onFriendSetInitialized(event:Event) : void
      {
         event.target.removeEventListener(event.type,arguments.callee);
         this.m_isInitialized = true;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function isPartyOver() : Boolean
      {
         var endTime:Number = NaN;
         var result:Boolean = false;
         if(null != this.m_partyEndDate && "" != this.m_partyEndDate)
         {
            endTime = FarmGameUtil.synchronizedDateToNumber(this.m_partyEndDate);
            if(GlobalEngine.serverTime >= endTime)
            {
               result = true;
            }
         }
         return result;
      }
      
      public function get shouldAutoComplete() : Boolean
      {
         return this.m_shouldAutoComplete;
      }
      
      public function get friendSet() : FriendSet
      {
         return this.m_friendSetGoal.friendSet;
      }
      
      public function get goal() : FriendSetGoal
      {
         return this.m_friendSetGoal;
      }
      
      public function get accessible() : Boolean
      {
         return this.goal.hasData;
      }
      
      public function get partyPlacement() : String
      {
         return this.m_partyLocation;
      }
      
      public function get friendSetCode() : String
      {
         return this.m_friendSetCode;
      }
      
      public function get isInitialized() : Boolean
      {
         return this.m_isInitialized;
      }
   }
}

