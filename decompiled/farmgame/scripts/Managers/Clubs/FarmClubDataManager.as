package Managers.Clubs
{
   import Classes.Constants.FarmClubConstants;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import Events.DynamicObjectEvent;
   import Managers.Clubs.DataObjects.*;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Transactions.TGenericTransaction;
   import Widgets.Frames.Clubs.FarmClubLeaderboardSlotContainerFrame;
   import Widgets.Frames.Clubs.MyClubFrame;
   import flash.utils.Dictionary;
   
   public class FarmClubDataManager
   {
      
      private static var m_dataStore:Dictionary;
      
      private static var m_callers:Dictionary;
      
      public static const BROWSE_CLUB_DATA:String = "browse_club";
      
      public static const TOP_50_DATA:String = "top_50";
      
      public static const CLUB_FRIENDS_DATA:String = "my_friends";
      
      public static const FARM_CLUB_DATA:String = "farm_club";
      
      public static const CLUB_VIEW_DATA:String = "other_club";
      
      public static const DRILLDOWN_VIEW_DATA:String = "drilldown_club";
      
      public static const OUR_RANK_DATA:String = FarmClubLeaderboardSlotContainerFrame.LEADERBOARD_VIEW_MY_TIER;
      
      public static const TOP_FARMERS_DATA:String = MyClubFrame.TOP_FARMERS_FRAME;
      
      public static const MY_FRIENDS_DATA:String = MyClubFrame.MY_FRIENDS_FRAME;
      
      public static const MY_RANK_DATA:String = FarmClubLeaderboardSlotContainerFrame.LEADERBOARD_VIEW_ROSTER;
      
      public static const METER_FRAME_DATA:String = "meter_frame";
      
      public static const TIER_TOP_10_DATA:String = "tier_top";
      
      public static const TIER_TOP_AMOUNT:int = 10;
      
      public static const UNREGISTERED:int = 0;
      
      private static const TOP_50_TTL:int = 3600;
      
      public static const DEFAULT_TTL:int = 300;
      
      private static var m_instance:FarmClubDataManager = null;
      
      private static var m_initialized:Boolean = false;
      
      private static var m_callerId:int = 1;
      
      public function FarmClubDataManager()
      {
         super();
         if(!m_initialized)
         {
            m_initialized = true;
            m_callers = new Dictionary();
            m_dataStore = new Dictionary();
            m_dataStore[BROWSE_CLUB_DATA] = new BrowseClubObject(BROWSE_CLUB_DATA,DEFAULT_TTL);
            m_dataStore[OUR_RANK_DATA] = new MyClubLeaderboardObject(OUR_RANK_DATA,DEFAULT_TTL);
            m_dataStore[TOP_FARMERS_DATA] = new MyClubLeaderboardObject(TOP_FARMERS_DATA,DEFAULT_TTL);
            m_dataStore[MY_FRIENDS_DATA] = new MyClubLeaderboardObject(MY_FRIENDS_DATA,DEFAULT_TTL);
            m_dataStore[MY_RANK_DATA] = new MyClubLeaderboardObject(MY_RANK_DATA,DEFAULT_TTL);
            m_dataStore[TOP_50_DATA] = new FarmClubLeaderboardObject(TOP_50_DATA,TOP_50_TTL);
            m_dataStore[FARM_CLUB_DATA] = new FarmClubDataObject(FARM_CLUB_DATA,DEFAULT_TTL);
            m_dataStore[DRILLDOWN_VIEW_DATA] = new FarmClubDataObject(DRILLDOWN_VIEW_DATA,DEFAULT_TTL);
            m_dataStore[METER_FRAME_DATA] = new FarmClubBaseObject(METER_FRAME_DATA,DEFAULT_TTL);
            return;
         }
         throw new Error("Error: Instantiation failed: Use FarmClubDataManager.getInstance() instead of new.");
      }
      
      public static function getInstance() : FarmClubDataManager
      {
         if(m_instance == null)
         {
            m_instance = new FarmClubDataManager();
         }
         return m_instance;
      }
      
      public static function getTop10DataKey(tier:int) : String
      {
         return tier + TIER_TOP_10_DATA;
      }
      
      public function initialize() : void
      {
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,FarmClubUtility.onTransactionAdded);
         if(this.clubId != null)
         {
            this.getFarmClubDataObject();
         }
      }
      
      public function featureOptionsUpdated(optionName:String, optionValue:Object) : void
      {
         var farmClubDataObject:FarmClubDataObject = null;
         var leaderboardDataObj:MyClubLeaderboardObject = null;
         var browseClubDataObj:BrowseClubObject = null;
         var meterData:FarmClubBaseObject = null;
         switch(optionName)
         {
            case FarmClubConstants.OPTION_CURRENT_CLUB_ID:
               if(optionValue != "")
               {
                  farmClubDataObject = FarmClubDataManager.getInstance().getFarmClubDataObject(true);
                  if(farmClubDataObject != null)
                  {
                     farmClubDataObject.setDirty();
                  }
                  leaderboardDataObj = FarmClubDataManager.getInstance().getMyClubLeaderboardObject(MyClubFrame.OUR_RANK_FRAME) as MyClubLeaderboardObject;
                  if(leaderboardDataObj != null)
                  {
                     leaderboardDataObj.setDirty();
                  }
                  browseClubDataObj = FarmClubDataManager.getInstance().getBrowseClubObject();
                  if(browseClubDataObj != null)
                  {
                     browseClubDataObj.setDirty();
                  }
                  meterData = FarmClubDataManager.getInstance().getMeterData(true);
                  if(meterData != null)
                  {
                     meterData.setDirty();
                  }
                  leaderboardDataObj = FarmClubDataManager.getInstance().getMyClubLeaderboardObject(MY_RANK_DATA) as MyClubLeaderboardObject;
                  if(leaderboardDataObj != null)
                  {
                     leaderboardDataObj.setDirty();
                  }
                  FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.CREATE_CLUB_EVENT));
               }
               else
               {
                  FarmClubUtility.dispatcher.dispatchEvent(new DynamicObjectEvent(FarmClubConstants.ON_LEAVE_CLUB_EVENT));
               }
         }
      }
      
      public function getBrowseClubObject() : BrowseClubObject
      {
         var result:BrowseClubObject = null;
         result = this.fetchData(BROWSE_CLUB_DATA,new TGenericTransaction("FarmClubService","getJoinableClubs",function(result:Object):void
         {
            onLoadData(BROWSE_CLUB_DATA,result);
         })) as BrowseClubObject;
         return result;
      }
      
      public function getTop50LeaderboardObject() : FarmClubLeaderboardObject
      {
         var result:FarmClubLeaderboardObject = null;
         result = this.fetchData(TOP_50_DATA,new TGenericTransaction("FarmClubService","getTop50",function(result:Object):void
         {
            onLoadData(TOP_50_DATA,result);
         })) as FarmClubLeaderboardObject;
         return result;
      }
      
      public function getMyClubLeaderboardObject(view:String) : MyClubLeaderboardObject
      {
         var result:MyClubLeaderboardObject = null;
         var clubId:String = this.clubId;
         if(view == MyClubFrame.OUR_RANK_FRAME && clubId != null && clubId != "")
         {
            result = this.fetchData(OUR_RANK_DATA,new TGenericTransaction("FarmClubService","getClubTierLeaderboard",function(result:Object):void
            {
               onLoadData(OUR_RANK_DATA,result);
            },[clubId])) as MyClubLeaderboardObject;
         }
         else if(clubId != null)
         {
            result = this.fetchData(view,new TGenericTransaction("FarmClubService","getMemberLeaderboard",function(result:Object):void
            {
               onLoadData(view,result);
            },[clubId,view])) as MyClubLeaderboardObject;
         }
         return result;
      }
      
      public function getClubViewLeaderboardObject(clubId:String) : ViewFarmClubObject
      {
         var result:ViewFarmClubObject = null;
         var key:String = null;
         key = clubId + CLUB_VIEW_DATA;
         if(!m_dataStore[key])
         {
            m_dataStore[key] = new ViewFarmClubObject(key,DEFAULT_TTL);
         }
         result = this.fetchData(key,new TGenericTransaction("FarmClubService","getMemberLeaderboard",function(result:Object):void
         {
            onLoadData(key,result);
         },[clubId,MyClubFrame.TOP_FARMERS_FRAME,true])) as ViewFarmClubObject;
         return result;
      }
      
      public function getTierTop10Data(tier:int) : FarmClubLeaderboardObject
      {
         var key:String = null;
         var result:FarmClubLeaderboardObject = null;
         key = getTop10DataKey(tier);
         if(!m_dataStore[key])
         {
            m_dataStore[key] = new FarmClubLeaderboardObject(key,DEFAULT_TTL);
         }
         result = this.fetchData(key,new TGenericTransaction("FarmClubService","getTierTop",function(result:Object):void
         {
            onLoadData(key,result);
         },[tier,TIER_TOP_AMOUNT])) as FarmClubLeaderboardObject;
         return result;
      }
      
      public function getClubDrillDownDataObject(clubId:String, ignoreStale:Boolean = false, staleOverride:Boolean = false) : FarmClubDataObject
      {
         var result:FarmClubDataObject = null;
         ;
         if(clubId != null && clubId != "")
         {
            result = this.fetchData(DRILLDOWN_VIEW_DATA,new TGenericTransaction("FarmClubService","getDrillDownData",function(result:Object):void
            {
               onLoadData(DRILLDOWN_VIEW_DATA,result);
            },[clubId]),ignoreStale,staleOverride) as FarmClubDataObject;
         }
         return result;
      }
      
      public function getFarmClubDataObject(ignoreStale:Boolean = false) : FarmClubDataObject
      {
         var result:FarmClubDataObject = null;
         var clubId:String = this.clubId;
         if(clubId != null && clubId != "")
         {
            result = this.fetchData(FARM_CLUB_DATA,new TGenericTransaction("FarmClubService","getMyClubData",function(result:Object):void
            {
               onLoadData(FARM_CLUB_DATA,result);
            }),ignoreStale) as FarmClubDataObject;
         }
         return result;
      }
      
      public function saveUserFarmClubData(data:FarmClubDataObject) : void
      {
         m_dataStore[FARM_CLUB_DATA] = data;
      }
      
      public function getMeterData(ignoreStale:Boolean = false) : FarmClubBaseObject
      {
         var result:FarmClubBaseObject = null;
         result = this.fetchData(METER_FRAME_DATA,new TGenericTransaction("FarmClubService","getMeterInfo",function(result:Object):void
         {
            onLoadData(METER_FRAME_DATA,result);
         }),ignoreStale) as FarmClubBaseObject;
         return result;
      }
      
      public function getFarmClubDataObjectForId(clubId:String, ignoreStale:Boolean = false) : FarmClubDataObject
      {
         var result:FarmClubDataObject = null;
         var key:String = null;
         key = clubId + FARM_CLUB_DATA;
         if(!m_dataStore[key])
         {
            m_dataStore[key] = new FarmClubDataObject(key,DEFAULT_TTL);
         }
         if(clubId != null && clubId != "")
         {
            result = this.fetchData(key,new TGenericTransaction("FarmClubService","getClubDataObject",function(result:Object):void
            {
               onLoadData(key,result);
            },[clubId]),ignoreStale) as FarmClubDataObject;
         }
         return result;
      }
      
      private function fetchData(type:String, transaction:Transaction, ignoreStale:Boolean = false, staleOverride:Boolean = false) : IFarmClubObject
      {
         var result:IFarmClubObject = null;
         var dataObj:IFarmClubObject = null;
         if(m_dataStore[type])
         {
            dataObj = m_dataStore[type] as IFarmClubObject;
            if(!staleOverride && (dataObj.isLoaded && !dataObj.isStale) || Boolean(ignoreStale && dataObj.data) && Boolean(dataObj.isLoaded))
            {
               result = dataObj;
            }
            if((staleOverride || (!dataObj.isLoaded || dataObj.isStale)) && !dataObj.isPending)
            {
               dataObj.setIsPending();
               TransactionManager.addTransaction(transaction,true);
            }
         }
         else
         {
            FarmStatsManager.count("farm_clubs","errors","FarmClubDataManager::fetchData","dataStoreMissingType",type);
         }
         return result;
      }
      
      private function onLoadData(type:String, result:Object) : void
      {
         var dataObject:IFarmClubObject = null;
         if(m_dataStore[type] != null)
         {
            dataObject = m_dataStore[type] as IFarmClubObject;
            dataObject.onLoadData(result);
            this.notify(type);
         }
      }
      
      public function registerCaller(type:String, callback:Function) : int
      {
         var obj:Object = new Object();
         obj.type = type;
         obj.callback = callback;
         var idx:int = m_callerId++;
         m_callers[idx] = obj;
         return idx;
      }
      
      private function notify(type:String) : void
      {
         var obj:Object = null;
         var idx:int = 0;
         for each(obj in m_callers)
         {
            if(obj != null && obj.type == type)
            {
               obj.callback(m_dataStore[type]);
            }
         }
      }
      
      public function unregisterCaller(idx:int) : void
      {
         if(m_callers[idx])
         {
            delete m_callers[idx];
         }
      }
      
      public function get clubId() : String
      {
         var result:String = null;
         var value:Object = FeatureOptionsManager.getInstance().getFeatureOption(FarmClubConstants.FARM_CLUB,FarmClubConstants.OPTION_CURRENT_CLUB_ID);
         if(value != null && value != "")
         {
            result = String(value);
         }
         return result;
      }
   }
}

