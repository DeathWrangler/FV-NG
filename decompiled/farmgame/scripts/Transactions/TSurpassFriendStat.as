package Transactions
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   
   public class TSurpassFriendStat extends TFarmTransaction
   {
      
      public static const LEVEL:String = "level";
      
      public static const RIBBONS:String = "ribbons";
      
      public static const MASTERIES:String = "masteries";
      
      public static const MEDALS:String = "medals";
      
      public static const COLLECTIONS:String = "collections";
      
      public static const BUILDINGS:String = "buildings";
      
      protected var m_statObject:Object;
      
      protected var m_backendVerified:Boolean;
      
      public function TSurpassFriendStat(statObject:Object, backendVerified:Boolean)
      {
         super();
         this.m_statObject = statObject;
         this.m_backendVerified = backendVerified;
      }
      
      override public function perform() : void
      {
         signedCall("StatsPassService.onSurpassedFriendStat",this.m_statObject.statType,this.m_statObject.statSubType,this.m_statObject.friendID.toString(),this.m_backendVerified);
      }
      
      override protected function onComplete(result:Object) : void
      {
         var shareCallback:Function = null;
         var subTypeForLocalization:String = null;
         var key:String = null;
         var friendName:String = null;
         var friendGender:String = null;
         var popupMessage:String = null;
         var popup:GenericPopup = null;
         var friendId:String = null;
         var params:Object = null;
         var bundleId:String = null;
         var targetIds:Array = null;
         var fuelcan:FarmItem = null;
         var iconUrl:String = null;
         if(result != "success")
         {
            if(Boolean(result) && Boolean(result.hasOwnProperty("verified")) && result.verified == true)
            {
               shareCallback = function(evt:GenericPopupEvent):void
               {
                  if(evt.button == GenericPopup.ACCEPT)
                  {
                     TransactionManager.addTransaction(new TSurpassFriendStat(m_statObject,true));
                  }
               };
               subTypeForLocalization = this.m_statObject.statSubType as String;
               if(subTypeForLocalization.length == 0)
               {
                  subTypeForLocalization = "total";
               }
               key = "StatsPassDialog" + "_" + (this.m_statObject.statType as String);
               friendName = this.m_statObject.friendName as String;
               friendGender = Global.friendManager.getFriendGender(this.m_statObject.friendID);
               popupMessage = ZLocUtils.t("Dialogs",key,{"user":ZLocUtils.tn(friendName,ZLocUtils.tg(friendGender))});
               popup = new GenericPopup(popupMessage,GenericPopup.TYPE_SHARECANCEL,shareCallback);
               popup.setTrackerKey(this.m_statObject.statType as String);
               Global.popupManager.addInactiveUserPopup(popup);
            }
            else if(Boolean(result) && result.hasOwnProperty("rewardLink"))
            {
               friendId = this.m_statObject.friendID;
               params = new Object();
               bundleId = "StatsPassW2W" + "_" + this.m_statObject.statType;
               targetIds = new Array();
               fuelcan = Global.farmGameSettingsManager.getFarmItemByName("fuelLoot1");
               iconUrl = fuelcan.icon;
               targetIds.push(friendId);
               params.uid = Global.player.snUser.uid.toString();
               params.claimFuelLink = result["rewardLink"];
               params.deadUser = Global.friendManager.getFriendName(friendId,true);
               params.originator = Global.player.name;
               params.color = this.m_statObject.statSubType;
               if((this.m_statObject.statSubType as String).length > 0)
               {
                  params.creative = this.m_statObject.statSubType as String;
               }
               params.images = [{
                  "src":iconUrl,
                  "href":"{SN_APP_URL}" + result["rewardLink"]
               }];
               GlobalEngine.socialNetwork.publishFeedStory(bundleId,params,targetIds,false);
            }
         }
      }
   }
}

